program CreateMeta;

uses
  Vcl.Forms,
  MainMeta in 'MainMeta.pas' {FormMeta};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMeta, FormMeta);
  Application.Run;
end.
