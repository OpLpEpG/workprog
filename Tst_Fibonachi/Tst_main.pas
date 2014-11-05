unit Tst_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Fibonach,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFormTest = class(TForm)
    Memo: TMemo;
    procedure FormCreate(Sender: TObject);
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

