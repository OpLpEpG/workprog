unit DevBur;

interface

uses  tools, System.IOUtils, RootIntf,
  Winapi.Windows, System.SysUtils, System.Classes, CPort, CRC16, Vcl.ExtCtrls, System.Variants, Xml.XMLIntf, Xml.XMLDoc,
  Generics.Collections,  Vcl.Forms, Vcl.Dialogs,Vcl.Controls, Actns,
  DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl;


  const
    LEN_MAX_SHORT = 252;//-CASZ; //�� 252 ��-�� ��� ���
 type
  EReadRamBurException = class(EReadRamException);
    EAsyncReadRamBurException = class(EAsyncReadRamException);
  TBurReadRam = class(TReadRam)
  public
   const
    MAX_RAM = $420000;
    MAX_BAD = 70;
    RLEN =  $7FF-2-2;// $7FFFF-3;
    WAIT_RLEN = 2000;
  private
    type TResRef = reference to procedure;
    procedure Read(RamPtr: Integer; len: DWord;  ev: TReceiveDataRef; WaitTime: Integer = -1);
  protected
    procedure Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0); override;
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
    procedure Turbo(adr: Byte; speed: integer);

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
    [DynamicAction('<I> ��������...', '<I>', 142, '0:����������|3.<I>:-1', '���� ���������� �� ��������')]
    procedure DoDelay(Sender: IAction);
//    [DynamicAction('<I> ��������� �����...', '<I>', Dialog_SyncDelay_ICON, '0:����������|3.<I>', '���� ��������� ����� �������. ���������� ����� ������� ������,� ������ ����������.')]
//    procedure DoSync(Sender: IAction);
    [DynamicAction('<I> ����������', '<I>', 52, '0:����������|3.<I>;2:', '�����/���� � ����� ������ ����������')]
    procedure DoData(Sender: IAction);
//    procedure DoInfo(Sender: IAction);
    [DynamicAction('(������ �����)', '<I>', 69, '0:����������|3.<I>.�������������|0',
    '���������� ����������������� ������� ������� ����������, ��������� ������ ������� � ��������� �������')]
    procedure DoStd(Sender: IAction);
    [DynamicAction('��������� ������', '<I>', 71, '0:����������|3.<I>.�������������|0', '��������� ������� � ������ �����')]
    procedure DoIdle(Sender: IAction);
  published
    property CyclePeriod;
  end;

implementation

uses  Parser;

const
  RS_ErrReadData = '������ ������ ������ ���������� � �������: %d SZ=%d[%d] CA=0x%x';
  RS_ErrNoInfo = '�� ���������������� ���������� �� �����������';


{$REGION  'TBurReadRam - ��� ��������� � �������'}
{ TBurReadRam }
//������ ����� ������ ������ �� ������ RamPtr
procedure TBurReadRam.Read(RamPtr: Integer; len: DWord;  ev: TReceiveDataRef; WaitTime: Integer = -1);
begin
//  if FFlagTerminate then Exit;
  with TDeviceBur(FAbstractDevice) do
   try
    SerialQe.Add(procedure()
     var
      d: TStdRec;
    begin
     // if FFlagTerminate then Exit;
      D := TStdRec.Create(FAdr, CMD_READ_RAM, SizeOf(DWord)*2);
      D.AssignRamRead(DWord(RamPtr), len);
      ConnectIO.Send(d.Ptr, d.SizeOf, procedure(p: Pointer; n: integer)
      begin
        if FFlagTerminate then ev(nil, -1)
        else if ((len + d.SizeOfAC) = n) and D.CheckAC(p) then
          ev(@PbyteArray(p)[d.SizeOfAC], n-d.SizeOfAC)
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

procedure TBurReadRam.Execute(const binFile: string; FromKadr, ToKadr: Integer; ReadToFF: Boolean; FastSpeed, Adr: Integer; evInfoRead: TReadRamEvent; ModulID: integer; PacketLen: Integer = 0);
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
    TDeviceBur(FAbstractDevice).Turbo(Fadr, FFastSpeed);
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
  // ������� ��������
  FuncRead := procedure(Data: Pointer; DataSize: integer)
    procedure CloseAny;
    begin
      TDeviceBur(FAbstractDevice).Turbo(Fadr, 0);
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
    procedure NextRead(Status: EnumCopyAsyncRun);
    begin
      WriteStream;
     // if Assigned(FReadRamEvent) then FReadRamEvent(Status, FAdr, ProcToEnd);
      Read(DWord(FCurAdr), FPacketLen, FuncRead, wait); //��������
    end;
    procedure EndWrite(Reason: EnumCopyAsyncRun);
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
      if ErrCnt > MAX_BAD then EndWrite(carError)
      else NextRead(carErrorSector);
     end
    else
     begin
      ErrCnt := 0;
      if TestFF(@PbyteArray(Data)[DataSize-256], 256) then
       begin
        while (DataSize > 0) and (PbyteArray(Data)[DataSize-1] = $FF) do Dec(DataSize);
        EndWrite(carZerroes);
       end
      else if (FCurAdr >= FToAdr) then EndWrite(carEnd)
      else NextRead(carOk);
     end;
  end;
  Read(DWord(FCurAdr), RLEN, FuncRead, wait); //������ ��������
end;
{$ENDREGION  TBurReadRam}

{$REGION  'TDeviceBur - ��� ��������� � �������'}
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
   if Length(Res.ErrAdr) > 0 then raise EAsyncBurException.CreateFmt('���������� ��������� (%s) �� �������', [TAddressRec(Res.ErrAdr).ToNames]);
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
  (GContainer as IActionEnum).Get(IName + '_DoStd').Checked := True;
  (Self as ICycleEx).StdOnly := True;
  if RegisterDialog.TryGet<Dialog_SetDeviceDelay>(d) then (d as IDialog<IDelayDevice>).Execute(Self as IDelayDevice);
//  if Supports(GlobalCore, Idialogs, d) then d.Execute(DIALOG_SetDeviceDelay, Self);
end;

procedure TDeviceBur.DoIdle(Sender: IAction);
begin
  if MessageDlg('��������� ������� � ������ �����?', mtWarning, [mbYes, mbNo, mbCancel], 0) <> mrYes then Exit;
  SetDelay(0, 0, nil);
end;

{procedure TDeviceBur.DoInfo(Sender: IAction);
begin
  InitMetaData(InfoEvent2);
end;

procedure TDeviceBur.InfoEvent2(Res: TInfoEventRes);
begin
  if Length(Res.ErrAdr) > 0 then raise EAsyncBurException.CreateFmt('���������� ��������� (%s) �� �������', [TAddressRec(Res.ErrAdr).ToNames]);
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

//procedure TDeviceBur.DoSync(Sender: IAction);
// var
//  d: Idialog;
//begin
//  if RegisterDialog.TryGet<Dialog_SyncDelay>(d) then (d as IDialog<IDevice>).Execute(Self as IDevice);
//end;

//function TDeviceBur.GetActionsDevClass: TAbstractActionsDevClass;
//begin
//  Result := TActionsDevBur;
//end;

function TDeviceBur.CreateReadRam: TReadRam;
begin
  if Supports(IConnect, ImicroSDConnectIO) then Result := TBurReadRam.Create(Self)
  else Result := TBurReadRam.Create(Self);
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

//     TDebug.Log('Root1: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]); ��������� ������ ������
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

  //      TDebug.Log('Root2: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]);��������� ������ ������
//        FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'DevBur_SetInfo.xml');��������� ������ ������

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

      //  TDebug.Log('Root3: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]); ��������� ������ ������

        if Supports(GlobalCore, IProjectMetaData, ip) then
          for i in TmpGood do
           begin
             FExeMetr.UpdateExecRunSetupMetr(FMetaDataInfo.Info, i, FExeMetr);
             ip.SetMetaData(Self as IDevice, i, FindDev(FMetaDataInfo.Info, i)); //��������� ������ ������ ������ �����
           end;

      //  TDebug.Log('Root4: %s %d', [FMetaDataInfo.Info.NodeName, FMetaDataInfo.Info.ChildNodes.Count]); ��������� ������ ������
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

//type
//  TTurbo = packed record
//    CmdAdr: TCmdADR;
//    speed: Byte;
//  end;

procedure TDeviceBur.Turbo(adr: Byte; speed: integer);
 const
  SPD: array[0..7]of Integer = (125000, 500000, 1000000, 2250000, 4500000, 8000000, 12000000, 100000000);
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
      d: TStdRec;
    begin
      if adr > 16 then d := TStdRec.Create($FF, $FD, 1)
      else d := TStdRec.Create($F, $D, 1);
      d.AssignByte(speed);
//      d.CmdAdr := ToAdrCmd($FF,$FD);
//      d.speed := speed;
      Send(D.Ptr, D.SizeOf, procedure(p: Pointer; n: integer)
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
//   CmdAdr: TCmdADR;
   varType: Byte;
   Length: Word;
  end;
  const DIHLEN = SizeOf(TInfoDataHeader);
begin
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        D1: TStdRec;
      begin
        D1 := TStdRec.Create(adr, CMD_INFO, 1);
        D1.AssignByte(DIHLEN);
      //   Tdebug.Log('std SEND %x', [d1.CmdAdr]);
        Send(D1.Ptr, D1.SizeOf, procedure(p1: Pointer; n1: integer)
           var
            savelen: Word;
            from: Word;
            recur: TReceiveDataRef;
            Data: TArray<Byte>;
            bads: Integer;
            Dn: TStdRec;
           // tst: TInfoDataHeader;
         begin
       //    if assigned(p1) then Tdebug.Log('std READ Header = %x  D1 = %x', [PInfoDataHeader(p1).CmdAdr, d1.CmdAdr])
       //    else Tdebug.Log('std READ Header = nil  D1 = %x', [d1.CmdAdr]);
           if (n1 = D1.SizeOfAC + DIHLEN) and (D1.CheckAC(p1)) then
            begin
              Dn := TStdRec.Create(p1, adr>15, DIHLEN);
           //  tst := PInfoDataHeader(p1)^;
             savelen := PInfoDataHeader(Dn.DataPtr).Length;
            // Tdebug.Log('%d', [savelen]);
             from := 0;
             bads := 0;
             SetLength(Data, savelen);// + CASZ);
            // PCmdAdr(@Data[0])^ := d1.CmdAdr;

             recur := procedure(pr: Pointer; nr: integer)
               var
                pb: PByteArray;
                n: Integer;
              begin
                pb := pr;
           //     if Assigned(Pb) then Tdebug.Log('adv recur READ Header=%x adr=%x S=%x', [pb[0], adr, saveCmdAdr])
           //     else Tdebug.Log('adv recur READ Header=NIL adr = %x  D1 = %x', [adr, saveCmdAdr]);
                if (nr > D1.SizeOfAC) and D1.CheckAC(pr) then
                 begin
                  n := nr - D1.SizeOfAC;
                  move(pb[D1.SizeOfAC], Data[from], n);
                  Inc(from, n);
                  if from >= savelen then
                   begin
                    //Tdebug.Log(from.ToString + '  ' + savelen.ToString());
                    ev(0, adr, @Data[0], savelen);
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
                  D: TStdRec;
                  l: Integer;
                begin
                  D := TStdRec.Create(adr, CMD_INFO, 3);
                  if savelen-from > LEN_MAX_SHORT-D.SizeOfAC then
                       l := LEN_MAX_SHORT-D.SizeOfAC
                  else l := savelen-from;
                  D.AssignAdvStdRead(l, from);
                //  Tdebug.Log('adv recur SEND %x', [d.CmdAdr]);
                  Send(D.Ptr, D.SizeOf, recur);
                end)
              end;
             recur(nil, -1);
             //if savelen > 252 then raise EAsyncBurException.CreateFmt('�������������� ����� ���������� ������ 252 �������: %d', [savelen]);
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
  if not Assigned(e) then raise EBurException.CreateFmt('���������� EEPROM ���������� � ������� %d ���', [Addr]);
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        a: TPars.TOutArray;
        D: TStdRec;
      begin
        TPars.GetData(e, a);
        D := TStdRec.Create(Addr, CMD_WRITE_EE, Length(a) + 2);
        D.AssignEEPWrite(0, a);
//        D := TEepWrite.Create(Addr, 0, a);
        Send(D.Ptr, d.SizeOf, procedure(p: Pointer; n: integer)
        begin;
          if Assigned(ev) then ev(n = d.SizeOfAC);
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
    ReadEepromAdrRef(wrk, adr, procedure (Res: TEepromEventRes)
    begin
     try
      FExeMetr.Execute(T_EEPROM, Adr);
     finally
      if Assigned(ev) then ev(res);
     end;
    end);
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
  if siz > 250 then raise EAsyncBurException.CreateFmt('������ ������ ��������� ������������ ����� EEPROM ������ 250 �������: %d', [siz]);
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        D: TStdRec;
      begin
        D := TStdRec.Create(adr, CMD_READ_EE, 3);
        D.AssignEEPRead(0, siz);
        Send(D.Ptr, D.SizeOf, procedure(p: Pointer; n: integer)
         var
          pb: PByte;
        begin
          if (n > 0) and (n-d.SizeOfAC = siz) and d.CheckAC(p) then
           begin
            pb := p;
            Inc(Pb, d.SizeOfAC);
            TPars.SetData(root, pb);
//            FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'GK.xml');
            FeepromEventInfo.DevAdr := adr;
            FeepromEventInfo.eep := root;

            if Assigned(ev) then ev(FeepromEventInfo);
            Notify('S_EepromEventInfo');
           end
           else if n<=0 then raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz, d.Adr])
           else  raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz, PByte(p)^]);
        end);
      end);
   end;
end;


procedure TDeviceBur.ReadWorkAdrRef(root: IXMLNode; adr: Byte; StdOnly: Boolean; ev: TWorkEventRef);
 var
  siz: Integer;
  cntStd: Integer;
  p: IXMLNode;
begin
  cntStd := -1;
  if StdOnly then
   begin
    p := root.ParentNode;
    if Assigned(p) and p.HasAttribute(AT_EXT_NP_LEN) then
     begin
      siz := p.Attributes[AT_EXT_NP_LEN];
      cntStd := p.Attributes[AT_EXT_NP];
      end
    else
     begin
      siz := SizeOf(LongWord) + SizeOf(Byte);
      cntStd := 2;
     end;
   end
  else siz := root.Attributes[AT_SIZE];
  with SerialQe, ConnectIO do
   begin
     Add(procedure()
       var
        D: TStdRec;
      begin
        if siz < 255 then
         begin
          D := TStdRec.Create(adr, CMD_WORK, 1);
          D.AssignByte(siz);
         end
        else
         begin
          D := TStdRec.Create(adr, CMD_WORK, 2);
          D.AssignWord(siz);
         end;
        Send(D.Ptr, d.SizeOf, procedure(p: Pointer; n: integer)
         var
          pb: PByte;
        begin
          pb := p;
          if (n > 0) and ((n-D.SizeOfAC) = siz) and D.CheckAC(pb) then
           begin
            inc(pb, D.SizeOfAC);
//            if StdOnly then TPars.SetStd(root, pb)
//            else
            TPars.SetData(root, pb, True, cntStd);
//            FMetaDataInfo.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'GK.xml');
            if Assigned(ev) then
             begin
              if StdOnly then
               begin
                inc(pb,siz);
                fillchar(pb^, Integer(root.Attributes[AT_SIZE])-siz, 0);
               end;
              ev(adr, root, p, root.Attributes[AT_SIZE]);
             end;
           end
           else if n<=0 then raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz, d.adr])
           else  raise EAsyncBurException.CreateFmt(RS_ErrReadData, [adr, n, siz, PByte(p)^]);
        end);
      end);
   end;
end;

procedure TDeviceBur.SendROW(Data: Pointer; Cnt: Integer; Event: TReceiveDataRef; WaitTime: Integer);
begin
  CheckConnect;  //���k���������� ������� ��� ������ ��������
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

//type
//  TTimeSync = packed record
//    CmdAdr: TCmdADR;
//    time: Integer;
//  end;

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
     D: TStdRec;
//     LNow,
     CNow: TDateTime;
     Delay, RDelay : TTime;
     kadrDelay: Integer;
   begin
     if FAddressArray[0] > 16 then d := TStdRec.Create($FF, $F5, 4)
     else d := TStdRec.Create($F, 5, 4);
//     D := TStdRec.Create(@buf, $FF, $F5, 4);
//     d.CmdAdr := ToAdrCmd($FF, $F5);//$F5
     if StartTime <> 0 then
      begin
       //LNow := Now();
       Delay := StartTime - Now();
       /// kadrDelay <Delay
       kadrDelay := Trunc(Delay * CTime.TIME_TO_KADR);
//       d.time := -kadrDelay;//  -Ctime.ToKadr(Delay);
       D.AssignInt(-kadrDelay);
       /// ��������  ������ �� �������
       RDelay := Ctime.FromKadr(kadrDelay); //-Ctime.FromKadr(d.time);
       //Tdebug.Log('%1.5f',[(Delay-RDelay)*24*3600*1000]);
       /// ����� ���������� �� �������� ��������� ������ �������� �� 2�� ������
       CNow := StartTime - RDelay;// LNow + Delay - RDelay;
       //     Tdebug.Log('Delay Delta %1.2f %% ', [(CNow - Now)*TIME_TO_KADR*100]);
       while CNow > Now do
        begin
         Tthread.Yield;
       //  Tdebug.Log('%1.5f',[(CNow- Now)*24*3600*1000]);
        end;
      end
     else d.AssignInt(0);

     Send(D.Ptr, d.Sizeof, procedure(p: Pointer; n: integer)
     begin
       Tdebug.Log('%1.5f',[(Now - CNow)*24*3600*1000]);
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

{$REGION  'TRamReadInfoBur - ��� ��������� � �������'}
{ TRamReadInfoBur }
//procedure TRamReadInfoBur.Get_Tstart_Tdelay(RAMInfo: IRAMInfo; var tstart, tdelay: TDateTime);
//begin
//  tstart := StrToDateTime(RAMInfo.Attributes[AT_START_TIME]);
//  tdelay := MyStrToTime(RAMInfo.Attributes[AT_DELAY_TIME]);
//end;

{function TRamReadInfoBur.Update(Info: IXMLInfo; UpdateTimeSyncEvent: TRamEvent): IRAMInfo;
  var
   rf: IRAMInfo; // ��� ��� ���������� ��������� Result
begin
  with TDeviceBur(FAbstractDevice) do
   begin
    CheckConnect;
    if (ConnectIO as IConnectIO).Locked(Cycle) then raise ERamReadInfoBurException.Create(RS_IsCycle);
    if not (ConnectIO as IConnectIO).IsOpen then (ConnectIO as IConnectIO).Open;
    // ������� ���� ���������� ������
    Result := Get();
    if not Assigned(Info) then raise ERamReadInfoBurException.Create(RS_ErrNoInfo);
    if UpdateRun(Result, Info) then Result.OwnerDocument.SaveToFile(FileInfo);
    // ������� ���� ���������� ������ ������������ ��������������� �������
    rf := Result; // ��� ��� ���������� ��������� Result
    ReadWorkRef(rf, procedure (DevAdr: Integer; Work: IXMLInfo)
     var
      nt, p: IXMLNode;
      ts, td, t: TDateTime;
    begin
      nt := Work.ChildNodes.FindNode('�����');
      p := FindDev(rf, DevAdr);
      if not p.HasAttribute(AT_KOEF_TIME) and Assigned(nt) then
       begin
        Get_Tstart_Tdelay(rf, ts, td);
        t := StrToTime(nt.Attributes[AT_ROW]);        //������������� �����
        p.Attributes[AT_KOEF_TIME] := (Now-ts)/(t+td); //������������� �����
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
