program Glut;

uses
  Vcl.Forms,
  glutest in 'glutest.pas' {FormTG};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormTG, FormTG);
  Application.Run;
end.
