program Project7;

uses
  Vcl.Forms,
  Unit7 in 'Unit7.pas' {Form7},
  Unit2 in 'Unit2.pas' {Frame2: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm7, Form7);
  Application.Run;
end.
