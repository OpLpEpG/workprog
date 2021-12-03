unit VCL.Dlg.Ram;

interface

uses RootIntf,
  DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, SDcardToolsAsync,  System.Threading, FileCachImpl,
  System.TypInfo, Vcl.Menus,  System.IOUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Container,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Xml.XMLIntf,
  System.Bindings.Helper, Vcl.ExtCtrls, Vcl.Mask, JvExMask, JvToolEdit, RangeSelector, VCL.Frame.RangeSelect;

type
  EFrmDlgRam = class(ENeedDialogException);
  TFormDlgRam = class(TDialogIForm, IDialog, IDialog<IXMLNode, TDialogResult>)
    btStart: TButton;
    btExit: TButton;
    cbToFF: TCheckBox;
    Progress: TProgressBar;
    btTerminate: TButton;
    sb: TStatusBar;
    rg: TRadioGroup;
    lbFile: TLabel;
    od: TJvFilenameEdit;
    edLen: TEdit;
    lbLen: TLabel;
    cbSD: TComboBox;
    lbSD: TLabel;
    cbClcCreate: TCheckBox;
    RangeSelect: TFrameRangeSelect;
    procedure btExitClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
    procedure cbSDChange(Sender: TObject);
    procedure cbSDDropDown(Sender: TObject);
    procedure rgClick(Sender: TObject);
  private
    FDevs: TArray<TLogicalDevice>;
    FSDStream: TSDStream;
//    FTerminate: Boolean;
    FTerminated: Boolean;
    FRecSize: Integer;
    FFrom: Int64;
    FCnt: Int64;

    FModul: IXMLNode;
    FRes: TDialogResult;
    FDev: IDevice;

    FRamSize:Int64;
    FDelayStart: TDateTime;
    FkadrSize: Integer;

    FS_TableModulUpdate: string;
    procedure CheckRAMFile(ram: IXMLNode);
    procedure inerExecute(IsImport: boolean);
    procedure inerReadSSD;
    procedure NImportClick(Sender: TObject);
    procedure NExportClick(Sender: TObject);
    function GetDevice: IDevice;
    procedure UpdateControls(FlagEna: Boolean);
    procedure UpdateControlsSD(SDEna: Boolean);
    procedure UpdateStat(car: EnumCopyAsyncRun; Stat: TStatistic);
    procedure ReadSSDEvent(car: EnumCopyAsyncRun; Stat: TStatistic);
    procedure ReadRamEvent(EnumRR: EnumCopyAsyncRun; DevAdr: Integer; Stat: TStatistic);
  protected
    procedure Loaded; override;
    function GetInfo: PTypeInfo; override;
    function Execute(Modul: IXMLNode; Res: TDialogResult): Boolean;
  public
    property Dev: IDevice read GetDevice;
    property S_TableModulUpdate: string read FS_TableModulUpdate write FS_TableModulUpdate;
  end;

implementation

{$R *.dfm}

uses AbstractPlugin, tools;

type
 ESpeed = (S125K = $80, S500K = $40, S1M = $20, S2M = $10, S4M = $08,
           SSD_ENA = $4000, USB = $8000);
const
  CONST_SPEED: array[0..4] of ESpeed = (S125K, S500K, S1M, S2M, S4M);
  TXT_SPEDE: array[0..Length(CONST_SPEED)-1] of string = ('125K','0.5M','1M','2.25M','4.5M');

 const
  CARSTR: array[EnumCopyAsyncRun] of string =('Чтение', 'Пустая память', 'Конец', 'Прервано', 'Ошибка', 'Пакет.Ош.');

function TFormDlgRam.Execute(Modul: IXMLNode; Res: TDialogResult): Boolean;
  procedure EnableSerial(ena: Boolean);
  begin
    rg.Enabled := ena;
    lbFile.Enabled := ena;
    od.Enabled := ena;
    lbLen.Enabled := ena;
    edLen.Enabled := ena;
  end;
  procedure EnableSSD(ena: Boolean);
  begin
    lbSD.Enabled := ena;
    cbSD.Enabled := ena;
  end;
   const
    MAX_RAM = $420000;
 var
  i: Integer;
  ram: IXMLNode;
begin
  Result := True;
  TBindHelper.RemoveExpressions(Self);
  FModul := Modul;
  ram := FModul.ChildNodes.FindNode(T_RAM);
  if not Assigned(Ram) then raise EFrmDlgRam.CreateFmt('Метаданные RAM %s не найдены', [Fmodul.NodeName]);

  if (XToVar(FModul).WRK.автомат.DEV.VALUE and $3F) < 4 then
    raise EFrmDlgRam.CreateFmt('Модуль %s не выключен !!! Находится в состоянии [%s].', [Fmodul.NodeName, XToVar(FModul).WRK.автомат.CLC.VALUE]);

  if not ram.HasAttribute(AT_RAMSIZE) then FRamSize := MAX_RAM
  else if ram.Attributes[AT_RAMSIZE] = 5 then FRamSize := MAX_RAM
  else FRamSize := Ram.Attributes[AT_RAMSIZE] * 1024 * 1024;
  FDelayStart := (GContainer as IProjectOptions).DelayStart;
  FkadrSize := ram.Attributes[AT_SIZE];

  RangeSelect.Init(FkadrSize, FRamSize, FDelayStart);

   // BIT15:USB  BIT14:SSD BIT7:125Kbt BIT6:500Kbt  5-1M 4-2M
  if FModul.HasAttribute(AT_SPEED) then
   begin
    rg.Items.Clear;
    for I := 0 to High(CONST_SPEED) do
     if (CONST_SPEED[i] and FModul.Attributes[AT_SPEED]) <> 0  then
       rg.Items.AddObject(TXT_SPEDE[i], TObject(CONST_SPEED[i]));
    EnableSSD((SSD_ENA and FModul.Attributes[AT_SPEED]) <> 0);
    EnableSerial(rg.Items.Count > 0); 
   end;
  FRes := Res;
  FS_TableModulUpdate := 'Ram';
  Caption := '[' + Modul.nodeName +'] Чтение памяти';
  Bind(GlobalCore as IManager, 'C_TableUpdate', ['S_TableModulUpdate']);
  IShow;
end;


procedure TFormDlgRam.UpdateControlsSD(SDEna: Boolean);
begin
  RangeSelect.RunEnable(SDEna);
//  edBegin.Enabled := SDEna;
//  edCnt.Enabled := SDEna;
//  lbEnd.Enabled := SDEna;
//  lbBegin.Enabled := SDEna;
  lbFile.Enabled := not SDEna;
  od.Enabled := not SDEna;
  lbLen.Enabled := not SDEna;
  edLen.Enabled := not SDEna;
  cbClcCreate.Checked := not SDEna;
  cbClcCreate.Enabled := not SDEna;
end;


procedure TFormDlgRam.UpdateStat(car: EnumCopyAsyncRun; Stat: TStatistic);
begin
  sb.Panels[4].Text := CARSTR[car];
  if car = carError then Exit;
  sb.Panels[0].Text := Stat.ProcRun.ToString(ffFixed, 7, 1)+'%';
  if Stat.Speed > 0.1 then
    sb.Panels[1].Text := Stat.Speed.ToString(ffFixed, 7, 0)+'Mb/s'
  else
    sb.Panels[1].Text := (Stat.Speed*1024).ToString(ffFixed, 7, 0)+'Kb/s';
  sb.Panels[2].Text := TimeToStr(Stat.TimeFromBegin);
  sb.Panels[3].Text := TimeToStr(Stat.TimeToEnd);
  Progress.Position := Round(Stat.ProcRun);
end;

function TFormDlgRam.GetDevice: IDevice;
begin
  if not Assigned(FDev) then Fdev := (GlobalCore as IDeviceEnum).Get(FModul.ParentNode.NodeName);
  Result := Fdev;
end;

function TFormDlgRam.GetInfo: PTypeInfo;
begin
  Result :=TypeInfo(Dialog_RamRead);
end;

procedure TFormDlgRam.Loaded;
// var
//  n: TMenuItem;
begin
  inherited;
  AddToNCMenu('-');
  AddToNCMenu('Импортировать...', NImportClick);
  AddToNCMenu('Экспортировать...', NExportClick);
end;

procedure TFormDlgRam.NExportClick(Sender: TObject);
 var
  d: IDevice;
//  e: IExport;
begin
  d := GetDevice;
{  if Supports(d, IExport, e) then
  with TOpenDialog.Create(nil) do
   try
    InitialDir := ExtractFilePath(ParamStr(0));
    Options := Options + [ofOverwritePrompt, ofPathMustExist];
    Filter := e.Filters;
    if Execute(Handle) then e.Execute(FileName, FilterIndex, procedure (ProcToEnd: Double)
    begin
      sb.Panels[0].Text := Format('Экспорт сталось %1.3f',[ProcToEnd]);
    end);
   finally
    Free;
   end;}
end;

procedure TFormDlgRam.NImportClick(Sender: TObject);
begin
  inerExecute(True);
end;

procedure TFormDlgRam.rgClick(Sender: TObject);
begin
  UpdateControlsSD(false);
  RangeSelect.RunEnable(True);
end;

procedure TFormDlgRam.UpdateControls(FlagEna: Boolean);
begin
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
  cbClcCreate.Enabled := FlagEna;
  cbToFF.Enabled := False;// FlagEna;
  RangeSelect.Enabled := FlagEna;
end;

procedure TFormDlgRam.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_RamRead>;
end;

procedure TFormDlgRam.inerExecute(IsImport: boolean);
 var
  ri: IRamImport;
  flName: string;
  flIndex, Addr: Integer;
  ram: IXMLNode;
begin
   Progress.Position := 0;
   flIndex := 0;
   if not Assigned(Dev) then raise EFrmDlgRam.CreateFmt('Устройство %s не найдено', [Fmodul.NodeName]);
   if not Supports(Dev, IReadRamDevice) then raise EFrmDlgRam.CreateFmt('Устройство %s без памяти', [Fmodul.NodeName]);
   addr := FModul.Attributes[AT_ADDR];
   if IsImport then
    begin
     if not Supports(FDev as IReadRamDevice, IRamImport, ri) then raise EFrmDlgRam.CreateFmt('Устройство %s неподдерживает импорт из файла', [FModul]);
     with TOpenDialog.Create(nil) do
      try
       InitialDir := ExtractFilePath(ParamStr(0));
       Options := Options + [ofPathMustExist, ofFileMustExist];
       Filter := ri.Filters;
       if not Execute(Handle) then Exit
       else
        begin
         flName := FileName;
         flIndex := FilterIndex;
        end;
      finally
       Free;
      end;
    end;
   ram := FModul.ChildNodes.FindNode(T_RAM);
   CheckRAMFile(ram);
   //////////////////
  // ram.Attributes['test_before_construct']:= 'test_before_construct';
  // /.ConstructFileName(ram);
  // ram.Attributes['test_before_resync']:= 'test_before_resync';
  // ram.OwnerDocument.Resync;
 //  ram.Attributes['test_after_resync']:= 'test_after_resync';
 //  exit;
   /////////////////
   UpdateControls(False);
   try
    if not IsImport then
     with (FDev as IReadRamDevice) do
      begin
       CreateClcFile := cbClcCreate.Checked;
       var cnt := StrToInt('$'+edLen.Text);
       Execute(od.FileName, RangeSelect.kadr.first, RangeSelect.kadr.last, cbToFF.Checked, rg.ItemIndex, addr, ReadRamEvent, addr, cnt)
      end
    else ri.Import(flName, flIndex, RangeSelect.kadr.first, RangeSelect.kadr.last, cbToFF.Checked, addr, ReadRamEvent, addr);
   except
    UpdateControls(True);
    raise;
   end;
end;

procedure TFormDlgRam.CheckRAMFile(ram: IXMLNode);
begin
  if not Assigned(Ram) then raise EFrmDlgRam.CreateFmt('Метаданные RAM %s не найдены', [Fmodul.NodeName]);
  if (GContainer as IProjectDataFile).DataFileExists(ram) then
  if (MessageDlg('Память уже считана предыдущие данные будут удалены!!!', mtWarning, [mbYes, mbCancel], 0) = mrCancel) then
    raise EAbort.Create('mrCancel')
  else
   begin
    (GContainer as IProjectDataFile).DataSectionDelete(ram);
    TBindings.Notify(Self, 'S_TableModulUpdate');
   end;
//   RemoveXMLAttr(ram, AT_START_TIME);
//   RemoveXMLAttr(ram, AT_DELAY_TIME);
//   RemoveXMLAttr(ram, AT_KOEF_TIME);
//   RemoveXMLAttr(ram, AT_FILE_NAME);
  RemoveXMLAttr(ram, AT_FROM_TIME);
  RemoveXMLAttr(ram, AT_TO_TIME);
  RemoveXMLAttr(ram, AT_FROM_ADR);
  RemoveXMLAttr(ram, AT_TO_ADR);
  RemoveXMLAttr(ram,AT_END_REASON);
  RemoveXMLAttr(ram, AT_FROM_KADR);
  RemoveXMLAttr(ram, AT_TO_KADR);     
end;


procedure TFormDlgRam.inerReadSSD;
 const
  MB: int64 = 1024*1024;
  GB: int64 = 1024*1024*1024;
 var
  i: Integer;
  ram: IXMLNode;
  lastAdrSave: int64;
begin
  if cbSD.ItemIndex < 0  then raise EFrmDlgRam.Create('Не выбран диск');
  ram := FModul.ChildNodes.FindNode(T_RAM);
  CheckRAMFile(ram);  
  if Assigned(FSDStream) then FreeAndNil(FSDStream);
  FSDStream := TSDStream.Create(FDevs[cbSD.ItemIndex], GENERIC_READ);
//  FTerminate := False;
  FTerminated := False;
  Progress.Position := 0;

  FRecSize := Ram.Attributes[AT_SIZE];
//  FFrom := (StrToInt64(edBegin.Text)*MB div FRecSize) * FRecSize;
//  FCnt :=  (StrToInt64(edCnt.Text)*MB div FRecSize) * FRecSize;
  FFrom := RangeSelect.adr.first;
  FCnt := RangeSelect.adr.cnt;

  ram.Attributes[AT_FROM_ADR] := Format('0x%x',[FFrom]);
  ram.Attributes[AT_FROM_KADR] := FFrom div FRecSize;
  ram.Attributes[AT_FROM_TIME] := CTime.AsString(2.097152/24/3600 * (FFrom div FRecSize));

  for I := 0 to sb.Panels.Count-1 do sb.Panels[i].Text := '';

  if (RangeSelect.adr.last > FSDStream.Size) then
   begin
    lastAdrSave := RangeSelect.adr.last;
    RangeSelect.Range.SelEnd := FSDStream.Size div FRecSize;

    raise ENeedDialogException.CreateFmt('Размер физической памяти %1.2f GB меньше выбранного %1.2f GB ' +#$D#$A +
    'Установлен соответствующий физической памяти!',
          [FSDStream.Size / GB, lastAdrSave / GB]);
   end;


  UpdateControls(False);
  try
   FSDStream.AsyncCopyTo(GFileDataFactory.ConstructFileName(ram), FFrom, FCnt, cbToFF.Checked, ReadSSDEvent);
  except
   UpdateControls(True);
   raise;
  end;
end;

procedure TFormDlgRam.ReadSSDEvent(car: EnumCopyAsyncRun; Stat: TStatistic);
 var
  ram: IXMLNode;
begin
  ram := FModul.ChildNodes.FindNode(T_RAM);
  ram.Attributes[AT_TO_ADR] := Format('0x%x',[FFrom + Stat.NRead]);
  ram.Attributes[AT_TO_KADR] := (FFrom + Stat.NRead) div FRecSize;
  ram.Attributes[AT_TO_TIME] := CTime.AsString(2.097152/24/3600 * Double(ram.Attributes[AT_TO_KADR]));

  if not FTerminated and (TTask.CurrentTask.Status <> TTaskStatus.Canceled) then
   TThread.Queue(TThread.CurrentThread, procedure
   begin
     if FTerminated then Exit;
     if car <> carOk then
      begin
       ram.Attributes[AT_END_REASON] := CARSTR[car];
       FTerminated := True;
       UpdateControls(True);
      end;
     UpdateStat(car, Stat);
   end);
end;

procedure TFormDlgRam.ReadRamEvent(EnumRR: EnumCopyAsyncRun; DevAdr: Integer; Stat: TStatistic);
 ////var
 // r:Ixmlnode;
begin
  UpdateStat(EnumRR, Stat);
  if EnumRR in COPY_STOP_EVENT then
   begin
    (GContainer as IALLMetaDataFactory).Get.Save;
    FRes(Self, mrOk);
    UpdateControls(True);
    TBindings.Notify(Self, 'S_TableModulUpdate');
   end;
end;

procedure TFormDlgRam.odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
begin
  od.FileName := '';
end;

procedure TFormDlgRam.btStartClick(Sender: TObject);
begin
  (GlobalCore as IMainScreen).Changed;
  if rg.ItemIndex <> -1 then inerExecute(False)
  else inerReadSSD();
end;

procedure TFormDlgRam.btTerminateClick(Sender: TObject);
begin
  TAsyncCopy.Terminate();
  if not Assigned(FDev) then Exit;
  try
   (FDev as IReadRamDevice).Terminate();
   except
   UpdateControls(True);
  end;
end;

procedure TFormDlgRam.cbSDChange(Sender: TObject);
 var
  ram: IXMLNode;
begin
  ram := FModul.ChildNodes.FindNode(T_RAM);
  rg.ItemIndex := -1;
  UpdateControlsSD(True);
  if (cbSD.ItemIndex >= 0) and (ram.Attributes[AT_RAMSIZE] < FDevs[cbSD.ItemIndex].DiskSize div 1024 div 1024)
  and (MessageDlg('Физический объем диска больше указанного в метаданных, выбрать его ?', mtWarning, [mbYes, mbNo], 0) = mrYes) then
   begin
    ram.Attributes[AT_RAMSIZE] := FDevs[cbSD.ItemIndex].DiskSize div 1024 div 1024;
    RangeSelect.Init(FkadrSize, FDevs[cbSD.ItemIndex].DiskSize, FDelayStart);
   end;
end;

procedure TFormDlgRam.cbSDDropDown(Sender: TObject);
 var
  d: TLogicalDevice;
begin
  cbSD.Items.Clear;
  FDevs := TSDStream.EnumLogicalDrives;
  for d in FDevs do cbSD.Items.Add(d.Letter);
end;

initialization
  RegisterDialog.Add<TFormDlgRam, Dialog_RamRead>;
finalization
  RegisterDialog.Remove<TFormDlgRam>;
end.
