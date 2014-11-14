unit Tst_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Fibonach,System.Threading, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IOUtils,
  System.Generics.Collections;

type
  TFormTest = class(TForm)
    Memo: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

procedure TFormTest.FormCreate(Sender: TObject);
 var
  i, j, n2: Integer;
  s: string;
  f: file;
begin
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


end.

