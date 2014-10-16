// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library CreatePSK;

uses
  System.SysUtils,
  PluginAPI,
  DockIForm,
  ExtendIntf,
  AbstractPlugin,
  System.Classes,
  PskCreateForm in 'PskCreateForm.pas' {FormPsk},
  MetrCreateForm in 'MetrCreateForm.pas' {FormMetr},
  OptionsProject in 'OptionsProject.pas' {Form2};

{$R *.res}

type
 TPlugin = class(TAbstractPlugin, INotifyAfteActionManagerLoad)
 protected
   FPskMenu, FMetrMenu: TStaticMenu;
   procedure LoadNotify; override; safecall;
   procedure DestroyNotify; override; safecall;
   procedure AfteActionManagerLoad(); safecall;
 end;

function Init(const ACore: ICore): IPlugin; safecall;
begin
  Result := TPlugin.Create(HInstance, ACore, '�������� �������� ��� � ����������', PLUGIN_CreatePSK);
end;

exports
  Init name SPluginInitFuncName;

{ TPlugin }

procedure TPlugin.LoadNotify;
begin
  FPskMenu := TStaticMenu.InitMenu('����� �������� �������� ���', '����������', TFormPSK);
  FMetrMenu := TStaticMenu.InitMenu('�������� ���������� ��������', '����������', TFormMetr);
end;

procedure TPlugin.AfteActionManagerLoad;
begin
  FPskMenu.ShowInMainMenu('��������.����������');
  FMetrMenu.ShowInMainMenu('��������.����������')
end;

procedure TPlugin.DestroyNotify;
begin
  FPskMenu.Free;
  FMetrMenu.Free;
end;

begin
end.
