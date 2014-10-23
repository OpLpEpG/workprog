// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library Metrol;

{$R 'SndMetrol.res' 'SndMetrol.rc'}

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  MetrInclin in 'MetrInclin.pas' {FormInclin},
  MetrForm in 'MetrForm.pas',
  MetrInclinSetup in 'MetrInclinSetup.pas' {FormInclSetup},
  MetrGK in 'MetrGK.pas' {FormGK},
  MetrNNK in 'MetrNNK.pas' {FormNNK},
  MetrFormSetup in 'MetrFormSetup.pas' {FormMetrSetup},
  VTEditors in '..\VTEditors.pas',
  MetrUAKI in 'MetrUAKI.pas' {FormUAKI},
  UakiUI in 'UakiUI.pas' {FrameUakiUI: TFrame},
  AutoMetr.Inclin in 'AutoMetr.Inclin.pas',
  MetrInclinGraph in 'MetrInclinGraph.pas',
  FrameInclinGraph in 'FrameInclinGraph.pas' {FrmInclinGraph: TFrame},
  MetrInclin.Math in 'MetrInclin.Math.pas',
  MetrUAKI.ToleranceForm in 'MetrUAKI.ToleranceForm.pas' {FormUAKItolerance},
  MetrInclin.CheckForm in 'MetrInclin.CheckForm.pas' {FormInclinCheck},
  CheckFormSetup in 'CheckFormSetup.pas' {FormCheckSetup},
  MetrInclin.TrrAndP2 in 'MetrInclin.TrrAndP2.pas',
  MetrInclin.TrrAndP3 in 'MetrInclin.TrrAndP3.pas',
  AutoMetr.GK in 'AutoMetr.GK.pas',
  StolGKUI in 'StolGKUI.pas' {FormStolGK},
  MetrInclin.CheckFormSetup in 'MetrInclin.CheckFormSetup.pas',
  MetrGK.CheckFormSetup in 'MetrGK.CheckFormSetup.pas',
  UakiUI.Ten in 'UakiUI.Ten.pas' {FrameUakiTEN: TFrame};

{$R *.res}

//type
// TPlugin = class(TAbstractPlugin, INotifyAfteActionManagerLoad)
// protected
//   FormTreeIncl: TStaticMenu;
//   FormGk: TStaticMenu;
//   FormNGk: TStaticMenu;
//   FormNNk: TStaticMenu;
//   procedure LoadNotify; override;
//   procedure DestroyNotify; override;
//   procedure AfteActionManagerLoad(); safecall;
// end;
//
//function Init(const ACore: ICore): IPlugin; safecall;
// const
//  GMT: TGUID ='{B2DB1392-6B4E-4906-ACC8-2F2B80D4D11C}';
//begin
//  Result := TPlugin.Create(HInstance, ACore, 'Метрология', GMT);
//end;
//
//exports
//  Init name SPluginInitFuncName;
//
//{ TPlugin }
//
//procedure TPlugin.LoadNotify;
//begin
//  FormTreeIncl := TStaticMenu.InitMenu('Новая тарировка Т21', 'Инклинометры', TFormInclin);
//  FormGk := TStaticMenu.InitMenu('Новая тарировка ГК', 'ГК', TFormGK);
//  FormNGk := TStaticMenu.InitMenu('Новая тарировка НГК', 'ННК', TFormNGK);
//  FormNNk := TStaticMenu.InitMenu('Новая тарировка ННК', 'ННК', TFormNNK);
//end;
//
//procedure TPlugin.AfteActionManagerLoad;
//begin
//  FormTreeIncl.ShowInMainMenu('Метрология.Инклинометры');
//  FormGk.ShowInMainMenu('Метрология.ГК');
//  FormNGk.ShowInMainMenu('Метрология.ННК');
//  FormNNk.ShowInMainMenu('Метрология.ННК');
//end;
//
//procedure TPlugin.DestroyNotify;
//begin
//  FormTreeIncl.Free;
//  FormGk.Free;
//  FormNGk.Free;
//  FormNNk.Free;
//end;

type
 TMetrology = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TMetrology, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TMetrology);
end;

procedure Done;
begin
  GContainer.RemoveModel<TMetrology>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TMetrology.PluginName: string;
begin
  Result := 'Метрология';
end;

class function TMetrology.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
