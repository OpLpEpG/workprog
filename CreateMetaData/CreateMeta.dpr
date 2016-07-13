program CreateMeta;

uses
  Vcl.Forms,
  MainMeta in 'MainMeta.pas' {FormMeta},
  Parser in '..\Core\Parser.pas',
  MetaData in 'MetaData.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMeta, FormMeta);
  Application.Run;
end.
