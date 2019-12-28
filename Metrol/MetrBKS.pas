unit MetrBKS;

interface

uses  DeviceIntf, PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, math, MetrForm,
     LuaInclin.Math, XMLLua.Math, MetrInclin.Math2, RootImpl, JDtools, VerySimple.Lua.Lib, tools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Xml.XMLIntf,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormBKS = class(TFormMetrolog)
    PanelM: TPanel;
    lbInfo: TLabel;
    lbAlpha: TLabel;
    Tree: TVirtualStringTree;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
  protected
   const
     NICON = 196;
    procedure Loaded; override;
    class function ClassIcon: Integer; override;
//    function UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean; override;
  public
    [StaticAction('����� ���������� ���', '����������', NICON, '0:����������.��')]
    class procedure DoCreateForm(Sender: IAction); override;
    class function MetrolMame: string; override;
    class function MetrolType: string; override;
  end;

var
  FormBKS: TFormBKS;

implementation

{$R *.dfm}

{ TFormBKS }

class function TFormBKS.ClassIcon: Integer;
begin
  Result := NICON
end;

class procedure TFormBKS.DoCreateForm(Sender: IAction);
begin
  inherited;

end;

procedure TFormBKS.Loaded;
begin
  SetupStepTree(Tree);
  inherited;
  AttestatPanel.Align := alBottom;
end;

class function TFormBKS.MetrolMame: string;
begin
  Result := '���';
end;

class function TFormBKS.MetrolType: string;
begin
  Result := 'TBKS1'
end;

procedure TFormBKS.TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  lbInfo.Caption := PNodeExData(Tree.GetNodeData(Node)).XMNode.Attributes['INFO'];
  AttestatLabel.Caption := '����������';
end;

procedure TFormBKS.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
 var
  p: PNodeExData;
  procedure SetData(const path, atr: string; const fmt: string = '');
   var
    V: Variant;
    r: IXMLNode;
  begin
    if path = '' then r := p.XMNode
    else r := GetXNode(p.XMNode, Path);
    if not Assigned(r) then Exit;
    if r.HasAttribute(atr) then V := r.Attributes[atr];
    if not VarIsNull(V) then
     if (fmt <> '') then CellText := Format(fmt,[Double(V)])
     else CellText := V;
  end;
begin
  CellText := '';
  p := Sender.GetNodeData(Node);
  if not Assigned(p.XMNode) then Exit;
   case Column of
    0: SetData('', 'STEP');
    1: SetData('', 'FOCUS');
    2: SetData('', 'CNL');
    3: SetData(Format('focus%d.%s.DEV',[Integer(p.XMNode.Attributes['FOCUS']), p.XMNode.Attributes['CNL']]), AT_VALUE);
    4: SetData('', 'K');
    5: SetData('Ubk.DEV', AT_VALUE);
   end;
end;


initialization
  RegisterClass(TFormBKS);
  TRegister.AddType<TFormBKS, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormBKS>;
end.
