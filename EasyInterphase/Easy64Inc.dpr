program Easy64Inc;

uses
  Vcl.Forms,
  Easy64Incl in 'Easy64Incl.pas' {FormEasyIntf},
  PluginManager in '..\MainExe\PluginManager.pas',
  ActionBarHelper in '..\MainExe\ActionBarHelper.pas',
  ExceptionForm in '..\MainExe\ExceptionForm.pas' {FormExceptions};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormEasyIntf, FormEasyIntf);
  Application.Run;
end.
