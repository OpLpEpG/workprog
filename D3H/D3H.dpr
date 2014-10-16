// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library D3H;

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  DlgForm in 'DlgForm.pas' {FormDH3};

{$R *.res}

type
 TD3HCommands = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TD3HCommands, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TD3HCommands);
end;

procedure Done;
begin
  GContainer.RemoveModel<TD3HCommands>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TD3HCommands.PluginName: string;
begin
  Result := 'Низкоуровневые команды 3DMDH3';
end;

class function TD3HCommands.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
