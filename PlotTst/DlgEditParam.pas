unit DlgEditParam;

interface

uses RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RTTI, Container, RootIntf, JDtools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.UITypes, System.TypInfo,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvExControls, JvInspector, Vcl.ExtCtrls, JvComponentBase, CustomPlot;

type
  TFormEditParam = class(TDialogIForm, IDialog, IDialog<TGraphPar>)
    btExit: TButton;
    insp: TJvInspector;
    InspectorBorlandPainter: TJvInspectorBorlandPainter;
    procedure btExitClick(Sender: TObject); virtual;
  private
    FEditParam: TGraphPar;
  public
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: TGraphPar): Boolean;
  end;

  TFormEditArrayParam = class(TFormEditParam, IDialog<TArray<TObject>>)
    procedure btExitClick(Sender: TObject); override;
  private
    FEditParam: TArray<TObject>;
  public
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: TArray<TObject>): Boolean; reintroduce;
  end;

implementation

{$R *.dfm}

{ TFormEditParam }

procedure TFormEditParam.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_EditViewParameters>;
end;

function TFormEditParam.Execute(InputData: TGraphPar): Boolean;
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

{ TFormEditArrayParam }

procedure TFormEditArrayParam.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_EditArrayParameters>;
end;

function TFormEditArrayParam.Execute(InputData: TArray<TObject>): Boolean;
begin
  Result := True;
  FEditParam := InputData;
  Insp.Root.SortKind := iskNone;
  ShowPropAttribute.Apply(FEditParam, Insp);
  IShow;
end;

function TFormEditArrayParam.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_EditArrayParameters);
end;

initialization
  RegisterDialog.Add<TFormEditParam, Dialog_EditViewParameters>;
  RegisterDialog.Add<TFormEditArrayParam, Dialog_EditArrayParameters>;
finalization
  RegisterDialog.Remove<TFormEditParam>;
  RegisterDialog.Remove<TFormEditArrayParam>;
end.
