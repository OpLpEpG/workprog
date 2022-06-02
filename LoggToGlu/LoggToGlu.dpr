// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library LoggToGlu;

uses
  System.TypInfo,
  System.SysUtils,
  PluginAPI,
  DockIForm,
  Container,
  ExtendIntf,
  AbstractPlugin,
  System.Classes,
  LoggForm in 'LoggForm.pas' {FormLogg},
  Convertor in 'Convertor.pas';

{$R *.res}

type
 TLoggToGlu = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;


function Init(): PTypeInfo;
begin
  TRegister.AddType<TLoggToGlu, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TLoggToGlu);
end;

procedure Done;
begin
  GContainer.RemoveModel<TLoggToGlu>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TLoggToGlu.PluginName: string;
begin
  Result := 'logg to glu';
end;

class function TLoggToGlu.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
