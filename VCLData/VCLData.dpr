// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLData;

uses
  System.TypInfo,
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Factory,
  FireDAC.Stan.Intf,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  RootImpl,
  tools,
  Xml.XMLIntf,
  DeviceIntf,
  DockIForm,
  AbstractPlugin,
  PluginAPI,
  ExtendIntf,
  Container,
  FormWork in 'FormWork.pas' {FormWrok},
  AbstractDlgParams in 'AbstractDlgParams.pas' {FormParamsAbstract},
  DlgFltParam in 'DlgFltParam.pas',
  DlgViewParam in 'DlgViewParam.pas',
  DlgFromToGlu in 'DlgFromToGlu.pas' {FormDlgGluFilter},
  DialogOpenLas in 'DialogOpenLas.pas' {DlgOpenLAS},
  VCL.FormShowArray in 'VCL.FormShowArray.pas' {FormShowArray},
  VCL.CustomDataForm in 'VCL.CustomDataForm.pas',
  VCL.GraphDataForm in 'VCL.GraphDataForm.pas' {GraphDataForm},
  VCL.TableDataForm in 'VCL.TableDataForm.pas' {TableDataForm},
  DlgEditParam in 'DlgEditParam.pas' {FormEditParam};

{$R *.res}

type
 TVCLData = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  FFDGUIxSilentMode  := True;
  TRegister.AddType<TVCLData, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TVCLData);
end;

procedure Done;
begin
  GContainer.RemoveModel<TVCLData>;
  FDTerminate;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TVCLData.PluginName: string;
begin
  Result := 'Основные формы';
end;

class function TVCLData.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
