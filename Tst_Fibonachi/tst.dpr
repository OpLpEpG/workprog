program tst;

uses
  Vcl.Forms,
  Tst_main in 'Tst_main.pas' {FormTest},
  Fibonach in '..\Fibonach.pas',
  DataProf in '..\DataProf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormTest, FormTest);
  Application.Run;
end.
