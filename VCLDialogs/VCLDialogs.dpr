// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLDialogs;

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  VCL.Dlg.ConnectIO in 'VCL.Dlg.ConnectIO.pas' {FormSetupConnect},
  VCL.Dlg.ConnectIO.COM in 'VCL.Dlg.ConnectIO.COM.pas' {FormSetupCom},
  InitDialogs in 'InitDialogs.pas',
  VCL.Dlg.ConnectIO.NET in 'VCL.Dlg.ConnectIO.NET.pas' {FormSetupNet},
  VCL.Dlg.ConnectIO.WLAN in 'VCL.Dlg.ConnectIO.WLAN.pas' {FormSetupWlan},
  VCL.Dlg.Device in 'VCL.Dlg.Device.pas' {DlgSetupDev},
  VCL.Dlg.RootDevice in 'VCL.Dlg.RootDevice.pas' {FormSetupRootDevice},
  VCL.Dlg.OptionSetup in 'VCL.Dlg.OptionSetup.pas' {FormOptionSetup};

{$R *.res}

type
 TVCLDialogs = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TVCLDialogs, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TVCLDialogs);
end;

procedure Done;
begin
  GContainer.RemoveModel<TVCLDialogs>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TVCLDialogs.PluginName: string;
begin
  Result := 'Диалоги';
end;

class function TVCLDialogs.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
