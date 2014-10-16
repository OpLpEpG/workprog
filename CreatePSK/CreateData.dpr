// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library CreateData;

uses
  System.TypInfo,
  System.SysUtils,
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
  System.Classes,
  PskCreateForm in 'PskCreateForm.pas' {FormPsk},
  MetrCreateForm in 'MetrCreateForm.pas' {FormMetr},
  OptionsProject in 'OptionsProject.pas' {FormProjectOptions};

{$R *.res}

type
 TCreateMetrPskPlugin = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
// protected
//   FPskMenu, FMetrMenu, FOptionsMenu: TStaticMenu;
//   procedure LoadNotify; override;
//   procedure DestroyNotify; override;
//   procedure AfteActionManagerLoad(); safecall;
 end;

function Init(): PTypeInfo;
begin
  FFDGUIxSilentMode  := True;
  TRegister.AddType<TCreateMetrPskPlugin, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TCreateMetrPskPlugin);
end;

procedure Done;
begin
  GContainer.RemoveModel<TCreateMetrPskPlugin>;
  FDTerminate;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

{ TPlugin }

//procedure TPlugin.LoadNotify;
//begin
//  FPskMenu := TStaticMenu.InitMenu('Новый Редактор приборов ПСК', 'Отладочные', TFormPSK);
//  FMetrMenu := TStaticMenu.InitMenu('Редактор метрологии приборов', 'Отладочные', TFormMetr);
//  FOptionsMenu := TStaticMenu.InitMenu('Редактор свойств проекта', 'Отладочные', TFormProjectOptions);
//end;
//
//procedure TPlugin.AfteActionManagerLoad;
//begin
//  FPskMenu.ShowInMainMenu('Показать.Отладочные');
//  FMetrMenu.ShowInMainMenu('Показать.Отладочные');
//  FOptionsMenu.ShowInMainMenu('Показать.Отладочные');
//end;
//
//procedure TPlugin.DestroyNotify;
//begin
//  FPskMenu.Free;
//  FMetrMenu.Free;
//  FOptionsMenu.Free;
//end;

{ TPlugin }

class function TCreateMetrPskPlugin.GetHInstance: THandle;
begin
  Result := HInstance;
end;

class function TCreateMetrPskPlugin.PluginName: string;
begin
  Result := 'Редактор приборов ПСК и метрологии';
end;

begin
end.
