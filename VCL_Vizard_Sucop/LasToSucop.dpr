program LasToSucop;

uses
  Vcl.Forms,
  VCL.Vizard.Sucop in 'VCL.Vizard.Sucop.pas' {FormSUCOPconverter},
  DialogOpenLas in '..\VCLData\DialogOpenLas.pas' {DlgOpenLAS},
  SucopAdapter in 'SucopAdapter.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSUCOPconverter, FormSUCOPconverter);
  Application.Run;
end.
