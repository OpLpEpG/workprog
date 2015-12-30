library WorkProgPreviewHandler;

uses
  ComServ,
  MyPreviewHandler in 'MyPreviewHandler.pas',
  PreviewHandler in 'PreviewHandler.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.RES}

begin
end.

