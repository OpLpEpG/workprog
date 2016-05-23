unit DevBur;

interface

uses    System.IOUtils,
  Winapi.Windows, System.SysUtils, System.Classes, CPort, CRC16, Vcl.ExtCtrls, System.Variants, Xml.XMLIntf, Xml.XMLDoc,
  Generics.Collections,  Vcl.Forms, Vcl.Dialogs,Vcl.Controls, Actns,
  DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl;


  const
    LEN_MAX_SHORT = 251; //не 252 из-за фая вая
 type
  EReadRamBurException = class(EReadRamException);
    EAsyncReadRamBurException = class(EAsyncReadRamException);
  TBurReadRam = class(TReadRam)
  public
   const
    MAX_RAM = $420000;
    MAX_BAD = 70;
    RLEN =  $7FF-3;// $7FFFF-3;
    WAIT_RLEN = 2000;
  private
    type TResRef = reference to procedure;
    procedure Read(RamPtr: Integer; len: DWord;  ev: TReceiveDataRef; WaitTime: Integer = -1);
  protected
    procedure Execute(const binFile: string; FromTime, ToTime: TDateTime; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0); override;
  end;

//  ERamReadInfoBurException = class(ERamReadInfoException);
//    EAsyncRamReadInfoBurException = class(EAsyncRamReadInfoException);
//  TRamReadInfoBur = class(TRamReadInfo)
//  protected
//    procedure Get_Tstart_Tdelay(RAMInfo: IRAMInfo; var tstart: TDateTime; var tdelay: TDateTime);
//    function Update(Info: IXMLInfo; UpdateTimeSyncEvent: TRamEvent = nil): IRAMInfo; override;
//  end;

  TNotifyInfoEventRef = reference to procedure (Exception: Integer; Adr: Integer; Data: PByte; n: Integer);
  TWorkEventRef = reference to procedure (DevAdr: Integer; Work: IXMLInfo; Data: PByte; n: Integer);

  EBurException = class(EDeviceException);
   EAsyncBurException = class(EAsyncDeviceException);

  TDeviceBur = class(TAbstractDevice, IDevice, ILowLevelDeviceIO, IDataDevice,
                     IDelayDevice, ITurbo, ICycle, ICycleEx, IReadRamDevice, IEepromDevice, IGetActions)
  private
    Ftimer: TTimer;

    FTmpSender: IAction;
    FCycle: TCycleEx;
    FGetActions: TGetActionsImpl;

    procedure OnTimer(Sender: TObject);

    function GetSerialQe: TProtocolBur;
    procedure InfoEvent(Res: TInfoEventRes);
    procedure ReadEepromAdrRef(root: IXMLNode; adr: Byte; ev: TEepromEventRef);
//    procedure InfoEvent2(Res: TInfoEventRes);
  protected
    // ILowLevelDeviceIO
    procedure SendROW(Data: Pointer; Cnt: Integer; Event: TReceiveDataRef = nil; WaitTime: Integer = -1); override;
    // ITurbo
    procedure Turbo(speed: integer);

    procedure ReadInfoAdr(adr: Byte; ev: TNotifyInfoEventRef);
    procedure ReadWorkAdrRef(root: IXMLNode; adr: Byte; StdOnly: Boolean; ev: TWorkEventRef);

//    function GetActionsDevClass: TAbstractActionsDevClass; override;
//    function GetReadRamClass: TReadRamClass; override;
    function CreateReadRam: TReadRam; override;
    property ReadRam: TReadRam read PropertyReadRam implements IReadRamDevice;
    property GetActions: TGetActionsImpl read FGetActions implements IGetActions;
  public
    constructor Create(); override;
    constructor CreateWithAddr(const AddressArray: TAddressArray; const DeviceName: string); override;
    destructor Destroy; override;
    procedure InitMetaData(ev: TInfoEvent);
    procedure ReadWork(ev: TWorkEvent; StdOnly: Boolean = false);
    procedure ReadEeprom(ev: TEepromEventRef);
    procedure WriteEeprom(Addr: Integer; ev: TResultEventRef);
    procedure SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
    procedure CheckConnect(); override;
    procedure ReadWorkRef(Info: IXMLNode; ev: TWorkEventRef; StdOnly: Boolean);
//    function GetReadDeviceRam(): IReadRamDevice; override;
//    function GetRamReadInfo(): IRamReadInfo; override;
    property SerialQe: TProtocolBur read GetSerialQe;
    property Cycle: TCycleEx read FCycle implements  ICycle, ICycleEx;
// actions
    //Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
    [DynamicAction('<I> Задержка...', '<I>', 142, '0:Управление|3.<I>:-1', 'Окно постановки на задержку')]
    procedure DoDelay(Sender: IAction);
    [DynamicAction('<I> Коррекция часов...', '<I>', Dialog_SyncDelay_ICON, '0:Управление|3.<I>', 'Окно коррекции часов модулей. Вызывается перед чтением памяти,в режиме информации.')]
    procedure DoSync(Sender: IAction);
    [DynamicAction('<I> Информация', '<I>', 52, '0:Управление|3.<I>;2:', 'Выход/Вход в режим чтения информации')]
    procedure DoData(Sender: IAction);
//    procedure DoInfo(Sender: IAction);
    [DynamicAction('(только время)', '<I>', 69, '0:Управление|3.<I>.Дополнительно|0',
    'Пониженное энергопотребление прибора режимне информации, получение только времени и состояния прибора')]
    procedure DoStd(Sender: IAction);
    [DynamicAction('Выключить прибор', '<I>', 71, '0:Управление|3.<I>.Дополнительно|0', 'Перевести приборы в спящий режим')]
    procedure DoIdle(Sender: IAction);
  published
    property CyclePeriod;
  end;

implementation

uses tools, Parser;

resourcestring
  RS_ErrReadData = 'Ошибка чтения данных устройства с адресом: %d SZ=%d[%d] CA=0x%x';
  RS_ErrNoInfo = 'Не инициализирована информация об устройствах';

type
  PStdRead = ^TStdRead;
  TStdRead = packed record
    CmdAdr: Byte;
    ln: Byte;
    constructor Create(addr, command, ReadLength: Byte);
  end;
  PStdReadLong = ^TStdReadLong;
  TStdReadLong = packed record
    CmdAdr: Byte;
    ln: Word;
    constructor Create(addr, command, ReadLength: Word);
  end;
  TAdvStdRead = packed record
    CmdAdr: Byte;
    ln: Byte;
    from: Word;
    constructor Create(addr, command, ReadLength: Byte; ReadFrom: Word);
  end;

  TEepRead = packed record
    CmdAdr: Byte;
    From: Word;
    len: Byte;
    constructor Create(addr: Byte; AFrom: Word; ReadLength: Byte);
  end;

  TEepWrite = packed record
    CmdAdr: Byte;
    From: Word;
    Data: array[0..255] of Byte;
    constructor Create(addr: Byte; AFrom: Word; const AData: array of byte);
  end;

{ TEepWrite }

constructor TEepWrite.Create(addr: Byte; AFrom: Word; const AData: array of byte);
begin
  CmdAdr := ToAdrCmd(addr, CMD_WRITE_EE);
  From := AFrom;
  if Length(AData) > Length(Data) then EBurException.Create('длинна данных EEPROM больще 255');
  Move(AData, Data, Length(AData));
end;

{ TEepRead }

constructor TEepRead.Create(addr: Byte; AFrom: Word; ReadLength: Byte);
begin
  CmdAdr := ToAdrCmd(addr, CMD_READ_EE);
  From := AFrom;
  len := ReadLength;
end;

{ TStdRead }

constructor TStdRead.Create(addr, command, ReadLength: Byte);
begin
  CmdAdr := ToAdrCmd(addr, command);
  ln := ReadLength;
end;

{ TStdReadLong }

constructor TStdReadLong.Create(addr, command, ReadLength: Word);
begin
  CmdAdr := ToAdrCmd(addr, command);
  ln := ReadLength;
end;


{ TAdvStdRead }

constructor TAdvStdRead.Create(addr, command, ReadLength: Byte; ReadFrom: Word);
begin
  CmdAdr := ToAdrCmd(addr, command);
  ln := ReadLength;
  from := ReadFrom;
end;



type
  PRamRead =^TRamRead;
  TRamRead = packed record
    CmdAdr: Byte;
    Adr: DWORD;
//    Len: DWORD;
//    PH, P6LB2H, BL: Byte;
    Length: DWord;
    constructor Create(DevAdr: Byte; RmAdr, len: DWord);
  end;

{ TRamRead }

constructor TRamRead.Create(DevAdr: Byte; RmAdr, len: DWord);
// var
//  page, base: Word;
begin
  CmdAdr := ToAdrCmd(DevAdr, CMD_READ_RAM);
//  page := RmAdr div 528;
//  base := RmAdr mod 528;
//  PH := Byte(page shr 6);
//  BL := Byte(base);
//  P6LB2H := Byte(page shl 2) or Byte(base shr 8);
  Length := len;
  Adr := RmAdr;
end;

{$REGION  'TBurReadRam - все процедуры и функции'}
{ TBurReadRam }
//Чтение одной секции данных по адресу RamPtr
procedure TBurReadRam.Read(RamPtr: Integer; len: DWord;  ev: TReceiveDataRef; WaitTime: Integer = -1);
begin
//  if FFlagTerminate then Exit;
  with TDeviceBur(FAbstractDevice) do
   try
    SerialQe.Add(procedure()
     var
      a: TRamRead;
    begin
     // if FFlagTerminate then Exit;
      a := TRamRead.Create(FAdr, DWord(RamPtr), len);
      ConnectIO.Send(@a, SizeOf(a), procedure(p: Pointer; n: integer)
      begin
        if FFlagTerminate then ev(nil, -1)
        else if ((len + 1) = n) and (PbyteArray(p)[0] = a.CmdAdr) then ev(@PbyteArray(p)[1], n-1)
        else ev(nil, -1);
      end, WaitTime);
    end);
   except
    on E: Exception do
     begin
      TDebug.DoException(E, False);
//      ev(nil, -1);
     end;
   end;
end;

procedure TBurReadRam.Execute(const binFile: string; FromTime, ToTime: TDateTime; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0);
   var
    FuncRead: TReceiveDataRef;
    ErrCnt: Integer;
    Wait: Integer;
    FFileStream: TFileStream;
//    t: Integer;
begin
  inherited ;//Execute(evInfoRead, Addrs);
  if FPacketLen = 0 then FPacketLen := RLEN;

  if FFastSpeed > 0 then
   begin
    TDeviceBur(FAbstractDevice).Turbo(FFastSpeed);
    Sleep(100);
    Wait := 2000;
   end
  else Wait := WAIT_RLEN;

  if FPacketLen > 0 then Wait := -1;


  FCurAdr := FFromAdr;
  ErrCnt := 0;

  if binFile <> '' then
   begin
    if TFile.Exists(binFile) then TFile.Delete(binFile);
    FFileStream := TFileStream.Create(binFile, fmCreate);
   end;
  // функция рекурсии
  FuncRead := procedure(Data: Pointer; DataSize: integer)
    procedure CloseAny;
    begin
      TDeviceBur(FAbstractDevice).Turbo(0);
      if Assigned(FFileStream) then FreeAndNil(FFileStream);
    end;
    procedure WriteStream;
     var
      l: Integer;
    begin
      if DataSize < 0 then Exit;
//      Acquire;
//      try
       l := Length(Fifo);
       SetLength(fifo,l+DataSize);
       move(Data^, fifo[l], DataSize);
//      finally
//       Release;
//      end;
      if Assigned(FFileStream) then FFileStream.Write(Data^, DataSize);
      //fifo.Push(Data, DataSize);
      Inc(FCurAdr, DataSize);

      //FEvent.SetEvent;
       WriteToBD;
    end;
    procedure NextRead(Status: EnumReadRam);
    begin
      WriteStream;
     // if Assigned(FReadRamEvent) then FReadRamEvent(Status, FAdr, ProcToEnd);
      Read(DWord(FCurAdr), FPacketLen, FuncRead, wait); //рекурсия
    end;
    procedure EndWrite(Reason: EnumReadRam);
    begin
      FEndReason := Reason;
      FFlagEndRead := True;
      WriteStream();
      //FEvent.SetEvent;
      CloseAny;
    end;
  begin
    if FFlagTerminate then
     begin
      FFlagEndRead := True;
      WriteToBD;
      CloseAny;
      Exit;
     end;
    if DataSize < 0 then
     begin
      Inc(ErrCnt);
      if ErrCnt > MAX_BAD then EndWrite(eirCantRead)
      else NextRead(eirReadErrSector);
     end
    else
     begin
      ErrCnt := 0;
      if TestFF(@PbyteArray(Data)[DataSize-256], 256) then
       begin
        while (DataSize > 0) and (PbyteArray(Data)[DataSize-1] = $FF) do Dec(DataSize);
        EndWrite(eirEnd);
       end
      else if (FCurAdr >= FToAdr) then EndWrite(eirEnd)
      else NextRead(eirReadOk);
     end;
  end;
  Read(DWord(FCurAdr), RLEN, FuncRead, wait); //начало рекурсии
end;
{$ENDREGION  TBurReadRam}

{$REGION  'TDeviceBur - все процедуры и функции'}
{ TDeviceBur }
procedure TDeviceBur.CheckConnect;
begin
  inherited CheckConnect;
  if not Assigned(ConnectIO.FProtocol) or not (TAbstractProtocol(ConnectIO.FProtocol) is TProtocolBur) then
   begin
    ConnectIO.FProtocol := TProtocolBur.Create;
   end;
end;

constructor TDeviceBur.Create;
begin
  inherited;
  FGetActions := TGetActionsImpl.Create(Self);
  FCycle := TCycleEx.Create(Self);
  /////
  Ftimer := TTimer.Create(Self);
  Ftimer.OnTimer := OnTimer;
  Ftimer.Interval := 3000;
  Ftimer.Enabled := False;
  /////
end;

constructor TDeviceBur.CreateWithAddr(const AddressArray: TAddressArray; const DeviceName: string);
begin
  inherited;
  TRegister.AddType<TDeviceBur>.AddInstance(Name, Self as IInterface);
end;

destructor TDeviceBur.Destroy;
begin
  FCycle.Free;
  FGetActions.Free;
  inherited;
end;

procedure TDeviceBur.DoData(Sender: IAction);
begin
  //Ftimer.Enabled := True;
  if (Self as ICycle).Cycle then
   begin
    (Self as ICycle).Cycle := False;
    Sender.Checked := False;
   end
  else if (S_Status in [dsNoInit, dsPartReady]) then
   begin
    FTmpSender := Sender;
    InitMetaData(InfoEvent);
    FTmpSender.Checked := True;
   end
  else
   begin
    (Self as ICycle).Cycle := True;
    Sender.Checked := True;
   end;
end;

procedure TDeviceBur.InfoEvent(Res: TInfoEventRes);
begin
  FTmpSender.Checked := False;
  try
   if Length(Res.ErrAdr) > 0 then raise EAsyncBurException.CreateFmt('Метаданные устройств (%s) не считаны', [TAddressRec(Res.ErrAdr).ToNames]);
  finally
   if Length(FAddressArray) > Length(Res.ErrAdr) then
    begin
     FTmpSender.Checked := True;
     (Self as ICycle).Cycle := True;
    end;
  end;
end;

procedure TDeviceBur.DoDelay(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetDeviceDelay>(d) then (d as IDialog<IDelayDevice>).Execute(Self as IDelayDevice);
//  if Supports(GlobalCore, Idialogs, d) then d.Execute(DIALOG_SetDeviceDelay, Self);
end;

procedure TDeviceBur.DoIdle(Sender: IAction);
begin
  if MessageDlg('Перевести приборы в спящий режим?', mtWarning, [mbYes, mbNo, mbCancel], 0) <> mrYes then Exit;
  SetDelay(0, 0, nil);
end;

{procedure TDeviceBur.DoInfo(Sender: IAction);
begin
  InitMetaData(InfoEvent2);
end;

procedure TDeviceBur.InfoEvent2(Res: TInfoEventRes);
begin
  if Length(Res.ErrAdr) > 0 then raise EAsyncBurException.CreateFmt('Метаданные устройств (%s) не считаны', [TAddressRec(Res.ErrAdr).ToNames]);
end;}

//procedure TDeviceBur.DoRam(Sender: IAction);
// var
//  d: Idialog;
//begin
//  if RegisterDialog.TryGet<Dialog_RamRead>(d) then (d as IDialog<Integer>).Execute(FAddressArray[0]); { TODO : dialog box select modul for read }
//end;

procedure TDeviceBur.DoStd(Sender: IAction);
begin
  Sender.Checked := not Sender.Checked;
  (Self as ICycleEx).StdOnly := Sender.Checked;
end;

procedure TDeviceBur.DoSync(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SyncDelay>(d) then (d as IDialog<IDevice>).Execute(Self as IDevice);
end;

//function TDeviceBur.GetActionsDevClass: TAbstractActionsDevClass;
//begin
//  Result := TActionsDevBur;
//end;

function TDeviceBur.CreateReadRam: TReadRam;
begin
  Result := TBurReadRam.Create(Self);
end;

//function TDeviceBur.GetRamReadInfo: IRamReadInfo;
//begin
//  Result := TRamReadInfoBur.Create(Self);
//end;

//function TDeviceBur.GetReadDeviceRam: IReadRamDevice;
//begin
//  Result := TBurReadRam.Create(Self);
//end;

function TDeviceBur.GetSerialQe: TProtocolBur;
begin
  Result := TProtocolBur(ConnectIO.FProtocol);
end;

procedure TDeviceBur.InitMetaData(ev: TInfoEvent);
 var
//  GDoc: IXMLDocument;
  a: Byte;
  cnt: Integer;
  IsOldClose: Boolean;
  TmpErr, TmpGood: TAddressArray;
begin
  with  FMetaDataInfo do
  begin
   if Length(ErrAdr) = 0 then
    begin
     try
      if Assigned(ev) then ev(FMetaDataInfo);
     finally
      Notify('S_MetaDataInfo');
     end;
     Exit;
    end;

   CheckStatus([dsNoInit, dsPartReady, dsReady]);
   CheckConnect;
   IsOldClose := not ConnectOpen();
   CheckLocked;

   if not Assigned(FMetaDataInfo.Info) then
    begin
//     GDoc := NewXDocument();
//     FMetaDataInfo.Info := GDoc.DocumentElement;
//     FMetaDataInfo.Info := GDoc.AddChild('DEVICE');
     FMetaDataInfo.Info := GetIDeviceMeta((GContainer as IALLMetaDataFactory).Get().Get(), Name);

//     TDebug.Log('Root1: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]);
    end;

   SetLength(TmpErr, 0);
   SetLength(TmpGood, 0);
   cnt := 0;
   for a in ErrAdr do ReadInfoAdr(a, procedure (Exc: Integer; Adr: Integer; Data: PByte; n: Integer)
      var
       i: Integer;
       ip: IProjectMetaData;
    begin
      if Exc = 0 then
       begin
        TPars.SetInfo(FMetaDataInfo.Info, Data, n); // parse all data for device

  //      TDebug.Log('Root2: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]);

//        FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'DevBur_SetInfo.xml');

        CArray.Add<Integer>(TmpGood,  adr);
       end
      else CArray.Add<Integer>(TmpErr,  adr);
      Inc(cnt);
      if (cnt >= Length(ErrAdr)) then
       try
        ErrAdr := TmpErr;

        if Length(TmpErr) = 0 then S_Status := dsReady
        else if Length(TmpErr) < Length(FAddressArray) then S_Status := dsPartReady
        else S_Status := dsNoInit;

        if IsOldClose then connectClose;

        TPars.SetMetr(FMetaDataInfo.Info, FExeMetr, True);

      //  TDebug.Log('Root3: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]);

        if Supports(GlobalCore, IProjectMetaData, ip) then
          for i in TmpGood do
            ip.SetMetaData(Self as IDevice, i, FindDev(FMetaDataInfo.Info, i));

      //  TDebug.Log('Root4: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]);

  //      FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'DevBur_SetMetr.xml');

       finally
        try
         if Assigned(ev) then ev(FMetaDataInfo);
        finally
         Notify('S_MetaDataInfo');
        end;
       end;
      // raise EComException.Create('TEST');
      //Integer(Pointer(nil)^) := 0;
    end);
  end;
end;

procedure TDeviceBur.OnTimer(Sender: TObject);
begin
  DoData(FTmpSender);
end;

procedure TDeviceBur.Turbo(speed: integer);
 const
  SPD: array[0..7]of Integer = (125000, 500000, 1000000, 2000000, 3000000, 8000000, 12000000, 100000000);
begin
  with SerialQe, ConnectIO do
   begin
    if speed = 0 then
     begin
      if ConnectIO is TComConnectIO then TComConnectIO(ConnectIO).Com.CustomBaudRate := SPD[speed];
      Exit;
     end;
    Add(procedure()
     var
      d: word;
    begin
      d := $FD00 + speed;
      d := Swap(d);
      Send(@D, Sizeof(D), procedure(p: Pointer; n: integer)
      begin
        if ConnectIO is TComConnectIO then TComConnectIO(ConnectIO).Com.CustomBaudRate := SPD[speed];
      end, 300);
    end);
   end;
end;

procedure TDeviceBur.ReadInfoAdr(adr: Byte; ev: TNotifyInfoEventRef);
type
  PInfoDataHeader=^TInfoDataHeader;
  TInfoDataHeader=packed record
   CmdAdr: Byte;
   varType: Byte;
   Length: Word;
  end;
begin
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        D1: TStdRead;
      begin
        D1 := TStdRead.Create(adr, CMD_INFO, SizeOf(TInfoDataHeader)-1); // SizeOf(TInfoDataHeader)-1 так как в TInfoDataHeader присутствует первый байт адреса-команды
      //   Tdebug.Log('std SEND %x', [d1.CmdAdr]);
        Send(@D1, Sizeof(D1), procedure(p1: Pointer; n1: integer)
           var
            savelen: Word;
            from: Word;
            recur: TReceiveDataRef;
            Data: TArray<Byte>;
            bads: Integer;
           // tst: TInfoDataHeader;
         begin
       //    if assigned(p1) then Tdebug.Log('std READ Header = %x  D1 = %x', [PInfoDataHeader(p1).CmdAdr, d1.CmdAdr])
       //    else Tdebug.Log('std READ Header = nil  D1 = %x', [d1.CmdAdr]);
           if (n1 = SizeOf(TInfoDataHeader)) and (PInfoDataHeader(p1).CmdAdr = d1.CmdAdr) then
            begin
           //  tst := PInfoDataHeader(p1)^;
             savelen := PInfoDataHeader(p1).Length;
            // Tdebug.Log('%d', [savelen]);
             from := 0;
             bads := 0;
             SetLength(Data, savelen + 1);
             Data[0] := d1.CmdAdr;

             recur := procedure(pr: Pointer; nr: integer)
               var
                pb: PByteArray;
              begin
                pb := pr;
           //     if Assigned(Pb) then Tdebug.Log('adv recur READ Header=%x adr=%x S=%x', [pb[0], adr, saveCmdAdr])
           //     else Tdebug.Log('adv recur READ Header=NIL adr = %x  D1 = %x', [adr, saveCmdAdr]);
                if (nr > 1) and (pb[0] = ToAdrCmd(adr, CMD_INFO)) then
                 begin
                  move(pb[1], Data[from+1], nr-1);
                  Inc(from, nr-1);
                  if from >= savelen then
                   begin
                    //Tdebug.Log(from.ToString + '  ' + savelen.ToString());
                    ev(0, adr, @Data[0], savelen+1);
                    Exit;
                   end;
                 end
                else
                 begin
                  inc(bads);
                  if bads > 7 then
                   begin
                    ev(-1, adr, pr, nr);
                    Exit;
                   end;
                 end;
               Add(procedure()
                 var
                  D: TAdvStdRead;
                begin
                  if savelen-from > LEN_MAX_SHORT then D := TAdvStdRead.Create(adr, CMD_INFO, LEN_MAX_SHORT, from)
                  else D := TAdvStdRead.Create(adr, CMD_INFO, savelen-from, from);
                //  Tdebug.Log('adv recur SEND %x', [d.CmdAdr]);
                  Send(@D, Sizeof(D), recur);
                end)
              end;
             recur(nil, -1);
             //if savelen > 252 then raise EAsyncBurException.CreateFmt('Поддерживается длина метаданных меньше 252 текущая: %d', [savelen]);
            end
           else ev(-1, adr, p1, n1);
         end);
      end);
   end;
end;

procedure TDeviceBur.WriteEeprom(Addr: Integer; ev: TResultEventRef);
 var
  e: IXMLNode;
begin
  CheckConnect;
  ConnectOpen;
  e := FindEeprom(FMetaDataInfo.Info, Addr);
  if not Assigned(e) then raise EBurException.CreateFmt('Метаданных EEPROM устройства с адресом %d нет', [Addr]);
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        a: TPars.TOutArray;
        D: TEepWrite;
      begin
        TPars.GetData(e, a);
        D := TEepWrite.Create(Addr, 0, a);
        Send(@D, Length(a)+3, procedure(p: Pointer; n: integer)
        begin;
          if Assigned(ev) then ev(n = 1);
        end, 2000);
      end);
   end;
end;

procedure TDeviceBur.ReadEeprom(ev: TEepromEventRef);
begin
  CheckConnect;
  ConnectOpen;
  if not Assigned(FMetaDataInfo.Info) then raise EBurException.Create(RS_ErrNoInfo);
  FindAllEeprom(FMetaDataInfo.Info, procedure(wrk: IXMLNode; Adr: Byte; const name: string)
  begin
    ReadEepromAdrRef(wrk, adr, ev);
  end);
end;

procedure TDeviceBur.ReadWork(ev: TWorkEvent; StdOnly: Boolean);
 var
  ip: IProjectData;
  ix: IProjectDataFile;
begin
  CheckConnect;
  ConnectOpen;
  ReadWorkRef(FMetaDataInfo.Info, procedure (DevAdr: Integer; Work: IXMLInfo; Data: PByte; n: Integer)
  begin
    FWorkEventInfo.DevAdr := DevAdr;
    FWorkEventInfo.Work := Work;
    try
     FExeMetr.Execute(T_WRK, DevAdr);

//     FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'INCL.xml');

     if Supports(GlobalCore, IProjectDataFile, ix) then ix.SaveLogData(Self as IDevice, DevAdr, Work, Data, n)
     else if Supports(GlobalCore, IProjectData, ip) then ip.SaveLogData(Self as IDevice, DevAdr, Work, StdOnly);
    finally
     if Assigned(ev) then ev(FWorkEventInfo);
     Notify('S_WorkEventInfo');
    end;
  end, StdOnly);
end;

procedure TDeviceBur.ReadWorkRef(Info: IXMLNode; ev: TWorkEventRef; StdOnly: Boolean);
begin
  if not Assigned(Info) then raise EBurException.Create(RS_ErrNoInfo);
  FindAllWorks(Info, procedure(wrk: IXMLNode; Adr: Byte; const name: string)
  begin
    ReadWorkAdrRef(wrk, adr, StdOnly, ev);
  end);
end;

procedure TDeviceBur.ReadEepromAdrRef(root: IXMLNode; adr: Byte; ev: TEepromEventRef);
 var
  siz: Integer;
begin
  siz := root.Attributes[AT_SIZE];
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        D: TEepRead;
      begin
        D := TEepRead.Create(adr, 0, siz);
        Send(@D, Sizeof(D), procedure(p: Pointer; n: integer)
        begin
          if (n > 0) and (n-1 = siz) and (PByte(p)^ = d.CmdAdr) then
           begin
            inc(PByte(p));
            TPars.SetData(root, p);
//            FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'GK.xml');
            FeepromEventInfo.DevAdr := adr;
            FeepromEventInfo.eep := root;

            if Assigned(ev) then ev(FeepromEventInfo);
            Notify('S_EepromEventInfo');
           end
           else if n<=0 then raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz+1, d.CmdAdr])
           else  raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz+1, PByte(p)^]);
        end);
      end);
   end;
end;


procedure TDeviceBur.ReadWorkAdrRef(root: IXMLNode; adr: Byte; StdOnly: Boolean; ev: TWorkEventRef);
 var
  siz: Integer;
begin
  if StdOnly then siz := SizeOf(LongWord) + SizeOf(Byte)
  else siz := root.Attributes[AT_SIZE];
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        D: TStdReadLong;
        sz: Integer;
      begin
        if siz < 255 then
         begin
          PStdRead(@D)^ := TStdRead.Create(adr, CMD_WORK, siz);
          sz := Sizeof(TStdRead);
         end
        else
         begin
          D := TStdReadLong.Create(adr, CMD_WORK, siz);
          sz := Sizeof(TStdReadLong);
         end;
        Send(@D, sz, procedure(p: Pointer; n: integer)
        begin
          if (n > 0) and (n-1 = siz) and (PByte(p)^ = d.CmdAdr) then
           begin
            inc(PByte(p));
            if StdOnly then TPars.SetStd(root, p)
            else TPars.SetData(root, p);

//            FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'GK.xml');

            if Assigned(ev) then ev(adr, root, p, siz);
           end
           else if n<=0 then raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz+1, d.CmdAdr])
           else  raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz+1, PByte(p)^]);
        end);
      end);
   end;
end;

procedure TDeviceBur.SendROW(Data: Pointer; Cnt: Integer; Event: TReceiveDataRef; WaitTime: Integer);
begin
  CheckConnect;  //низkоуровневая функция без особых проверок
  CheckLocked;
  ConnectOpen();
  try
   SerialQe.Add(procedure()
   begin
     inherited;
   end);
  except
   SerialQe.Clear;
   raise;
  end;
end;

type
  TTimeSync = packed record
    CmdAdr: Byte;
    time: Integer;
  end;

procedure TDeviceBur.SetDelay(StartTime: TDateTime; WorkTime: TTime; ResultEvent: TSetDelayEvent);
 var
  IsOldClose: Boolean;
begin
  try
   CheckStatus([dsNoInit, dsPartReady, dsReady, dsData]);
   CheckConnect;
   CheckLocked;
   IsOldClose := not ConnectOpen();
   SerialQe.Clear;
   with SerialQe, ConnectIO do Add(procedure()
    var
     d: TTimeSync;
     LNow, CNow: TDateTime;
     Delay, RDelay : TTime;
   begin
     d.CmdAdr := $F5;
     if StartTime <> 0 then
      begin
       LNow := Now();
       Delay := StartTime - LNow;
       d.time := -Ctime.ToKadr(Delay);
       RDelay := -Ctime.FromKadr(d.time);
       CNow := LNow + Delay - RDelay;
       //     Tdebug.Log('Delay Delta %1.2f %% ', [(CNow - Now)*TIME_TO_KADR*100]);
       while CNow > Now do Tthread.Yield;
      end
     else d.time := 0;
     Send(@D, Sizeof(D), procedure(p: Pointer; n: integer)
     begin
       DoDelayEvent(True, CNow, RDelay, 0, ResultEvent);
       if IsOldClose then ConnectClose();
     end, 100);
//     Tdebug.Log('Delay Delta ERR %1.4f %%', [(StartTime - Now-RDelay)*TIME_TO_KADR*100]);
   end);
  except
   DoDelayEvent(False, 0, 0, 0, ResultEvent);
   if IsOldClose then ConnectClose();
   raise;
  end;
end;
{$ENDREGION  TDeviceBur}

{$REGION  'TRamReadInfoBur - все процедуры и функции'}
{ TRamReadInfoBur }
//procedure TRamReadInfoBur.Get_Tstart_Tdelay(RAMInfo: IRAMInfo; var tstart, tdelay: TDateTime);
//begin
//  tstart := StrToDateTime(RAMInfo.Attributes[AT_START_TIME]);
//  tdelay := MyStrToTime(RAMInfo.Attributes[AT_DELAY_TIME]);
//end;

{function TRamReadInfoBur.Update(Info: IXMLInfo; UpdateTimeSyncEvent: TRamEvent): IRAMInfo;
  var
   rf: IRAMInfo; // так как невозможно захватить Result
begin
  with TDeviceBur(FAbstractDevice) do
   begin
    CheckConnect;
    if (ConnectIO as IConnectIO).Locked(Cycle) then raise ERamReadInfoBurException.Create(RS_IsCycle);
    if not (ConnectIO as IConnectIO).IsOpen then (ConnectIO as IConnectIO).Open;
    // обновим файл информации чтения
    Result := Get();
    if not Assigned(Info) then raise ERamReadInfoBurException.Create(RS_ErrNoInfo);
    if UpdateRun(Result, Info) then Result.OwnerDocument.SaveToFile(FileInfo);
    // обновим файл информации чтения коэффициенты рассогласования времени
    rf := Result; // так как невозможно захватить Result
    ReadWorkRef(rf, procedure (DevAdr: Integer; Work: IXMLInfo)
     var
      nt, p: IXMLNode;
      ts, td, t: TDateTime;
    begin
      nt := Work.ChildNodes.FindNode('время');
      p := FindDev(rf, DevAdr);
      if not p.HasAttribute(AT_KOEF_TIME) and Assigned(nt) then
       begin
        Get_Tstart_Tdelay(rf, ts, td);
        t := StrToTime(nt.Attributes[AT_ROW]);        //относительное время
        p.Attributes[AT_KOEF_TIME] := (Now-ts)/(t+td); //относительное время
        rf.OwnerDocument.SaveToFile(FileInfo);
        if Assigned(UpdateTimeSyncEvent) then UpdateTimeSyncEvent(DevAdr, Work);
       end;
    end, True);
   end;
end;  }
{$ENDREGION  TRamReadInfoBur}

initialization
  RegisterClass(TDeviceBur);
  TRegister.AddType<TDeviceBur, IDevice>.LiveTime(ltSingletonNamed)
finalization
  GContainer.RemoveModel<TDeviceBur>;
end.
