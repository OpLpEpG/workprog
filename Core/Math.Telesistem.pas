unit Math.Telesistem;

interface

uses System.SysUtils, Fibonach, MathIntf, System.Math;

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
    ///	  проверка СП в состоянии csCode
    ///	</summary>
   csCode,
    ///	<summary>
    ///	  принято решение о потере синхронизации из-за множества ошибок
    ///   и начале поиска СП
    ///	</summary>
   csCheckSP,
    ///	<summary>
    ///	  выдаются коды
    ///	</summary>
   csBadCodes,
    ///	<summary>
    ///	  пользователь принял решение о потере синхронизации
    ///   и начале поиска СП
    ///	</summary>
   csUserToFindSP);
{$ENDREGION}

   TFindSPRef = reference to procedure(EventState: TCorrelatorState; const corr: TArray<Double>);

   PTelesistemDecoder = ^TTelesistemDecoder;
   TTelesistemDecoder = record
   private
     Buf: TArray<Double>;
     ///	<summary>
     ///	  Глобальный указатель на Buf после Index все данные обработаны
     ///    значение меняется с приходом новых данных но содержимое Buf[Index] не меняется
     ///	</summary>
     Index: integer;
     function BufMaxLen: Integer; inline;
     function BufSPLen: Integer; inline;
     function GetCount: Integer; inline;
   public
     Bits, DataCnt, DataLen, SPLen: Integer;
     State: TCorrelatorState;
     constructor Create(ABits, ADataCnt, ADataLen, ASPLen: Integer);
     procedure AddData(data: PDouble; len: Integer);
     property Count: Integer read GetCount;
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
                          Min1Index: Integer;);
       csSP:           ();
       csCode:         ();
       csBadCodes:     ();
       csUserToFindSP: ();
   end;

function CorrSP(var d: TTelesistemDecoder; idx, cnt: Integer): TArray<Double>;

procedure FindSP(var d: TTelesistemDecoder; event: TFindSPRef);

implementation

procedure FindSP(var d: TTelesistemDecoder; event: TFindSPRef);
 var
  cnt: Integer;
  corr: TArray<Double>;
begin
  Assert(not (d.State in [csFindSP, csCheckSP]), 'not (d.State in [csFindSP, csCheckSP]');
  cnt := d.Count - d.FindSPCount - d.BufSPLen + 1;
  if cnt > 0 then
   begin
    corr := CorrSP(d, d.FindSPCount, cnt);
    // особый случай когда СП в перыых 16 тактах  |SP|_____|SP|
    if d.FindSPCount >= d.BufMaxLen then
     begin
      inc(d.Index, d.BufMaxLen - d.BufSPLen);
      d.Max1 := 0;
      d.Max2 := 0;
      d.Max1Index := 0;
      d.Min1Index := 0;
      d.FindSPCount := 0;
     end
    else event(csFindSP, corr);
   end;
end;

function CorrSP(var d: TTelesistemDecoder; idx, cnt: Integer): TArray<Double>;
 const
  SPLEN = 128;
  SP: array [0..SPLEN-1] of integer =
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
  Assert(d.SPLen <> SPLEN, 'd.SPLen <> Length(SP)');
  Assert(d.Index + idx + cnt > Length(d.Buf) - d.BufSPLen, 'idx + cnt > Length(d.Buf) - Length(SP) * d.Bits');
  SetLength(Result, cnt);
  with d do for n := 0 to cnt-1 do
   begin
    Result[n] := 0;
    for i := 0 to SPLEN-1 do for j := 0 to Bits-1 do Result[n] := Result[n] + SP[i] * Buf[Index + Idx + i*Bits + j];
    Result[n] := Result[n]/Bits/SPLEN;
     if  Max2 < Result[n] then
      begin
       if  Max1 < Result[n] then
        begin
         if idx > Max1Index + Bits then Max2 := Max1;
         Max1Index := idx;
         Max1 := Result[n];
        end
       else if idx > Max1Index + Bits then Max2 := Result[n];
      end;
     if  Min2 > Result[n] then
      begin
       if  Min1 > Result[n] then
        begin
         if idx > Min1Index + Bits then Min2 := Min1;
         Min1Index := idx;
         Min1 := Result[n];
        end
       else if idx > Min1Index + Bits then Min2 := Result[n];
      end;
    Inc(Idx);
   end;
  Inc(d.FindSPCount, cnt);
end;

{ TTelesistemDecoder }

constructor TTelesistemDecoder.Create(ABits, ADataCnt, ADataLen, ASPLen: Integer);
begin
  Bits := ABits;
  DataCnt := ADataCnt;
  DataLen := ADataLen;
  SPLen := ASPLen
end;

function TTelesistemDecoder.BufMaxLen: Integer;
begin
  Result := Bits * (DataCnt * DataLen + SPLen)
end;

function TTelesistemDecoder.BufSPLen: Integer;
begin
  Result := Bits * SPLen
end;

function TTelesistemDecoder.GetCount: Integer;
begin
  Result := Length(Buf)- Index;
end;

procedure TTelesistemDecoder.AddData(data: PDouble; len: Integer);
 var
  n: Integer;
begin
  n := Length(Buf);
  SetLength(Buf, n+len);
  Move(data^, Buf[n], len*SizeOf(Double));
  n := Length(Buf) - BufMaxLen*2;
  if n > 0 then
   begin
    Delete(Buf,0, n);
    Dec(Index, n);
    Assert(Index < 0, 'Index < 0');
   end;
end;

end.
