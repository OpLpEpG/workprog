program LasToSucop;

uses
  Vcl.Forms,
  VCL.Vizard.Sucop in 'VCL.Vizard.Sucop.pas' {FormSUCOPconverter},
  DialogOpenLas in '..\VCLData\DialogOpenLas.pas' {DlgOpenLAS},
  SucopAdapter in 'SucopAdapter.pas',
  VerySimple.Lua.Lib in '..\Core\VerySimpleLua\VerySimple.Lua.Lib.pas',
  VerySimple.Lua in '..\Core\VerySimpleLua\VerySimple.Lua.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSUCOPconverter, FormSUCOPconverter);
  Application.Run;
end.
