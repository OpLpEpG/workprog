// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLTelesis;

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  VCL.ControlRootForm in 'VCL.ControlRootForm.pas',
  VCL.Telesis.FFT in 'VCL.Telesis.FFT.pas' {UsoOscForm},
  VCL.Telesis.UsoOsc in 'VCL.Telesis.UsoOsc.pas' {FFTForm};

{$R *.res}

type
 TvclTelesis = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TvclTelesis, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TvclTelesis);
end;

procedure Done;
begin
  GContainer.RemoveModel<TvclTelesis>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TvclTelesis.PluginName: string;
begin
  Result := 'Формы для телесистемы';
end;

class function TvclTelesis.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
