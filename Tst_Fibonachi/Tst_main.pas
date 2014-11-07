unit Tst_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Fibonach,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormTest = class(TForm)
    Memo: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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
  B: Word;
  Arr: TArray<TArray<Word>>;
  function  GlobCorr(): boolean;
   var
    n: integer;
    C: word;
  begin
    Result := True;
    for n := 0 to Length(Arr[High(Arr)])-1 do
     begin
      c := Arr[High(Arr)][n];
      if (B = C) or (Abs(FastCorr(B, C)) > 1) then Exit(False)
     end;
  end;

begin

  for i := 0 to 2583 do
   begin
    SetLength(Arr, Length(Arr)+1);
    SetLength(Arr[High(Arr)], 1);
    Arr[High(Arr)][0] := FIBONACH_ENCODED_PSK[i];
    for j := 0 to 2583 do
     begin
      B := FIBONACH_ENCODED_PSK[j];
      if GlobCorr() then
       begin
        SetLength(Arr[High(Arr)], Length(Arr[High(Arr)]) + 1);
        Arr[High(Arr)][High(Arr[High(Arr)])] := B;
       end;
     end;
   end;



end;

procedure TFormTest.FormCreate(Sender: TObject);
 var
  i, j, n: Integer;
  s: string;
begin
 { n := 0;
  s := '';
  for i := 0 to 2583 do
   begin
    s := s + '$'+ encod(i).ToHexString + ',';
    if (i+1) mod 25 = 0 then
     begin
      Memo.Lines.Add(s);
      s := '';
     end
   end;
  Memo.Lines.Add(s);}

  for i := 0 to 2583 do Memo.Lines.Add(IntToBin(encod(i)));
end;

end.

