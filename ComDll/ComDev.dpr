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
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Xml.XMLIntf,
  DeviceIntf,
  UakiIntf,
  StolGKIntf,
  StolBKIntf,
  System.Generics.Collections,
  PluginAPI,
  AbstractPlugin,
  tools,
  Container,
  AbstractDev in 'AbstractDev.pas',
  DevPsk in 'DevPsk.pas',
  DevBur in 'DevBur.pas',
  RestConn in 'RestConn.pas',
  WlanConn in 'WlanConn.pas',
  UDPConn in 'UDPConn.pas',
  DevUaki in 'DevUaki.pas',
  Dev.Telesistem in 'Dev.Telesistem.pas',
  SubDevImpl in 'SubDevImpl.pas',
  Dev.Telesistem.Decoder in 'Dev.Telesistem.Decoder.pas',
  Dev.StolGK in 'Dev.StolGK.pas',
  Dev.Telesistem.Shum in 'Dev.Telesistem.Shum.pas',
  Dev.Telesistem.Data in 'Dev.Telesistem.Data.pas',
  DevUaki2 in 'DevUaki2.pas',
  Dev.GLUSonic in 'Dev.GLUSonic.pas',
  Dev.BK in 'Dev.BK.pas',
  Dev.TelesisRetr2 in 'Dev.TelesisRetr2.pas',
  MicroSDConn in 'MicroSDConn.pas',
  NetConn in 'NetConn.pas';

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
  GetConnectIOCB(1, 'ComPort', 'Соединение по Ком Порту');
  GetConnectIOCB(2, 'NetPort', 'Соединение по Ethernet');
  GetConnectIOCB(3, 'WlanPort', 'Соединение по WiFi');
  GetConnectIOCB(4, 'UDP', 'Соединение по UDP');
  GetConnectIOCB(5, 'Rest', 'Соединение по HTTP');
 // GetConnectIOCB(5, 'MicroSD', 'Чтение памяти с SD карты');
end;

function TComDevPlugin.ConnectIO(ConnectID: Integer): IConnectIO;
begin
  case ConnectID of
   2:  Result := TNetConnectIO.Create();
   3:  Result := TWlanConnectIO.Create();
   4:  Result := TUDPConnectIO.Create();
   5:  Result := TRestConnectIO.Create();
 //  5:  Result := TMicroSDConnectIO.Create();
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
   5:  Result := TRestConnectIO.Enum();
  else Result := TComConnectIO.Enum();
  end;
end;

function TComDevPlugin.IsManualCreate(ConnectID: Integer): Boolean;
begin
  Result := ConnectID in [2,3,4,5];
end;

class function TComDevPlugin.GetHInstance: THandle;
begin
  Result := HInstance;
end;

class function TComDevPlugin.PluginName: string;
begin
  Result := 'Устройства Ввода-Выода и Приборы';
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
  if Length(Adr) > 1 then for a in Adr do if A >= 100 then raise EDeviceException.Create('Устройство с адресом >=100 может быть только одно');
  if Length(Adr) >= 1 then
   begin
    if Adr[0] = 100 then Result := TUso.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = 101 then Result := TGlu.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = ADR_UAKI then Result := TDevUaki.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = ADR_UAKI2 then Result := TDevUaki2.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = ADR_STOL_GK then Result := TStolGK.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = ADR_PULT_BK then Result := TDevPultBK.CreateWithAddr(Adr, DeviceName) as IDevice
    else if Adr[0] = 111 then Result := TGluSonic.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (Adr[0] > 101) and (adr[0] < 200) then  Result := TPskStd.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (adr[0] = 1000) then Result := TTelesistem.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (adr[0] = 1001) then Result := TTelesisRetr.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (adr[0] = 1002) then Result := TTelesis1ware.CreateWithAddr(Adr, DeviceName) as IDevice
    else if (adr[0] > 15) then raise EDeviceException.Create('Устройство с неверным адресом')

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
