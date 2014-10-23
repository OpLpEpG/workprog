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

   PTelesistemDecoderData = ^TTelesistemDecoderData;
   TTelesistemDecoderData = record
   protected
     Buf: TArray<Double>;
     corr: TArray<Double>;
     ///	<summary>
     ///	  Глобальный указатель на Buf после Index все данные обработаны
     ///    значение меняется с приходом новых данных но содержимое Buf[Index] не меняется
     ///	</summary>
     Index: integer;
     // установки пакета
     FBits, FDataCnt, FDataCodLen, FSPcodLen: Integer;
     // состояние автомата
     FState: TCorrelatorState;

     function GetKadrLen: Integer; virtual;
     function GetSPLen: Integer; virtual;
     function GetCount: Integer; virtual;
     function GetBuffer: PDoubleArray; virtual;

     procedure AddData(data: PDouble; len: Integer);
    procedure SetState(const Value: TCorrelatorState);
   public
     constructor Create(ABits, ADataCnt, ADataCodLen, ASPCodLen: Integer);
     property Count: Integer read GetCount;
     property Buffer: PDoubleArray read GetBuffer;
     property KadrLen: Integer read GetKadrLen;
     property SPLen: Integer read GetSPLen;
     property State: TCorrelatorState read FState write SetState;
     property SPcodLen: Integer read FSPcodLen;
     property DataCnt: Integer read FDataCnt;
     property DataCodLen: Integer read FDataCodLen;
     property Bits: Integer read FBits;
     case TCorrelatorState of
       csFindSP, csCheckSP:
                       (  Max1: Double;
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
                          FindSpData: ^TArray<Double>);
       csSP, csCode, csBadCodes, csUserToFindSP:
                       (SPIndex: Integer;
                        Faza: Integer;
                        SpData: ^TArray<Double>);
   end;


//   TDecoder = class;
//   TDecoderEvent = procedure(Sender: TDecoder; EventState: TCorrelatorState; const corr: TArray<Double>) of object;
   TDecoder = class
   private
     FData: TTelesistemDecoderData;
    function GetData: PTelesistemDecoderData;
   protected
     FFaza: Integer;
     FEvent: TNotifyEvent;
     function CorrSP(idx, cnt: Integer): TArray<Double>; virtual;
//     function CorrCod(idx, cnt: Integer): TArray<Double>; virtual;
   public
   ///	<summary>
   ///	  Превышение основного пика SP над остальными В проц.
   ///	</summary>
     PorogSP: Real;
   ///	<summary>
   ///	  Гарантированное СП  = 0.8 max Amp Uso
   ///	</summary>
     AmpPorogSP: Real;
   ///	<summary>
   ///	  Превышение основного пика Кодов над остальными В проц.
   ///	</summary>
     PorogCode: Real;
   ///	<summary>
   ///	  Порог плохих кодов.
   ///	</summary>
     NumBadCode: Integer;
     constructor Create(ABits, ADataCnt, ADataCodLen, ASPCodLen: Integer; AEvent: TNotifyEvent);
     procedure AddData(data: PDouble; len: Integer);
     property  Data: PTelesistemDecoderData read GetData;
   end;
   TDecoderClass = class of TDecoder;

implementation

{$REGION 'TTelesistemDecoderData'}

{ TTelesistemDecoder }

constructor TTelesistemDecoderData.Create(ABits, ADataCnt, ADataCodLen, ASPCodLen: Integer);
begin
  FBits := ABits;
  FDataCnt := ADataCnt;
  FDataCodLen := ADataCodLen;
  FSPcodLen := ASPCodLen;
  FState := csSP;
  State := csFindSP;
end;

function TTelesistemDecoderData.GetKadrLen: Integer;
begin
  Result := Bits * (DataCnt * DataCodLen + SPcodLen + 1)
end;

function TTelesistemDecoderData.GetSPLen: Integer;
begin
  Result := Bits * SPcodLen
end;

function TTelesistemDecoderData.GetBuffer: PDoubleArray;
begin
  Result := @Buf[Index];
end;

function TTelesistemDecoderData.GetCount: Integer;
begin
  Result := Length(Buf)- Index;
end;

procedure TTelesistemDecoderData.AddData(data: PDouble; len: Integer);
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
end;

procedure TTelesistemDecoderData.SetState(const Value: TCorrelatorState);
begin
  if FState <> Value then
   begin
    FState := Value;
    case Value of
      csFindSP:
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
        FindSpData := @corr;
       end;
      csSP: ;
      csCode: ;
      csCheckSP: ;
      csBadCodes: ;
      csUserToFindSP: ;
    end;
   end;
end;
{$ENDREGION}


{ TDecoder }

constructor TDecoder.Create(ABits, ADataCnt, ADataCodLen, ASPCodLen: Integer; AEvent: TNotifyEvent);
begin
  FEvent := AEvent;
  FData := TTelesistemDecoderData.Create(ABits, ADataCnt, ADataCodLen, ASPCodLen);
end;

function TDecoder.GetData: PTelesistemDecoderData;
begin
  Result := @FData;
end;

function TDecoder.CorrSP(idx, cnt: Integer): TArray<Double>;
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
  Assert(FData.FSPcodLen = CSPCODLEN, Format('d.SPLen %d <> Length(SP) 128',[FData.FSPcodLen]));
  Assert(FData.Index + idx + cnt <= Length(FData.Buf) - FData.SPLen, 'idx + cnt > Length(d.Buf) - Length(SP) * d.Bits');
  SetLength(Result, cnt);
  with FData do for n := 0 to cnt-1 do
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

procedure TDecoder.AddData(data: PDouble; len: Integer);
 var
  cnt: Integer;
begin
  FData.AddData(data, len);
  with FData do case State of
    csFindSP:
     begin
      cnt := Count - FindSPCount - SPLen;
      if cnt > 0 then
       begin
       // Tdebug.Log('%d, %d, %d',[FindSPCount, cnt, KadrLen]);
        if FindSPCount + cnt > KadrLen then cnt := KadrLen - FindSPCount;
        corr := CorrSP(FindSPCount, cnt);
        FindSpData := @corr;
        Inc(FindSPCount, cnt);
        FEvent(Self);
        // особый случай когда СП в перыых 16 тактах  |SP|_____|SP|
        if FindSPCount = KadrLen then
         begin
          FState := csSP;
           State := csFindSP;
          inc(Index, KadrLen);// - SPLen);
         end
        else
         begin
          if (Max1 > -Min1) then
           if (Max1Index > FindSPCount + Bits) and (Max1 > AmpPorogSP) then
            begin
             State := csSP;
            end
           else if (Min1Index > FindSPCount + Bits) and (-Min1 > AmpPorogSP) then
            begin

            end;
         end;
       end;
     end;
    csSP: ;
    csCode: ;
    csCheckSP: ;
    csBadCodes: ;
    csUserToFindSP: ;
  end;
end;

end.
