// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ENDIF}
library ProjectManager;

uses
  System.SysUtils,
  System.TypInfo,
  FireDAC.Stan.Factory,
  FireDAC.Stan.Intf,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  PluginAPI,
  DockIForm,
  Container,
  ExtendIntf,
  AbstractPlugin,
  System.Classes,
  DButil in 'DButil.pas',
  manager in 'manager.pas',
  DBEnumers in 'DBEnumers.pas',
  PrjTool in 'PrjTool.pas';

{$R *.res}

function Init(): PTypeInfo;
begin
  FFDGUIxSilentMode  := True;
  Result := TypeInfo(TManager);
  TRegister.AddType<TManager, IPlugin, IManager, IProjectData, IProjectMetaData, IMetrology, IProjectOptions>.LiveTime(ltSingleton);
end;

procedure Done;
begin
  GContainer.RemoveModel<TManager>;
  FDTerminate;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

begin
end.
