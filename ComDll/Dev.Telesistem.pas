unit Dev.Telesistem;

interface

uses System.SysUtils,  System.Classes, System.TypInfo, System.Rtti, Fibonach, MathIntf, System.Math, Dev.Telesistem.Decoder,
     Actns, DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl, RootIntf, SubDevImpl, tools,
     Math.Telesistem;

const
//   TELESIS_USO: TSubDeviceInfo = (typ: [sdtUniqe, sdtMastExist]; Category: 'Усо');
//   TELESIS_FLT: TSubDeviceInfo = (Category: 'Фильтры');
//   TELESIS_DECODER: TSubDeviceInfo = (typ: [sdtUniqe, sdtMastExist]; Category: 'Декодер');

   TELESIS_STRUCURE: array[0..4] of TSubDeviceInfo = (
   (typ: [sdtUniqe, sdtMastExist]; Category: 'Усо'),
                                  (Category: 'Фильтры'),
   (typ: [sdtUniqe, sdtMastExist]; Category: 'Коррелятор'),
                                  (Category: 'Фильтры-2'),
   (typ: [sdtUniqe, sdtMastExist]; Category: 'Декодер'));

type
  TTelesistem = class;
  TProtocolTelesis = class(TAbstractProtocol)
  protected
    Ftelesis: TTelesistem;
    procedure EventRxTimeOut(Sender : TAbstractConnectIO); override;
    procedure EventRxChar(Sender : TAbstractConnectIO); override;
    procedure TxChar(Sender : TAbstractConnectIO; Data: Pointer; var Cnt: Integer; maxsend: Integer = $200); override;
  public
    constructor Create(telesis: TTelesistem);
  end;

  TTelesistem = class(TRootDevice)
  private
    procedure Start(AIConnectIO: IConnectIO);
    procedure Stop(AIConnectIO: IConnectIO);
    procedure BindPortStstus(isLost: Boolean);
  protected
    FlagLostPort: Boolean;
    procedure SetConnect(AIConnectIO: IConnectIO); override;
    function GetService: PTypeInfo; override;
    function GetStructure: TArray<TSubDeviceInfo>; override;
    procedure Loaded; override;
    function CanClose: Boolean; override;
    procedure BeforeRemove(); override;
  public
    procedure CheckConnect(); override;
    [DynamicAction('Установки телесистемы <I> ', '<I>', 52, '0:Телесистема', 'Установки телесистемы')]
    procedure DoSetup(Sender: IAction); override;
  end;

   TTestUsoData = (tudNone, tudFibonach, tudRMCod, tudFSK, tudFibonachCorr);
   TTelesisFrequency = (afq40, afq20, afq10, afq5, afq2p5, afq1p25);
    TRecRun = record
       LSync, HSync: Boolean;
       SumDat: Integer;
       NCanal: Integer;
       Nfq: Integer;
       case integer of
        0: (Buff: array[0..2] of Byte);
        1: (Wrd: Word);
     end;

  const
    USO_LEN = 64;
    FFT_LEN = 1024;
    FFT_OVERSAMP = FFT_LEN div 4;

    FFT_SAMPLES = FFT_LEN - FFT_OVERSAMP*2;// FFT_LEN div 2;
    FFT_AMP_LEN = FFT_LEN div 2;

type
  TUso1 = class(TSubDevWithForm<TUsoData>, ITelesistem)
  private
    FFrequency: TTelesisFrequency;
    FKSum: Integer;
    RecRun: TRecRun;
    Tst_Data: TArray<Boolean>;
    FData: TArray<Double>;
    FTestUsoData: TTestUsoData;
    procedure SetFrequency(const Value: TTelesisFrequency);
    procedure SetTestUsoData(const Value: TTestUsoData);
  protected
    function GetCategory: TSubDeviceInfo; override;
    function GetCaption: string; override;
  public
    procedure InputData(Data: Pointer; DataSize: integer); override;
    constructor Create; override;
    [DynamicAction('Показать осцилограмму усо <I> ', '<I>', 52, '0:Телесистема.<I>', 'Показать осцилограмму усо')]
    procedure DoSetup(Sender: IAction); override;
  published
    [ShowProp('Частота прибора')] property Frequency: TTelesisFrequency read FFrequency write SetFrequency default afq10;
    [ShowProp('Тестовые даррые')] property TestUsoData: TTestUsoData read FTestUsoData write SetTestUsoData default tudNone;
   end;

//   TUso2 = class(TUso1)
//   protected
//     function GetCaption: string; override;
//   end;

   TFltBPF = class(TSubDevWithForm<TFFTData>, ITelesistem)
   private
     FDataIn, FDataOut, FFData, FFDataFlt, FltCoeff: TArray<Double>;
     FFourier: IFourier;
     FDataCnt: Integer;
   protected
     procedure FBCH(from, too: Integer);
     procedure FNCH(from, too: Integer);
     procedure DoOutputData(Data: Pointer; DataSize: integer); virtual;
     function GetCategory: TSubDeviceInfo; override;
     function GetCaption: string; override;
     procedure OnUserRemove; override;
   public
     procedure InputData(Data: Pointer; DataSize: integer); override;
     constructor Create; override;
     [DynamicAction('Показать спектр <I> ', '<I>', 52, '0:Телесистема.<I>', 'спектр')]
     procedure DoSetup(Sender: IAction); override;
   end;

   TbitFlt = class(TSubDevWithForm<TUsoData>, ITelesistem)
   private
     Ffifo: array [0..7] of Double;
   protected
     function GetCaption: string; override;
     function GetCategory: TSubDeviceInfo; override;
   public
     procedure InputData(Data: Pointer; DataSize: integer); override;
     constructor Create; override;
     [DynamicAction('Показать осцилограмму BIT <I> ', '<I>', 53, '0:Телесистема.<I>', 'Показать осцилограмму BIT')]
     procedure DoSetup(Sender: IAction); override;
   end;

   TPalseFlt = class(TbitFlt)
   protected
     function GetCategory: TSubDeviceInfo; override;
     function GetCaption: string; override;
   public
     procedure InputData(Data: Pointer; DataSize: integer); override;
     constructor Create; override;
     [DynamicAction('Показать осцилограмму ФОИ <I> ', '<I>', 54, '0:Телесистема.<I>', 'Показать осцилограмму ФОИ')]
     procedure DoSetup(Sender: IAction); override;
   end;

   TPalseFlt2 = class(TPalseFlt)
   protected
     function GetCategory: TSubDeviceInfo; override;
     function GetCaption: string; override;
   end;

   TDecoder1 = class(TCustomDecoder, ITelesistem)
   protected
     function GetCaption: string; override;
     function GetDecoderClass: TDecoderClass; override;
   public
     constructor Create; override;
     [DynamicAction('Показать окно Декорера', '<I>', 55, '0:Телесистема.<I>', 'Показать окно Декорера')]
     procedure DoSetup(Sender: IAction); override;
   end;

  TDecoder2 = class(TCustomDecoder, ITelesistem)
  private
    FIsMul: Boolean;
    FFltZerro: Boolean;
    procedure SetIsMul(const Value: Boolean);
    procedure SetFltZerro(const Value: Boolean);
  protected
    function GetCaption: string; override;
    function GetDecoderClass: TDecoderClass; override;
    procedure SetupNewDecoder;  override;
  public
    constructor Create; override;
    [DynamicAction('Показать окно Декорера', '<I>', 55, '0:Телесистема.<I>', 'Показать окно Декорера')]
    procedure DoSetup(Sender: IAction); override;
  published
    [ShowProp('Фильтр единиц умножением')] property IsMul: Boolean read FIsMul write SetIsMul default True;
    [ShowProp('Фильтр нулей')] property FltZerro: Boolean read FFltZerro write SetFltZerro default True;
  end;

  TDecoder3 = class(TCustomDecoder, ITelesistem)
  protected
    function GetCaption: string; override;
    function GetDecoderClass: TDecoderClass; override;
  public
    constructor Create; override;
    [DynamicAction('Показать окно Декорера', '<I>', 55, '0:Телесистема.<I>', 'Показать окно Декорера')]
    procedure DoSetup(Sender: IAction); override;
  end;

  TDecoder4 = class(TCustomDecoder, ITelesistem)
  private
    FCorLen: Integer;
    procedure SetCorLen(const Value: Integer);
  protected
    procedure SetupNewDecoder;  override;
    function GetCaption: string; override;
    function GetDecoderClass: TDecoderClass; override;
  public
    constructor Create; override;
    [DynamicAction('Показать окно Декорера', '<I>', 55, '0:Телесистема.<I>', 'Показать окно Декорера')]
    procedure DoSetup(Sender: IAction); override;
  published
    [ShowProp('длина керреляции')] property CorLen: Integer read FCorLen write SetCorLen;
  end;

//   TCorrelate = class(TSubDevWithForm<TUsoData>, ITelesistem)
//   protected
//     procedure InputData(Data: Pointer; DataSize: integer); override;
//     function GetCategory: TSubDeviceInfo; override;
//     function GetCaption: string; override;
//   public
//     [DynamicAction('Показать окно корреляции', '<I>', 55, '0:Телесистема.<I>', 'Показать окно корреляции')]
//     procedure DoSetup(Sender: IAction); override;
//   end;

implementation

{$REGION ' Telesis '}
{ TProtocolTelesis }

constructor TProtocolTelesis.Create(telesis: TTelesistem);
begin
  Ftelesis := telesis;
end;

procedure TProtocolTelesis.EventRxChar(Sender: TAbstractConnectIO);
begin
  with Sender do
   begin
    FTimerRxTimeOut.Enabled := False;
    try
     if Assigned(FEventReceiveData) then FEventReceiveData(@FInput[0], FICount);
     FICount := 0;
    finally
     FTimerRxTimeOut.Enabled := True;
    end;
   end;
end;

procedure TProtocolTelesis.EventRxTimeOut(Sender: TAbstractConnectIO);
begin
  with Ftelesis do
   try
    BindPortStstus(True);
   finally
    try
     Ftelesis.Stop(Sender as IConnectIO);
    finally
     Ftelesis.Start(Sender as IConnectIO);
    end;
   end;
end;

procedure TProtocolTelesis.TxChar(Sender: TAbstractConnectIO; Data: Pointer; var Cnt: Integer; maxsend: Integer);
begin
end;

{ TTelesistem }

procedure TTelesistem.BeforeRemove;
begin
  inherited;
  try
   Stop(IConnect);
  except
   on E: Exception do TDebug.DoException(E);
  end;
end;

procedure TTelesistem.BindPortStstus(isLost: Boolean);
begin
  if FlagLostPort <> isLost then
   begin
    FlagLostPort := isLost;
    { TODO : bind start or stop connection}
   end
end;

function TTelesistem.CanClose: Boolean;
begin
  Result := True;
  try
   Stop(IConnect);
   // ессли произошла перезагрузка экрана то через 10 сек вкл прибор
   ConnectIO.FTimerRxTimeOut.Enabled := True;
  except
   on E: Exception do TDebug.DoException(E);
  end;
end;

procedure TTelesistem.CheckConnect;
begin
  inherited CheckConnect;
  if not Assigned(ConnectIO.FProtocol) or
     not (TAbstractProtocol(ConnectIO.FProtocol) is TProtocolTelesis) then ConnectIO.FProtocol := TProtocolTelesis.Create(Self);
end;

procedure TTelesistem.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TTelesistem.GetService: PTypeInfo;
begin
  Result := TypeInfo(ITelesistem);
end;

function TTelesistem.GetStructure: TArray<TSubDeviceInfo>;
begin
  SetLength(Result, Length(TELESIS_STRUCURE));
  Move(TELESIS_STRUCURE[0], Result[0], Length(TELESIS_STRUCURE)*SizeOf(TSubDeviceInfo));
end;

procedure TTelesistem.Loaded;
begin
  inherited;
  Start(IConnect);
end;

procedure TTelesistem.SetConnect(AIConnectIO: IConnectIO);
 var
  old: IConnectIO;
begin
  if Assigned(AIConnectIO) and not Supports(AIConnectIO, IComPortConnectIO) then
    raise EConnectIOException.CreateFmt('%s не COM соединение. Возможно только COM соединение!',[AIConnectIO.ConnectInfo]);
  old := IConnect;
  Stop(IConnect);
  inherited SetConnect(AIConnectIO);
  try
   Start(AIConnectIO);
  except
   inherited SetConnect(old);
   raise;
  end;
end;

procedure TTelesistem.Start(AIConnectIO: IConnectIO);
begin
//  TDebug.Log('start %s %s',[GetDeviceName, AIConnectIO.ConnectInfo]);
  if Assigned(AIConnectIO) then
   try
    CheckLocked();
    CheckConnect;
    AIConnectIO.ConnectInfo := AIConnectIO.ConnectInfo+ ';38400';
    ConnectOpen;
    ConnectLock;
    ConnectIO.Send(Self, -1, procedure(Data: Pointer; DataSize: integer)
    begin
      BindPortStstus(False);
      if (FSubDevs.Count>0) then
       with TSubDev(FSubDevs.Items[0]) as ISubDevice do
         if Category.Category = TELESIS_STRUCURE[0].Category then InputData(Data, DataSize);
    end, 3000);
    S_Status := dsData;
   except
    ConnectIO.FTimerRxTimeOut.Enabled := True;
    raise;
   end;
end;

procedure TTelesistem.Stop(AIConnectIO: IConnectIO);
begin
//  TDebug.Log('s t o p  %s %s',[GetDeviceName, AIConnectIO.ConnectInfo]);
  if Assigned(AIConnectIO) then
   begin  //для меня            .. для всех
    ConnectIO.FTimerRxTimeOut.Enabled := False;
    S_Status := dsReady;
    if not IsConnectLocked then ConnectUnLock();
    if AIConnectIO.IsOpen then IConnect.Close;
    AIConnectIO.ConnectInfo := ';';
   end;
end;

{$ENDREGION}

{$REGION ' uso '}

{ TUso1 }

constructor TUso1.Create;
begin
  FKSum := 1;
  FFrequency :=  afq10;
  SetLength(FData, USO_LEN);
  FS_Data.Data := @Fdata[0];
  FS_Data.Size := USO_LEN;
  InitConst('TUsoOscForm', 'OscForm_');
  inherited;
end;

procedure TUso1.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TUso1.GetCaption: string;
begin
  Result := 'Усо телесистемы'
end;

function TUso1.GetCategory: TSubDeviceInfo;
begin
  Result := TELESIS_STRUCURE[0];
end;

procedure TUso1.InputData(Data: Pointer; DataSize: integer);
  const
   {$J+}
     i: Integer = 0;
     c: Integer = 0;
   {$J-}
  var
   p: PByte;
begin

 while True do
  begin
    if FTestUsoData <> tudNone then
     begin
      if c >= Length(Tst_Data) then c := 0;
      if Tst_Data[c] then FData[i] := 1 else FData[i] := - 1;
      Inc(c);
     end;
    inc(i);
    if i = Length(FData) then
     begin
      i := 0;
      NotifyData;
      if Assigned(FSubDevice) then FSubDevice.InputData(@FData[0], Length(FData));
      Exit;
     end;
  end;

 { p := Data;
  with RecRun do while DataSize > 0 do
   begin
    if HSync then
     begin
      Buff[Ncanal] := p^;
      Inc(Ncanal);
      if Ncanal >= 3 then
       begin
        SumDat := SumDat + SmallInt(Swap(wrd));
        Inc(Nfq);
        if Nfq >= FKSum then
         begin
          Nfq := 0;
          FData[i] := SumDat / FKSum * 0.0625;
          if FTestUsoData <> tudNone then
           begin
            if c >= Length(Tst_Data) then c := 0;
            if Tst_Data[c] then FData[i] := 1 else FData[i] := - 1;
            Inc(c);
           end;
          SumDat := 0;
          inc(i);
          if i = Length(FData) then
           begin
            i := 0;
            NotifyData;
            if Assigned(FSubDevice) then FSubDevice.InputData(@FData[0], Length(FData));
           end;
         end;
        Ncanal := 0;
        HSync := False;
        LSync := False;
       end;
     end
    else
     if LSync=False then
      begin
       if P^ = $a5 then LSync := True;
      end
     else
      begin
       if P^ = $5a then HSync := True;
      end;
    Dec(DataSize);
    Inc(p);
   end;   }
end;

procedure TUso1.SetFrequency(const Value: TTelesisFrequency);
begin
  if FFrequency <> Value then
   begin
    FFrequency := Value;
    case FFrequency of
        afq40: FKSum := 1;
        afq20: FKSum := 1;
        afq10: FKSum := 1;
         afq5: FKSum := 2;
       afq2p5: FKSum := 4;
      afq1p25: FKSum := 8;
    end;
    Owner.PubChange;
   end;
end;

procedure TUso1.SetTestUsoData(const Value: TTestUsoData);
 var
  cb: Boolean;
  d, i: Integer;
  a: TArray<Word>;
begin
  if FTestUsoData <> Value then
   begin
    FTestUsoData := Value;
    SetLength(Tst_Data, 0);
    cb := True;
    CreateSuncro(8, cb, Tst_Data);
    case FTestUsoData of
     tudNone: SetLength(Tst_Data, 0);
     tudFibonach:
      begin
       SetLength(a, 16);
       Decode($9249, d);
       for I := 0 to Length(a)-1 do a[i] := d;
       Encode(a, 8, cb, Tst_Data);
//       Encode([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 8, cb, Tst_Data);
      end;
     tudRMCod: EncodeRM([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31], 8, Tst_Data);
     tudFSK:
      begin
       EncodeFSK([2583, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 8, Tst_Data);
      end;
     tudFibonachCorr:
      begin
       SetLength(a, 16);
       Decode($9249, d);
       for I := 0 to Length(a)-1 do a[i] := d;
       Encode(a, 8, Tst_Data);
      // Encode([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], 8, Tst_Data);
      end;
    end;
    Owner.PubChange;
   end;
end;

{$ENDREGION}

{$REGION 'PalseFlt, bitFlt'}

{ TfltFFT }

constructor TbitFlt.Create;
begin
  inherited;
  InitConst('TBitOscForm', 'BitForm_');
end;

procedure TbitFlt.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TbitFlt.GetCaption: string;
begin
  Result := 'Фильтр BIT'
end;

function TbitFlt.GetCategory: TSubDeviceInfo;
begin
  Result := TELESIS_STRUCURE[3];
end;

procedure TbitFlt.InputData(Data: Pointer; DataSize: integer);
  const
   {$J+} j: Integer = 0; {$J-}
 var
  a: PDoubleArray;
  i: Integer;
  FData: TArray<Double>;
begin
   a := Data;
   SetLength(FData, DataSize);
   FS_Data.Data := @Fdata[0];
   FS_Data.Size := DataSize;
   for i := 0 to DataSize-1 do
    begin
     FData[i] := a^[i]+Ffifo[j];
     Ffifo[j] := a^[i];
     j := (j+1) mod Length(Ffifo);
    end;
    NotifyData;
    if Assigned(FSubDevice) then FSubDevice.InputData(@FData[0], DataSize);
end;

{ TPalseFlt }

constructor TPalseFlt.Create;
begin
  inherited;
  InitConst('TPalsOscForm', 'PalsForm_');
end;

procedure TPalseFlt.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TPalseFlt.GetCaption: string;
begin
  Result := 'Фильтр ОИ'
end;

function TPalseFlt.GetCategory: TSubDeviceInfo;
begin
  Result := TELESIS_STRUCURE[3];
end;

procedure TPalseFlt.InputData(Data: Pointer; DataSize: integer);
  const
   {$J+} j: Integer = 0; {$J-}
 var
  a: PDoubleArray;
  i, k: Integer;
  sum: Double;
  FData: TArray<Double>;
begin
   a := Data;
   SetLength(FData, DataSize);
   FS_Data.Data := @Fdata[0];
   FS_Data.Size := DataSize;
   for i := 0 to DataSize-1 do
    begin
     Ffifo[j] := a^[i];
     j := (j+1) mod Length(Ffifo);
     sum := 0;
     for k := 0 to Length(Ffifo)-1 do sum := sum + Ffifo[k];
     FData[i] := sum / Length(Ffifo);
    end;
    NotifyData;
    if Assigned(FSubDevice) then FSubDevice.InputData(@FData[0], DataSize);
end;

{ TPalseFlt2 }

function TPalseFlt2.GetCaption: string;
begin
  Result := 'Фильтр ОИ (hidden)'
end;

function TPalseFlt2.GetCategory: TSubDeviceInfo;
begin
  Result := TELESIS_STRUCURE[1];
end;

{$ENDREGION}

{$REGION 'TFltBPF'}

procedure TFltBPF.FNCH(from, too: Integer);
 var
  i: Integer;
begin
  for i := 0 to from do FltCoeff[i] := 0;
  for i := from to too do FltCoeff[i] := Sin((i-from) * PI/2 / (too-from));
end;
procedure TFltBPF.FBCH(from, too: Integer);
 var
  i: Integer;
begin
  for i := from to too do FltCoeff[i] := Cos((i-from) * PI/2 / (too-from));
  for i := too to FFT_AMP_LEN div 4 do FltCoeff[i] := 0;
end;

constructor TFltBPF.Create;
 var
  i: Integer;
begin
  if not Assigned(FFourier) then {FFourier := TFFourier.Create;} FourierFactory(FFourier);
  SetLength(FdataIn, FFT_LEN);
  SetLength(FDataOut, FFT_LEN);
  // особые точки 0 и максимальная гармоника n/2 не нужны приравниваем 0 при фильтровании
  //       1 == n-1 .... n/2-1 = n/2+1
  //      0 1..n/2-1 n/2 n/2+1..n-1
  SetLength(FltCoeff, FFT_AMP_LEN-1); // нет 0
  for i := 0 to FFT_AMP_LEN div 4-1  do FltCoeff[i] := 1;

//  FNCH(9, 17);
//  FBCH(Round(m-m/1.7), Round(m-m/3));

  SetLength(FFdata, FFT_AMP_LEN);
  SetLength(FFdataFlt, FFT_AMP_LEN);
  FS_Data.FF := @FFdata[0];
  FS_Data.FFFiltered := @FFdataFlt[0];
  FS_Data.FFTSize := FFT_AMP_LEN;
  FS_Data.InData := @FdataIn[FFT_OVERSAMP];
  FS_Data.SampleSize := FFT_SAMPLES;

  FDataCnt := FFT_OVERSAMP;

  InitConst('TFFTForm', 'FFTForm_');
  inherited;
end;

procedure TFltBPF.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TFltBPF.GetCaption: string;
begin
  Result := 'Фильтр FFT'
end;

function TFltBPF.GetCategory: TSubDeviceInfo;
begin
  Result := TELESIS_STRUCURE[1];
end;

procedure TFltBPF.InputData(Data: Pointer; DataSize: integer);
  procedure Amp(var d: TArray<Double>; co: PComplex);
   var
    i: Integer;
  begin
    for i := 0 to Length(d) - 1 do
     begin
      d[i] := Hypot(co.X, co.Y);
      inc(co);
     end;
  end;
  procedure ApplyFlt(co: PComplex);
   var
    i: Integer;
    ce: PComplex;
  begin
    ce := co;
    inc(ce, FFT_LEN-1); // начинаем с последней гармоники = 1 гармонике
    co.x := 0; // обнуляем 0 гармонику
    co.y := 0;
    inc(co); // начинаем с 1 гармоники
    for i := 0 to Length(FltCoeff)-1 do
     begin
      co.x := FltCoeff[i]*co.x;
      co.y := FltCoeff[i]*co.y;
      ce.x := FltCoeff[i]*ce.x;
      ce.y := FltCoeff[i]*ce.y;
      Inc(co);
      Dec(ce);
     end;
    co.x := 0; // обнуляем N/2 гармонику
    co.y := 0;
  end;
  procedure CosFlt;
   var
    i: Integer;
    k: Double;
  begin
    for i := 0 to FFT_OVERSAMP-1 do
     begin
      k := Sin(i/FFT_OVERSAMP*PI/2);
      FDataOut[i] := FDataOut[i] * k;
      FDataOut[FFT_LEN-1-i] := FDataOut[FFT_LEN-1-i] * k;
     end;
  end;
  var
   c: PComplex;
begin
  Move(Data^, FDataIn[FDataCnt], DataSize*Sizeof(Double));
  Inc(FDataCnt, DataSize);
  if FDataCnt = FFT_LEN then
   begin
    Move(FDataIn[0], FDataOut[0], FFT_LEN*Sizeof(Double));

 //   CosFlt();

    CheckMath(FFourier, FFourier.fft(@FDataOut[0], FFT_LEN));
    CheckMath(FFourier, FFourier.GetLastFF(c));
    Amp(FFData, c);
    ApplyFlt(c);
    Amp(FFDataFlt, c);
    CheckMath(FFourier, FFourier.ifft(FS_Data.OutData));

    inc(FS_Data.OutData, FFT_OVERSAMP);

    DoOutputData(FS_Data.OutData, FFT_SAMPLES);

    Move(FDataIn[FFT_SAMPLES], FDataIn[0], FFT_OVERSAMP*2*Sizeof(Double));
    FDataCnt := FFT_OVERSAMP*2;

   end
  else if FDataCnt > FFT_LEN then raise EBaseException.Create('FDataCnt > FFT_LEN');
end;

procedure TFltBPF.DoOutputData(Data: Pointer; DataSize: integer);
begin
  NotifyData;
  if Assigned(FSubDevice) then FSubDevice.InputData(Data, DataSize);
end;

procedure TFltBPF.OnUserRemove;
begin
  inherited;
  if Assigned(FSubDevice) and (FDataCnt > FFT_OVERSAMP) then FSubDevice.InputData(@FDataIn[FFT_OVERSAMP], FDataCnt - FFT_OVERSAMP);
end;

{$ENDREGION}


{ TDecoder1}

constructor TDecoder1.Create;
begin
  inherited;
  InitConst('TDecoderECHOForm', 'DecoderECHO_');
end;

procedure TDecoder1.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TDecoder1.GetCaption: string;
begin
  Result := 'Декодер-RM'
end;

function TDecoder1.GetDecoderClass: TDecoderClass;
begin
  Result := TTelesistemDecoder;
end;

{ TDecoder2 }

constructor TDecoder2.Create;
begin
  inherited;
  InitConst('TDecoderECHOForm', 'DecoderECHO_');
  DataCnt := 16;
  DataCodLen := 17;
  FIsMul := True;
  FFltZerro := True;
end;

procedure TDecoder2.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TDecoder2.GetCaption: string;
begin
  Result := 'Декодер-F'
end;

function TDecoder2.GetDecoderClass: TDecoderClass;
begin
  Result := TFibonachiDecoder;
end;

procedure TDecoder2.SetFltZerro(const Value: Boolean);
begin
  FFltZerro := Value;
  if Assigned(FDecoder) then TFibonachiDecoder(FDecoder).FindZeroes := Value;
  Owner.PubChange;
end;

procedure TDecoder2.SetIsMul(const Value: Boolean);
begin
  FIsMul := Value;
  if Assigned(FDecoder) then TFibonachiDecoder(FDecoder).AlgIsMull := Value;
  Owner.PubChange;
end;

procedure TDecoder2.SetupNewDecoder;
begin
  inherited;
  TFibonachiDecoder(FDecoder).AlgIsMull := FIsMul;
  TFibonachiDecoder(FDecoder).FindZeroes := FFltZerro;
end;

{ TDecoder3 }

constructor TDecoder3.Create;
begin
  inherited;
  InitConst('TDecoderECHOForm', 'DecoderECHO_');
  DataCnt := 16;
  DataCodLen := 34;
end;

procedure TDecoder3.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TDecoder3.GetCaption: string;
begin
  Result := 'Декодер-FSK'
end;

function TDecoder3.GetDecoderClass: TDecoderClass;
begin
  Result := TFSKDecoder;
end;

{ TDecoder4 }

constructor TDecoder4.Create;
begin
  inherited;
  InitConst('TDecoderECHOForm', 'DecoderECHO_');
  DataCnt := 16;
  DataCodLen := 18;
  FCorLen := 2;
end;

procedure TDecoder4.DoSetup(Sender: IAction);
begin
  inherited;
end;

function TDecoder4.GetCaption: string;
begin
  Result := 'Декодер-корр-фиб'
end;

function TDecoder4.GetDecoderClass: TDecoderClass;
begin
  Result := TCorFibonachDecoder;
end;

procedure TDecoder4.SetCorLen(const Value: Integer);
begin
  FCorLen := Value;
  if Assigned(FDecoder) then TCorFibonachDecoder(FDecoder).SimbLen := Value;
  Owner.PubChange;
end;

procedure TDecoder4.SetupNewDecoder;
begin
  inherited;
  TCorFibonachDecoder(FDecoder).SimbLen := FCorLen;
end;

initialization
  RegisterClasses([TTelesistem, TUso1, TDecoder1, TDecoder2, TDecoder3, TDecoder4, TbitFlt, TFltBPF, TPalseFlt, TPalseFlt2]);
  TRegister.AddType<TTelesistem, IDevice>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TUso1, ITelesistem>.LiveTime(ltTransientNamed);
//  TRegister.AddType<TUso2, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TbitFlt, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TFltBPF, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TPalseFlt, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TPalseFlt2, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TDecoder1, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TDecoder2, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TDecoder3, ITelesistem>.LiveTime(ltTransientNamed);
  TRegister.AddType<TDecoder4, ITelesistem>.LiveTime(ltTransientNamed);
//  TRegister.AddType<TDecoderFibonach, ITelesistem>.LiveTime(ltTransientNamed);
//  TRegister.AddType<TCorrelate, ITelesistem>.LiveTime(ltTransientNamed);
finalization
  GContainer.RemoveModel<TTelesistem>;
  GContainer.RemoveModel<TUso1>;
//  GContainer.RemoveModel<TUso2>;
  GContainer.RemoveModel<TbitFlt>;
  GContainer.RemoveModel<TPalseFlt>;
  GContainer.RemoveModel<TPalseFlt2>;
  GContainer.RemoveModel<TFltBPF>;
  GContainer.RemoveModel<TDecoder1>;
  GContainer.RemoveModel<TDecoder2>;
  GContainer.RemoveModel<TDecoder3>;
  GContainer.RemoveModel<TDecoder4>;
//  GContainer.RemoveModel<TCorrelate>;
//  GContainer.RemoveModel<TDecoderFibonach>;
end.
