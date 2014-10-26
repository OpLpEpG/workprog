unit Math.Telesistem;

interface

uses System.SysUtils, System.Classes, Fibonach, MathIntf, System.Math, debug_except;

type
{$REGION 'TCorrelatorState'}
   TCorrelatorState = (
    ///	<summary>
    ///	  Поиск СП, длительный процесс
    ///	</summary>
   csFindSP,
    ///	<summary>
    ///	  принятие решения о синхронизации
    ///	</summary>
   csSP,
    ///	<summary>
    ///	  выдаются коды
    ///	</summary>
   csCode,
    ///	<summary>
    ///	  проверка СП в состоянии csCode
    ///	</summary>
   csCheckSP,
    ///	<summary>
    ///	  принято решение о потере синхронизации из-за множества ошибок
    ///   и начале поиска СП
    ///	</summary>
   csBadCodes,
    ///	<summary>
    ///	  пользователь принял решение о потере синхронизации
    ///   и начале поиска СП
    ///	</summary>
   csUserToFindSP,
    ///	<summary>
    ///	  пользователь принял решение о синхронизации
    ///	</summary>
   csUserToSP);

{$ENDREGION}

   TTelesistemDecoder = class
   public
    type
     TFindSPData = record
      Max1: Double;
      Max2: Double;
      Min1: Double;
      Min2: Double;
     ///	<summary>
     ///	  Локальный счетчик поиска ср SP
     ///	</summary>
      FindSPCount: Integer;
     ///	<summary>
     ///	  Локальные указательи на Buf
     ///    Buf[Index + Max1Index] не меняется
     ///	</summary>
      Max1Index: Integer;
      Min1Index: Integer;
      Max2Index: Integer;
      Min2Index: Integer;
      Corr: TArray<Double>;
     end;
     TSPData = record
      Faza: Integer;
      Idx: Integer;
      Amp: Double;
      Porog: Double;
      Corr: TArray<Double>;
     end;
     TCodData = record
      Code: Integer;
      Porog : Double;
      IsBad: Boolean;
      Corr: TArray<Double>;
     end;
     TPaketCodes = record
      CodeCnt: Integer;
      BadCodes: Integer;
      CodData: TArray<TCodData>;
     end;
     TCheckSPData = record
      FazaNew: Integer;
      Dkadr: Integer;
      Amp: Double;
      Porog : Double;
      Corr: TArray<Double>;
     end;
   private
     // установки пакета
     FBits, FDataCnt, FDataCodLen, FSPcodLen: Integer;
     // состояние автомата
     FState: TCorrelatorState;

     FAmpPorogSP: Double;
     FPorogSP: Double;
     FPorogCod: Double;
     FPorogBadCodes: Integer;
     // поиск СП
     FFindSPData: TFindSPData;
     // СП
     FSPData: TSPData;
    FCodes: TPaketCodes;
    FCheckSPData: TCheckSPData;
     procedure SetState(const Value: TCorrelatorState);
     function GetFindSPData: TFindSPData;
     procedure RunAutomat;
   protected
     Buf: TArray<Double>;
     ///	<summary>
     ///	  Глобальный указатель на Buf после Index все данные обработаны
     ///    значение меняется с приходом новых данных но содержимое Buf[Index] не меняется
     ///	</summary>
     Index: integer;
     // польсобытие
     FEvent: TNotifyEvent;

     function GetDataLen: Integer; virtual;
     function GetKadrLen: Integer; virtual;
     function GetSPLen: Integer; virtual;
     function GetCount: Integer; virtual;
     function GetBuffer: PDoubleArray; virtual;

     function CorrSP(var fs: TFindSPData; idx, cnt: Integer): TArray<Double>; virtual;
     function CorrCode(var cd: TCodData):Integer; virtual;

     procedure ForceState(const Value: TCorrelatorState);

     property Count: Integer read GetCount;
     property Buffer: PDoubleArray read GetBuffer;
     class function ToPorog(Amp, Amp2: Double): Double; static; inline;
   public
     constructor Create(ABits, ADataCnt, ADataCodLen, ASPCodLen: Integer; AEvent: TNotifyEvent);
     procedure AddData(data: PDouble; len: Integer);

     property State: TCorrelatorState read FState write SetState;
     // константы
     property KadrLen: Integer read GetKadrLen;
     property SPLen: Integer read GetSPLen;
     property DataLen: Integer read GetDataLen;

     property SPCodLen: Integer read FSPcodLen;
     property DataCnt: Integer read FDataCnt;
     property DataCodLen: Integer read FDataCodLen;
     property Bits: Integer read FBits;
     // пользовательские данные
     ///	<summary>
     ///	  Амплитуда СП настоько большая что можно принять решение не дожидаясь конца пакета
     ///	</summary>
     property AmpPorogSP: Double read FAmpPorogSP write FAmpPorogSP;
     ///	<summary>
     ///	  Разниза Max1 Max2 в процентах
     ///	</summary>
     property PorogSP: Double read FPorogSP write FPorogSP;
     ///	<summary>
     ///	  Разниза Max1 Max2 в процентах
     ///	</summary>
     property PorogCod: Double read FPorogCod write FPorogCod;
     property PorogBadCodes: Integer read FPorogBadCodes write FPorogBadCodes;

     property FindSPData: TFindSPData read GetFindSPData;
     property SPData: TSPData read FSPData;
     property Codes: TPaketCodes read FCodes;
     property CheckSPData: TCheckSPData read FCheckSPData;
   end;
   TDecoderClass = class of TTelesistemDecoder;

implementation

{$REGION 'TTelesistemDecoder'}

{ TTelesistemDecoder }

constructor TTelesistemDecoder.Create(ABits, ADataCnt, ADataCodLen, ASPCodLen: Integer; AEvent: TNotifyEvent);
begin
  FBits := ABits;
  FDataCnt := ADataCnt;
  FDataCodLen := ADataCodLen;
  FSPcodLen := ASPCodLen;
  FEvent := AEvent;
            //ADC USO 16 бит
  FAmpPorogSP := $8000 * 0.85;
  FPorogSP := 70;  //%
  FPorogCod := 50; //%
  FPorogBadCodes := FDataCnt div 2;
end;

function TTelesistemDecoder.GetKadrLen: Integer;
begin
  Result := Bits * (DataCnt * DataCodLen + SPcodLen + 1)
end;

function TTelesistemDecoder.GetSPLen: Integer;
begin
  Result := Bits * SPcodLen
end;

function TTelesistemDecoder.GetBuffer: PDoubleArray;
begin
  Result := @Buf[Index];
end;

function TTelesistemDecoder.GetCount: Integer;
begin
  Result := Length(Buf)- Index;
end;

function TTelesistemDecoder.GetDataLen: Integer;
begin
  Result := Bits * DataCodLen;
end;

function TTelesistemDecoder.GetFindSPData: TFindSPData;
begin
  Assert(FState = csFindSP, 'FState <> csFindSP');
  Result := FFindSPData;
end;

procedure TTelesistemDecoder.SetState(const Value: TCorrelatorState);
begin
  if FState <> Value then ForceState(Value);
end;

procedure TTelesistemDecoder.ForceState(const Value: TCorrelatorState);
begin
  FState := Value;
  case Value of
    csFindSP: with FFindSPData do
     begin
      Max1 := 0;
      Max2 := 0;
      Min1 := 0;
      Min2 := 0;
      Max1Index := 0;
      Min1Index := 0;
      Max2Index := 0;
      Min2Index := 0;
      FindSPCount := 0;
     end;
    csCode: with FCodes do
     begin
      CodeCnt := 0;
      BadCodes := 0;
      SetLength(CodData, DataCnt);
     end;
  end;
end;

procedure TTelesistemDecoder.AddData(data: PDouble; len: Integer);
 var
  n: Integer;
begin
  n := Length(Buf);
  SetLength(Buf, n+len);
  Move(data^, Buf[n], len*SizeOf(Double));
  n := Length(Buf) - KadrLen*2;
  if n > 0 then
   begin
    Delete(Buf,0, n);
    Dec(Index, n);
    Assert(Index >= 0, 'Index < 0');
   end;
  RunAutomat;
end;

function TTelesistemDecoder.CorrCode(var cd: TCodData): Integer;
 const RMCBIN: array [0..31, 0..31] of Integer =(
  (-1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1),
  (-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1),
  (-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1),
  (-1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1),
  (-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1),
  (-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1),
  (-1, 1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1),
  (-1, 1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1),
  (-1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1),
  (-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1),
  (-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1),
  (-1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1),
  (-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1),
  (-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1),
  (-1, 1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1),
  (-1, 1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1),
  ( 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1),
  ( 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1),
  ( 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1),
  ( 1,-1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1),
  ( 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1),
  ( 1,-1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1),
  ( 1,-1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1),
  ( 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1),
  ( 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1),
  ( 1,-1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1),
  ( 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1),
  ( 1,-1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1),
  ( 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1),
  ( 1,-1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1),
  ( 1,-1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1),
  ( 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1,-1, 1));

 var
    m, c, j, i: Integer;
    mx1,  mx2: Double;
    mxi1: Integer;
begin
  SetLength(cd.Corr, 32);
  mxi1 := 0;
  mx1 := 0;
  mx2 := 0;
  for c := 0 to 31 do
   begin
    m := 0;
    for i := 0 to 31 do for j := 0 to Bits-1 do
     begin
      cd.Corr[c] := cd.Corr[c] + RMCBIN[c,i] * buffer[m];
      Inc(m);
     end;
    cd.Corr[c] := cd.Corr[c]/32/Bits;
    if FSPData.Faza = -1 then cd.Corr[c] := -cd.Corr[c];
    if cd.Corr[c] >= mx1 then
     begin
      mx2 := mx1;
      mx1 := cd.Corr[c];
      mxi1 := c;
     end;
   end;
  cd.Code := mxi1;
  cd.Porog := ToPorog(mx1, mx2);
  cd.IsBad := cd.Porog < PorogCod;
  if cd.IsBad then Result := 1 else Result := 0;
end;

function TTelesistemDecoder.CorrSP(var fs: TFindSPData; idx, cnt: Integer): TArray<Double>;
 const
  CSPCODLEN = 128;
  SP: array [0..CSPCODLEN-1] of integer =
         ( -1, 1,-1, 1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,
            1,-1, 1,-1, 1,-1,-1, 1, 1,-1, 1,-1, 1,-1, 1,-1,
           -1, 1,-1, 1, 1,-1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,
            1,-1, 1,-1,-1, 1,-1, 1,-1, 1,-1, 1, 1,-1,-1, 1,
            1,-1, 1,-1, 1,-1,-1, 1,-1, 1,-1, 1, 1,-1, 1,-1,
           -1, 1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1,
           -1, 1,-1, 1,-1, 1, 1,-1,-1, 1,-1, 1, 1,-1, 1,-1,
           -1, 1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1, 1,-1,-1, 1);
 var
  i, j, n: Integer;
begin
  Assert(FSPcodLen = CSPCODLEN, Format('d.SPLen %d <> Length(SP) 128', [FSPcodLen]));
  Assert(Index + idx + cnt <= Length(Buf) - SPLen, 'idx + cnt > Length(d.Buf) - Length(SP) * d.Bits');
  SetLength(Result, cnt);
  with fs do for n := 0 to cnt-1 do
   begin
    Result[n] := 0;
    for i := 0 to CSPCODLEN-1 do for j := 0 to Bits-1 do Result[n] := Result[n] + SP[i] * Buffer[Idx + i*Bits + j];
    Result[n] := Result[n]/Bits/CSPCODLEN;
     if  Max2 < Result[n] then
      begin
       if  Max1 < Result[n] then
        begin
         if idx > Max1Index + Bits then
          begin
           Max2 := Max1;
           Max2Index := Max1Index;
          end;
         Max1Index := idx;
         Max1 := Result[n];
        end
       else if idx > Max1Index + Bits then
        begin
         Max2 := Result[n];
         Max2Index := idx;
        end;
      end;
     if  Min2 > Result[n] then
      begin
       if  Min1 > Result[n] then
        begin
         if idx > Min1Index + Bits then
          begin
           Min2 := Min1;
           Min2Index := Min1Index;
          end;
         Min1Index := idx;
         Min1 := Result[n];
        end
       else if idx > Min1Index + Bits then
        begin
         Min2 := Result[n];
         Min2Index := idx;
        end;
      end;
    Inc(Idx);
   end;
end;

class function TTelesistemDecoder.ToPorog(Amp, Amp2: Double): Double;
begin
  if Amp = 0 then Result := 0
  else Result := (1 - Amp2/Amp) * 100;
end;

procedure TTelesistemDecoder.RunAutomat;
  procedure SafeExceEvent;
  begin
    try
     FEvent(Self);
    except
     on E: Exception do TDebug.DoException(E);
    end;
  end;
  procedure SetcsSP(Fz, SPidx: Integer; spAmp, Prg: Double);
   var
    si: Integer;
    z: TArray<Double>;
    d: TFindSPData;
  begin
    with FSPData do
     begin
      Faza := Fz;
      Idx := SPidx;
      Amp := spAmp;
      Porog := Prg;
     end;
    si := FSPData.Idx - Bits*2;
    if si + Index < 0 then
     begin
      si := -si - Index;
      FSPData.Corr := CorrSP(d, 0, Bits*4 - si);
      SetLength(z, si);
      FSPData.Corr := z + FSPData.Corr;
     end
    else FSPData.Corr := CorrSP(d, si, Bits*4);
    ForceState(csSP);
    RunAutomat;
  end;
  // особый случай когда СП в перыых 8 тактах  |SP|_____|SP|
  function UniqeCaseSP(m1idx, m2idx: Integer): Boolean;
  begin
    Result := (m1idx < 3) and (m2idx > KadrLen - 3);
  end;
  procedure ResetToFindSP;
  begin
    if Index > Length(Buf) - KadrLen div 2 then Index := Length(Buf) - KadrLen div 2;
    ForceState(csFindSP);
    RunAutomat;
  end;
 var
  cnt: Integer;
  pr: Double;
  fs: TFindSPData;
begin
   case State of
    csFindSP: with FFindSPData do
     begin
      cnt := Count - FindSPCount - SPLen;
      if cnt > 0 then
       begin
        if FindSPCount + cnt > KadrLen then cnt := KadrLen - FindSPCount;
        Corr := CorrSP(FFindSPData, FindSPCount, cnt);
        Inc(FindSPCount, cnt);
        SafeExceEvent();
        if FindSPCount = KadrLen then //  конeц пакета
         begin
          if (Max1 > -Min1) then
           begin
            pr := ToPorog(Max1,  Max2);
            if (pr >= FPorogSP) or UniqeCaseSP(Max1Index, Max2Index) then
             begin
              SetcsSP( 1, Max1Index,  Max1, pr);
              Exit;
             end
           end
          else
           begin
            pr := ToPorog(-Min1, -Min2);
            if (pr >= FPorogSP) or UniqeCaseSP(Min1Index, Min2Index) then
             begin
              SetcsSP(-1, Min1Index, -Min1, pr);
              Exit;
             end;
           end;
          ForceState(csFindSP);
          inc(Index, KadrLen);
         end
        else
         // Амплитуда СП настоько большая что можно принять решение не дожидаясь конца пакета
         if (Max1 > -Min1) then
          if (Max1Index > FindSPCount + Bits*2) and (Max1 > FAmpPorogSP) then
              SetcsSP( 1, Max1Index,  Max1, ToPorog( Max1,  Max2))
          else if (Min1Index > FindSPCount + Bits*2) and (-Min1 > FAmpPorogSP) then
              SetcsSP(-1, Min1Index, -Min1, ToPorog(-Min1, -Min2));
       end;
     end;
    csSP:
     begin
      SafeExceEvent();
      inc(Index, FSPData.Idx + SPLen);
      ForceState(csCode);
      RunAutomat;
     end;
    csCode: while Count >= DataLen do with FCodes do
     begin
      Inc(BadCodes, CorrCode(CodData[CodeCnt]));
      Inc(CodeCnt);
      SafeExceEvent();
      Inc(Index, DataLen);
      if CodeCnt >= DataCnt then
       begin
        ForceState(csCheckSP);
        Exit;
       end
      else if BadCodes > PorogBadCodes then
       begin
        ForceState(csBadCodes);
        RunAutomat;
        Exit;
       end;
     end;
    csCheckSP: if Count >= SPLen + Bits*2 then with FCheckSPData do
     begin
      Corr := CorrSP(fs, -Bits*2, Bits*4);
      if fs.Max1 > -fs.Min1 then
       begin
        FazaNew := 1;
        Dkadr := fs.Max1Index;
        Amp := fs.Max1;
        Porog := ToPorog(fs.Max1, fs.Max2);
       end
      else
       begin
        FazaNew := -1;
        Dkadr := fs.Min1Index;
        Amp := -fs.Min1;
        Porog := ToPorog(-fs.Min1, -fs.Min2);
       end;
      SafeExceEvent();
      if (FazaNew = FSPData.Faza) and (Porog >= FPorogSP) and (Dkadr < 8) then
       begin
        inc(Index, SPLen + Dkadr);
        ForceState(csCode);
       end
      else ResetToFindSP;
     end;
    csBadCodes, csUserToFindSP:
     begin
      SafeExceEvent();
      ResetToFindSP;
     end;
    csUserToSP:
     begin
      SafeExceEvent();
      with FFindSPData do
       if (Max1 > -Min1) then SetcsSP( 1, Max1Index,  Max1, ToPorog( Max1,  Max2))
       else SetcsSP(-1, Min1Index, -Min1, ToPorog(-Min1, -Min2));
     end
  end;
end;


{$ENDREGION}


end.
