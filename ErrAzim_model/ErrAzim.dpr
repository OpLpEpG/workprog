program ErrAzim;

uses
  Vcl.Forms,
  MainErrAzim in 'MainErrAzim.pas' {FrmErrAzi};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmErrAzi, FrmErrAzi);
  Application.Run;
end.
