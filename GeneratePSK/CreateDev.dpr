program CreateDev;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ActiveX,
  PSKFormats in 'PSKFormats.pas',
  tools in '..\tools.pas';

begin
  try
    CoInitialize(nil);
    GetPSKInfo(ADR_USO);
    GetPSKInfo(ADR_GLUBIONMER);
    GetPSKInfo(ADR_AK_XMEGA_LOC_NOISE);
    GetPSKInfo(ADR_PSK4);
    GetPSKInfo(ADR_AK60);
    GetPSKInfo(ADR_AP);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
