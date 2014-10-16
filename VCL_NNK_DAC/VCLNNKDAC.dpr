// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLNNKDAC;

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  NNKDacForm in 'NNKDacForm.pas' {FormDACNNk};

{$R *.res}

type
 TnnkGkDAC = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TnnkGkDAC, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TnnkGkDAC);
end;

procedure Done;
begin
  GContainer.RemoveModel<TnnkGkDAC>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TnnkGkDAC.PluginName: string;
begin
  Result := 'Настройка ЦАП Гамма и ННК';
end;

class function TnnkGkDAC.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
