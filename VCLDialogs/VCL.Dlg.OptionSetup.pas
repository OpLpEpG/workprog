unit VCL.Dlg.OptionSetup;

interface

uses RootIntf, DeviceIntf, debug_except, ExtendIntf, DockIForm, PluginAPI, RootImpl, Container, JDtools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.TypInfo,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Xml.XMLIntf, JvComponentBase, JvInspector, Vcl.StdCtrls, JvExControls;

type
  TFormOptionSetup = class(TDialogIForm, IDialog, IDialog<IXMLNode, IXMLNode, TJvInspectorOptionDataEvent, TDialogResult>)
    insp: TJvInspector;
    btOK: TButton;
    btCancel: TButton;
    InspectorBorlandPainter: TJvInspectorBorlandPainter;
    procedure btOKClick(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
  private
    FRes: TDialogResult;
  protected
//    procedure CanClose(var CanClose: Boolean);
    function GetInfo: PTypeInfo; override;
    function Execute(RootOptions: IXMLNode; RootData: IXMLNode; OnData: TJvInspectorOptionDataEvent; Res: TDialogResult): Boolean;
    class function ClassIcon: Integer; override;
  public
    { Public declarations }
  end;

var
  FormOptionSetup: TFormOptionSetup;

implementation

{$R *.dfm}

{ TFormOptionSetup }

procedure TFormOptionSetup.btCancelClick(Sender: TObject);
begin
  if Assigned(FRes) then FRes(Self, mrCancel);
  RegisterDialog.UnInitialize<Dialog_SetupOptions>;
end;

procedure TFormOptionSetup.btOKClick(Sender: TObject);
begin
  if Assigned(FRes) then FRes(Self, mrOk);
  RegisterDialog.UnInitialize<Dialog_SetupOptions>;
end;

class function TFormOptionSetup.ClassIcon: Integer;
begin
  Result := 111;
end;

function TFormOptionSetup.Execute(RootOptions, RootData: IXMLNode; OnData: TJvInspectorOptionDataEvent; Res: TDialogResult): Boolean;
begin
  FRes := Res;
  insp.Clear;
  insp.Root.SortKind := iskNone;
  Result := Length(TJvInspectorOptionData.New(insp.Root, RootData, RootOptions, OnData)) > 0;
  IShow;
end;

function TFormOptionSetup.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_SetupOptions);
end;

initialization
  RegisterDialog.Add<TFormOptionSetup, Dialog_SetupOptions>;
finalization
  RegisterDialog.Remove<TFormOptionSetup>;
end.
