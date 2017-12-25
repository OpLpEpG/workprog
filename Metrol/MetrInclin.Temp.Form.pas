unit MetrInclin.Temp.Form;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, math, tools, XMLLua.Math,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Bindings.Expression, Xml.XMLIntf,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, Vcl.ImgList, Vcl.ExtCtrls, Vcl.StdCtrls,
  MetrForm, Vcl.ComCtrls, AutoMetr.Inclin, RootImpl;

type
  TFormMetrInclinT = class(TFormMetrolog, IAutomatMetrology)
    Tree: TVirtualStringTree;
    lbInfo: TLabel;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FAutomatMetrology: TinclAuto;
  protected
   const
    NICON = 86;
    procedure Loaded; override;
    function UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean; override;
//    function UserSetupAlg(alg: IXMLNode): Boolean; override;
    class function ClassIcon: Integer; override;
  public
    [StaticAction('���������� ����. �� �', '����������', NICON, '0:����������.������������:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
    class function MetrolMame: string; override;
    class function MetrolType: string; override;
    destructor Destroy; override;
    property AutomatMetrology: TinclAuto read FAutomatMetrology implements IAutomatMetrology;
  end;

implementation

{$R *.dfm}

{ TFormMetrInclinT }

class function TFormMetrInclinT.ClassIcon: Integer;
begin
  Result := NICON;
end;

destructor TFormMetrInclinT.Destroy;
begin
  FAutomatMetrology.Free;
  inherited;
end;

class procedure TFormMetrInclinT.DoCreateForm(Sender: IAction);
begin
  inherited;
end;

procedure TFormMetrInclinT.Loaded;
begin
  FlagNoUpdateFromEtalon := True;
  SetupStepTree(Tree);
  inherited;
  FAutomatMetrology := TinclAuto.Create(Self, AutoReport);
  AttestatPanel.Align := alBottom;
end;

class function TFormMetrInclinT.MetrolMame: string;
begin
  Result := 'InclinT'
end;

class function TFormMetrInclinT.MetrolType: string;
begin
  Result := 'InclTem1'
end;

procedure TFormMetrInclinT.TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  lbInfo.Caption := PNodeExData(Tree.GetNodeData(Node)).XMNode.Attributes['INFO'];
end;

procedure TFormMetrInclinT.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
 var
  p: PNodeExData;
  r: IXMLNode;
  i: Integer;
  procedure SetData(const path, attr, fmt: string; Correction: Double = 0);
   var
    V: IXMLNode;
  begin
    if TryGetX(p.XMNode, Format('Inclin%d.%s', [(Column-1) div 7 + 1, path]), V, attr) then
         CellText := Format(fmt,[Double(V.NodeValue) + Correction])
    else
         CellText := ''
  end;
begin
  CellText := '';
  p := Sender.GetNodeData(Node);
  if not Assigned(p.XMNode) then Exit;
  case Column of
   0: begin
       r := p.XMNode;
       if r.HasAttribute('STEP') then CellText := r.Attributes['STEP']
       else CellText := 'STEP';
      end;
   1, 8, 15, 22, 29: SetData('accel.X.DEV',      AT_VALUE,     '%7.0f');
   2, 9, 16, 23, 30: SetData('accel.Y.DEV',      AT_VALUE,     '%7.0f');
   3,10, 17, 24, 31: SetData('accel.Z.DEV',      AT_VALUE,     '%7.0f');
   4,11, 18, 25, 32: SetData('magnit.X.DEV',     AT_VALUE,     '%7.0f');
   5,12, 19, 26, 33: SetData('magnit.Y.DEV',     AT_VALUE,     '%7.0f');
   6,13, 20, 27, 34: SetData('magnit.Z.DEV',     AT_VALUE,     '%7.0f');
   7,14, 21, 28, 35: SetData('T.DEV',     AT_VALUE,     '%7.0f');
  end;
end;

function TFormMetrInclinT.UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean;
begin
  Result := True;
end;

{function TFormMetrInclinT.UserSetupAlg(alg: IXMLNode): Boolean;
  function AddHG(stp: IXMLNode; const Root: string):Variant;
  begin
    stp := TXMLScriptMath.AddXmlPath(stp, Root);
    TXMLScriptMath.AddXmlPath(stp, 'X.DEV');
    TXMLScriptMath.AddXmlPath(stp, 'Y.DEV');
    TXMLScriptMath.AddXmlPath(stp, 'Z.DEV');
    Result := XToVar(stp);
    Result.X.DEV.VALUE := 0;
    Result.Y.DEV.VALUE := 0;
    Result.Z.DEV.VALUE := 0;
  end;
 const
  NFORT = 12;
  NT = 4;
  procedure AddStep(tmp, stp: Integer;  alg: IXMLNode);
   const
    TINF: array [1..NT] of string = ('21','130','100','21');
    INF: array [1..NFORT] of string = ('������ 90 ����� 90 Gx ��������',
                                                           '�x ��������',
                                                           'Gy ��������',
                                                           'Hy ��������',
                                                           'Gx �������',
                                                           'Hx �������',
                                                           'Gy �������',
                                                           'Hy �������',
                                 '������ 0 ����� 0','����� 19.5 �z ��������',
                                 '����� 180 Gz �������','����� 160.5 Hz �������');
   var
    i, step: Integer;
    v: Variant;
    r, t: IXMLNode;
  begin
    step := NFORT*(tmp-1) + stp;
    r := TXMLScriptMath.AddXmlPath(alg, 'STEP' + step.ToString());
    v := XToVar(r);
    v.EXECUTED := False;
    v.STEP := step;
    v.INFO := Format('%d) ����:%s; %s',[step, TINF[tmp], INF[stp]]);
    for i := 1 to 5 do
     begin
      AddHG(r, Format('Inclin%d.%s.', [i, 'accel']));
      AddHG(r, Format('Inclin%d.%s.', [i, 'magnit']));
      t := TXMLScriptMath.AddXmlPath(r, Format('Inclin%d.T.DEV', [i]));
      t.Attributes[AT_VALUE] := 0;
     end;
  end;
 var
  i,t: Integer;
begin
  Result := True;
   for t := 1 to NT do
    for i := 1 to NFORT do AddStep(t, i, alg);
end;  }

initialization
  RegisterClass(TFormMetrInclinT);
  TRegister.AddType<TFormMetrInclinT, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormMetrInclinT>;
end.
