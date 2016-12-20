unit Unit7;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Unit2, Vcl.StdCtrls, System.IOUtils, Vcl.ExtCtrls;

type
  TForm7 = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Button2: TButton;
    Frame21: TFrame2;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation

{$R *.dfm}

procedure TForm7.Button1Click(Sender: TObject);
 var
  ss: TStringStream;
  ms: TMemoryStream;
  F: TFrame2;
begin
//  f := TFrame2.Create(Self);
//  f.Name := 'Frame2';
//  f.Parent := Panel1;


  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ms.WriteComponent(Self);
   ms.Position := 0;
   ObjectBinaryToText(ms, ss);
   ss.DataString;
   ss.SaveToFile(Tpath.GetDirectoryName(ParamStr(0))+'\Graph.txt');
  finally
   ss.Free;
   ms.Free;
  end;
end;

procedure TForm7.Button2Click(Sender: TObject);
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
    Button1.Free;
    Panel1.Free;
    Frame21.Free;
    Button2.Free;

   Sleep(1000);

   ss := TStringStream.Create;
   ms := TMemoryStream.Create;
   try
    ss.LoadFromFile(Tpath.GetDirectoryName(ParamStr(0))+'\Graph.txt');
    ss.Position := 0;
    ObjectTextToBinary(ss, ms);
    ms.Position := 0;
    ms.ReadComponent(Self);
   finally
    ss.Free;
    ms.Free;
   end;
end;

end.
