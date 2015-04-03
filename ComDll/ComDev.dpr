// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library ComDev;

uses
  System.TypInfo,
  Windows,
  System.SysUtils,
  System.Classes,
  Xml.XMLIntf,
  DeviceIntf,
  UakiIntf,
  StolGKIntf,
  System.Generics.Collections,
  PluginAPI,
  AbstractPlugin,
  tools,
  Container,
  AbstractDev in 'AbstractDev.pas',
  DevPsk in 'DevPsk.pas',
  DevBur in 'DevBur.pas',
  NetConn in 'NetConn.pas',
  WlanConn in 'WlanConn.pas',
  UDPConn in 'UDPConn.pas',
  DevUaki in 'DevUaki.pas',
  Dev.Telesistem in 'Dev.Telesistem.pas',
  SubDevImpl in 'SubDevImpl.pas',
  Dev.Telesistem.Decoder in 'Dev.Telesistem.Decoder.pas',
  Dev.StolGK in 'Dev.StolGK.pas',
  Dev.Telesistem.Shum in 'Dev.Telesistem.Shum.pas',
  Dev.Telesistem.Data in 'Dev.Telesistem.Data.pas';

{$R *.res}

type
 TComDevPlugin = class(TAbstractPlugin, IGetDevice, IGetConnectIO)
 protected
   function  Device(const Addrs: TAddressArray; const DeviceName: string): IDevice;
   procedure EnmDevices(GetDevicesCB: TGetDevicesCB);
   procedure IGetDevice.Enum = EnmDevices;
   procedure IGetConnectIO.Enum = EnumConnect;
   procedure EnumConnect(GetConnectIOCB: TGetConnectIOCB);
   function  ConnectIO(ConnectID: Integer): IConnectIO;

   function IsManualCreate(ConnectID: Integer): Boolean;
   function GetConnectInfo(ConnectID: Integer): TArray<string>;

   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
   destructor Destroy; override;
 end;

{ TComDevPlugin }

procedure TComDevPlugin.EnumConnect(GetConnectIOCB: TGetConnectIOCB);
begin
  GetConnectIOCB(1, 'ComPort', '���������� �� ��� �����');
  GetConnectIOCB(2, 'NetPort', '���������� �� Ethernet');
  GetConnectIOCB(3, 'WlanPort', '���������� �� WiFi');
  GetConnectIOCB(4, 'UDP', '���������� �� UDP');
end;

function TComDevPlugin.ConnectIO(ConnectID: Integer): IConnectIO;
begin
  case ConnectID of
   2:  Result := TNetConnectIO.Create();
   3:  Result := TWlanConnectIO.Create();
   4:  Result := TUDPConnectIO.Create();
  else Result := TComConnectIO.Create();
  end;
end;

procedure TComDevPlugin.EnmDevices(GetDevicesCB: TGetDevicesCB);
begin
  EnumDevices(GetDevicesCB);
end;

function TComDevPlugin.GetConnectInfo(ConnectID: Integer): TArray<string>;
begin
  case ConnectID of
   2:  Result := TNetConnectIO.Enum();
   3:  Result := TWlanConnectIO.Enum();
   4:  Result := TUDPConnectIO.Enum();
  else Result := TComConnectIO.Enum();
  end;
end;

function TComDevPlugin.IsManualCreate(ConnectID: Integer): Boolean;
begin
  Result := ConnectID in [2,3,4];
end;

class function TComDevPlugin.GetHInstance: THandle;
begin
  Result := HInstance;
end;

class function TComDevPlugin.PluginName: string;
begin
  Result := '���������� �����-����� � �������';
end;

destructor TComDevPlugin.Destroy;
begin
  OutputDebugString(PChar('ComDevPlugin.Destroy '));
  inherited;
end;

function TComDevPlugin.Device(const Addrs: TAddressArray; const DeviceName: string): IDevice;
 var
  a: Integer;
  adr: TAddressArray;
begin
  Result := nil;
  adr := Addrs;
  TArray.Sort<Integer>(adr);
  if Length(Adr) > 1 then for a in Adr do if A >= 100 then raise EDeviceException.Create('���������� � ������� >=100 ����� ���� ������ ����');
  if Length(Adr) >= 1 then
   begin
    if Adr[0] = 100 then Result := TUso.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = 101 then Result := TGlu.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = ADR_UAKI then Result := TDevUaki.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = ADR_STOL_GK then Result := TStolGK.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (Adr[0] > 101) and (adr[0] < 200) then  Result := TPskStd.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (adr[0] = 1000) then Result := TTelesistem.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (adr[0] > 15) then raise EDeviceException.Create('���������� � �������� �������')

    else Result := TDeviceBur.CreateWithAddr(Adr, DeviceName) as IDevice
   end
//  else Result := TViewRamDevice.CreateWithAddr(nil, Adr);
end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TComDevPlugin, IPlugin, IGetDevice, IGetConnectIO>.LiveTime(ltSingleton);
  Result := TypeInfo(TComDevPlugin);
end;

procedure Done;
begin
  GContainer.RemoveModel<TComDevPlugin>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

begin
end.
