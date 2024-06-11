// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLControl3;

{$INCLUDE global.inc}

uses
  System.TypInfo,
  System.SysUtils,
  System.Classes,
  RootImpl,
  Actns,
  DeviceIntf,
  Vcl.Dialogs,
  DockIForm,
  AbstractPlugin,
  PluginAPI,
  ExtendIntf,
  Container,
  ControForm3 in 'ControForm3.pas' {FormControl},
  FormDlgDev in 'FormDlgDev.pas' {FormCreateDev},
  FormDelay2 in 'FormDelay2.pas' {DialogDelay},
  VCLDlgRam in 'VCLDlgRam.pas' {FormDlgRam},
  ConnectDeviceHelper in 'ConnectDeviceHelper.pas',
  DlgSetupDate in 'DlgSetupDate.pas' {FormCalendar},
  ExportToPSK6_V3 in 'ExportToPSK6_V3.pas' {FormExportToPSK6_V3},
  VCLDlgExportAcoustics in 'VCLDlgExportAcoustics.pas' {FormDlgExportAcoustics},
  VCLDlgClc in 'VCLDlgClc.pas' {FormDlgClc},
  VCLFrameRangeSelect in 'VCLFrameRangeSelect.pas' {FrameRangeSelect: TFrame},
  VCLDlgExportLAS in 'VCLDlgExportLAS.pas' {FormExportLASP3},
  FormDlgSetupProject in 'FormDlgSetupProject.pas' {FormSetupProject},
  FindDevices in 'FindDevices.pas' {FormFindDev},
  FrameFindDevs2 in 'FrameFindDevs2.pas' {FrameFindDev: TFrame},
  FrameDelayDev in 'FrameDelayDev.pas' {FrameDelayInfo: TFrame},
  SelectPath in 'SelectPath.pas' {SelectPathFrm: TFrame},
  VCLFrmSeltPar in 'VCLFrmSeltPar.pas' {FrameSelectParam: TFrame},
  VCLDlgExportCaliper in 'VCLDlgExportCaliper.pas' {FormDlgExportCaliper};

{$R *.res}

{$IFDEF ENG_VERSION}
  const
   C_Proj ='Project';
   C_file ='File';
   C_Desctop= 'Desktop';
   C_Show =  'Show';
   C_New_Proj ='New project...';
   C_Prop_Proj ='-Project properties...';
   C_Open_Proj ='Open project...';
   C_exp= 'Export';

{$ELSE}
  const
   C_Proj ='������';
   C_file ='����';
   C_exp= '�������';
   C_Desctop= '������� ����';
   C_Show =  '��������';
   C_New_Proj ='����� ������...';
   C_Prop_Proj ='-�������� �������...';
   C_Open_Proj ='������� ������...';
{$ENDIF}


type
 TVCLControl = class(TAbstractPlugin)
 private
//  class procedure InnerProject(const PrjName: string; isNew: Boolean);
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
//    [StaticAction('����� �������', '���� ������������', NICON, '0:��������.���� ������������','',False,False,0,True, True)]
   [StaticAction(C_Proj, C_file, -1, '0:'+C_file+'|1:0','',False,False,0,True, True)]
    class procedure DoUpdate(Sender: IAction);
   [StaticAction(C_exp, C_file, -1, '0:'+C_file+'|1:1','',False,False,0,True, True)]
    class procedure DoUpdateExp(Sender: IAction);
   [StaticAction(C_Desctop, C_file, -1, '0:'+C_file,'',False,False,0,True, True)]
    class procedure DoUpdateWrk(Sender: IAction);
   [StaticAction(C_Show, '', -1, '0','',False,False,0,True, True)]
    class procedure DoUpdateShow(Sender: IAction);
  //Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
   [StaticAction(C_New_Proj, C_Proj, 16, '0:'+C_file+'.'+C_Proj+'|1:0')]
   class procedure DoNewProject(Sender: IAction);
   [StaticAction(C_Prop_Proj, C_Proj, 238, '0:'+C_file+'.'+C_Proj+'|1:4')]
   class procedure DoZPropertyProject(Sender: IAction);
   [StaticAction(C_Open_Proj, C_Proj, 329, '0:'+C_file+'.'+C_Proj+'|1:1')]
   class procedure DoOpenProject(Sender: IAction);
//   [StaticAction('-������� ������', '������', 226, '0:����.������|1:2')]
   class procedure DoSloseProject(Sender: IAction);
 end;

function Init(): PTypeInfo;
begin
//  FFDGUIxSilentMode  := True;
  TRegister.AddType<TVCLControl, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TVCLControl);
end;

procedure Done;
begin
  GContainer.RemoveModel<TVCLControl>;
//  FDTerminate;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TVCLControl.PluginName: string;
begin
  Result := '���������� �������� 3';
end;

class function TVCLControl.GetHInstance: THandle;
begin
  Result := HInstance;
end;

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

class procedure TVCLControl.DoUpdate(Sender: IAction);
begin
  Sender.Visible := Supports(GContainer, IManager);
end;

class procedure TVCLControl.DoUpdateExp(Sender: IAction);
 var
  m: IManager;
begin
  Sender.Visible := Supports(GContainer, IManager, m) and (m.ProjectName <> '');
end;

class procedure TVCLControl.DoUpdateShow(Sender: IAction);
 var
  m: IManager;
  v: Boolean;
  a: IAction;
begin
  v := Supports(GContainer, IManager, m) and (m.ProjectName <> '');
  a := (GlobalCore as IActionEnum).Get('TFormControl_DoCreateForm', False);
  a.Visible := v;
  a := (GlobalCore as IActionEnum).Get('TFormWrok_DoCreateForm', False);
  a.Visible := v;
end;

class procedure TVCLControl.DoUpdateWrk(Sender: IAction);
 var
  m: IManager;
begin
  Sender.Visible := Supports(GContainer, IManager, m) and (m.ProjectName <> '');
end;

class procedure TVCLControl.DoZPropertyProject(Sender: IAction);
begin
  (GContainer as IProject).Setup;
end;

begin
end.
