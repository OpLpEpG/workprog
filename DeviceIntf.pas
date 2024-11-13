unit DeviceIntf;

interface

uses Container, tools,
     winapi.Windows, SysUtils, XMLIntf, Classes, RootIntf, System.TypInfo;//, Controls;

type
  IRAMInfo = IXMLNode;
  IRAMData = IXMLNode;
  IEEPData = IXMLNode;
  TInfoEventRes = TDeviceMetaData;
  TInfoEvent = procedure (Res: TInfoEventRes) of object;
  TCheckInfoEvent = procedure (d, tst: IXMLNode) of object;
  // ������� ���������� ������ (����� ���������� (��������))
  // Work: IXMLInfo - ����� Info: IXMLInfo c ������������ ������ ������� ������ � ������ ��������
  TWorkEventRes = record
    DevAdr: Integer; Work: IXMLInfo;
  end;
//  TSubDevData = record
//     Data: Pointer; DataSize: integer;
//  end;
  TEepromEventRes = record
    DevAdr: Integer;
    eep: IXMLInfo;
  end;
  TWorkEvent = procedure (Res: TWorkEventRes) of object;
  TEepromEventRef = reference to procedure (Res: TEepromEventRes);
  // ������� ���������� XML ���������� RAM
  TRamEvent = procedure (DevAdr: Integer; RamInfo: IRAMInfo) of object;
  // ������� � ��������� ���������� ���
  //                        ��������� ������  ���������� �������  �����    ��������      ����� �� ���� ��� ����������
                                                                                       // ��� ������ � ������� ��������
//  EnumReadRam = (eirReadOk, eirReadErrSector,     eirCantRead,    eirEnd,  eirTerminate);//,       eirEndDev);
  // ProcToEnd - % �� ��������� ���������� ��� �������� ����������
  TReadRamEvent = procedure (EnumRR: EnumCopyAsyncRun; DevAdr: Integer; Statistic: TStatistic) of object;
  // ������� ��������� ������ ��� ������ ������� ���������� ������ ��������� ��������� ������ � ������� �����
  TGetConnectIOCB = reference to procedure (ConnectID: Integer; const ConnectName, ConnectInfo: string);

  TResultEvent = procedure (Res: Boolean) of object;

  TResultEventRef = reference to procedure (Res: Boolean);

  // ���������� ������ TDebug �������� ����������� ������������������ ����������
  // ��������� �� TForm ����������, ��������� � � �������� (������ ��� �����)
  // � ���������� � ���������� ����������� �� JEDI
  TAsyncException = procedure (const ClassName, msg, StackTrace: WideString) of object;

{$REGION  'DevCom - ��� ����������'}
//��������� ���������� ������� ������������ � IConnectIO
  IDevice = interface;
  TDeviceArray = TArray<IDevice>;
  TReceiveDataRef = reference to procedure(Data: Pointer; DataSize: integer);

  TConnectIOStatus =(iosOpen, iosError, iosLock, icAdding, icUserAdding);

  TSetConnectIOStatus = set of TConnectIOStatus;
  ///	<summary>
  ///	  ��������� ������ ������� � ������� �����. ����������� ���������: �����
  ///	  ���� ��������� IDevice<br />
  ///	</summary>
  IConnectIO = interface(IManagItem)
  ['{8AC3328B-BF3D-44EF-9996-EE882E5DBDE2}']
    procedure SetConnectInfo(const Value: string);
    function GetConnectInfo: string;
    procedure Open;
    procedure Close;
    function IsOpen: Boolean;
    ///	<remarks>
    ///	  ����� �������� ������ �� ������ �� ��������� - 500 �� (������� ��
    ///	  ���������)
    ///	</remarks>
    procedure SetWait(Value: integer);
    function GetWait: integer;
//  �������� ���� �� ����� ����� ������� � ��������� ����������� � �� x���� ��������� �� ��������
//  ��� � ��������� ���� ����� � ���������� ������
    { TODO : ������ �� ����� ��� ��� }
    function Locked(const User): Boolean;
    procedure Lock(const User);
    procedure Unlock(const User);

    procedure CheckOpen;
    procedure SendROW(Data: Pointer; Cnt: Integer; Event: TReceiveDataRef = nil; WaitTime: Integer = -1);

    function GetStatus: TSetConnectIOStatus;
    procedure SetStatus(Value: TSetConnectIOStatus);

    property ConnectInfo: string read GetConnectInfo write SetConnectInfo;
    property Wait: integer read GetWait write SetWait;
    property Status: TSetConnectIOStatus read GetStatus write SetStatus;
  end;
  ///	<summary>
  ///	  ���������� IConnectIO ��� ��������
  ///	</summary>
  IComPortConnectIO = interface(IConnectIO)
  ['{617A30B1-F76F-4583-BAB5-80794947CEA2}']
   function DefaultSpeed: Integer;
  end;
  ///	<summary>
  ///	  ���������� IConnectIO ��� TCP
  ///	</summary>
  INetConnectIO = interface(IConnectIO)
  ['{F7222E26-D257-4288-802C-EDAC8ED0EE9E}']
  end;
  IRestConnectIO = interface(IConnectIO)
  ['{C31C36BB-C528-496B-9DB5-FE3DFF6F2404}']
  end;
  ///	<summary>
  ///	  ���������� IConnectIO ��� UDP
  ///	</summary>
  IUDPBinConnectIO=interface(IConnectIO)
  ['{229C0035-2B30-42C8-ADD1-E9FDB93B812C}']
  end;
  ///	<summary>
  ///	  ���������� IConnectIO ��� ������ ������ � microSD �����
  ///	</summary>
  ImicroSDConnectIO = interface(IConnectIO)
  ['{CF7E43AF-87A0-4F9C-8739-87FFBCB1F5E8}']
  end;
//  IFileConnectIO = interface(IConnectIO)
//  ['{B7BCD1DB-8068-426E-BCE2-80E88D943B25}']
//  end;

  TReceiveUDPRef = reference to procedure(const Data: string; status: integer);

  ///	<summary>
  ///	  ���������� IConnectIO ��� UAKI
  ///	</summary>
  IUDPConnectIO = interface(IConnectIO)
  ['{0F0AC653-2AC1-47EB-8214-7806F7376666}']
    procedure Send(const cmd: string; ev: TReceiveUDPRef = nil; TimeOut: Integer = -1);
  end;
  ///	<summary>
  ///	  ���������� IConnectIO ��� WiFi
  ///	</summary>
  IWlanConnectIO = interface(INetConnectIO)
  ['{C97BE14F-BD9E-4B00-A213-0D6CB2890B61}']
  end;

  TDeviceStatus = (
    ///	<summary>
    ///	  ���������� �� �����������������
    ///	</summary>
    dsNoInit,
    ///	<summary>
    ///	  ���� ������� � �� ������� ������
    ///	</summary>
    dsPartReady,
    ///	<summary>
    ///	  ������ �����
    ///	</summary>
    dsReady,
    ///	<summary>
    ///	  ����� ������� (����� ����������)
    ///	</summary>
    dsData,
    ///	<summary>
    ///	  ���������� �� ��������
    ///	</summary>
    dsDelay,
    ///	<summary>
    ///	  ������ ������
    ///	</summary>
    dsReadRam
  );
  TSetDeviceStatus = set of TDeviceStatus;
  ///	<summary>
  ///	  ��������� ���������� ������� ������������ � IConnectIO
  ///	</summary>
  IDevice = interface(IManagItem)
  ['{D4F8618E-42CE-4893-9EBB-75E178162038}']
    procedure SetConnect(AIConnectIO: IConnectIO);
    function GetConnect: IConnectIO;
    function GetNamesArray(Index: Integer): string;
    function AddressArrayToNames(const Addrs: TAddressArray): string;
//    function GetDeviceName: string;
//    procedure SetDeviceName(const Value: string);
//  ������� �� �������� ������� �������� �������� IDevice;
    function GetAddrs: TAddressArray;
    function GetStatus: TDeviceStatus;
    function CanClose: Boolean;
    // ��������� ���������� ����� � ��������
    property IConnect: IConnectIO read GetConnect write SetConnect;
    property Addrs: TAddressArray read GetAddrs;
    property NamesArray[Index: Integer]: string read GetNamesArray;
    property Status: TDeviceStatus read GetStatus;
//    property Name: string read GetDeviceName write SetDeviceName;
  end;

  TSubDeviceInfo = record
    Typ: set of (
    ///	<summary>
    ///	  ����� ���� ������ ���� ����������
    ///	</summary>
    sdtUniqe,
    ///	<summary>
    ///	  ������������ ����������
    ///	</summary>
    sdtMastExist);
    Category: string;
  end;

//  ISubDeviceData<I, O> = interface
//  ['{A8084EB5-2EC4-48B1-B043-FB17554C7870}']
//    procedure InputData(Data: I);
//    procedure SetData(Value: O);
//  end;

  ISubDevice = interface//(IManagItem)
  ['{D9947F39-BE31-45BC-9F5F-6FAC6CB19FC8}']
    function GetCategory: TSubDeviceInfo;
    function GetCaption: string;
    function GetItemName: string;

    ///	<summary>
    ///	 ����� �������
    ///	</summary>
  //  procedure InputData(Data: Pointer; DataSize: integer);
    ///	<summary>
    ///	 ����� �������
    ///	</summary>
//    procedure SetChild(SubDevice: ISubDevice);
//    function GetAddr: Integer;
//    property Addr: Integer read GetAddr;

    property Category: TSubDeviceInfo read GetCategory;
    property Caption: string read GetCaption;

    property IName: String read GetItemName;
  end;

  ISubDevice<T> = interface(ISubDevice)
  ['{374907BE-F493-465F-B012-2F97AC9FBC7F}']
    function GetData: T;
    property Data: T read GetData;
  end;

  IRootDevice = interface
  ['{3B0C08A9-E077-4F97-AC56-3A064B443C6D}']
    function GetSubDevices: TArray<ISubDevice>;
    function Index(SubDevice: ISubDevice): Integer;
    procedure Remove(Index: Integer);
    function AddOrReplase(SubDeviceType: ModelType): ISubDevice;
    function TryMove(SubDevice: ISubDevice; UpTrueDownFalse: Boolean): Boolean;
  //private
    function GetService: PTypeInfo;
    function GetStructure: TArray<TSubDeviceInfo>;
  ///	<summary>
  ///	 �������� ��������� ISubDevice ��� IRootDevice
  ///	</summary>
    property Service: PTypeInfo read GetService;
  ///	<summary>
  ///	 �������� ��������� ISubDevice ��� IRootDevice
  ///	</summary>
    property Structure: TArray<TSubDeviceInfo> read GetStructure;
    property SubDevices: TArray<ISubDevice> read GetSubDevices;
  end;

  ///	<summary>
  ///	  �������� ��������� �������������
  ///	</summary>
  { TODO : Register Factory interface }
  IGetDevice = interface
  ['{01465AA3-D6F2-4A6D-941E-016B27BF2AB8}']
   procedure Enum(GetDevicesCB: TGetDevicesCB);
   function  Device(const Addrs: TAddressArray; const DeviceName, ModulesNames: string): IDevice;
 end;

  IGetConnectIO = interface
  ['{A6A71F43-DFF8-4F95-A07D-D023792623F6}']
   procedure Enum(GetConnectIOCB: TGetConnectIOCB);
   function  ConnectIO(ConnectID: Integer): IConnectIO;

   function IsManualCreate(ConnectID: Integer): Boolean;
   function GetConnectInfo(ConnectID: Integer): TArray<string>;
 end;

  ///	<summary>
  ///	  ���������� ����� �������� ����������, ������, �������������, ������
  ///	</summary>
  IDataDevice = interface(IDevice)
  ['{717D72A7-CF04-4AE6-9E14-BD67E9FC3949}']
    ///	<remarks>
    ///	  <para>
    ///	    ������ ���������� ���������,
    ///	  </para>
    ///	  <para>
    ///	    1.�������� �� ������� ��
    ///	  </para>
    ///	  <para>
    ///	    2. ����� �� � � ����������� �Ġ
    ///	  </para>
    ///	  <para>
    ///	    (�����.)������ ����� ������ ��������� ��� ������� ��� 14 ���������
    ///	    ��� ������ ������ ��������� - ������ ������� �o 100 ��� ������
    ///	    ��������� ��������� ����� �������������<br />�??? ���� �����
    ///	    PathToDataDir � ��� ����� �� ���������� ���������� �� ram.xml �����
    ///	    �� ����� ��� ����� ��������� ???
    ///	  </para>
    ///	</remarks>
    procedure InitMetaData(ev: TInfoEvent);
    ///	<summary>
    ///	  <para>
    ///	    �� ��
    ///	  </para>
    ///	  <para>
    ///	    (�����.) ��������� ���������� ������ �InitMetaData��
    ///	  </para>
    ///	</summary>
    function GetMetaData: TDeviceMetaData;
    ///	<remarks>
    ///	  ���������� ������ (��������) StdOnly: Boolean = True - �����������
    ///	  ������ ������� ����� � ��������� ������������� ���������� � ������
    ///	  ������ �� ��� �� ������� �� ����StdOnly: Boolean = false - ����
    ///	  ���������� � ������ ������ ������� �� ���� ��� ��������� ���������
    ///	  StdOnly ��������������
    ///	</remarks>
    procedure ReadWork(ev: TWorkEvent; StdOnly: Boolean = false);
  end;

  IEepromDevice = interface(IDataDevice)
  ['{887C1E42-94B0-4E7C-83A0-1AF1DC43AD12}']
    ///	<remarks>
    ///	  ���������� EEPROM
    ///	</remarks>
    procedure ReadEeprom(Addr: Integer; ev: TEepromEventRef);
    ///	<remarks>
    ///	  ������ ��� ������ ������
    ///	</remarks>
    procedure WriteEeprom(Addr: Integer; ev: TResultEventRef; section: Integer = -1);
  end;

  TSetDelayRes = record
   Res: Boolean;
   Delay, WorkTime: TTime;
   SetTime: TDateTime;
  end;
//  TNullTime = ^TTime;

  TSetDelayEvent = procedure (Res: TSetDelayRes) of object;

  // ���������� ����� �������� �� ��������

  ///	<remarks>
  ///	  ���������� ���� ��������� �� ��������<br />���� TSetDelayEvent =
  ///	  procedure (Res: Boolean; Delay: TTime; SetTime: TDateTime)<br />����
  ///	  Res-true ���� ��������� ������ �� ��������<br />���� Delay ����������
  ///	  �������� ����� �������� ����� ���� �������� �� ��������; SetTime: �����
  ///	  ���������� �� ��������)<br />���� WorkTime-����� ������ ������� �����
  ///	  ���� �������� �� ��������;
  ///	</remarks>
  IDelayDevice = interface(IDevice)
  ['{E291C1CD-4943-4D1F-B207-0ECCE8889AF9}']
    procedure SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
  end;

  // �������� ����������� ��� ������ � �������
//  IRamReadInfo = interface;
//  IReadRamDevice = interface;
//  IRAMDataEnumerator = interface;
  // �������� ����������� ��� ������ � �������
//  IRamDevice = interface(IDevice)
//    ['{27423E99-7C55-4BE4-A7AC-D827EA1A9687}']
    // ��������� ���������� ��������� � ����������� ������� ���, ���������� ������ ������������
    // ����� ��������� ���� ������� ����������� �������� IRamReadInfo
    // ������� ����������� �������� IReadDeviceRAM
//    procedure RamDataPath(const PathToRamDataDir: WideString);
    // ������ ������ ������ ��������� � �����, ��� ���������, ����������� � �.�.
//    function GetRamDataEnumerator(adr: Integer): IRAMDataEnumerator;
    // ��� ����������� ������ � ��������, ������ ���������� ��� ���������� � �����,
//    function GetRamReadInfo(): IRamReadInfo;
    // ���������� ������ �� ���������� �� ����
//    function GetReadDeviceRam(): IReadRamDevice;
//  end;

  ///	<summary>
  ///	  ��� ����������� ������ � ��������, ������ ���������� (����������) ���
  ///	  ���������� � �����,<br />����� ����� - 0 ��� ������ � �� �������
  ///	  UpdateTimeSyncEvent ��� ������ (ICom as IRamReadInfo)
  ///	</summary>
//  IRamReadInfo = interface
//  ['{2E5B198E-CFD5-4E08-BCA3-7B81CCDE5B87}']
    // ������� ����� ������ �������� (����������� � PathToReadRamDir ram.xml) ���� ��� ������ �� ������ � ���������� ����� ��������
//    function New(TimeSart: TDateTime; TimeDelay: TTime): IRAMInfo;
    // ��������� � ����� IRAMInfo �
    // ���������� ��� ����������� ������ � ����������� � ����� ������ ��� ������
    // ������ ���������� � ������� �� ��������� ������� �������� ��� ������������� ������� (��������� ����������� �� ����)
    // ����������� �����
//    function Update(Info: IXMLInfo; UpdateEvent: TRamEvent = nil): IRAMInfo;
    // ��������� � ����� IRAMInfo
//    function Get(): IRAMInfo;
//  end;

  // ���������� ������ �� ����
  IReadRamDevice = interface
  ['{30BC6538-48E3-4B7F-9682-22EBB0FA5489}']
    // ������ ��������� ��� ������ ���

    // private
//    function GetFromTime: TDateTime;
//    function GetToTime: TDateTime;
//    procedure SetReadToFF(Flag: Boolean);
//    function GetReadToFF: Boolean;
//    procedure SetFastSpeed(Flag: Boolean);
//    function GetFastSpeed: Boolean;

    function GetCreateClcFile: Boolean;
    procedure SetCreateClcFile(const Value: Boolean);
    // public
    // ���������� �����. �� ��������� - ��� ������ (FromTime=ToTime=0)
//    procedure SetReadTime(FromTime, ToTime: TDateTime);
    // ����������� ����� ������, ������������ � ��������� �������� ����� �� ����
    // ��������� � �������� �� ����� IRAMInfo ������� � PathToReadRamDir xxxxxxx.bin ��� ������� ����������
    procedure Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0);
    // ��������� ���������� ����������� ����� Execute
    procedure Terminate(Res: TResultEvent = nil);

    // ���� ���������� ������ ���� ���� FF �� ��������� - ��
//    property ReadToFF: Boolean read GetReadToFF write SetReadToFF;
    // ���� �������� 0.5 ���� �� ��������� - ��
//    property FastSpeed: Boolean read GetFastSpeed write SetFastSpeed;
//    property FromTime: TDateTime read GetFromTime;
    property CreateClcFile: Boolean read GetCreateClcFile write SetCreateClcFile;
  end;

  TRunEvent = reference to procedure (ProcToEnd: Double);

  IFileDialog = interface
  ['{E80BBDD8-3127-4F7B-94BD-CC89DE00EE55}']
    function GetFilters: string;
//    procedure Execute(const FileName: string; FilterIndex: Integer; event: TRunEvent);
    property Filters: string read GetFilters;
  end;
  // ��� ������ ������� �� �����
  IRamImport = interface(IFileDialog)
  ['{C9ACE1A0-E1AA-4751-9128-99EC616DDBD2}']
    procedure Import(const FileName: string; FilterIndex: Integer;
                      FromKadr, ToKadr: Integer; ReadToFF: Boolean;
                      Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer);
    // ��������� ���������� ����������� ����� Execute
//    procedure Terminate(Res: TResultEvent = nil);
  end;
  // ��� ������ ������� � ����
//  IExport = interface(IFileDialog)
//  ['{D56A202E-0456-409A-AAE5-2338EF22B01B}']
//  end;

  // ��� ���������� � �����, - �� ����� ����� ������� � ���� ������
//  IRAMDataEnumerator = interface
//  ['{AE7B33FF-FBA5-49C3-89F9-64CA847EA98A}']
//    function GetRamReadInfo(): IRAMInfo;
//    function Current(): IRAMData;
//    function MoveNext(): Boolean;
//    function GotoKadr(Kadr: Integer): Boolean;
//    function CountKadr(): Integer;
//  end;

// ��������������� ����������

  ILowLevelDeviceIO = interface(IDevice)
  ['{3754E9DF-B976-47D0-A25A-486041E7CCDB}']
    procedure SendROW(Data: Pointer; Cnt: Integer; Event: TReceiveDataRef = nil; WaitTime: Integer = -1);
  end;


// ��������� ���������� �������� ����� �������
  ITurbo = interface(IDevice)
  ['{ED12F5BF-0785-4EC7-A767-08B69AB54893}']
    procedure Turbo(adr: Byte; speed: integer);
  end;

// ���������, (����� ����������) ����� ������� + ��� + ����������
  ICycle = interface
  ['{0745B82C-A141-451E-8F3A-F18EB201C9F0}']
    function GetCycle: Boolean;
    procedure SetCycle(const Value: Boolean);
    function GetPeriod: Integer;
    procedure SetPeriod(const Value: Integer);

    property Cycle: Boolean read GetCycle write SetCycle;
    property Period: Integer read GetPeriod write SetPeriod;
  end;
// ���������, ����� �������
  ICycleEx = interface(ICycle)
  ['{E62086C4-17E7-424D-9CB9-76F913180285}']
    function GetStdOnly: Boolean;
    procedure SetStdOnly(const Value: Boolean);
    property StdOnly: Boolean read GetStdOnly write SetStdOnly;
  end;

  // ���������� ��� ��������� ���������
  IStop = interface(IDevice)
  ['{C196F3A4-FF10-4348-98DE-75EDA8F9E175}']
  // ���������� ���������� ������
    procedure StopFlow(ResultEvent: TResultEvent = nil);
  // ��������� ����� ??
    function IsFlow: Boolean;
  // ���������� �������
  // procedure PowerOff(ResultEvent: TResultEvent = nil);
  end;

  EnumIOStatus = (iosRx, iosTx, iosTimeOut);
  TIOEvent = procedure (IOStatus: EnumIOStatus; Data: PByteArray; DataSize: Integer) of object;
  TIOEventString = procedure (IOStatus: EnumIOStatus; const Data: string) of object;
  // �������� ������ ��� ��������
  IDebugIO = interface
  ['{584A2F02-C26C-4468-BDDB-143CB52474E3}']
    procedure SetIOEvent(const AIOEvent: TIOEvent);
    function GetIOEvent(): TIOEvent;
    procedure SetIOEventString(const AIOEvent: TIOEventString);
    function GetIOEventString(): TIOEventString;
    property IOEvent: TIOEvent read GetIOEvent write SetIOEvent;
    property IOEventString: TIOEventString read GetIOEventString write SetIOEventString;
  end;
{$ENDREGION}



  // ���������������� ����������
  IConnectIOEnum = interface(IServiceManager<IConnectIO>)
  ['{C8548D8C-B5DC-4040-9090-33AE82786DA6}']
  end;

  IDeviceEnum = interface(IServiceManager<IDevice>)
  ['{5B043A5F-F374-409E-BEAD-028C8E2AF926}']
  end;


implementation

uses System.Bindings.Outputs, RTTI;

initialization
  TValueRefConverterFactory.RegisterConversion(TypeInfo(TSetConnectIOStatus), TypeInfo(string),
  TConverterDescription.Create(procedure(const I: TValue; var O: TValue)
  begin
    O := 'SetConnectIOStatus';
  end, 'SetConnectIOStatusToStr', 'SetConnectIOStatusToStr', '', True, '', nil));

  TValueRefConverterFactory.RegisterConversion(TypeInfo(TDeviceStatus), TypeInfo(string),
  TConverterDescription.Create( procedure(const I: TValue; var O: TValue)
  begin
    O := 'DeviceStatus';
  end, 'DeviceStatusToStr', 'DeviceStatusToStr', '', True, '', nil));
finalization

  TValueRefConverterFactory.UnRegisterConversion('SetConnectIOStatusToStr');
  TValueRefConverterFactory.UnRegisterConversion('DeviceStatusToStr');
end.
