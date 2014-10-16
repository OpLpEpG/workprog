// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCL_RP45;

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  RP45.Metrology in 'RP45.Metrology.pas' {RP45FormDlgMetrol};

{$R *.res}

type
 TRP45VclControl = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TRP45VclControl, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TRP45VclControl);
end;

procedure Done;
begin
  GContainer.RemoveModel<TRP45VclControl>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TRP45VclControl.PluginName: string;
begin
  Result := 'Глубиномер РП-45';
end;

class function TRP45VclControl.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
