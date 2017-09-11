unit VCL.Dlg.Ram;

interface

uses  DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, SDcardTools,  System.Threading, FileCachImpl,
  System.TypInfo, Vcl.Menus,  System.IOUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Container,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Xml.XMLIntf,
  System.Bindings.Helper, Vcl.ExtCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  EFrmDlgRam = class(EBaseException);
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
    edBegin: TEdit;
    edCnt: TEdit;
    lbEnd: TLabel;
    lbBegin: TLabel;
    cbSD: TComboBox;
    lbSD: TLabel;
    procedure btExitClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
    procedure cbSDChange(Sender: TObject);
    procedure cbSDDropDown(Sender: TObject);
    procedure rgClick(Sender: TObject);
  private

    FSDStream: TSDStream;
    FTerminate: Boolean;
    FTerminated: Boolean;
    FRecSize: Integer;
    FFrom: Int64;
    FCnt: Int64;
    
    FModul: IXMLNode;
    FRes: TDialogResult;
    FDev: IDevice;
    
    FS_TableModulUpdate: string;
    procedure CheckRAMFile(ram: IXMLNode);
    procedure inerExecute(IsImport: boolean);
    procedure inerReadSSD;
    procedure ReadEvent(car: EnumCopyAsyncRun; Stat: TStatistic; var Erminate: Boolean);
    procedure NImportClick(Sender: TObject);
    procedure NExportClick(Sender: TObject);
    function GetDevice: IDevice;
    procedure UpdateControls(FlagEna: Boolean);
    procedure UpdateControlsSD(SDEna: Boolean);
    procedure ReadRamEvent(EnumRR: EnumReadRam; DevAdr: Integer; ProcToEnd: Double);
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
 ESpeed = (S125K = $80, S500K = $40, S1M = $20, S2M = $10,
           SSD_ENA = $4000, USB = $8000);
const
  CONST_SPEED: array[0..3] of ESpeed = (S125K, S500K, S1M, S2M);
  TXT_SPEDE: array[0..Length(CONST_SPEED)-1] of string = ('125K','0.5M','1M','2M');

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
 var
  i: Integer;
begin
  Result := True;
  TBindHelper.RemoveExpressions(Self);
  FModul := Modul;
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
  edBegin.Enabled := SDEna;
  edCnt.Enabled := SDEna;
  lbEnd.Enabled := SDEna;
  lbBegin.Enabled := SDEna;
  lbFile.Enabled := not SDEna;
  od.Enabled := not SDEna;
  lbLen.Enabled := not SDEna;
  edLen.Enabled := not SDEna;
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
end;

procedure TFormDlgRam.UpdateControls(FlagEna: Boolean);
begin
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
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
   UpdateControls(False);
   try
    if not IsImport then
     (FDev as IReadRamDevice).Execute(od.FileName, 0, 0, cbToFF.Checked, rg.ItemIndex, addr, ReadRamEvent, addr, StrToInt('$'+edLen.Text))
    else ri.Import(flName, flIndex,0,0, cbToFF.Checked, addr, ReadRamEvent, addr);
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
  RemoveXMLAttr(ram, AT_FROM_KADR);
  RemoveXMLAttr(ram, AT_TO_KADR);     
end;


procedure TFormDlgRam.inerReadSSD;
 const
  MB: int64 = 1024*1024;
 var
  i: Integer;
  ram: IXMLNode;
begin
  if cbSD.ItemIndex < 0  then raise Exception.Create('Не выбран диск');
  ram := FModul.ChildNodes.FindNode(T_RAM);
  CheckRAMFile(ram);  
  if Assigned(FSDStream) then FreeAndNil(FSDStream);
  FSDStream := TSDStream.Create(cbSD.Items[cbSD.ItemIndex], GENERIC_READ);
  FTerminate := False;
  FTerminated := False;
  Progress.Position := 0;
  
  FRecSize := Ram.Attributes[AT_SIZE];
  FFrom := (StrToInt64(edBegin.Text)*MB div FRecSize) * FRecSize;
  FCnt :=  (StrToInt64(edCnt.Text)*MB div FRecSize) * FRecSize;
  
  ram.Attributes[AT_FROM_ADR] := Format('0x%x',[FFrom]);
  ram.Attributes[AT_FROM_KADR] := FFrom div FRecSize;
  ram.Attributes[AT_FROM_TIME] := CTime.AsString(2.097152/24/3600 * (FFrom div FRecSize));
  
  for I := 0 to sb.Panels.Count-1 do sb.Panels[i].Text := '';
  UpdateControls(False);
  try
   FSDStream.AsyncCopyTo(GFileDataFactory.ConstructFileName(ram), FFrom, FCnt, cbToFF.Checked, ReadEvent);
  except
   UpdateControls(True);
   raise;
  end;
end;

procedure TFormDlgRam.ReadEvent(car: EnumCopyAsyncRun; Stat: TStatistic; var Erminate: Boolean);
 const
  CARSTR: array[EnumCopyAsyncRun] of string =('Чтение', 'Пустая память', 'Конец', 'Прервано', 'Ошибка');
 var
  ram: IXMLNode; 
begin
  ram := FModul.ChildNodes.FindNode(T_RAM);
  ram.Attributes[AT_TO_ADR] := Format('0x%x',[FFrom + Stat.NRead]);
  ram.Attributes[AT_TO_KADR] := (FFrom + Stat.NRead) div FRecSize;
  ram.Attributes[AT_TO_TIME] := CTime.AsString(2.097152/24/3600 * ((FFrom + Stat.NRead) div FRecSize));

  Erminate := FTerminate;
  if not FTerminated and (TTask.CurrentTask.Status <> TTaskStatus.Canceled) then
   TThread.Queue(TThread.CurrentThread, procedure
   begin
     if FTerminated then Exit;
     if car <> carOk then
      begin
       FTerminated := True;
       UpdateControls(True);
      end;
     sb.Panels[4].Text := CARSTR[car];
     if car = carError then Exit;
     sb.Panels[0].Text := Stat.ProcRun.ToString(ffFixed, 7, 1)+'%';
     sb.Panels[1].Text := Stat.Speed.ToString(ffFixed, 7, 0)+'Mb/s';
     sb.Panels[2].Text := TimeToStr(Stat.TimeFromBegin);
     sb.Panels[3].Text := TimeToStr(Stat.TimeToEnd);
     Progress.Position := Round(Stat.ProcRun);
   end);
end;

procedure TFormDlgRam.ReadRamEvent(EnumRR: EnumReadRam; DevAdr: Integer; ProcToEnd: Double);
  procedure Stop(const reason: string);
  begin
    sb.Panels[4].Text := reason;
    (GContainer as IALLMetaDataFactory).Get.Save;
    FRes(Self, mrOk);
    UpdateControls(True);
  end;
begin
  Progress.Position := 100 - Round(ProcToEnd);
  case EnumRR of
   eirReadOk:        sb.Panels[4].Text := Format('Чтение памяти Адрес: %d осталось %1.3f',[DevAdr, ProcToEnd]);
   eirReadErrSector: sb.Panels[4].Text := Format('Ошибка чтения памяти Адрес: %d осталось %1.3f', [DevAdr, ProcToEnd]);
   eirCantRead:  Stop(Format('Невозможно считать память Адрес: %d', [DevAdr]));
   eirEnd:       Stop('чтение памяти ОКОНЧЕНО');
   eirTerminate: Stop('чтение памяти прервано');
  end;
end;

procedure TFormDlgRam.odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
begin
  od.FileName := '';
end;

procedure TFormDlgRam.btStartClick(Sender: TObject);
begin
  if rg.ItemIndex <> -1 then inerExecute(False)
  else inerReadSSD();
end;

procedure TFormDlgRam.btTerminateClick(Sender: TObject);
begin
  FTerminate := True;
  if not Assigned(FDev) then Exit;
  try
   (FDev as IReadRamDevice).Terminate();
   except
   UpdateControls(True);
  end;
end;

procedure TFormDlgRam.cbSDChange(Sender: TObject);
begin
  rg.ItemIndex := -1;
  UpdateControlsSD(True);
end;

procedure TFormDlgRam.cbSDDropDown(Sender: TObject);
 var
  d: Char;
begin
  cbSD.Items.Clear;
  for d in TSDStream.EnumLogicalDrives do cbSD.Items.Add(d);
end;

initialization
  RegisterDialog.Add<TFormDlgRam, Dialog_RamRead>;
finalization
  RegisterDialog.Remove<TFormDlgRam>;
end.
