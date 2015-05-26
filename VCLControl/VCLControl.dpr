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
  Actns,
  DeviceIntf,
  Vcl.Dialogs,
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
 private
//  class procedure InnerProject(const PrjName: string; isNew: Boolean);
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
  //Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
   [StaticAction('Новый проект...', 'Проект', 16, '0:Файл.Проект|1:0')]
   class procedure DoNewProject(Sender: IAction);
   [StaticAction('-Свойства проекта...', 'Проект', 238, '0:Файл.Проект|1:4')]
   class procedure DoZPropertyProject(Sender: IAction);
   [StaticAction('Открыть проект...', 'Проект', 329, '0:Файл.Проект|1:1')]
   class procedure DoOpenProject(Sender: IAction);
   [StaticAction('-Закрыть проект', 'Проект', 226, '0:Файл.Проект|1:2')]
   class procedure DoSloseProject(Sender: IAction);
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

{class procedure TVCLControl.InnerProject(const PrjName: string; isNew: Boolean);
begin
  (GContainer as IMainScreen).Lock;
  try
   if isNew then
         (GContainer as IManager).NewProject(PrjName)
   else  (GContainer as IManager).LoadProject(PrjName);
   (GContainer as IMainScreen).StatusBarText[1] := (GContainer as IManager).ProjectName;
   (GContainer as IRegistry).SaveString('CurrentProject', (GContainer as IManager).ProjectName, True);
   (GContainer as IActionProvider).ResetActions;
  finally
   (GContainer as IMainScreen).UnLock;
  end;
end;   }

class procedure TVCLControl.DoNewProject(Sender: IAction);
 var
  s: string;
begin
  (GContainer as IProject).New(s);
end;

class procedure TVCLControl.DoOpenProject(Sender: IAction);
 var
  s: string;
begin
  (GContainer as IProject).Load(s);
end;

class procedure TVCLControl.DoSloseProject(Sender: IAction);
begin
  (GContainer as IProject).Close;
end;

class procedure TVCLControl.DoZPropertyProject(Sender: IAction);
begin
  (GContainer as IProject).Setup;
end;


begin
end.
