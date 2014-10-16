unit InitDialogs;

interface

uses DeviceIntf, DockIForm, debug_except, ExtendIntf, RootImpl, PluginAPI, RootIntf, DBIntf, DBImpl, Data.DB,
     System.Variants, Container, System.TypInfo, System.SysUtils, System.UITypes;
type
//  EDialogDelayException = class(EBaseException);

  TDialogConnectIO = class(TIComponent, IDialog, IForm, IDialog<IConnectIO>)
  private
   FConect: IConnectIO;
   FRes: TModalResult;
  public
    procedure Show;
    function GetInfo: PTypeInfo;
    function Execute(InputData: IConnectIO): Boolean;
  end;

  TDialogDevice = class(TIComponent, IDialog, IForm, IDialog<IDevice>)
  private
    FDevice: IDevice;
    FRes: TModalResult;
  public
    procedure Show;
    function GetInfo: PTypeInfo;
    function Execute(InputData: IDevice): Boolean;
  end;


implementation

uses VCL.Dlg.ConnectIO.COM, VCL.Dlg.ConnectIO.NET, VCL.Dlg.ConnectIO.WLAN, VCL.Dlg.Device;

{ TDialogConnectIO }

function TDialogConnectIO.Execute(InputData: IConnectIO): Boolean;
begin
  FConect := InputData;
  Show;
  RegisterDialog.UnInitialize<Dialog_SetupConnectIO>;
  Result := FRes = mrOk;
end;

function TDialogConnectIO.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_SetupConnectIO);
end;

procedure TDialogConnectIO.Show;
begin
  if Supports(FConect, IComPortConnectIO) then FRes := TFormSetupCom.Execute(FConect)
  else if Supports(FConect, IWlanConnectIO) then FRes := TFormSetupWlan.Execute(FConect)
  else if Supports(FConect, INetConnectIO) or Supports(FConect, IUDPConnectIO) then FRes := TFormSetupNet.Execute(FConect)
  else FRes := mrCancel
end;

{ TDialogDevice }

function TDialogDevice.Execute(InputData: IDevice): Boolean;
begin
  FDevice := InputData;
  Show;
  RegisterDialog.UnInitialize<Dialog_SetupDevice>;
  Result := FRes = mrOk;
end;

function TDialogDevice.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_SetupDevice);
end;

procedure TDialogDevice.Show;
begin
  { TODO : ��� ���� ��x � ������� �� ������� ���������� }
  FRes := TDlgSetupDev.Execute(FDevice);
end;

initialization
  RegisterDialog.Add<TDialogConnectIO, Dialog_SetupConnectIO>;
  RegisterDialog.Add<TDialogDevice, Dialog_SetupDevice>;
finalization
  RegisterDialog.Remove<TDialogConnectIO>;
  RegisterDialog.Remove<TDialogDevice>;
end.
