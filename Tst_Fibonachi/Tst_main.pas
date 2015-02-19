unit Tst_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Fibonach,System.Threading, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils,
  System.Generics.Collections, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, FireDAC.Comp.UI;

type
  TFormTest = class(TForm)
    Memo: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    vld: TFDSQLiteValidate;
    Button6: TButton;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure vldProgress(ASender: TFDPhysDriverService; const AMessage: string);
  private
    rm: TArray<Cardinal>;
    n1: Cardinal;
    const NNN = 32;
  public
    FM4: array [0..3524577] of Integer;
  end;

var
  FormTest: TFormTest;



implementation

{$R *.dfm}
function IntToBin(Value: integer; Digits: integer = 16): string;
var
  i: integer;
begin
  result := '';
  for i := 0 to Digits - 1 do
    if Value and (1 shl i) > 0 then
      result := '1' + result
    else
      result := '0' + result;
end;


procedure TFormTest.Button1Click(Sender: TObject);
 var
  i, j: Integer;
  B: Integer;
  Arr: TArray<TArray<Integer>>;
  function  GlobCorr(): boolean;
   var
    n: integer;
    C: Integer;
  begin
    Result := True;
    for n := 0 to Length(Arr[High(Arr)])-1 do
     begin
      c := Arr[High(Arr)][n];
      //if B = not c then Exit(True);
      if (B = C) or (Abs(FastCorr(B, C, NNN)) <> 0) then Exit(False)
     end;
  end;
begin
  for i := High(FM4) div 2 to High(FM4) do
   begin
    SetLength(Arr, Length(Arr)+1);
    SetLength(Arr[High(Arr)], 1);
    Arr[High(Arr)][0] := $55555555;// FM4[i];
    for j := 0 to High(FM4) do
     begin
      B := FM4[j];
      if GlobCorr() then
       begin
        SetLength(Arr[High(Arr)], Length(Arr[High(Arr)]) + 1);
        Arr[High(Arr)][High(Arr[High(Arr)])] := B;
       end;
     end;
   end;
end;

  function Checkword(w: integer; n: Integer): Boolean;
   var
    old, nold: Integer;
    function Check3(new: Integer): Boolean;
    begin
      if new = old then
       begin
        inc(Nold);
        Exit(Nold > 2);
       end;
      old := new;
      Nold := 1;
      Result := False;
    end;
   var
    i: Integer;
  begin
    old := w and 1;
    Nold := 1;
    for i := 1 to n-1 do if Check3((w shr i) and 1) then Exit(False);
    Result := True;
  end;


procedure CreateSuncro(Bits: Integer; var CurBit: Boolean; var bin: TArray<Boolean>);
 const
  SINCRO: array[0..7] of Integer = (5,  123, 1850, 1837, 1691, 2345, 1725, 1973);
  var
   n: Integer;
   procedure AddBit(bit: Boolean);
    var
     i: Integer;
   begin
     if not bit then CurBit := not CurBit;
     for I := 0 to bits-1 do bin[n+i] := CurBit;
     Inc(n, bits);
   end;
  var
   b,i: Integer;
   cod: Word;
begin
  n := 0;
  SetLength(bin, Bits*(Length(SINCRO)*16));
  for I := 0 to Length(SINCRO)-1 do
   begin
    if SINCRO[i] > 2583 then raise Exception.Create('BAD NUMBER FIBONAHI > 2583');
    cod := FIBONACH_CODES[SINCRO[i]];
    for b := 0 to 15 do
     begin
      AddBit((cod and $8000) <> 0);
      cod := cod shl 1;
     end;
   end;
end;

procedure TFormTest.FormCreate(Sender: TObject);
 const
  SINCRO: array[0..7] of Integer = (5,  123, 1850, 1837, 1691, 2345, 1725, 1973);
 var
  i, j, n2: Integer;
  s: string;
  f: file;
begin
  for i := 0 to 2583 do if FIBONACH_ENCODED_PSK[i] = $5555 then Caption :=FIBONACH_CODES[i].ToString();


  for I := 0 to Length(SINCRO)-1 do
   begin
    memo.Lines.Add(IntToHex(FIBONACH_CODES[SINCRO[i]], 4));
   end;

  rm := RMCodes;
  TArray.Sort<Cardinal>(rm);
//  for i := 0 to 31 do if not Checkword(rm[i], 32) then Memo.Lines.Add(IntToBin(rm[i], 32));
//  for i := 0 to 15 do for j := i+1 to 15 do  Memo.Lines.Add(FastCorr(rm[i],rm[j], 32).ToString());
 { n := 0;
  s := '';
  for i := 0 to 2583 do
   begin
    s := s + '$'+ encod(i).ToHexString + ',';
    if (i+1) mod 25] = 0 then
     begin
      Memo.Lines.Add(s);
      s := '';
     end
   end;
  Memo.Lines.Add(s);}

 // for i := 0 to 2583 do Memo.Lines.Add(IntToBin(FIBONACH_CODES[i]) + '  '+ IntToBin(encod(i)));


{  n2 := 0;
  n1 := Round(IntPower(2, NNN-1))-1;   //$24924924 - 0010 0100 1001 0010 0100 1001 0010 0100
  for i := 0 to n1 do if Checkword(i, NNN) then
   begin
    //Memo.Lines.Add(Format('%5d %s %x',[n2, IntToBin(i, NNN), i]));
    FM4[n2] := i;
    inc(n2);
   end;}

  {  Memo.Lines.Add((n2).ToString());
  with TFile.OpenWrite(s) do
  try
   Position := 0;
   Write(FM4, Length(FM4)*SizeOf(Integer))
  finally
   Free;
  end;}
  s := TPath.GetDirectoryName(ParamStr(0))+'\fm32.bin';

  with TFile.OpenRead(s) do
  try
   Position := 0;
   Read(FM4, Length(FM4)*SizeOf(Integer))
  finally
   Free;
  end;
   i := 0;
   for j := 0 to High(FM4) do if FM4[j] = rm[i] then
    begin
     Memo.Lines.Add(Format('%5d %5d %x %s',[i, j, FM4[j], IntToBin(fm4[j], 32)]));
     inc(i);
     if i = 16 then Break;
    end;
   Memo.Lines.Add('--------------------------------------------' );
end;

procedure TFormTest.vldProgress(ASender: TFDPhysDriverService; const AMessage: string);
begin
  Memo.Lines.Add(AMessage);
end;

procedure TFormTest.Button2Click(Sender: TObject);
 var
  i: Integer;
  function  GlobCorr(d: integer): boolean;
   var
    n: integer;
    C: Integer;
  begin
    Result := True;
    for n := 0 to 15 do
     begin
      c := rm[n];
      if (d = C) or (Abs(FastCorr(d, C, 32)) <> 0) then Exit(False)
     end;
  end;
begin
  for i := 0 to High(FM4) do if GlobCorr(fm4[i]) then Memo.Lines.Add(Format('%5d %x %s',[i, fm4[i], IntToBin(fm4[i], 32)]));


end;


procedure TFormTest.Button3Click(Sender: TObject);
const S1 = '//%d';
		  S2 = 'STRH reg0,  [reg2, 0x00]   // set clock';
		  S3 = 'LDR  reg5,  [reg3, 0x00]   // считываем GPIOC->IDR';
		  S4 = 'STRH reg0,  [reg1, 0x00]   // reset clock';
		  S5 = 'STR  reg5,  [peg, #%d]   // записываем то, что было в GPIOC->IDR, в память со смещением';
  var
   i: Integer;
begin
  Memo.Clear;
  Memo.Lines.BeginUpdate;
  for I := 0 to 680 do
   begin
     Memo.Lines.Add(Format(S1,[i]));
     Memo.Lines.Add(S2);
     Memo.Lines.Add(S3);
     Memo.Lines.Add(S4);
     Memo.Lines.Add(Format(S5,[i*4]));
   end;
  Memo.Lines.EndUpdate;
end;


procedure TFormTest.Button4Click(Sender: TObject);
 const
  NN = 22;
  CD: array [0..NN-1] of Integer = (1,-1,-1,1,1,-1,1,-1,-1,1,1,-1,1,-1,1,-1,-1,1,-1,1,-1,1);
//  CD: array [0..NN-1] of Integer = (-1,-1,-1,1,1,1,-1,-1,1,1,-1,1,1,-1,1,-1,1,-1);
//  CD: array [0..NN-1] of Integer = (1, 1, 1, 1, -1,-1,-1, -1, 1,-1, 1,-1,-1, 1, 1,-1,-1, 1);
 var
  data: array [0..NN*2-1] of Integer;
  function corr(from: Integer): Integer;
    var
     i: Integer;
  begin
    Result := 0;
    for i := 0 to NN-1 do Result := Result + data[from+i]*CD[i];
  end;
 var
  i: Integer;
  s: string;
begin
  for i := 0 to High(data) do data[i] := 0;
  for i := 0 to NN-1 do data[i] := CD[i];
  s := '';
  for i := 1 to NN-1 do s := s +corr(i).ToString()+ ' ';
  s := s.Trim;
  Memo.Lines.Add(s);
end;

procedure TFormTest.Button5Click(Sender: TObject);
 const
  NL = 22;
 var
  i, n, cr, crold, crglob: Integer;
  rez: TArray<Integer>;
  rezs: TArray<string>;
  s: string;
begin
  crglob := NL;
  for n := 1 to (2 shl (NL-1)) - 1 do
   begin
//    n := 246425;
    crold := -NL;
    s := '';
    for i := 1 to NL-1 do
     begin
      cr := FastCorr(n, n shr i, NL-i);
      s := s + cr.ToString() + ' ';
     // cr := Abs(cr);
      if cr > crold then crold := cr;
     end;
    if crold = crglob then
     begin
      rez := rez + [n];
      rezs := rezs + [s];
     end
    else if crold < crglob then
     begin
      crglob := crold;
      SetLength(rez, 1);
      SetLength(rezs, 1);
      rez[0] := n;
      rezs[0] := s;
     end;
   end;
  Caption := crglob.ToString();
  for i:=0 to High(rez) do Memo.Lines.Add(Format('%d  %x  %s %s',[i,rez[i], IntToBin(rez[i],NL), rezs[i]]));
end;

procedure TFormTest.Button6Click(Sender: TObject);
begin
  Memo.Clear;
  vld.Analyze;
end;

end.

