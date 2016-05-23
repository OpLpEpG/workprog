unit VCL.Dlg.Ram;

interface

uses  DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except,
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
    Label1: TLabel;
    od: TJvFilenameEdit;
    edLen: TEdit;
    Label2: TLabel;
    procedure btExitClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
  private
    FModul: IXMLNode;
    FRes: TDialogResult;
    FDev: IDevice;
    FS_TableModulUpdate: string;
    procedure inerExecute(IsImport: boolean);
    procedure NImportClick(Sender: TObject);
    procedure NExportClick(Sender: TObject);
    function GetDevice: IDevice;
    procedure UpdateControls(FlagEna: Boolean);
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

function TFormDlgRam.Execute(Modul: IXMLNode; Res: TDialogResult): Boolean;
begin
  Result := True;
  TBindHelper.RemoveExpressions(Self);
  FModul := Modul;
  FRes := Res;
  FS_TableModulUpdate := 'Ram';
  Caption := '[' + Modul.nodeName +'] Чтение памяти';
  Bind(GlobalCore as IManager, 'C_TableUpdate', ['S_TableModulUpdate']);
  IShow;
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

procedure TFormDlgRam.ReadRamEvent(EnumRR: EnumReadRam; DevAdr: Integer; ProcToEnd: Double);
  procedure Stop(const reason: string);
  begin
    sb.Panels[0].Text := reason;
    (GContainer as IALLMetaDataFactory).Get.Save;
    FRes(Self, mrOk);
    UpdateControls(True);
  end;
begin
  Progress.Position := 100 - Round(ProcToEnd);
  case EnumRR of
   eirReadOk:        sb.Panels[0].Text := Format('Чтение памяти Адрес: %d осталось %1.3f',[DevAdr, ProcToEnd]);
   eirReadErrSector: sb.Panels[0].Text := Format('Ошибка чтения памяти Адрес: %d осталось %1.3f', [DevAdr, ProcToEnd]);
   eirCantRead:  Stop(Format('Невозможно считать память Адрес: %d', [DevAdr]));
   eirEnd:       Stop('чтение памяти ОКОНЧЕНО');
   eirTerminate: Stop('чтение памяти прервано');
  end;
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
   if not Assigned(Dev) then raise EFrmDlgRam.CreateFmt('Устройство %s не найдено', [Fmodul.NodeName]);
   if not Supports(Dev, IReadRamDevice) then raise EFrmDlgRam.CreateFmt('Устройство %s без памяти', [Fmodul.NodeName]);
   ram := FModul.ChildNodes.FindNode(T_RAM);
   if not Assigned(Ram) then raise EFrmDlgRam.CreateFmt('Метаданные RAM %s не найдены', [Fmodul.NodeName]);
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
    if (GContainer as IProjectDataFile).DataFileExists(ram) then
    if (MessageDlg('Память уже считана предыдущие данные будут удалены!!!', mtWarning, [mbYes, mbCancel], 0) = mrCancel) then Exit
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

procedure TFormDlgRam.odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
begin
  od.FileName := '';
end;

procedure TFormDlgRam.btStartClick(Sender: TObject);
begin
  inerExecute(False);
end;

procedure TFormDlgRam.btTerminateClick(Sender: TObject);
begin
  if not Assigned(FDev) then Exit;
  try
   (FDev as IReadRamDevice).Terminate();
   except
   UpdateControls(True);
  end;
end;

initialization
  RegisterDialog.Add<TFormDlgRam, Dialog_RamRead>;
finalization
  RegisterDialog.Remove<TFormDlgRam>;
end.
