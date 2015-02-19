program tstD2D1;

uses
  Vcl.Forms,
  Tst_D2D1 in 'Tst_D2D1.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
