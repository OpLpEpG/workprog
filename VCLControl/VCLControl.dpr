// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLControl;

uses
  System.TypInfo,
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Factory,
  FireDAC.Stan.Intf,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  RootImpl,
  DeviceIntf,
  DockIForm,
  AbstractPlugin,
  PluginAPI,
  ExtendIntf,
  Container,
  ControlForm in 'ControlForm.pas' {FormControl},
  FormDlgDev in 'FormDlgDev.pas' {FormCreateDev},
  FormDlgRam in 'FormDlgRam.pas' {FrmDlgRam},
  ControlDBForm in 'ControlDBForm.pas',
  ControlRamForm in 'ControlRamForm.pas' {FormControlRam},
  ControlTrrForm in 'ControlTrrForm.pas' {FormControlTrr},
  FormDlgSetupProject in 'FormDlgSetupProject.pas' {FormSetupProject},
  DlgSetupDate in 'DlgSetupDate.pas' {FormCalendar},
  FormDelay2 in 'FormDelay2.pas' {DialogDelay},
  FormDlgSyncClock in 'FormDlgSyncClock.pas' {DialogSyncDelay};

{$R *.res}

type
 TVCLControl = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  FFDGUIxSilentMode  := True;
  TRegister.AddType<TVCLControl, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TVCLControl);
end;

procedure Done;
begin
  GContainer.RemoveModel<TVCLControl>;
  FDTerminate;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TVCLControl.PluginName: string;
begin
  Result := 'Управление проектом';
end;

class function TVCLControl.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
