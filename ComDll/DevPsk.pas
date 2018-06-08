unit DevPsk;

interface

uses  RootIntf,
  Winapi.Windows, System.SysUtils, System.Classes, CPort, CRC16, Vcl.ExtCtrls, System.Variants, Xml.XMLIntf, Xml.XMLDoc, Container,
  Generics.Collections, Actns, ExtendIntf, PluginAPI,
  DeviceIntf, AbstractDev, debug_except, RootImpl;

type
  // PPskCmd = ^TPskCmd;
   TPskCmd = record
    Cmd: Byte;
    Str: string;
   end;

const
   ADR_USO = 100;
   ADR_GLUBIONMER = 101;
   ADR_AP = 102;
   ADR_AK_XMEGA_LOC_NOISE = 103;
   ADR_PSK4 = 104;


   //��������� ������ ������
   //��� 8 ���� ������� ���� ������
   // ������� �������
   PRO_HI = $40; //��� ����������� ������������� �������� ��������� �� ���������������
   PRO_SWAP = $80;
   PRO_MASK = $7F;
   // ������ ������ 01 - FE - ������
   PRO_H_01 = 1;
   // ������ ������ 01 - FE 01 - 01 - ������
   PRO_H_02 = 2;

   //��� 8 ���� ������� ���� ������
   // ����������� ���������
   PRO_L_STD = 1;
   // ��������� �� ��������
   PRO_L_APW = 2;
   // ����������
   PRO_L_GLU = 3;
   // ���
   PRO_L_IKN = 4;

   //��������� ������ ������
   PRO_D_STD = 1;
   PRO_D_USO = 2;
   PRO_D_GLU = 3;

    DEV_RAM_ON_HI_SPEED: TPskCmd=(Cmd: $01; Str: '������ ������� ������ ����������������� ���������� ������');
    DEV_POWER_USO: TPskCmd =     (Cmd: $0C; Str: '������� ��� ���: ��������� �������');
    USO_POWER_OFF_DEV: TPskCmd = (Cmd: $0D; Str: '������� ��� ���: ��������� ������� ���������� �������');
    POWER_OFF_DEV: TPskCmd =     (Cmd: $85; Str: '������� ��� ��: ��������� ��������� �������');
    DEV_RESET: TPskCmd =         (Cmd: $80; Str: '������� ��� ��: ������������� �������');
    DEV_RAM_ON: TPskCmd =        (Cmd: $86; Str: '������� ��� ��: ������� ������� � ����� ������ ������');
    DEV_RAM_ON_AP: TPskCmd =     (Cmd: $87; Str: '������� ��� �� ��: ������� ������� � ����� ������ ������');
    DEV_INFO_ON: TPskCmd =       (Cmd: $84; Str: '������� ��� ��: ������� ������� � ����� �������� ����������';);
    USO_FLOW_ON: TPskCmd =       (Cmd: $27; Str: '������� ��� ���: ������� � ��������� �����';);
    USO_FLOW_OFF: TPskCmd =      (Cmd: $2A; Str: '������� ��� ���: ����� �� ���������� ������';);
    DEV_START_INFO: TPskCmd =    (Cmd: $8F; Str: '������� ��� ���: ������ ���������� ��������';);
    DEV_WRITE_DELAY: TPskCmd =   (Cmd: $81; Str: '������ ����� ��� ��: ������ ������� ��������';);
    USO_WRITE_DELAY_DEV: TPskCmd=(Cmd: $0B; Str: '������ ����� ��� ���: ������ ������� �������� � ��';);
    DEV_READ_DELAY: TPskCmd =    (Cmd: $89; Str: '������ ��� ��: ������ ������� ��������';);
    USO_WRITE_HDELAY: TPskCmd =  (Cmd: $02; Str: '������ ����� ��� ���: ������ �������� ����� ������� ��������';);
    USO_WRITE_LDELAY: TPskCmd =  (Cmd: $03; Str: '������ ����� ��� ���: ������ �������� ����� ������� ��������';);
    USO_READ_HDELAY: TPskCmd =   (Cmd: $06; Str: '������ ��� ���: ������ �������� ����� ������� ��������';);
    USO_READ_LDELAY: TPskCmd =   (Cmd: $05; Str: '������ ��� ���: ������ �������� ����� ������� ��������';);
    DEV_CLEAR: TPskCmd =         (Cmd: $8C; Str: '������� ��� ��: �������� ������';);
    DEV_START_DELAY: TPskCmd =   (Cmd: $82; Str: '������� ��� ��: ���� ��������';);
    USO_START_DELAY: TPskCmd =   (Cmd: $08; Str: '������� ��� ���: ���� ��������';);
    USO_LUP: TPskCmd =           (Cmd: $13; Str: '������ ��� ���: ������ �������� ����� �������';);
    USO_HUP: TPskCmd =           (Cmd: $14; Str: '������ ��� ���: ������ �������� ����� �������';);
    USO_LDOWN: TPskCmd =         (Cmd: $15; Str: '������ ��� ���: ������ �������� ����� ������';);
    USO_HDOWN: TPskCmd =         (Cmd: $16; Str: '������ ��� ���: ������ �������� ����� ������';);
    USO_LNAGR: TPskCmd =         (Cmd: $1F; Str: '������ ��� ���: ������ �������� ����� ������� ��������';);
    USO_HNAGR: TPskCmd =         (Cmd: $20; Str: '������ ��� ���: ������ �������� ����� ������� ��������';);
    RP_WRITE: TPskCmd =          (Cmd: $32; Str: '������ ����� ��� ��: ������ ������ � ��';);
    RP_DELAY_H: TPskCmd =        (Cmd: $4E; Str: '������� ��� ��: ������ �������� ����� ������� ��������';);
    RP_READ_DELAY_H: TPskCmd =   (Cmd: $42; Str: '������ ����� ��� ��: ������ �������� ����� ������� ��������';);
    RP_DELAY_M: TPskCmd =        (Cmd: $4F; Str: '������� ��� ��: ������ �������� ����� ������� ��������';);
    RP_READ_DELAY_M: TPskCmd =   (Cmd: $41; Str: '������ ����� ��� ��: ������ �������� ����� ������� ��������';);
    RP_DELAY_L: TPskCmd =        (Cmd: $50; Str: '������� ��� ��: ������ �������� ����� ������� ��������';);
    RP_READ_DELAY_L: TPskCmd =   (Cmd: $40; Str: '������ ����� ��� ��: ������ �������� ����� ������� ��������';);
    RP_START_DELAY: TPskCmd =    (Cmd: $51; Str: '������� ��� ��: ���� ��������';);
    RP_READ_INFO: TPskCmd =      (Cmd: $57; Str: '������� ��� ��: �������� ������ �����';);
    RP_PAGE_L: TPskCmd =         (Cmd: $53; Str: '������� ��� ��: ���� �������� ����� ������ ��������';);
    RP_PAGE_H: TPskCmd =         (Cmd: $54; Str: '������� ��� ��: ���� �������� ����� ������ ��������';);
    RP_READ_PAGE: TPskCmd =      (Cmd: $55; Str: '������� ��� ��: ������ ��������';);
    DEV_WORK_TIME_9: TPskCmd =   (Cmd: $8E; Str: '������� ��� ��: ���������� ����� ������ �� 9.5 �����';);
    DEV_WORK_TIME_38: TPskCmd =  (Cmd: $8A; Str: '������� ��� ��: ���������� ����� ������ �� 38 �����';);
    DEV_WORK_TIME_57: TPskCmd =  (Cmd: $8B; Str: '������� ��� ��: ���������� ����� ������ �� 57 �����';);
    DEV_WORK_TIME_76: TPskCmd =  (Cmd: $8D; Str: '������� ��� ��: ���������� ����� ������ �� 76 �����';);

type
  EnumTypeRunCmd = (ercCmdN, ercWriteN, ercWriteAndTestN, ercReadByte, ercInvN);

  TRunCmd = record
    kind: EnumTypeRunCmd;
    Data: Byte;
    Cmd, CmdT : TPskCmd;
    MaxErr: Integer;
    Delay: Integer;
    constructor Read(Acmd: TPskCmd;                     AMaxErr: Integer = 5; ADelay: Integer = 1000);
    constructor Init(Acmd: TPskCmd;                     AMaxErr: Integer = 5; ADelay: Integer = 1000); overload;
    constructor InitInv(Acmd: TPskCmd;                  AMaxErr: Integer = 5; ADelay: Integer = 1000);
    constructor InitD(Acmd: TPskCmd;        Adata: Byte; AMaxErr: Integer = 5; ADelay: Integer = 1000); overload;
    constructor Init(Acmd, AcmdT: TPskCmd; Adata: Byte; AMaxErr: Integer = 5; ADelay: Integer = 1000); overload;
  end;

  EAbstractPskException = class(EDeviceException);
  EPskExceptionClass = class of EAbstractPskException;

  TCmdByteRef = reference to procedure(Res: boolean; Data: PByte; DataSize: integer);
  TAbstractPsk = class(TAbstractDevice, INotifyAfterAdd, IGetActions)
  private
    FGetActions: TGetActionsImpl;
  protected
    FOldStatus: TDeviceStatus;
//    function GetActionsDevClass: TAbstractActionsDevClass; override;
{    procedure LoadBeroreAdd(); override;
    procedure BeforeAdd(); override;}
    procedure AfterAdd();
    procedure DoDelayEventHelper(rez, oldclose: Boolean; Delay, WorkTime: TTime; ResultEvent: TSetDelayEvent);
    property GetActions: TGetActionsImpl read FGetActions implements IGetActions;
  public
    Scenna: TArray<TRunCmd>;
    constructor Create(); override;
    destructor Destroy; override;
    procedure StopFlowRef(ResultEvent: TCmdByteRef);
    procedure InitMetaData(ev: TInfoEvent);
//    procedure ReadWork(ev: TWorkEvent; StdOnly: Boolean = false); override; safecall;
    function Inv(data: Byte): Byte; inline;
    procedure WaitRxData(Event: TCmdByteRef);
    procedure AsyncByte(Data: Byte; Event: TCmdByteRef; WaitTime: Integer = -1; ClearBuff: boolean = True);
    procedure AsyncInv( Cmd:  Byte; Event: TCmdByteRef; WaitTime: Integer = -1);
    procedure AsyncCmd( Cmd:  Byte; Event: TCmdByteRef; WaitTime: Integer = -1);
    procedure AsyncCmdReadData (Cmd: Byte;  Event: TCmdByteRef; WaitTime: Integer = -1);
    procedure AsyncCmdReadDataN(Cmd: Byte;  Event: TCmdByteRef; WaitTime: Integer = -1; MaxErr: Integer = 3);
    procedure AsyncInvN(Cmd: Byte;               Event: TCmdByteRef; WaitTime: Integer = -1; MaxErr: Integer = 3);
    procedure AsyncCmdN(Cmd: Byte;               Event: TCmdByteRef; WaitTime: Integer = -1; MaxErr: Integer = 3); overload;
    procedure AsyncCmdN2(Cmd: Byte;              Event: TCmdByteRef; WaitTime: Integer = -1; MaxErr: Integer = 3); overload;
    procedure AsyncCmdN(Cmd, Data: Byte;         Event: TCmdByteRef; WaitTime: Integer = -1; MaxErr: Integer = 3); overload;
    procedure AsyncCmdN(WCmd, RWCmd, Data: Byte; Event: TCmdByteRef; WaitTime: Integer = -1; MaxErr: Integer = 3); overload;
    procedure AddR(Acmd: TPskCmd;                    AMaxErr: Integer = 5; ADelay: Integer = -1);
    procedure AddInv(Acmd: TPskCmd;                  AMaxErr: Integer = 5; ADelay: Integer = -1);
    procedure Add(Acmd: TPskCmd;                     AMaxErr: Integer = 5; ADelay: Integer = -1); overload;
    procedure AddD(Acmd: TPskCmd;        Adata: Byte; AMaxErr: Integer = 5; ADelay: Integer = -1);
    procedure Add(Acmd, AcmdT: TPskCmd; Adata: Byte; AMaxErr: Integer = 5; ADelay: Integer = -1); overload;
    procedure ScennaBegin();
    procedure ScennaRun(Event: TCmdByteRef; ErrEvent: Boolean = False);
    procedure CheckConnect(); override;
    class function GetPSKInfo(Addr: Byte): IXMLNode;
//    procedure ChLockLockOpen(const User; e: EPskExceptionClass);
//    procedure UnLockClose(const User);
  end;

  EReadRamPskException = class(EReadRamException);
  TAbstractReadRamPsk = class(TReadRam)
  protected
    procedure Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0); override;
  public
    FFlagSwap: Boolean;
    FProtokol: Integer;
    FFlowDataWait: Integer;
  end;

  IProtocolReadRam = interface //  ���������� ��������� ��� ������������ �������
    procedure Execute;
    procedure Terminate(Res: TResultEvent);
  end;
//
  TStdReadRam = class;
  TProtocolReadRam_H_1 = class(TIObject, IProtocolReadRam)
  protected
    FErrCnt: Integer;
    FStdReadRam: TStdReadRam;
    procedure RamDataEvent(Res: boolean; Data: PByte; DataSize: integer);
    procedure ReStartRam(); virtual;
    procedure Execute; virtual;
    procedure Terminate(Res: TResultEvent);
    procedure DoEndRead(Reason: EnumCopyAsyncRun = carEnd; ResEv: TResultEvent = nil; Res: Boolean = False); virtual;
  public
    constructor Create(AStdReadRam: TStdReadRam); reintroduce;
  end;

  TProtocolReadRam_H_2 = class(TProtocolReadRam_H_1)
  protected
    procedure FlowCmd(pc: TPskCmd);
    procedure Execute; override;
  end;

  TProtocolReadRamStd = class(TProtocolReadRam_H_2)
  const
   MAX_ERR = 5;
  protected
    procedure Execute; override;
    procedure ReStartRam(); override;
    procedure DoEndRead(Reason: EnumCopyAsyncRun = carEnd; ResEv: TResultEvent = nil; Res: Boolean = False); override;
  end;

  TProtocolReadRamApw = class(TProtocolReadRam_H_2)
  protected
    procedure Execute; override;
    procedure DoEndRead(Reason: EnumCopyAsyncRun = carEnd; ResEv: TResultEvent = nil; Res: Boolean = False); override;
  end;

  EReadRamStdException = class(EReadRamPskException);
  TStdReadRam = class(TAbstractReadRamPsk)
  private
    FExecReadRam: IProtocolReadRam;
  protected
    procedure Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0); override;
    procedure Terminate(Res: TResultEvent = nil); override;
  end;

  EPskStdException = class(EAbstractPskException);

  TPskStd = class(TAbstractPsk, IDelayDevice, IStop, IDataDevice, IReadRamDevice)
  private
  protected
    FActData: IAction;
    FFlagFlow: Boolean;
    FFlowDataWait: Integer;
//    FWork: IXMLInfo;
    FWorkLen: Integer; //bytes
    FSpHi: Byte;
    FWorkEvent: TWorkEvent;
    FWorkInput: array [0..$8000] of Byte;
    FcheckSP: Boolean;
    procedure FlowDataEvent(Res: boolean; DataB: PByte; DataSize: integer);
    procedure ReStartFlow();
    // IStop
    procedure StopFlow(ResultEvent: TResultEvent = nil); virtual;
    function IsFlow: Boolean;
    function CreateReadRam: TReadRam; override;
    procedure BeforeRemove(); override;
    property ReadRam: TReadRam read PropertyReadRam  implements IReadRamDevice;
  public
    procedure ReadWork(ev: TWorkEvent; StdOnly: Boolean = false);
    procedure SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
//    function GetReadDeviceRam(): IReadRamDevice; override; safecall;
// actions
    //Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
    [DynamicAction('<I> ��������...', '<I>', 142, '0:����������|3.<I>:-1', '���� ���������� �� ��������')]
    procedure DoDelay(Sender: IAction);
//    [DynamicAction('<I> ��������� �����...', '<I>', Dialog_SyncDelay_ICON, '0:����������.<I>', '���� ��������� ����� �������. ���������� ����� ������� ������,� ������ ����������.')]
    procedure DoSync(Sender: IAction);
    [DynamicAction('<I> ����������', '<I>', 52, '0:����������|3.<I>;2:', '�����/���� � ����� ������ ����������')]
    procedure DoData(Sender: IAction);
    [DynamicAction('<I> ��������� ������', '<I>', 71, '0:����������|3.<I>', '��������� ������� � ������ �����')]
    procedure DoIdle(Sender: IAction);
  end;

  EReadRamGluException = class(EReadRamPskException);
  TGluReadRam = class(TAbstractReadRamPsk)
  protected
  // IImport
    function GetFilters: string;
    procedure Import(const FileName: string; FilterIndex: Integer;
                      FromKadr, ToKadr: Integer; ReadToFF: Boolean;
                      Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer);
//    FStreamGlm: TStream;
    procedure StartReadPage(ev: TCmdByteRef);
//    procedure CheckCreateStream; override;
//    procedure FreeStream; override;
    procedure Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean;FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0); override;
  end;

  TPskCycle = class(TAbstractPsk, ICycle)
  private
    FCycle: TCycle;
  public
    constructor Create(); override;
    destructor Destroy; override;
    property Cycle: TCycle read FCycle implements ICycle;
  published
    property CyclePeriod;
  end;

  ECluException = class(EAbstractPskException);

  TGlu = class(TPskCycle, IDelayDevice, IDataDevice, IReadRamDevice, IRamImport)
  protected
    function GCreateReadRam: TGluReadRam;
    property ReadRam: TGluReadRam read GCreateReadRam implements IReadRamDevice, IRamImport;
  public
    procedure ReadWork(ev: TWorkEvent; StdOnly: Boolean = false);
    procedure SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
    [DynamicAction('<I> ��������...', '<I>', 142, '0:����������|3.<I>;0:����������.<I>', '���� ���������� �� ��������')]
    procedure DoDelay(Sender: IAction);
    [DynamicAction('<I> ����������', '<I>', 52, '0:����������|3.<I>;0:����������.<I>', '���������� �����������')]
    procedure DoMetr(Sender: IAction);
    [DynamicAction('<I> ��������� �����...', '<I>', Dialog_SyncDelay_ICON, '0:����������.<I>;0:����������.<I>', '���� ��������� ����� �������. ���������� ����� ������� ������,� ������ ����������.')]
    procedure DoSync(Sender: IAction);
    [DynamicAction('<I> ����������', '<I>', 52, '0:����������|3.<I>;0:����������.<I>;2:', '�����/���� � ����� ������ ����������')]
    procedure DoData(Sender: IAction);
  end;

  EUsoException = class(EAbstractPskException);

  TUso = class(TPskCycle, IDelayDevice, IDataDevice)
  public
    procedure ReadWork(ev: TWorkEvent; StdOnly: Boolean = false);
    procedure SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
    [DynamicAction('<I> ��������...', '<I>', 142, '0:����������|3.<I>', '���� ���������� �� ��������')]
    procedure DoDelay(Sender: IAction);
    [DynamicAction('<I> ����������', '<I>', 52, '0:����������|3.<I>', '�����/���� � ����� ������ ����������')]
    procedure DoData(Sender: IAction);
  end;

implementation

uses tools, CRC16err, Parser;//, AbstractPlugin, PluginTools;

resourcestring
   RS_ZeroLenAdrArr = '����� ������� ������� ��������� ����� ����';
   RS_AdrNoXml = '����� xml %d ��������������� ������ %d ��� ������';
   RS_NoRamSize = '���������� �������� xml ���������� ��� ������ ������ � ������� ������';
   RS_NoHiProtokol = '���������� �������� xml ���������� �� ��������� ��� ������ ������ �� ������� ��������';
   RS_NoLoProtokol = '���������� �������� xml ���������� �� ��������� ��� ������ ������ �� ������� ��������';
   RS_NoMeta = '�� ����������������� ���������� ����� %d';
   RS_StopFlow = '���������� ��������� ����� ����������';
   RS_NoMetaInfo = '�� ����������������� ���������� ������ ����������';
   RS_ErrStartRam = '������ ������� ������ ���������� ������';
   RS_DelayToLong = '������� ������� ����� ��������';



function GetDevAndUsoTime(var Delay: TTime; var UsoTime: Word; Kdevide: integer): Byte;
const
 TO_DEV = 1/(2.097152);
 TO_USO = 1/(2.097152/2);
 TO_SEC = 24*60*60;
 var
  Kdev: Real;
  Res: Integer;
begin
  Kdev := TO_DEV/Kdevide;
  Res := Round(Delay*TO_SEC*Kdev);
  if Res > 255 then raise EPskStdException.Create(RS_DelayToLong);
  Result := Res;
  UsoTime := Round(Result/Kdev*TO_USO);
  Delay := Result/Kdev/TO_SEC;
end;

{$REGION  'TAbstractPsk - ��� ��������� � �������'}
{ TAbstractReadRamPsk }

procedure TAbstractReadRamPsk.Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0);
begin
  inherited ;//Execute(evInfoRead, Addrs);

//  CheckAndInitByAdr(Addrs[0], 0, 1, False);
  try
  if FRamXml.HasAttribute(AT_FLOWINTERVAL) then FFlowDataWait := FRamXml.Attributes[AT_FLOWINTERVAL]
  else FFlowDataWait := 1200;
//  FRamXml.Attributes[AT_RAM_FILE] := FFileRam;
//  FRamXml.Attributes[AT_FROM_TIME] := DateTimeToStr(FFromTimeAdr);
//  FRamXml.Attributes[AT_TO_TIME] := DateTimeToStr(FToTimeAdr);
//  FRamXml.Attributes[AT_FROM_ADR] := FFromAdr;
//  FRamXml.Attributes[AT_TO_ADR] := FToAdr;
  if FFastSpeed > 0 then
   if FRamXml.HasAttribute(AT_RAMHP) and (FRamXml.Attributes[AT_RAMHP] <> 0) then
    begin
     FFlagSwap := (FRamXml.Attributes[AT_RAMHP] and PRO_SWAP) <> 0;
     FProtokol :=  (FRamXml.Attributes[AT_RAMHP] and PRO_MASK) or PRO_HI;
    end
   else raise EReadRamPskException.Create(RS_NoHiProtokol)
  else
   if FRamXml.HasAttribute(AT_RAMLP) and (FRamXml.Attributes[AT_RAMLP] <> 0) then
    begin
     FFlagSwap := (FRamXml.Attributes[AT_RAMLP] and PRO_SWAP) <> 0;
     FProtokol :=  FRamXml.Attributes[AT_RAMLP] and PRO_MASK;
    end
   else raise EReadRamPskException.Create(RS_NoLoProtokol);
   except
    EndExecute;
    raise;
   end;

//  FRAMInfo.OwnerDocument.SaveToFile(FRAMInfo.OwnerDocument.FileName);
end;

{ TAbstractPsk }
{procedure TAbstractPsk.LoadBeroreAdd;
begin
  inherited;
  InitMetaData(nil);
end;

procedure TAbstractPsk.BeforeAdd;
begin
  inherited;
  InitMetaData(nil);
end;}

procedure TAbstractPsk.AfterAdd;
begin
  InitMetaData(nil);
end;


constructor TRunCmd.Init(Acmd: TPskCmd; AMaxErr, ADelay: Integer);
begin
  kind := ercCmdN;
  cmd := Acmd;
  MaxErr := AMaxErr;
  Delay := ADelay;
end;

constructor TRunCmd.InitInv(Acmd: TPskCmd; AMaxErr, ADelay: Integer);
begin
  Init(Acmd, AMaxErr, ADelay);
  kind := ercInvN;
end;


constructor TRunCmd.InitD(Acmd: TPskCmd; Adata: Byte; AMaxErr, ADelay: Integer);
begin
  kind := ercWriteN;
  cmd := Acmd;
  Data := Adata;
  MaxErr := AMaxErr;
  Delay := ADelay;
end;

constructor TRunCmd.Init(Acmd, AcmdT: TPskCmd; Adata: Byte; AMaxErr, ADelay: Integer);
begin
  kind := ercWriteAndTestN;
  cmd := Acmd;
  cmdT := AcmdT;
  Data := Adata;
  MaxErr := AMaxErr;
  Delay := ADelay;
end;

constructor TRunCmd.Read(Acmd: TPskCmd; AMaxErr, ADelay: Integer);
begin
  kind := ercReadByte;
  cmd := Acmd;
  MaxErr := AMaxErr;
  Delay := ADelay;
end;

procedure TAbstractPsk.ScennaBegin;
begin
  SetLength(Scenna, 0);
end;

procedure TAbstractPsk.AddD(Acmd: TPskCmd; Adata: Byte; AMaxErr, ADelay: Integer);
begin
  CArray.Add<TRunCmd>(Scenna, TRunCmd.InitD(Acmd, Adata, AMaxErr, ADelay))
end;

procedure TAbstractPsk.Add(Acmd: TPskCmd; AMaxErr, ADelay: Integer);
begin
  CArray.Add<TRunCmd>(Scenna, TRunCmd.Init(Acmd, AMaxErr, ADelay));
end;

procedure TAbstractPsk.Add(Acmd, AcmdT: TPskCmd; Adata: Byte; AMaxErr, ADelay: Integer);
begin
  CArray.Add<TRunCmd>(Scenna, TRunCmd.Init(Acmd, AcmdT, Adata, AMaxErr, ADelay));
end;

procedure TAbstractPsk.AddInv(Acmd: TPskCmd; AMaxErr, ADelay: Integer);
begin
  CArray.Add<TRunCmd>(Scenna, TRunCmd.InitInv(Acmd, AMaxErr, ADelay));
end;

procedure TAbstractPsk.AddR(Acmd: TPskCmd; AMaxErr, ADelay: Integer);
begin
  CArray.Add<TRunCmd>(Scenna, TRunCmd.Read(Acmd, AMaxErr, ADelay));
end;

procedure TAbstractPsk.AsyncByte(Data: Byte; Event: TCmdByteRef; WaitTime: Integer; ClearBuff: boolean);
begin
  CheckConnect;
  if not (ConnectIO as IConnectIO).IsOpen then (ConnectIO as IConnectIO).Open;
  if ClearBuff then ConnectIO.FICount := 0;
  ConnectIO.Send(@Data, 1, procedure (p: Pointer; n: integer)
  begin
    if Assigned(Event) then
     if n = 1 then Event(True, p, n)
     else Event(False, p, n)
  end, WaitTime);
end;

procedure TAbstractPsk.AsyncInv(Cmd: Byte; Event: TCmdByteRef; WaitTime: Integer);
begin
  with ConnectIO do AsyncByte(Cmd, procedure(Res: boolean; p: PByte; n: integer)
  begin
    if (n = 1) and (p^ = Inv(Cmd)) then Event(True, p, n)
    else Event(False, p, n);
  end, WaitTime);
end;

procedure TAbstractPsk.AsyncCmd(Cmd: Byte; Event: TCmdByteRef; WaitTime: Integer);
begin
  with ConnectIO do AsyncByte(Cmd, procedure(Res: boolean; p: PByte; n: integer)
  begin
    if (n = 1) and (p^ = Inv(Cmd)) then AsyncByte(Cmd, procedure(Res: boolean; p: PByte; n: integer)
     begin
       if (n = 1) and (p^ = Cmd) then Event(True, p, n)
       else Event(False, p, n);
     end, WaitTime)
    else Event(False, p, n);
  end, WaitTime);
end;

procedure TAbstractPsk.AsyncCmdReadData(Cmd: Byte; Event: TCmdByteRef; WaitTime: Integer);
begin
  with ConnectIO do AsyncByte(Cmd, procedure(Res: boolean; p: PByte; n: integer)
  begin
    if (n = 1) and (p^ = Inv(Cmd)) then AsyncByte(Cmd, procedure(Res: boolean; p: PByte; n: integer)
     begin
       Event(True, p, n);
     end, WaitTime)
    else Event(False, p, n);
  end, WaitTime);
end;

procedure TAbstractPsk.AsyncCmdReadDataN(Cmd: Byte; Event: TCmdByteRef; WaitTime, MaxErr: Integer);
 var
  en: Byte;
  rpe: TCmdByteRef;
begin
  en := 0;
  rpe := procedure (Res: boolean; p: PByte; n: integer)
  begin
    inc(en);
    if not Res and (en < MaxErr) then AsyncCmdReadData(Cmd, rpe, WaitTime)
    else Event(Res, p, n);
  end;
  AsyncCmdReadData(Cmd, rpe, WaitTime);
end;

procedure TAbstractPsk.CheckConnect;
begin
  inherited CheckConnect;
  if not Assigned(ConnectIO.FProtocol) or not (TAbstractProtocol(ConnectIO.FProtocol) is TProtocolPsk) then
   begin
    ConnectIO.FProtocol := TProtocolPsk.Create;
   end;
end;

constructor TAbstractPsk.Create;
begin
  inherited;
  FGetActions := TGetActionsImpl.Create(Self);
end;

destructor TAbstractPsk.Destroy;
begin
  FGetActions.Free;
  inherited;
end;

procedure TAbstractPsk.DoDelayEventHelper(rez, oldclose: Boolean; Delay, WorkTime: TTime; ResultEvent: TSetDelayEvent);
begin
  try
   S_Status := dsReady;
   ConnectUnlock;
   if OldClose then connectClose;
  finally
   DoDelayEvent(rez, Now, Delay, WorkTime, ResultEvent);
  end;
end;

//procedure TAbstractPsk.ChLockLockOpen(const User; e: EPskExceptionClass);
//begin
//  CheckConnect;
//  with (ConnectIO as IConnectIO) do
//   begin
//    if Locked(User) then raise e.Create(RS_Locked);
//    Lock(User);
//    if IsOpen then Open;
//   end;
//end;
//
//procedure TAbstractPsk.UnLockClose(const User);
//begin
//  CheckConnect;
//  with (ConnectIO as IConnectIO) do
//   begin
//    UnLock(User);
//    Close;
//   end;
//end;

//function TAbstractPsk.GetActionsDevClass: TAbstractActionsDevClass;
//begin
//  Result := TActionsDev;
//end;

class function TAbstractPsk.GetPSKInfo(Addr: Byte): IXMLNode;
 var
  SearchRec: TSearchRec;
  Found: integer;
  GDoc: IXMLDocument;
begin
  Result := nil;
  GDoc := NewXDocument();
  Found := FindFirst(ExtractFilePath(ParamStr(0)) + 'Devices' +'\*.xml', faAnyFile, SearchRec);
  while Found = 0 do
   begin
    GDoc.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Devices' +'\'+SearchRec.Name);
    if Assigned(FindDev(GDoc.DocumentElement, Addr)) then Exit(GDoc.DocumentElement);
    Found := FindNext(SearchRec);
   end;
end;

procedure TAbstractPsk.AsyncCmdN(Cmd: Byte; Event: TCmdByteRef; WaitTime, MaxErr: Integer);
 var
  en: Integer;
  rpe: TCmdByteRef;
begin
  en := 0;
  rpe := procedure (Res: boolean; p: PByte; n: integer)
  begin
    inc(en);
    if not Res and (en < MaxErr) then AsyncCmd(Cmd, rpe, WaitTime)
    else Event(Res, p, n);
  end;
  AsyncCmd(Cmd, rpe, WaitTime);
end;

procedure TAbstractPsk.AsyncCmdN2(Cmd: Byte; Event: TCmdByteRef; WaitTime, MaxErr: Integer);
 var
  en: Integer;
  rpe: TCmdByteRef;
  old: Byte;
begin
  en := 0;
  old := 0;
  rpe := procedure (Res: boolean; p: PByte; n: integer)
  begin
    if (en >= MaxErr) then Event(False, p, n)
    else if not Res then
     begin
      inc(en);
      old := 0;
      AsyncByte(Cmd, rpe, WaitTime)
     end
    else if (P^ = Cmd) and (Inv(old) = P^) then Event(Res, p, n)
    else
     begin
      inc(en);
      old := p^;
      AsyncByte(Cmd, rpe, WaitTime)
     end;
  end;
  AsyncByte(Cmd, rpe, WaitTime)
end;


procedure TAbstractPsk.AsyncInvN(Cmd: Byte; Event: TCmdByteRef; WaitTime, MaxErr: Integer);
 var
  en: Integer;
  rpe: TCmdByteRef;
begin
  en := 0;
  rpe := procedure (Res: boolean; p: PByte; n: integer)
  begin
    inc(en);
    if not Res and (en < MaxErr) then AsyncInv(Cmd, rpe, WaitTime)
    else Event(Res, p, n);
  end;
  AsyncInv(Cmd, rpe, WaitTime);
end;

procedure TAbstractPsk.AsyncCmdN(Cmd, Data: Byte; Event: TCmdByteRef; WaitTime, MaxErr: Integer);
begin
  with ConnectIO do AsyncCmdN(Cmd, procedure(Res: boolean; p: PByte; n: integer)
  begin
    if Res then AsyncByte(data, procedure(Res: boolean; p: PByte; n: integer)
    begin
      if (n = 1) and ((p^ = Inv(Data)) or (p^ = Data)) then Event(True, p, n)
      else Event(False, p, n);
    end, WaitTime);
  end, WaitTime, MaxErr);
end;

procedure TAbstractPsk.AsyncCmdN(WCmd, RWCmd, Data: Byte; Event: TCmdByteRef; WaitTime, MaxErr: Integer);
begin
  AsyncCmdN(WCmd, data, procedure(Res: boolean; p: PByte; n: integer)
  begin
    if Res then AsyncCmdReadDataN(RWCmd, procedure(Res: boolean; p: PByte; n: integer)
    begin
      if (n = 1) and (p^ = data) then Event(True, p, n)
      else Event(False, p, n);
    end, WaitTime, MaxErr);
  end, WaitTime, MaxErr);
end;

procedure TAbstractPsk.InitMetaData(ev: TInfoEvent);
 var
  ip: IProjectMetaData;
begin
  with FMetaDataInfo do
   begin
    if Length(ErrAdr) = 0 then Exit;
    if Length(FAddressArray) <> 1 then raise EAbstractPskException.Create(RS_ZeroLenAdrArr);
    Info := GetPSKInfo(FAddressArray[0]);
    SetLength(ErrAdr, 0);
    if not Assigned(Info) then CArray.Add<Integer>(ErrAdr, FAddressArray[0])
    else
     try
      if Supports(GlobalCore, IProjectMetaData, ip) then
       begin
        ip.SetMetaData(Self as IDevice, FAddressArray[0], FindDev(Info, FAddressArray[0]));
       end;
      Info := GetIDeviceMeta((GContainer as IALLMetaDataFactory).Get().Get(), Name);
      finally
       try
        try
         FExeMetr.SetMetr(Info, FExeMetr, True);
         (GContainer as IALLMetaDataFactory).Get().Save;
        finally
         S_Status := dsReady;
         FOldStatus := S_Status;
         if Assigned(ev) then ev(FMetaDataInfo);
        end;
       finally
        Notify('S_MetaDataInfo');
       end;
     end;
   end;
end;

function TAbstractPsk.Inv(data: Byte): Byte;
begin
  Result := $FF xor data;
end;

procedure TAbstractPsk.ScennaRun(Event: TCmdByteRef; ErrEvent: Boolean = False);
 var
  i: Integer;
  rpe: TCmdByteRef;
begin
  i := -1;
  rpe := procedure(Res: boolean; p: PByte; n: integer)
    procedure ascs(c: TRunCmd);
    begin
      case c.kind of
       ercCmdN:         AsyncCmdN2(c.Cmd.Cmd,                    rpe, c.Delay, c.MaxErr);
       ercWriteN:       AsyncCmdN(c.cmd.Cmd, c.Data,             rpe, c.Delay, c.MaxErr);
       ercWriteAndTestN:AsyncCmdN(c.cmd.Cmd, c.cmdT.Cmd, c.Data, rpe, c.Delay, c.MaxErr);
       ercReadByte:     AsyncCmdReadDataN(c.cmd.Cmd,             rpe, c.Delay, c.MaxErr);
       ercInvN:         AsyncInvN(c.Cmd.Cmd,                     rpe, c.Delay, c.MaxErr);
      end;
    end;
   var
    sd: TRunCmd;
  begin
    if Res then
     begin
      if i >= 0 then Scenna[i].Data := p^;
      Inc(i);
      if i >= Length(Scenna) then
       begin
        if Assigned(Event) then Event(True, p, n)
       end
      else
       try
        ascs(Scenna[i]);
       except
        if ErrEvent then Event(False, nil, -1);
        raise;
       end;
     end
    else
     begin
      sd := Scenna[i]; // �.�. � ������� ����� ���� ����� ������������� �����
      if ErrEvent then Event(False, nil, -1);
      if sd.kind <> ercWriteAndTestN then
         raise EAbstractPskException.CreateFmt('������ ���������� ������� 0x%x: %s', [sd.Cmd.Cmd, sd.Cmd.Str])
      else
         raise EAbstractPskException.CreateFmt('������ ���������� ������� 0x%x: %s ����� 0x%x %s',
               [sd.Cmd.Cmd, sd.Cmd.Str, sd.CmdT.Cmd, sd.CmdT.Str])
     end;
  end;
  rpe(True, nil, -1);
end;

//procedure TAbstractPsk.ReadWork(ev: TWorkEvent; StdOnly: Boolean);
//begin
//  if not Assigned(FMetaDataInfo.Info) then InitMetaData(nil);
//  if not Assigned(FMetaDataInfo.Info) then raise EAbstractPskException.CreateFmt(RS_NoMeta,[FAddressArray[0]]);
//end;

procedure TAbstractPsk.StopFlowRef(ResultEvent: TCmdByteRef);
begin
  CheckConnect;
  ScennaBegin;
  Add(USO_FLOW_OFF, Integer(20), Integer(100));
  Add(DEV_RESET, Integer(10), Integer(100));
  Add(POWER_OFF_DEV);
  Add(USO_POWER_OFF_DEV);
  ScennaRun(procedure(Res: boolean; Data: PByte; DataSize: integer)
  begin
   if Res then ResultEvent(Res, Data, DataSize)
   else
    begin
     ScennaBegin;
     Add(USO_FLOW_OFF, Integer(20), Integer(100));
     Add(USO_POWER_OFF_DEV);
     ScennaRun(ResultEvent, True);
    end;
  end, True);
end;

procedure TAbstractPsk.WaitRxData(Event: TCmdByteRef);
begin
  CheckConnect;
  ConnectIO.FTimerRxTimeOut.Enabled := True;
  ConnectIO.FEventReceiveData := procedure(Data: Pointer; DataSize: integer)
  begin
    if DataSize > 0 then Event(True, Data, DataSize)
    else Event(False, nil, -1)
  end;
end;
{$ENDREGION  TAbstractPsk}

{$REGION  'PSK - ��� ��������� � �������'}
{ TStdReadRam }

procedure TStdReadRam.Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0);
begin
  inherited ;//Execute(evInfoRead, Addrs);
  case FProtokol of
   PRO_L_STD: FExecReadRam := TProtocolReadRamStd.Create(Self);
   PRO_L_APW: FExecReadRam := TProtocolReadRamApw.Create(Self);
   PRO_H_01 or PRO_HI: FExecReadRam := TProtocolReadRam_H_1.Create(Self);
   PRO_H_02 or PRO_HI: FExecReadRam := TProtocolReadRam_H_2.Create(Self);
   else raise Exception.Create('�������� ������ ������ �� ������');
  end;
  FExecReadRam.Execute();
end;

procedure TStdReadRam.Terminate(Res: TResultEvent);
begin
  FFlagTerminate := True;
  if Assigned(FExecReadRam) then FExecReadRam.Terminate(Res);
end;

{ TReadRam_H_1 }

constructor TProtocolReadRam_H_1.Create(AStdReadRam: TStdReadRam);
begin
  FStdReadRam := AStdReadRam;
end;

procedure TProtocolReadRam_H_1.DoEndRead(Reason: EnumCopyAsyncRun; ResEv: TResultEvent; Res: Boolean);
begin
  with FStdReadRam do
   begin
    FStdReadRam.EndExecute();
    if Assigned(FReadRamEvent) then FReadRamEvent(Reason, FAdr, ProcToEnd);
//    FStdReadRam.FreeStream;
   end;
  if Assigned(ResEv) then ResEv(Res);
end;

procedure TProtocolReadRam_H_1.Execute;
begin
  with (FStdReadRam.FAbstractDevice as TAbstractPsk), FStdReadRam.FAbstractDevice.ConnectIO do
  AsyncByte(1, procedure(R: boolean; p: PByte; n: integer)
  begin
    if (n > 1) and (p^ = $FE) then
     begin
      Dec(FICount);
      if FICount>0 then move(FInput[1], FInput[0], FICount);
      WaitRxData(RamDataEvent);
     end
    else raise EReadRamStdException.Create(RS_ErrStartRam);
  end);
end;

procedure TProtocolReadRam_H_1.RamDataEvent(Res: boolean; Data: PByte; DataSize: integer);
  procedure DoSwap();
   var
    i: Integer;
  begin
    with FStdReadRam do
     begin
      for i := 0 to $2000 do PWordArray(Data)[i] := swap(PWordArray(Data)[i]);
//      FStream.Write(Data^, $4000);
      i := DataSize-$4000;
      if i > 0 then Move(PbyteArray(Data)[$4000], PbyteArray(Data)[0], i);
      FAbstractDevice.ConnectIO.FICount := i;
     end;
  end;
begin
  if FStdReadRam.FFlagTerminate then Exit;
  with TPskStd(FStdReadRam.FAbstractDevice), FStdReadRam, FStdReadRam.FAbstractDevice.ConnectIO do
   if DataSize < 0 then ReStartRam // ���������� ���������� ������
   else
    begin
     FErrCnt := 0;
     if DataSize >= $4000 then
      begin
//       CheckCreateStream();
       if FFlagSwap then DoSwap
       else
        begin
//         FStream.Write(Data^, DataSize);
         FICount := 0;
        end;
//       if (FRamSize <= FStream.Position) or TestFF(@FInput[DataSize-256], 256) then DoEndRead()
//       else
        begin
         if Assigned(FReadRamEvent) then FReadRamEvent(carOk, FAdr, ProcToEnd);
         WaitRxData(RamDataEvent);
        end;
      end
      else WaitRxData(RamDataEvent);
    end;
end;

procedure TProtocolReadRam_H_1.ReStartRam;
begin
  DoEndRead(carError);
end;

procedure TProtocolReadRam_H_1.Terminate(Res: TResultEvent);
begin
  DoEndRead(carTerminate, Res);
end;

{ TReadRam_H_2 }

procedure TProtocolReadRam_H_2.FlowCmd(pc: TPskCmd);
begin
  FStdReadRam.FAbstractDevice.ConnectIO.FICount := 0;
  with (FStdReadRam.FAbstractDevice as TAbstractPsk), FStdReadRam.FAbstractDevice.ConnectIO do
  AsyncByte(pc.Cmd, procedure(R1: boolean; p1: PByte; n1: integer)
  begin
    if (n1 = 1) and (p1^ = Inv(pc.cmd)) then AsyncByte(pc.cmd, procedure(R: boolean; p: PByte; n: integer)
    begin
      if (n > 0) and (p^ = pc.cmd) then
       begin
        Dec(FICount);
        if FICount>0 then move(FInput[1], FInput[0], FICount);
        WaitRxData(RamDataEvent);
       end
      else raise EReadRamStdException.Create(pc.Str);
    end)
    else raise EReadRamStdException.Create(pc.Str);
  end);
end;

procedure TProtocolReadRam_H_2.Execute;
begin
  FlowCmd(DEV_RAM_ON_HI_SPEED);
end;

{ TProtocolReadRamApw }

procedure TProtocolReadRamApw.Execute;
begin
  with (FStdReadRam.FAbstractDevice as TAbstractPsk) do
   begin
    ScennaBegin;
    Add(DEV_POWER_USO);
    Add(USO_FLOW_OFF);
    Add(DEV_RESET);
    ScennaRun(procedure(R: boolean; p: PByte; n: integer) // ������� �������� ������ True
    begin
      FlowCmd(DEV_RAM_ON_AP);
    end);
   end;
end;

procedure TProtocolReadRamApw.DoEndRead(Reason: EnumCopyAsyncRun; ResEv: TResultEvent; Res: Boolean);
begin
 with (FStdReadRam.FAbstractDevice as TAbstractPsk) do
  begin
   ScennaBegin;
   Add(USO_POWER_OFF_DEV, Integer(20), Integer(100));
   Add(DEV_POWER_USO);
   Add(POWER_OFF_DEV);
   Add(USO_POWER_OFF_DEV);
   ScennaRun(procedure(R: boolean; p: PByte; n: integer)
   begin
     inherited DoEndRead(Reason, ResEv, R);
   end, True);
  end;
end;

{ TProtocolReadRamStd }

procedure TProtocolReadRamStd.DoEndRead(Reason: EnumCopyAsyncRun = carEnd; ResEv: TResultEvent = nil; Res: Boolean = False);
begin
  with (FStdReadRam.FAbstractDevice as TAbstractPsk) do
  begin
   StopFlowRef(procedure(R: boolean; p: PByte; n: integer)
   begin
     inherited DoEndRead(Reason, ResEv, R);
   end);
  end;
end;

procedure TProtocolReadRamStd.Execute;
begin
 with (FStdReadRam.FAbstractDevice as TAbstractPsk) do
  begin
   ScennaBegin;
   Add(USO_FLOW_OFF);
   Add(DEV_POWER_USO);
   Add(DEV_RESET, Integer(40), Integer(100));
   Add(DEV_RAM_ON);
   Add(USO_FLOW_ON);
   ScennaRun(procedure(R: boolean; p: PByte; n: integer) // ������� �������� ������ True
   begin
     AsyncByte(DEV_START_INFO.Cmd, RamDataEvent, FStdReadRam.FFlowDataWait);
   end);
  end;
end;

procedure TProtocolReadRamStd.ReStartRam;
begin
  inc(FErrCnt);
  with FStdReadRam, (FStdReadRam.FAbstractDevice as TAbstractPsk) do if FErrCnt > MAX_ERR then DoEndRead(carError)
  else
   begin
   // FReadRamEvent(eirReadErrSector, Fadr, ProcToEnd);
    AsyncByte(DEV_START_INFO.Cmd, RamDataEvent, FFlowDataWait, False);
   end;
end;

{ TPskStd }

//function TPskStd.GetReadDeviceRam: IReadRamDevice;
//begin
//  if FFlagFlow then raise EPskStdException.Create(RS_StopFlow);
//  Result := TStdReadRam.Create(Self);
//end;

function TPskStd.IsFlow: Boolean;
begin
  Result := FFlagFlow;
end;

procedure TPskStd.StopFlow(ResultEvent: TResultEvent);
begin
  StopFlowRef(procedure(Res: boolean; p: PByte; n: integer)
  begin
   FFlagFlow := False;
   if Assigned(FActData) then  FActData.Checked := False;
   FFlagFlow := False;
   S_Status := FOldStatus;
   ConnectUnlock;
   ConnectClose;
   if Assigned(ResultEvent) then ResultEvent(Res);
  end);
end;

procedure TPskStd.SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
 var
  d: IXMLNode;
 procedure AddWorkTime;
 const
  T_9 = 9.5/24;
  T_19 = 19/24;
  T_38 = 38/24;
  T_57 = 57/24;
  T_76 = 76/24;
 begin
   if not (d.HasAttribute(AT_WORKTIME) and  (d.Attributes[AT_WORKTIME] = 1)) then
    begin
     WorkTime := 0;
     Exit;
    end;
   if WorkTime = 0 then Exit
   else if WorkTime < (T_9 + (T_19-T_9)/2) then
    begin
     Add(DEV_WORK_TIME_9);
     WorkTime := T_9;
    end
   else if WorkTime < (T_19 + (T_38-T_19)/2) then
    begin
     WorkTime := T_19;
     Exit
    end
   else if WorkTime < (T_38 + (T_57-T_38)/2) then
    begin
     WorkTime := T_38;
     Add(DEV_WORK_TIME_38)
    end
   else if WorkTime < (T_57 + (T_76-T_57)/2) then
    begin
     WorkTime := T_57;
     Add(DEV_WORK_TIME_57)
    end
   else
    begin
     WorkTime := T_76;
     Add(DEV_WORK_TIME_76)
    end;
 end;
 var
  UsoTime: Word;
  Kdevide: Integer;
  IsOldClose: Boolean;
  Delay: TTime;
begin
  Delay := Now - StartTime;
  try
   CheckStatus([dsReady]);
   CheckConnect;
   CheckLocked;
  except
   DoDelayEvent(false, StartTime, Delay, WorkTime, ResultEvent);
   raise;
  end;
  try
   IsOldClose := not ConnectOpen();
   ConnectLock;
   S_Status := dsDelay;

   d := FindDev(FMetaDataInfo.Info, FAddressArray[0]);
   if not Assigned(d) then raise EPskStdException.CreateFmt('���������� ������� %d ���������',[FAddressArray[0]]);
   ScennaBegin();
   Add(DEV_POWER_USO);
   Add(USO_FLOW_OFF);
   Add(DEV_RESET, Integer(40), Integer(100));
   Add(DEV_WRITE_DELAY);
   if d.HasAttribute(AT_DELAYDV) then Kdevide := d.Attributes[AT_DELAYDV]
   else Kdevide := 128;
   Add(USO_WRITE_DELAY_DEV, DEV_READ_DELAY, GetDevAndUsoTime(Delay, UsoTime, Kdevide));
   AddWorkTime();
 //  Add(USO_WRITE_HDELAY, USO_READ_HDELAY, Byte(UsoTime shr 8));
 //  Add(USO_WRITE_LDELAY, USO_READ_LDELAY, Byte(UsoTime));
   Add(DEV_CLEAR);
   Add(DEV_START_DELAY, 500, 600);
 //  Add(USO_START_DELAY);
   Add(USO_POWER_OFF_DEV);
   ScennaRun(procedure(Res: boolean; Data: PByte; DataSize: integer)
   begin
    DoDelayEventHelper(res, IsOldClose, Delay, WorkTime, ResultEvent);
   end, True);
  except
   DoDelayEventHelper(false, IsOldClose, Delay, WorkTime, ResultEvent);
   raise;
  end;
end;

procedure TPskStd.ReadWork(ev: TWorkEvent; StdOnly: Boolean);
begin
  if FFlagFlow then Exit;
//  ChLockLockOpen(FFlagFlow, EPskStdException);

  FWorkEventInfo.Work := FindWork(FMetaDataInfo.Info, FAddressArray[0]);
//  TDebug.Log(FWorkEventInfo.Work.OwnerDocument.FileName);

//  FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'IND.xml');

  if not Assigned(FWorkEventInfo.Work) then raise EPskStdException.Create(RS_NoMetaInfo);
  if FWorkEventInfo.Work.HasAttribute(AT_FLOWINTERVAL) then FFlowDataWait := FWorkEventInfo.Work.Attributes[AT_FLOWINTERVAL]
  else FFlowDataWait := 1200;
  FWorkLen := Integer(FWorkEventInfo.Work.Attributes[AT_SIZE]);
  if FWorkEventInfo.Work.HasAttribute(AT_SP_HI) then FSpHi := FWorkEventInfo.Work.Attributes[AT_SP_HI];
  FWorkEvent := ev;
  ScennaBegin();
  Add(USO_FLOW_OFF);
  Add(DEV_POWER_USO);
  Add(DEV_RESET, Integer(40), Integer(100));
  Add(DEV_INFO_ON);
  Add(USO_FLOW_ON);
  ScennaRun(procedure(Res: boolean; Data: PByte; DataSize: integer) // ������� �������� ������ True
   var
    ErrRes: TWorkEventRes;
  begin
    if Res then
     begin
      FFlagFlow := True;
      ReStartFlow;
     end
    else
     begin
      if Assigned(FActData) then FActData.Checked := False;
      S_Status := FOldStatus;
      ConnectUnlock;
      ConnectClose;
      if Assigned(FWorkEvent) then
       begin
        ErrRes.DevAdr := FAddressArray[0];
        ErrRes.Work := nil;
  //      UnLockClose(FFlagFlow);
        FWorkEvent(ErrRes);
       end;
     end;
  end, True);
end;
procedure TPskStd.ReStartFlow;
begin
  AsyncByte(DEV_START_INFO.Cmd, FlowDataEvent, FFlowDataWait, False);
end;

procedure TPskStd.BeforeRemove;
begin
  FActData := nil;
  inherited;
end;

function TPskStd.CreateReadRam: TReadRam;
begin
  Result := TStdReadRam.Create(Self);
end;

procedure TPskStd.DoData(Sender: IAction);
// var
//  ix: IProjectDataFile;
begin
//  if Supports(GlobalCore, IProjectDBData, pdb) then pdb.CommitTrans;
  if FFlagFlow then
   begin
    StopFlowRef(procedure(Res: boolean; p: PByte; n: integer)
     procedure DeleteAct;
     begin
      FActData := nil; //???? ����� ������� ������ ,,,
     end;
    begin
      if Assigned(FActData) then FActData.Checked := False;
      DeleteAct;
      FFlagFlow := False;
      S_Status := FOldStatus;
      ConnectUnlock;
      ConnectClose;
      EndInfo;
    end);
   end
  else
   begin
    CheckStatus([dsPartReady, dsReady]);
    FOldStatus := S_Status;
    CheckConnect;
    CheckLocked;
    FActData := Sender; { TODO : ���� ������ � ��������� psk �������� ����� ������ �������� �������}
    try
     S_Status := dsData;
     ConnectLock;
     ConnectOpen();
     ReadWork(nil);
     FActData.Checked := True;
    except
     FActData.Checked := False;
     S_Status := FOldStatus;
     ConnectUnlock;
     ConnectClose;
     raise;
    end;
   end;
end;

procedure TPskStd.DoIdle(Sender: IAction);
begin
  CheckConnect;
  CheckLocked;
  try
   ConnectLock;
   ConnectOpen();
   StopFlowRef(procedure(Res: boolean; p: PByte; n: integer)
   begin
     FFlagFlow := False;
     S_Status := FOldStatus;
     ConnectUnlock;
     ConnectClose;
     if Assigned(FActData) then FActData.Checked := False;
   end);
  except
   S_Status := FOldStatus;
   ConnectUnlock;
   ConnectClose;
   if Assigned(FActData) then FActData.Checked := False;
   raise;
  end;
end;

procedure TPskStd.DoDelay(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetDeviceDelay>(d) then (d as IDialog<IDelayDevice>).Execute(Self as IDelayDevice);
end;

procedure TPskStd.DoSync(Sender: IAction);
 var
  d: Idialog;
  dv: IDevice;
begin
  if RegisterDialog.TryGet<Dialog_SyncDelay>(d) then
   begin
    dv := Self as IDevice;
    (d as IDialog<IDevice>).Execute(dv);
   end;
end;

procedure TPskStd.FlowDataEvent(Res: boolean; DataB: PByte; DataSize: integer);
  function TestSP(Data: PWordArray; cnt: integer): Boolean;
   var
    ww: Integer;
  begin
    Result := False;
    ww := FWorkLen div 2;
    if FSpHi = 0 then
     begin
      if (Data[0] = 0) and (FWorkLen <= cnt) and (FcheckSP or ((FWorkLen+2 <= cnt) and (Data[ww] = 0))) then
       begin
        Result := True;
        FcheckSP := True;
       end;
      //if (Data[0] = 0) and (FWorkLen <= cnt) then Result := True;
     end
    else if {(FWorkLen+2+2+2 <= cnt)
         and} (Data[0] = Word(FSpHi shl 8))
         and ((Data[1] and $FF00) = $C000)
         and ((Data[2] and $FF00) = $C000)
         {and (Data[ww] = Word(FSpHi shl 8))
         and ((Data[ww+1] and $FF00) = $C000)
         and ((Data[ww+2] and $FF00) = $C000)} then Result := True
  end;
 var
  i: Integer;
  ip: IProjectData;
  ix: IProjectDataFile;
  cio: TAbstractConnectIO;
begin
  cio := ConnectIO;
  if not FFlagFlow then Exit;
  if DataSize < 0 then
   begin
    ReStartFlow; // ���������� ���������� ������
    with cio do
     begin
      if FICount > FWorkLen*8 then
       begin
        FICount := 0;
        FcheckSP := False;
      //  TDebug.Log('-1 FICount > FWorkLen*8==========   FICount:%d   FWorkLen:%d =============',[cio.FICount, FWorkLen]);
       end;
      // TDebug.Log('-1 ==========   FICount:%d   FWorkLen:%d =============',[cio.FICount, FWorkLen]);
     end;
   end
  else
   try
      i := 0;
      while (i < cio.FICount) and (cio.FICount >= FWorkLen) do if TestSP(@cio.FInput[i], cio.FICount-i) then
     // if (DataSize >= FWorkLen) and TestSP(@DataB[0], DataSize) then  // ����� �������
       begin
        with cio do
         begin
          Move(FInput[i], FWorkInput[0], FWorkLen);
          Dec(FICount, FWorkLen+i);// cio.FICount >= FWorkLen*2 !!!!
          Move(FInput[FWorkLen+i], FInput[0], FICount);
       //   TDebug.Log('SP========i:%d   FICount:%d   FWorkLen:%d =============',[i, FICount, FWorkLen]);
          i := 0;
         end;
        TPars.SetPsk(FWorkEventInfo.Work, @FWorkInput[0]);
        TDebug.Log(FWorkEventInfo.Work.OwnerDocument.FileName);

        FWorkEventInfo.DevAdr := FAddressArray[0];
        try
         FExeMetr.Execute(T_WRK);
         TPars.SetPskToStd(FWorkEventInfo.Work, @FWorkInput[0]);
         if Supports(GlobalCore, IProjectData, ip) then ip.SaveLogData(Self as IDevice, FWorkEventInfo.DevAdr, FWorkEventInfo.Work, False)
         else if Supports(GlobalCore, IProjectDataFile, ix) then
                    ix.SaveLogData(Self as IDevice, FWorkEventInfo.DevAdr, FWorkEventInfo.Work, @FWorkInput[0], FWorkLen);
          //
        finally
         if Assigned(FWorkEvent) then FWorkEvent(FWorkEventInfo);
         Notify('S_WorkEventInfo');
        end;
       end
       else
         begin
          Inc(i);
        //  TDebug.Log('==========i:%d   FICount:%d   FWorkLen:%d =============',[i, cio.FICount, FWorkLen]);
         end;
   finally
    WaitRxData(FlowDataEvent);
   end;
end;
{$ENDREGION  PSK}

{$REGION  'TGlu - ��� ��������� � �������'}
{ TGluReadRam }
//procedure TGluReadRam.FreeStream;
//begin
//  inherited;
//  if Assigned(FStreamGlm) then FreeAndNil(FStreamGlm);
//end;
//
//procedure TGluReadRam.CheckCreateStream;
//begin
//  inherited;
//  if not Assigned(FStreamGlm) then
//   begin
//    FStreamGlm := TFileStream.Create(ExtractFilePath(ParamStr(0)) + FRamXml.ParentNode.NodeName+'.glm', fmOpenWrite or fmCreate);
//    FStreamGlm.Position := 0;
//   end;
//end;

procedure TGluReadRam.StartReadPage(ev: TCmdByteRef);
begin
  with (FAbstractDevice as TAbstractPsk), FAbstractDevice.ConnectIO do AsyncByte(RP_READ_PAGE.Cmd, procedure(R: boolean; p: PByte; n: integer)
  begin
    if (n = 1) and (p^ = Inv(RP_READ_PAGE.Cmd)) then AsyncByte(RP_READ_PAGE.Cmd, ev)
    else ev(False, nil, -1);
  end);
end;

procedure TGluReadRam.Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean;FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0);
 var
  en, pg, FFSize: Integer;
  run: TCmdByteRef;
begin
//  if TGlu(FAbstractDevice).Cycle.GetCycle then raise EReadRamGluException.Create(RS_Cycle);
  inherited ;//Execute(evInfoRead, Addrs);
  if FProtokol <> PRO_L_GLU then raise EReadRamGluException.CreateFmt('�������� %d �� ����������� %d', [FProtokol, PRO_L_GLU]);
  en := -1;
  pg := 0;
  run := procedure(Res: boolean; p: PByte; n: integer)
    procedure SetPage;
    begin
      if en > 0 then if Assigned(FReadRamEvent) then FReadRamEvent(carErrorSector, Fadr, ProcToEnd);
      with FAbstractDevice as TAbstractPsk do
       begin
        ScennaBegin;
        Add(RP_PAGE_L);
        AddD(RP_WRITE, Byte(pg));
        Add(RP_PAGE_H);
        AddD(RP_WRITE, Byte(pg shr 8));
        ScennaRun(procedure (Rs: boolean; pg: PByte; nd: integer)
        begin
          if Rs then StartReadPage(run)
          else run(False, nil, -1);
        end, True);
       end;
    end;
    procedure DoEndRead(Reason: EnumCopyAsyncRun);
    begin
      FFlagEndRead := True;
      FEndReason := Reason;
      //FEvent.SetEvent;
    end;
    procedure ToFifo(n: Integer);
     var
      l: Integer;
    begin
      l :=  Length(Fifo);
      SetLength(fifo,l+n);
      move(FAbstractDevice.ConnectIO.FInput[1], fifo[l], n);
     // fifo.Push(@FAbstractDevice.ConnectIO.FInput[1], n);
      Inc(FCurAdr, n);
      //FEvent.SetEvent;
    end;
{    procedure DoSwapData(a: PWord);
     var
      i: Integer;
      d: Word;
    begin
      for i := 0 to 36 do
       begin
        d := PWordArray(a)[3];
        PWordArray(a)[3] := PWordArray(a)[6];
        PWordArray(a)[6] := d;
        Inc(a, 7);
       end;
    end;}
  begin
    if FFlagTerminate then
     begin
//      FreeStream;
      EndExecute();
      if Assigned(FReadRamEvent) then FReadRamEvent(carTerminate, Fadr, ProcToEnd);
      Exit;
     end;
    if n<0 then
     begin
      Inc(en);
      if en >= 5 then DoEndRead(carError)
      else SetPage();
     end
    else with FAbstractDevice.ConnectIO do
     if n = 531 then
      begin
       if CalcCRC16(@FInput[1], 530) = 0 then
        begin
//         CheckCreateStream();
//         FStream.Write(FInput[1], 518);
//         DoSwapData(@FInput[1]);
//         FStreamGlm.Write(FInput[1], 528);
         if (FCurAdr >= FToAdr) then
          begin
           ToFifo(518);
           DoEndRead(carEnd)
          end
         else if TestFF(@FInput[1], 518) then
          begin
           FFSize := 518;
           while (FFSize > 1) and (FInput[FFSize] = $FF) do Dec(FFSize);
           ToFifo(FFSize);
           DoEndRead(carEnd);
          end
         else
          begin
           ToFifo(518);
           en := 0;
           if Assigned(FReadRamEvent) then FReadRamEvent(carOk, FAdr, ProcToEnd);
           Inc(pg);
           StartReadPage(run);
          end;
         end
       else SetPage();
      end
     else (FAbstractDevice as TAbstractPsk).WaitRxData(run);
  end;
  run(False, nil, -1);
end;

function TGluReadRam.GetFilters: string;
begin
  Result := '���� ������ ����������� (*.glm)|*.glm';
end;


procedure TGluReadRam.Import(const FileName: string; FilterIndex: Integer;
                      FromKadr, ToKadr: Integer; ReadToFF: Boolean;
                      Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer);
 var
  s: TFileStream;
  cnt: Longint;
  b: array [0..528] of Byte;
  procedure ToFifo(n: Longint);
     var
      l: Integer;
    begin
      l :=  Length(Fifo);
      SetLength(fifo,l+n);
      move(b[0], fifo[l], n);
  //  fifo.Push(@b[0], n);
    Inc(FCurAdr, n);
    //FEvent.SetEvent;
  end;
begin
  inherited Execute('', FromKadr, ToKadr, ReadToFF,0, Adr, evInfoRead, ModulID);
  s := TFileStream.Create(FileName, fmOpenRead);
  try
   FToAdr := s.Size;
   repeat
    cnt := s.Read(b[0], 528);
    if cnt > 0 then
     if cnt = 528 then ToFifo(518)
     else ToFifo(cnt);
   until cnt <= 0;
  finally
   s.Free;
  end;
  FCurAdr := FToAdr;
  FEndReason := carEnd;
  FFlagEndRead := True;
  //FEvent.SetEvent;
end;

{ TGlu }

function TGlu.GCreateReadRam: TGluReadRam;
begin
  Result := TGluReadRam.Create(Self);
end;

procedure TGlu.DoData(Sender: IAction);
begin
  Sender.Checked := not Sender.Checked;
  (Self as ICycle).Cycle := Sender.Checked;
end;

procedure TGlu.DoDelay(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetDeviceDelay>(d) then (d as IDialog<IDelayDevice>).Execute(Self as IDelayDevice);
end;

procedure TGlu.DoMetr(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_GlubionmerTRR>(d) then (d as IDialog<IDevice>).Execute(Self as IDevice);
end;

procedure TGlu.DoSync(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SyncDelay>(d) then (d as IDialog<IDevice>).Execute(Self as IDevice);
end;

procedure TGlu.ReadWork(ev: TWorkEvent; StdOnly: Boolean);
 var
 // w: IXMLInfo;
  evn: TCmdByteRef;
begin
  CheckConnect;
  ConnectOpen;
  FWorkEventInfo.Work := FindWork(FMetaDataInfo.Info, FAddressArray[0]);
  if not Assigned(FWorkEventInfo.Work) then raise ECluException.Create('���������� �� ���������� �� �� �������');
  evn := procedure(R: boolean; p: PByte; n: integer)
  begin
    if not R then raise ECluException.Create('��� ������ �� ��')
    else
     if CalcCRC16(p, n) = 0 then
      begin
       TPars.SetData(FWorkEventInfo.Work, p);
       FWorkEventInfo.DevAdr := FAddressArray[0];
       try
        FExeMetr.Execute(T_WRK);
       finally
        if Assigned(ev) then ev(FWorkEventInfo);
        Notify('S_WorkEventInfo');
       end;
      end
     else WaitRxData(evn) // ����������� ����� evn() ���� ���� ������
  end;
  with ConnectIO do AsyncByte(RP_READ_INFO.Cmd, procedure(R: boolean; p: PByte; n: integer)
  begin
    if (n = 1) and (p^ = Inv(RP_READ_INFO.Cmd)) then AsyncByte(RP_READ_INFO.Cmd, procedure(Rs: boolean; pb: PByte; nn: integer)
    begin
      if (nn > 0) and (pb^ = RP_READ_INFO.Cmd) then
       begin
        Dec(FICount);
        if FICount>0 then move(FInput[1], FInput[0], FICount);
        evn(True, @FInput[0], FICount);
       end
      else raise ECluException.Create('������ ���������� �������: ' + RP_READ_INFO.Str);
    end)
    else raise ECluException.Create('������ ���������� �������: ' + RP_READ_INFO.Str);
  end);
end;

procedure TGlu.SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
  function GetGluTime(): LongWord;
   const
    TO_GLU = 1/(2.097152/2);
    TO_SEC = 24*60*60;
  begin
//    Result := Round(Delay*TO_SEC*TO_GLU);
//    Delay := Result/TO_GLU/TO_SEC;
  end;
 var
  GluTime: LongWord;
  IsOldClose: Boolean;
  Delay, RDelay : TTime;
begin
   Delay := Now - StartTime;
   { TODO : find RDelay }
  try
   CheckStatus([dsReady]);
   CheckConnect;
   CheckLocked;
  except
   DoDelayEvent(false, StartTime, Delay, WorkTime, ResultEvent);
   raise;
  end;
  try
   IsOldClose := not ConnectOpen();
   ConnectLock;
   S_Status := dsDelay;

   GluTime := GetGluTime(); { TODO : find }
   ScennaBegin;
   Add(RP_DELAY_H);
   Add(RP_WRITE, RP_READ_DELAY_H, Byte(GluTime shr 16));
   Add(RP_DELAY_M);
   Add(RP_WRITE, RP_READ_DELAY_M, Byte(GluTime shr 8));
   Add(RP_DELAY_L);
   Add(RP_WRITE, RP_READ_DELAY_L, Byte(GluTime));
   Add(RP_START_DELAY);
   ScennaRun(procedure(Res: boolean; Data: PByte; DataSize: integer)
   begin
     if Res then
      begin
       ScennaBegin;
       AddR(RP_READ_DELAY_L, 500, 600);
       ScennaRun(procedure(Rs: boolean; p: PByte; n: integer)
       begin
         DoDelayEventHelper(rs, IsOldClose, StartTime, 0, ResultEvent);
       end, True);
     end
    else DoDelayEventHelper(false, IsOldClose, StartTime, 0, ResultEvent);
   end, True);
  except
   DoDelayEventHelper(false, IsOldClose, StartTime, 0, ResultEvent);
   raise;
  end;
end;
{$ENDREGION  TGlu}

{$REGION  'TUso - ��� ��������� � �������'}
{ TUso }

procedure TUso.DoData(Sender: IAction);
begin
  Sender.Checked := not Sender.Checked;
  (Self as ICycle).Cycle := Sender.Checked;
end;

procedure TUso.DoDelay(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetDeviceDelay>(d) then (d as IDialog<IDelayDevice>).Execute(Self as IDelayDevice);
end;

procedure TUso.ReadWork(ev: TWorkEvent; StdOnly: Boolean);
begin
  CheckConnect;
  ConnectOpen;
  FWorkEventInfo.Work := FindWork(FMetaDataInfo.Info, FAddressArray[0]);
  if not Assigned(FWorkEventInfo.Work) then raise EUsoException.Create('���������� �� ���������� ��� �� �������');
  ScennaBegin;
  AddR(USO_READ_HDELAY);
  AddR(USO_READ_LDELAY);
  AddR(USO_LUP);
  AddR(USO_HUP);
  AddR(USO_LDOWN);
  AddR(USO_HDOWN);
  AddR(USO_LNAGR);
  AddR(USO_HNAGR);
  ScennaRun(procedure(Res: boolean; p: PByte; n: integer) // ������� �������� ������ True
   var
    d: array[0..3]of Word;
  begin
    d[0] := Scenna[0].Data shl 8 or Scenna[1].Data; // ����
    d[1] := Scenna[3].Data shl 8 or Scenna[2].Data; // �����
    d[2] := Scenna[5].Data shl 8 or Scenna[4].Data; // �����
    d[3] := Scenna[7].Data shl 8 or Scenna[6].Data; // nagr
    TPars.SetPsk(FWorkEventInfo.Work, @d[0]);
    FWorkEventInfo.DevAdr := FAddressArray[0];
    try
     FExeMetr.Execute(T_WRK);
    finally
     if Assigned(ev) then ev(FWorkEventInfo);
     Notify('S_WorkEventInfo');
    end;
  end);
end;

procedure TUso.SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
 var
  UsoTime: Word;
  IsOldClose: Boolean;
  Delay: TTime;
begin
  Delay := StartTime - Now;
  try
   CheckStatus([dsReady]);
   CheckConnect;
   CheckLocked;
  except
   DoDelayEvent(false, StartTime, Delay, WorkTime, ResultEvent);
   raise;
  end;
  try
   IsOldClose := not ConnectOpen();
   ConnectLock;
   S_Status := dsDelay;

   GetDevAndUsoTime(Delay, UsoTime, 128);
   ScennaBegin;
   Add(USO_FLOW_OFF);
   AddD(USO_WRITE_HDELAY, Byte(UsoTime shr 8));
   AddD(USO_WRITE_LDELAY, Byte(UsoTime));
   Add(USO_START_DELAY);
   ScennaRun(procedure(Res: boolean; p: PByte; n: integer)
   begin
     DoDelayEventHelper(res, IsOldClose, Delay, 0, ResultEvent);
   end, True);
  except
   DoDelayEventHelper(false, IsOldClose, Delay, 0, ResultEvent);
   raise;
  end;
end;
{$ENDREGION  TGlu}

{ TPskCycle }

constructor TPskCycle.Create();
begin
  inherited;
  FCycle := TCycle.Create(Self);
end;

destructor TPskCycle.Destroy;
begin
  FCycle.Free;
  inherited;
end;

initialization
  RegisterClass(TPskStd);
  RegisterClass(TGlu);
  RegisterClass(TUso);
  TRegister.AddType<TPskStd, IDevice>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TGlu, IDevice>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TUso, IDevice>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TPskStd>;
  GContainer.RemoveModel<TGlu>;
  GContainer.RemoveModel<TUso>;
end.
