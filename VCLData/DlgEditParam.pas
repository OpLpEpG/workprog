unit DlgEditParam;

interface

uses RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, Plot,  RTTI, IGDIPlus, Container, RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.UITypes, System.TypInfo,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvExControls, JvInspector, Vcl.ExtCtrls, JvComponentBase;

type
  TFormEditParam = class(TDialogIForm, IDialog, IDialog<TGraphParam>)
    btExit: TButton;
    insp: TJvInspector;
    InspectorBorlandPainter: TJvInspectorBorlandPainter;
    procedure btExitClick(Sender: TObject);
  private
    FEditParam: TGraphParam;
  public
    { Public declarations }
  protected
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: TGraphParam): Boolean;
  end;

implementation

{$R *.dfm}

uses SetGPClolor;

{ TFormEditParam }

procedure TFormEditParam.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_EditViewParameters>;
end;

function TFormEditParam.Execute(InputData: TGraphParam): Boolean;
begin
  Result := True;
  FEditParam := InputData;
  Insp.Root.SortKind := iskNone;
  ShowPropAttribute.Apply(FEditParam, Insp);
  IShow;
end;

function TFormEditParam.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_EditViewParameters);
end;

initialization
  RegisterDialog.Add<TFormEditParam, Dialog_EditViewParameters>;
finalization
  RegisterDialog.Remove<TFormEditParam>;
end.
