unit CRC16;

interface

uses  System.SysUtils;

function  runCRC16( Data: Pbyte; First, Count: word; var CRCLo, CRCHi: byte): word;

procedure  SetCRC16(Data: Pbyte; Count, CRCFirst: word); overload;
procedure  SetCRC16( Data: Pbyte; Count: word);  overload;

function TestCRC16(Data: Pbyte; Count, CRCFirst: word): boolean; overload;
function  TestCRC16(Data: Pbyte; Count: word): boolean; overload;

function  RVCRC16(Data: Pbyte; First: Word; Count: Integer): word;

function GetCRC8(const Buffer; Size: Integer): Byte;

var DefaultCRCFirst: Word = $FFFF;

const RIVAS_CRC_FIRST = $3BAC; 

implementation

const
TCRCHi:array[byte] of byte=(
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$01,$C0,$80,$41,$00,$C1,$81,$40,$00,$C1,$81,$40,$01,$C0,$80,$41,
$00,$C1,$81,$40,$01,$C0,$80,$41,$01,$C0,$80,$41,$00,$C1,$81,$40);
TCRCLo:array[byte] of byte=(
$00,$C0,$C1,$01,$C3,$03,$02,$C2,$C6,$06,$07,$C7,$05,$C5,$C4,$04,
$CC,$0C,$0D,$CD,$0F,$CF,$CE,$0E,$0A,$CA,$CB,$0B,$C9,$09,$08,$C8,
$D8,$18,$19,$D9,$1B,$DB,$DA,$1A,$1E,$DE,$DF,$1F,$DD,$1D,$1C,$DC,
$14,$D4,$D5,$15,$D7,$17,$16,$D6,$D2,$12,$13,$D3,$11,$D1,$D0,$10,
$F0,$30,$31,$F1,$33,$F3,$F2,$32,$36,$F6,$F7,$37,$F5,$35,$34,$F4,
$3C,$FC,$FD,$3D,$FF,$3F,$3E,$FE,$FA,$3A,$3B,$FB,$39,$F9,$F8,$38,
$28,$E8,$E9,$29,$EB,$2B,$2A,$EA,$EE,$2E,$2F,$EF,$2D,$ED,$EC,$2C,
$E4,$24,$25,$E5,$27,$E7,$E6,$26,$22,$E2,$E3,$23,$E1,$21,$20,$E0,
$A0,$60,$61,$A1,$63,$A3,$A2,$62,$66,$A6,$A7,$67,$A5,$65,$64,$A4,
$6C,$AC,$AD,$6D,$AF,$6F,$6E,$AE,$AA,$6A,$6B,$AB,$69,$A9,$A8,$68,
$78,$B8,$B9,$79,$BB,$7B,$7A,$BA,$BE,$7E,$7F,$BF,$7D,$BD,$BC,$7C,
$B4,$74,$75,$B5,$77,$B7,$B6,$76,$72,$B2,$B3,$73,$B1,$71,$70,$B0,
$50,$90,$91,$51,$93,$53,$52,$92,$96,$56,$57,$97,$55,$95,$94,$54,
$9C,$5C,$5D,$9D,$5F,$9F,$9E,$5E,$5A,$9A,$9B,$5B,$99,$59,$58,$98,
$88,$48,$49,$89,$4B,$8B,$8A,$4A,$4E,$8E,$8F,$4F,$8D,$4D,$4C,$8C,
$44,$84,$85,$45,$87,$47,$46,$86,$82,$42,$43,$83,$41,$81,$80,$40);

function  runCRC16( Data: Pbyte; First, Count: word; var CRCLo, CRCHi: byte): word;
 var
  i,t: integer;
begin
  CRCLo := Byte(First shr 8);//$FF;
  CRCHi := Byte(First); //$FF;
//  CRCLo := First;//$FF;
//  CRCHi := First shr 8; //$FF;
  for i:=0 to Count-1 do
   begin
    t := CRCHi xor Data^;
    CRCHi := CRCLo xor TCRCHi[t];
    CRCLo := TCRCLo[t];
    inc(Data);
   end;
  i := CRCLo;
  CRCLo := CRCHi;
  CRCHi := i;
  Result := word(CRCHi shl 8 or CRCLo);
end;

function TestCRC16(Data: Pbyte; Count, CRCFirst: word): boolean; overload;
 var
  CRCLo, CRCHi: byte;
begin
  Result:=false;
  runCRC16(Data, CRCFirst, Count-2, CRCLo, CRCHi);
  inc(Data,Count-2);
  if Data^ = CRCLo then
   begin
    inc(Data);
    if Data^ = CRCHi then Result := True;
   end
end;

function TestCRC16(Data: Pbyte; Count: word): boolean; overload;
 var
  CRCLo, CRCHi: byte;
begin
  Result := false;
  if count < 2 then Exit;
  runCRC16(Data, DefaultCRCFirst, Count-2, CRCLo, CRCHi);
  inc(Data,Count-2);
  if Data^ = CRCLo then
   begin
    inc(Data);
    if Data^ = CRCHi then Result := True;
   end
end;

procedure  SetCRC16(Data: Pbyte; Count, CRCFirst: word); overload;
 var
  CRCLo, CRCHi: byte;
begin
  runCRC16(Data, CRCFirst, Count, CRCLo, CRCHi);
  inc(Data,Count);
  Data^:=CRCLo;
  inc(Data);
  Data^:=CRCHi;
end;

procedure  SetCRC16( Data: Pbyte; Count: word); overload;
 var
  CRCLo, CRCHi: byte;
begin
  runCRC16(Data, DefaultCRCFirst, Count, CRCLo, CRCHi);
  inc(Data,Count);
  Data^:=CRCLo;
  inc(Data);
  Data^:=CRCHi;
end;

function  RVCRC16(Data: Pbyte; First: Word; Count: Integer): word;
 var
  CRCLo, CRCHi, t: byte;
  i: integer;
begin
  CRCHi := First shr 8;//$FF;
  CRCLo := First; //$FF;
  for i:=0 to Count-1 do
   begin
    t := CRCHi xor Data^;
    CRCHi := CRCLo xor TCRCHi[t];
    CRCLo := TCRCLo[t];
    inc(Data);
   end;
  i := CRCLo;
  CRCLo := CRCHi;
  CRCHi := i;
  Result := word(CRCHi shl 8 or CRCLo);
end;
{function RVTestCRC16(Data: Pbyte; First, Count: word): boolean;
 var
  CRCLo, CRCHi: byte;
begin
  Result:=false;
  runCRC16(Data, First, Count-2, CRCLo, CRCHi);
  inc(Data,Count-2);
  if Data^ = CRCLo then
   begin
    inc(Data);
    if Data^ = CRCHi then Result := True;
   end
end;

procedure RVSetCRC16(Data: Pbyte; First, Count: word);
 var
  CRCLo, CRCHi: byte;
begin
  runCRC16(Data, First, Count, CRCLo, CRCHi);
  inc(Data,Count);
  Data^:=CRCLo;
  inc(Data);
  Data^:=CRCHi;
end;}


function GetCRC8(const Buffer; Size: Integer): Byte;
 const
  CRCTable : array [0..255] of byte = (
    0,94,188,226,97,63,221,131,194,156,126,32,163,253,31,65,
    157,195,33,127,252,162,64,30,95,1,227,189,62,96,130,220,
    35,125,159,193,66,28,254,160,225,191,93,3,128,222,60,98,
    190,224,2,92,223,129,99,61,124,34,192,158,29,67,161,255,
    70,24,250,164,39,121,155,197,132,218,56,102,229,187,89,7,
    219,133,103,57,186,228,6,88,25,71,165,251,120,38,196,154,
    101,59,217,135,4,90,184,230,167,249,27,69,198,152,122,36,
    248,166,68,26,153,199,37,123,58,100,134,216,91,5,231,185,
    140,210,48,110,237,179,81,15,78,16,242,172,47,113,147,205,
    17,79,173,243,112,46,204,146,211,141,111,49,178,236,14,80,
    175,241,19,77,206,144,114,44,109,51,209,143,12,82,176,238,
    50,108,142,208,83,13,239,177,240,174,76,18,145,207,45,115,
    202,148,118,40,171,245,23,73,8,86,180,234,105,55,213,139,
    87,9,235,181,54,104,138,212,149,203,41,119,244,170,72,22,
    233,183,85,11,136,214,52,106,43,117,151,201,74,20,246,168,
    116,42,200,150,21,75,169,247,182,232,10,84,215,137,107,53);
 var
  Buf: PByte;
begin
  Buf := @Buffer;
  Result := 0;
  repeat
   Result := CRCTable[Result xor Buf^];
   inc(Buf);
   Dec(Size);
  until Size = 0;
end;
end.
