unit FormDlgRam;

interface

uses  DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, Data.DB, System.TypInfo, Vcl.Menus,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Container,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  System.Bindings.Helper;

type
  EFrmDlgRam = class(EBaseException);
  TFrmDlgRam = class(TDialogIForm, IDialog, IDialog<Integer>)
    btStart: TButton;
    btExit: TButton;
    cbTurbo: TCheckBox;
    cbToFF: TCheckBox;
    Progress: TProgressBar;
    btTerminate: TButton;
    sb: TStatusBar;
    cbShortPack: TCheckBox;
    procedure btExitClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
  private
    FModul: string;
    FModulID: Integer;
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
    function Execute(InputData: Integer): Boolean;
  public
    property S_TableModulUpdate: string read FS_TableModulUpdate write FS_TableModulUpdate;
  end;

implementation

{$R *.dfm}

uses AbstractPlugin, tools, DBImpl;

function TFrmDlgRam.Execute(InputData: Integer): Boolean;
begin
  Result := True;
  TBindHelper.RemoveExpressions(Self);
  FModulID := InputData;
  FS_TableModulUpdate := 'Ram';
  ConnectionsPool.Query.Acquire;
  try
   FModul := ConnectionsPool.Query.Connection.ExecSQLScalar('SELECT ������ FROM Modul WHERE id = '+ FModulID.ToString);
   Caption := '[' + FModul +'] ������ ������';
  finally
   ConnectionsPool.Query.Release;
  end;
  Bind(GlobalCore as IManager, 'C_TableUpdate', ['S_TableModulUpdate']);
  IShow;
end;

function TFrmDlgRam.GetDevice: IDevice;
 const
  SEL = 'SELECT Device.IName FROM Device,Modul WHERE Modul.id = %d AND Modul.fk = Device.id';
begin
  if Assigned(FDev) then Exit(FDev);
  ConnectionsPool.Query.Acquire;
  try
   Result := (GlobalCore as IDeviceEnum).Get(ConnectionsPool.Query.Connection.ExecSQLScalar(Format(SEL, [FModulID])))
  finally
   ConnectionsPool.Query.Release;
  end;
end;

function TFrmDlgRam.GetInfo: PTypeInfo;
begin
  Result :=TypeInfo(Dialog_RamRead);
end;

procedure TFrmDlgRam.Loaded;
 var
  n: TMenuItem;
begin
  inherited;
  AddToNCMenu('-', nil, n);
  AddToNCMenu('�������������...', NImportClick, n);
  AddToNCMenu('��������������...', NExportClick, n);
end;

procedure TFrmDlgRam.NExportClick(Sender: TObject);
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
      sb.Panels[0].Text := Format('������� ������� %1.3f',[ProcToEnd]);
    end);
   finally
    Free;
   end;}
end;

procedure TFrmDlgRam.NImportClick(Sender: TObject);
begin
  inerExecute(True);
end;

procedure TFrmDlgRam.ReadRamEvent(EnumRR: EnumReadRam; DevAdr: Integer; ProcToEnd: Double);
  procedure Stop(const reason: string);
  begin
    sb.Panels[0].Text := reason;
    UpdateControls(True);
  end;
begin
  Progress.Position := 100 - Round(ProcToEnd);
  case EnumRR of
   eirReadOk:        sb.Panels[0].Text := Format('������ ������ �����: %d �������� %1.3f',[DevAdr, ProcToEnd]);
   eirReadErrSector: sb.Panels[0].Text := Format('������ ������ ������ �����: %d �������� %1.3f', [DevAdr, ProcToEnd]);
   eirCantRead:  Stop(Format('���������� ������� ������ �����: %d', [DevAdr]));
   eirEnd:       Stop('������ ������ ��������');
   eirTerminate: Stop('������ ������ ��������');
  end;
end;

procedure TFrmDlgRam.UpdateControls(FlagEna: Boolean);
begin
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
end;

procedure TFrmDlgRam.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_RamRead>;
end;

procedure TFrmDlgRam.inerExecute(IsImport: boolean);
 const
      GET_ALL_DATA = 'SELECT Device.IName, Device.id,'+
                     ' Modul.�����, Modul.ToAdr'+
                     ' FROM Device, Modul'+
                     ' WHERE Modul.id = %d AND Modul.fk = Device.id';
     CLR_DATA = 'UPDATE Modul SET'+
                    ' FromAdr = NULL,'+
                    ' ToAdr = NULL,'+
                    ' FromKadr = NULL,'+
                    ' ToKadr = NULL,'+
                    ' FromTime = NULL,'+
                    ' ToTime = NULL'+
                    ' WHERE id = %d';

 var
  de: IDeviceEnum;
  ds: TAsyncADQuery;
  ri: IRamImport;
  flName: string;
  flIndex: Integer;
begin
  if not Supports(GlobalCore, IDeviceEnum, de) then Exit;
  ds := ConnectionsPool.Query;
  ds.Acquire;
  ds.Open(Format(GET_ALL_DATA,[FModulID]));
  try
   FDev := de.Get(ds['IName']);
   if not Assigned(FDev) then raise EFrmDlgRam.CreateFmt('���������� %s �� �������', [ds['IName']]);
   if not Supports(FDev, IReadRamDevice) then raise EFrmDlgRam.CreateFmt('���������� %s ��� ������', [FModul]);
   if IsImport then
    begin
     if not Supports(FDev as IReadRamDevice, IRamImport, ri) then raise EFrmDlgRam.CreateFmt('���������� %s �������������� ������ �� �����', [FModul]);
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
   if not ds.FieldByName('ToAdr').IsNull then
    if (MessageDlg('������ ��� ������� ���������� ������ ����� �������!!!', mtWarning, [mbYes, mbCancel], 0) = mrCancel) then Exit
    else
     begin
      ds.Connection.ExecSQL(Format('DELETE FROM Ram_%s_%s', [ds['�����'], ds['id']]));
      ds.Connection.ExecSQL(Format(CLR_DATA, [FModulID]));
      TBindings.Notify(Self, 'S_TableModulUpdate');
     end;
   UpdateControls(False);
   try
    if not IsImport then
     if cbShortPack.Checked then (FDev as IReadRamDevice).Execute(0, 0, cbToFF.Checked, cbTurbo.Checked, ds['�����'], ReadRamEvent, FModulID, 252)
     else (FDev as IReadRamDevice).Execute(0, 0, cbToFF.Checked, cbTurbo.Checked, ds['�����'], ReadRamEvent, FModulID)
    else ri.Import(flName, flIndex,0,0, cbToFF.Checked, ds['�����'], ReadRamEvent, FModulID);
   except
    UpdateControls(True);
    raise;
   end;
  finally
    ds.Release;
  end;
end;

procedure TFrmDlgRam.btStartClick(Sender: TObject);
begin
  inerExecute(False);
end;

procedure TFrmDlgRam.btTerminateClick(Sender: TObject);
begin
  if not Assigned(FDev) then Exit;
  try
   (FDev as IReadRamDevice).Terminate();
  except
   UpdateControls(True);
  end;
end;

initialization
  RegisterDialog.Add<TFrmDlgRam, Dialog_RamRead>;
finalization
  RegisterDialog.Remove<TFrmDlgRam>;
end.
