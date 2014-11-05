unit WlanClass;

interface

uses System.SysUtils, Vcl.Forms, winapi.Windows, nduWlanAPI, nduWlanTypes, nduL2cmn;

type
  TWlan_Notification_ACM =
   (autoconf_enabled=1,
    autoconf_disabled,
    background_scan_enabled,
    background_scan_disabled,
    bss_type_change,
    power_setting_change,
    scan_complete,
    scan_fail,
    connection_start,       //WLAN_CONNECTION_NOTIFICATION_DATA
    connection_complete,    //WLAN_CONNECTION_NOTIFICATION_DATA
    connection_attempt_fail,//WLAN_CONNECTION_NOTIFICATION_DATA
    filter_list_change,
    interface_arrival,
    interface_removal,
    profile_change,
    profile_name_change,
    profiles_exhausted,
    network_not_available,
    network_available,
    disconnecting, //WLAN_CONNECTION_NOTIFICATION_DATA
    disconnected,  //WLAN_CONNECTION_NOTIFICATION_DATA
    adhoc_network_state_change,
    profile_unblocked,
    screen_power_change,
    profile_blocked,
    scan_list_refresh);

  const
   WLAN_CONN_NOTIF_DATA: set of TWlan_Notification_ACM = [connection_start, connection_complete, connection_attempt_fail, disconnecting, disconnected];

  type

  EWlanConnectIOException = class(Exception);

  TResultConnect = reference to procedure(Code: TWlan_Notification_ACM; Data: Pndu_WLAN_CONNECTION_NOTIFICATION_DATA);
  TWlanConnection = class
  private
    FInnConn: Boolean;
  protected
    FVersion: DWORD;
    FClientHandle: THandle;
    FInterfaceList: Pndu_WLAN_INTERFACE_INFO_LIST;
    FNetworksList: Pndu_WLAN_AVAILABLE_NETWORK_LIST;
    FLastConnectFunc: TResultConnect;
    procedure ClearInterfacesList;
    procedure ClearNetworksList;
    procedure FillNetworksList(PInterface: PGUID);
    procedure FillInterfacesList;
  public
   type
    TIntfInfo = Tndu_WLAN_INTERFACE_INFO;
    TNetInfo = Tndu_WLAN_AVAILABLE_NETWORK;
    TInterfacesEnumerator = record
    private
      i: Integer;
      Lst: Pndu_WLAN_INTERFACE_INFO_LIST;
      function DoGetCurrent: TIntfInfo;
    public
      property Current: TIntfInfo read DoGetCurrent;
      function MoveNext: Boolean;
      function GetEnumerator: TInterfacesEnumerator;
    end;
    TNetworksEnumerator = record
    private
      i: Integer;
      Lst: Pndu_WLAN_AVAILABLE_NETWORK_LIST;
      function DoGetCurrent: TNetInfo;
    public
      property Current: TNetInfo read DoGetCurrent;
      function MoveNext: Boolean;
      function GetEnumerator: TNetworksEnumerator;
    end;
    constructor Create(); virtual;
    destructor Destroy; override;
    function DefaultInterfaceID: TGUID;
    procedure Scan(InterfaceID: TGUID);
    function Interfaces(Update: Boolean = False): TInterfacesEnumerator;
//    function Networks(InterfaceIndex: Cardinal = 0): TNetworksEnumerator; overload;
    function Networks(InterfaceID: TGUID): TNetworksEnumerator; overload;
    procedure Connect(InterfaceID: TGUID; const ssid: string; Secure: Boolean; func: TResultConnect); overload;
    procedure Connect(InterfaceID: TGUID; const ssid: string; Secure: Boolean); overload;
    procedure DisConnect(InterfaceID: TGUID);
//    function EditProfile(InterfaceID: TGUID; const Name: String; h: HWND): Tndu_WLAN_REASON_CODE;
    class function InterfaceStateToStr(state: Tndu_WLAN_INTERFACE_STATE): string;
    class function AuthAlgToStr(Alg: Tndu_DOT11_AUTH_ALGORITHM): string;
    class function ChiperAlgToStr(Alg: Tndu_DOT11_CIPHER_ALGORITHM): string;
    class function NotificationACMToStr(Code: TWlan_Notification_ACM): string;
    class function ReasonCodeToStr(Code: Tndu_WLAN_REASON_CODE): string;
    class function BSSToStr(bss: Tndu_DOT11_BSS_TYPE): string;
  end;

implementation


{ TInterfacesEnumerator }

function TWlanConnection.TInterfacesEnumerator.DoGetCurrent: TIntfInfo;
begin
  Result := Lst.InterfaceInfo[i];
end;

function TWlanConnection.TInterfacesEnumerator.GetEnumerator: TInterfacesEnumerator;
begin
  Result := Self;
end;

function TWlanConnection.TInterfacesEnumerator.MoveNext: Boolean;
begin
  Inc(i);
  Result := Cardinal(i) < Lst.dwNumberOfItems;
end;

{ TNetworksEnumerator }

function TWlanConnection.TNetworksEnumerator.DoGetCurrent: TNetInfo;
begin
  Result := Lst.Network[i];
end;

function TWlanConnection.TNetworksEnumerator.GetEnumerator: TNetworksEnumerator;
begin
  Result := Self;
end;

function TWlanConnection.TNetworksEnumerator.MoveNext: Boolean;
begin
  Inc(i);
  Result := Cardinal(i) < Lst.dwNumberOfItems;
end;

{ TWlanConnection }

procedure TWlanConnection.ClearInterfacesList;
begin
  if Assigned(FInterfaceList) then
   begin
    WlanFreeMemory(FInterfaceList);
    FInterfaceList := nil;
   end;
end;

procedure TWlanConnection.ClearNetworksList;
begin
  if Assigned(FNetworksList) then
   begin
    WlanFreeMemory(FNetworksList);
    FNetworksList := nil;
   end;
end;

procedure TWlanConnection.FillNetworksList(PInterface: PGUID);
 const
  WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES = $00000001;
 var
  Res: DWORD;
begin
  ClearNetworksList;
  Res := WlanGetAvailableNetworkList(FClientHandle,
                                     PInterface,
                                     WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES,
                                     nil,
                                     FNetworksList);
  if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ ������ ��������� ���� [%d]', [Res]);
end;

procedure TWlanConnection.FillInterfacesList;
 var
  Res: DWORD;
begin
  if not Assigned(FInterfaceList) then
   begin
    Res := WlanEnumInterfaces(FClientHandle, nil, @FInterfaceList);
    if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ ������ ��������� [%d]', [Res]);
   end;
end;

procedure WlanNotification(Data: Pndu_L2_NOTIFICATION_DATA; Self: Pointer); stdcall;
begin
  with TWlanConnection(Self) do
   if Assigned(FLastConnectFunc)
   and (Data.NotificationSource = NDU_L2_NOTIFICATION_SOURCE_WLAN_ACM)
   and (TWlan_Notification_ACM(Data.NotificationCode) in WLAN_CONN_NOTIF_DATA) then
       FLastConnectFunc(TWlan_Notification_ACM(Data.NotificationCode), Data.pData);
end;

constructor TWlanConnection.Create;
 var
  Res: DWORD;
begin
  Res := WlanOpenHandle(1, nil, @FVersion, @FClientHandle);
  if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ �������� Wlan [%d]', [Res]);
  Res := WlanRegisterNotification(FClientHandle, NDU_L2_NOTIFICATION_SOURCE_WLAN_ACM, True, @WlanNotification, Self, nil, nil);
  if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ WlanRegisterNotification [%d]', [Res]);
end;

destructor TWlanConnection.Destroy;
begin
  ClearNetworksList;
  ClearInterfacesList;
  if FClientHandle > 0 then WlanCloseHandle(FClientHandle, nil);
  inherited;
end;

function TWlanConnection.DefaultInterfaceID: TGUID;
begin
  FillInterfacesList;
  if FInterfaceList.dwNumberOfItems = 0 then raise EWlanConnectIOException.Create('��� WIFI ���������');
  Result := FInterfaceList^.InterfaceInfo[0].InterfaceGuid;
end;

function TWlanConnection.Interfaces(Update: Boolean = False): TInterfacesEnumerator;
begin
  if Update then ClearInterfacesList;
  FillInterfacesList;
  Result.Lst := FInterfaceList;
  Result.i := -1;
end;

function TWlanConnection.Networks(InterfaceID: TGUID): TNetworksEnumerator;
begin
  FillInterfacesList;
  ClearNetworksList;
  FillNetworksList(@InterfaceID);
  Result.Lst := FNetworksList;
  Result.i := -1;
end;

//function TWlanConnection.Networks(InterfaceIndex: Cardinal): TNetworksEnumerator;
//begin
//  FillInterfacesList;
//  if FInterfaceList.dwNumberOfItems = 0 then raise EWlanConnectIOException.Create('��� WIFI ���������');
//  if InterfaceIndex >= FInterfaceList.dwNumberOfItems then
//     raise EWlanConnectIOException.CreateFmt('����� ���������� %d ������ ���� ������ ������ ���������� %d',
//                                             [InterfaceIndex, FInterfaceList.dwNumberOfItems]);
//  ClearNetworksList;
//  FillNetworksList(@FInterfaceList^.InterfaceInfo[InterfaceIndex].InterfaceGuid);
//  Result.Lst := FNetworksList;
//  Result.i := -1;
//end;

procedure TWlanConnection.Connect(InterfaceID: TGUID; const ssid: string; Secure: Boolean; func: TResultConnect);
 var
  Res: DWORD;
  ConnParams: Tndu_WLAN_CONNECTION_PARAMETERS;
  n: TNetInfo;
begin
  FLastConnectFunc := func;
  for n in Networks(InterfaceID) do if SameText(ssid, string(PAnsiChar(@n.dot11Ssid.ucSSID))) then
   begin
    ConnParams := default(Tndu_WLAN_CONNECTION_PARAMETERS);// FillChar(ConnParams, SizeOf(ConnParams), 0);
    if Secure then ConnParams.wlanConnectionMode := wlan_connection_mode_discovery_secure
    else ConnParams.wlanConnectionMode := wlan_connection_mode_discovery_unsecure;
    ConnParams.dot11BssType := n.dot11BssType;
    ConnParams.pDot11Ssid := @n.dot11Ssid;
    Res := WlanConnect(FClientHandle, @InterfaceID, @ConnParams, nil);
    if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ ����������� [%d]', [Res]);
    Exit;
   end;
  Scan(InterfaceID);
  raise EWlanConnectIOException.CreateFmt('���� %s �� �������!', [ssid]);
end;

procedure TWlanConnection.Connect(InterfaceID: TGUID; const ssid: string; Secure: Boolean);
 var
  fwait: Boolean;
  reason: Tndu_WLAN_REASON_CODE;
begin
  if FInnConn then raise EWlanConnectIOException.CreateFmt('���������� � %s ��� ����!', [ssid]);
  fwait := True;
  FInnConn := True;
  try
    Connect(InterfaceID, ssid, Secure, procedure(Code: TWlan_Notification_ACM; pD: Pndu_WLAN_CONNECTION_NOTIFICATION_DATA)
    begin
      if Code = connection_complete then
       begin
        reason := pD.wlanReasonCode;
        fwait := False;
       end;
    end);
    while fwait do Application.ProcessMessages;
  finally
   FInnConn := False;
  end;
  if reason <> NDU_L2_REASON_CODE_SUCCESS then  raise EWlanConnectIOException.CreateFmt('���������� � %s ���������: %s!', [ssid, ReasonCodeToStr(reason)]);
end;

procedure TWlanConnection.DisConnect(InterfaceID: TGUID);
 var
  Res: DWORD;
begin
  FLastConnectFunc := nil;
  Res := WlanDisconnect(FClientHandle, @InterfaceID, nil);
  if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ ���������� [%d]', [Res]);
end;

{function TWlanConnection.EditProfile(InterfaceID: TGUID; const Name: String; h: HWND): Tndu_WLAN_REASON_CODE;
 var
  Res: DWORD;
begin
  ClearInterfacesList;
  FillInterfacesList;
  Res := WlanUIEditProfile(1, LPCWSTR(Name), @InterfaceID, h, WLConnectionPage, nil, @Result);
  if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ �������� UI [%d]', [Res]);
end;}

procedure TWlanConnection.Scan(InterfaceID: TGUID);
 var
  Res: DWORD;
begin
  FillInterfacesList;
  Res := WlanScan(FClientHandle, @InterfaceID, nil, nil, nil);
  if Res <> ERROR_SUCCESS then raise EWlanConnectIOException.CreateFmt('������ ������������ [%d]', [Res]);
end;


class function TWlanConnection.InterfaceStateToStr(state: Tndu_WLAN_INTERFACE_STATE): string;
begin
  case state of
    wlan_interface_state_not_ready: Result := 'not ready';
    wlan_interface_state_connected: Result := 'connected';
    wlan_interface_state_ad_hoc_network_formed: Result := 'ad hoc network formed';
    wlan_interface_state_disconnecting: Result := 'disconnecting';
    wlan_interface_state_disconnected: Result := 'disconnected';
    wlan_interface_state_associating: Result := 'associating';
    wlan_interface_state_discovering: Result := 'discovering';
    wlan_interface_state_authenticating: Result := 'authenticating';
    else Result := Integer(state).ToString;
  end;
end;

class function TWlanConnection.AuthAlgToStr(Alg: Tndu_DOT11_AUTH_ALGORITHM): string;
begin
  case Alg of
    DOT11_AUTH_ALGO_80211_OPEN          : Result:= '80211_OPEN';
    DOT11_AUTH_ALGO_80211_SHARED_KEY    : Result:= '80211_SHARED_KEY';
    DOT11_AUTH_ALGO_WPA                 : Result:= 'WPA';
    DOT11_AUTH_ALGO_WPA_PSK             : Result:= 'WPA_PSK';
    DOT11_AUTH_ALGO_WPA_NONE            : Result:= 'WPA_NONE';
    DOT11_AUTH_ALGO_RSNA                : Result:= 'RSNA';
    DOT11_AUTH_ALGO_RSNA_PSK            : Result:= 'RSNA_PSK';
    DOT11_AUTH_ALGO_IHV_START           : Result:= 'IHV_START';
    DOT11_AUTH_ALGO_IHV_END             : Result:= 'IHV_END';
    else Result := Integer(Alg).ToString;
  end

end;

class function TWlanConnection.BSSToStr(bss: Tndu_DOT11_BSS_TYPE): string;
begin
  case bss of
    dot11_BSS_type_infrastructure : Result := 'infrastructure';
    dot11_BSS_type_independent: Result := 'independent';
    dot11_BSS_type_any: Result := 'any';
    else Result := Integer(bss).ToString;
  end;
end;

class function TWlanConnection.ChiperAlgToStr(Alg: Tndu_DOT11_CIPHER_ALGORITHM): string;
begin
  case Alg of
    DOT11_CIPHER_ALGO_NONE      : Result:= 'NONE';
    DOT11_CIPHER_ALGO_WEP40     : Result:= 'WEP40';
    DOT11_CIPHER_ALGO_TKIP      : Result:= 'TKIP';
    DOT11_CIPHER_ALGO_CCMP      : Result:= 'CCMP';
    DOT11_CIPHER_ALGO_WEP104    : Result:= 'WEP104';
    DOT11_CIPHER_ALGO_WPA_USE_GROUP : Result:= 'WPA_USE_GROUP OR RSN_USE_GROUP';
//    DOT11_CIPHER_ALGO_RSN_USE_GROUP : Result:= 'RSN_USE_GROUP';
    DOT11_CIPHER_ALGO_WEP           : Result:= 'WEP';
    DOT11_CIPHER_ALGO_IHV_START     : Result:= 'IHV_START';
    DOT11_CIPHER_ALGO_IHV_END       : Result:= 'IHV_END';
    else Result := Integer(Alg).ToString;
  end;
end;

class function TWlanConnection.NotificationACMToStr(Code: TWlan_Notification_ACM): string;
begin
  case code of
    autoconf_enabled: Result := 'autoconf_enabled';
    autoconf_disabled: Result := 'autoconf_disabled';
    background_scan_enabled: Result := 'background_scan_enabled';
    background_scan_disabled: Result := 'background_scan_disabled';
    bss_type_change: Result := 'bss_type_change';
    power_setting_change: Result := 'power_setting_change';
    scan_complete: Result := 'scan_complete';
    scan_fail: Result := 'scan_fail';
    connection_start: Result := 'connection_start';
    connection_complete: Result := 'connection_complete';
    connection_attempt_fail: Result := 'connection_attempt_fail';
    filter_list_change: Result := 'filter_list_change';
    interface_arrival: Result := 'interface_arrival';
    interface_removal: Result := 'interface_removal';
    profile_change: Result := 'profile_change';
    profile_name_change: Result := 'profile_name_change';
    profiles_exhausted: Result := 'profiles_exhausted';
    network_not_available: Result := 'network_not_available';
    network_available: Result := 'network_available';
    disconnecting: Result := 'disconnecting';
    disconnected: Result := 'disconnected';
    adhoc_network_state_change: Result := 'adhoc_network_state_change';
    profile_unblocked: Result := 'profile_unblocked';
    screen_power_change: Result := 'screen_power_change';
    profile_blocked: Result := 'profile_blocked';
    scan_list_refresh: Result := 'scan_list_refresh';
    else Result := Integer(Code).ToString;
  end;
end;

class function TWlanConnection.ReasonCodeToStr(Code: Tndu_WLAN_REASON_CODE): string;
begin
  SetLength(Result, 1024);
  WlanReasonCodeToString(Code, 1024, PWideChar(Result), nil);
end;

end.
