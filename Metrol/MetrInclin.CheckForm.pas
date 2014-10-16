unit MetrInclin.CheckForm;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, math, MetrForm, AutoMetr.Inclin, RootImpl,
     MetrInclin.Math, XMLScript.Math, UakiIntf,
     VirtualTrees, Xml.XMLIntf, Vcl.Menus,
     Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
     Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormInclinCheck = class(TFormMetrolog, IAutomatMetrology)
    PanelM: TPanel;
    lbInfo: TLabel;
    pc: TCPageControl;
    Tree: TVirtualStringTree;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FAutomatMetrology: TinclAuto;
    procedure NParamClick(Sender: TObject);
  protected
    FStep: record
            stp: Integer;
            root: Variant;
           end;
    function FindMaxErr(alg: IXMLNode; from, too: Integer; const attr: string): Double;
    function AddStep(const Info: string; const Args: array of const): Variant;
    procedure Loaded; override;
   const
    NICON = 86;
    procedure DoStopAtt(AttNode: IXMLNode); override;
    function UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean; override;
    function UserSetupAlg(alg: IXMLNode): Boolean; override;
    class function ClassIcon: Integer; override;
  public
    destructor Destroy; override;
    [StaticAction('����� �������', '����������', NICON, '0:����������.������������:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
    class function MetrolMame: string; override;
    class function MetrolType: string; override;
    property AutomatMetrology: TinclAuto read FAutomatMetrology implements IAutomatMetrology;
  end;

implementation

{$R *.dfm}

uses tools, MetrInclin.CheckFormSetup;

{ TFormInclinCheck }

class function TFormInclinCheck.ClassIcon: Integer;
begin
  Result := NICON;
end;

destructor TFormInclinCheck.Destroy;
begin
  FAutomatMetrology.Free;
  inherited;
end;

class procedure TFormInclinCheck.DoCreateForm(Sender: IAction);
begin
  inherited;
end;

procedure TFormInclinCheck.DoStopAtt(AttNode: IXMLNode);
 var
  v: Variant;
begin
  v := XToVar(AttNode);
  v.����.������ := Double(FAutomatMetrology.uaki.Azi.CurrentAngle);
  v.����.����� := Double(FAutomatMetrology.uaki.Zen.CurrentAngle);
  v.����.err_������ := TMetrInclinMath.DeltaAngle(v.������.CLC.VALUE - v.����.������);
  if v.����.����� > 180 then v.����.err_����� := TMetrInclinMath.DeltaAngle(v.�����.CLC.VALUE -(360 - v.����.�����))
  else v.����.err_����� := TMetrInclinMath.DeltaAngle(v.�����.CLC.VALUE - v.����.�����);
  inherited;
end;

procedure TFormInclinCheck.Loaded;
 var
  n: TMenuItem;
begin
  FlagNoUpdateFromEtalon := True;
  SetupStepTree(Tree);
  inherited;
  NIsMedian.Visible := True;
  AddToNCMenu('-', nil, n);
  AddToNCMenu('��������� �������...', NParamClick, n);
  FAutomatMetrology := TinclAuto.Create(Self, AutoReport);
  AttestatPanel.Align := alBottom;
end;

class function TFormInclinCheck.MetrolMame: string;
begin
  Result := 'Inclin'
end;

class function TFormInclinCheck.MetrolType: string;
begin
  Result := 'P_1'
end;

procedure TFormInclinCheck.NParamClick(Sender: TObject);
begin
  if TFormInclinCheckSetup.Execute(GetMetr([MetrolType], FileData)) then
     if TrrFile <> '' then FileData.OwnerDocument.SaveToFile(TrrFile)
end;

procedure TFormInclinCheck.TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  lbInfo.Caption := PNodeExData(Tree.GetNodeData(Node)).XMNode.Attributes['INFO'];
end;

procedure TFormInclinCheck.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
 var
  p: PNodeExData;
  r: IXMLNode;
  procedure SetData(const path, attr, fmt: string);
   var
    V: IXMLNode;
  begin
    if TryGetX(p.XMNode, path, V, attr) then CellText := Format(fmt,[Double(V.NodeValue)])
    else CellText := ''
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
    1: SetData('����',             '������',     '%7.2f');
    2: SetData('������.CLC',       AT_VALUE,     '%6.1f');
    3: SetData('����',             'err_������', '%6.2f');
    4: SetData('����',             '�����',      '%7.2f');
    5: SetData('�����.CLC',        AT_VALUE,     '%7.2f');
    6: SetData('����',             'err_�����',  '%6.2f');
    7: SetData('�����������.CLC',  AT_VALUE,     '%6.1f');
    8: SetData('���_������.CLC',   AT_VALUE,     '%6.1f');
    9: SetData('������_accel.CLC', AT_VALUE,     '%7.1f');
   10: SetData('������_magnit.CLC',AT_VALUE,     '%7.1f');
   11: SetData('���_������.CLC',   AT_VALUE,     '%6.1f');
   12: SetData('accel.X.DEV',      AT_VALUE,     '%7.0f');
   13: SetData('accel.Y.DEV',      AT_VALUE,     '%7.0f');
   14: SetData('accel.Z.DEV',      AT_VALUE,     '%7.0f');
   15: SetData('magnit.X.DEV',     AT_VALUE,     '%7.0f');
   16: SetData('magnit.Y.DEV',     AT_VALUE,     '%7.0f');
   17: SetData('magnit.Z.DEV',     AT_VALUE,     '%7.0f');
   18: SetData('accel.X.CLC',      AT_VALUE,     '%7.1f');
   19: SetData('accel.Y.CLC',      AT_VALUE,     '%7.1f');
   20: SetData('accel.Z.CLC',      AT_VALUE,     '%7.1f');
   21: SetData('magnit.X.CLC',     AT_VALUE,     '%7.1f');
   22: SetData('magnit.Y.CLC',     AT_VALUE,     '%7.1f');
   23: SetData('magnit.Z.CLC',     AT_VALUE,     '%7.1f');
   end;
end;

function TFormInclinCheck.AddStep(const Info: string; const Args: array of const): Variant;
begin
  Result := TMetrInclinMath.AddStep(FStep.stp, Format(Info, Args), FStep.root);
  TXMLScriptMath.AddXmlPath(Result, '�����.CLC');
  TXMLScriptMath.AddXmlPath(Result, '������.CLC');
  TXMLScriptMath.AddXmlPath(Result, '�����������.CLC');
  TXMLScriptMath.AddXmlPath(Result, '���_������.CLC');
  TXMLScriptMath.AddXmlPath(Result, '������_accel.CLC');
  TXMLScriptMath.AddXmlPath(Result, '������_magnit.CLC');
  TXMLScriptMath.AddXmlPath(Result, '���_������.CLC');
  TXMLScriptMath.AddXmlPath(Result, '����');
  Result.�����.CLC.VALUE := 0;
  Result.�����.METR := ME_ANGLE;
  Result.������.CLC.VALUE := 0;
  Result.������.METR := ME_ANGLE;
  Result.�����������.CLC.VALUE := 0;
  Result.�����������.METR := ME_ANGLE;
  Result.���_������.CLC.VALUE := 0;
  Result.���_������.METR := ME_ANGLE;
  Result.���_������.CLC.VALUE := 0;
  Result.���_������.METR := ME_ANGLE;
  Result.������_accel.CLC.VALUE := 0;
  Result.������_magnit.CLC.VALUE := 0;
  Result.����.������ := 0;
  Result.����.����� := 0;
  Result.����.err_������ := 0;
  Result.����.err_����� := 0;
  Inc(FStep.stp);
end;

function TFormInclinCheck.UserSetupAlg(alg: IXMLNode): Boolean;
 var
  s: Variant;
  i, zu: Integer;
  procedure AddVizir(v: Integer);
  begin
    s := AddStep('������: ����� %d ��������.',[v*45]);
    s.TASK.Vizir_Dev := v*45;
    s.TASK.Vizir_tol := 0.5;
    s.TASK.Vizir_NIter := 4;
    s.TASK.Dalay_Kadr := 5;
  end;
  procedure AddAzim(a: Integer);
  begin
    s := AddStep('����: ������ %d ��������.',[a*30]);
    s.TASK.Azimut_Stol := a*30;
    s.TASK.Dalay_Kadr := 5;
  end;
begin
  Result := True;
  FStep.root := XToVar(alg);
  FStep.stp := 1;
  s := AddStep('����: ������ ���� 0, ����� 30, ������: ����� %d ��������.', [0]);
  s.TASK.Azimut_Stol := 0;
  s.TASK.Zenit_Stol := 30;
  s.TASK.Vizir_Dev :=  0;
  s.TASK.Vizir_tol :=  0.5;
  s.TASK.Vizir_NIter :=  4;
  s.TASK.Dalay_Kadr := 5;
  for I := 1 to 7 do AddVizir(i);
  zu := 60;
  while zu <= 120 do
   begin
    s := AddStep('����� %d, ������: ����� 315 ��������.', [zu]);
    s.TASK.Zenit_Stol := zu;
    s.TASK.Vizir_Dev :=  315;
    s.TASK.Vizir_tol :=  0.5;
    s.TASK.Vizir_NIter :=  4;
    s.TASK.Dalay_Kadr := 5;
    for I := 6 downto 0 do AddVizir(i);
    Inc(zu, 30);
    if zu > 120 then Break;
    s := AddStep('����� %d, ������: ����� 0 ��������.', [zu]);
    s.TASK.Zenit_Stol := zu;
    s.TASK.Vizir_Dev :=  0;
    s.TASK.Vizir_tol :=  0.5;
    s.TASK.Vizir_NIter :=  4;
    s.TASK.Dalay_Kadr := 5;
    for I := 1 to 7 do AddVizir(i);
    Inc(zu, 30);
   end;
  s := AddStep('����: ������ ���� %d, ����� 120, ������: ����� 180 ��������.', [0]);
  s.TASK.Azimut_Stol := 0;
  s.TASK.Zenit_Stol := 120;
  s.TASK.Vizir_Dev := 180;
  s.TASK.Vizir_tol :=  0.5;
  s.TASK.Vizir_NIter := 4;
  s.TASK.Dalay_Kadr := 5;
  for i := 1 to 11 do AddAzim(i);
  zu := 90;
  while zu >= 30 do
   begin
    s := AddStep('����: ������ ���� 330, ����� %d ��������', [zu]);
    s.TASK.Zenit_Stol := zu;
    s.TASK.Dalay_Kadr := 5;
    for i := 10 downto 0 do AddAzim(i);
    Dec(zu, 30);
    if zu < 30 then break;
    s := AddStep('����: ������ ���� 0, ����� %d ��������', [zu]);
    s.TASK.Zenit_Stol := zu;
    s.TASK.Dalay_Kadr := 5;
    for i := 1 to 11 do AddAzim(i);
    Dec(zu, 30);
   end;
  s := AddStep('����: ������ ���� 0, ����� %d ��������', [10]);
  s.TASK.Zenit_Stol := 10;
  s.TASK.Dalay_Kadr := 5;
  for i := 1 to 11 do AddAzim(i);
  s := AddStep('����: ������ ���� 330, ����� %d ��������', [5]);
  s.TASK.Zenit_Stol := 5;
  s.TASK.Dalay_Kadr := 5;
  for i := 10 downto 0 do AddAzim(i);
end;

function TFormInclinCheck.FindMaxErr(alg: IXMLNode;  from, too: Integer; const attr: string): Double;
 var
  i: Integer;
  n: IXMLNode;
begin
  Result := 0;
  for I := from to too do if TryGetX(alg, Format('STEP%d.����',[I]), n, attr) and (Abs(Result) < Abs(n.NodeValue)) then Result := n.NodeValue
end;

function TFormInclinCheck.UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean;
begin
  Result := True;
  case Step of
   32 :
       begin
        alg.Attributes['ErrZU']  := FindMaxErr(alg, 1,    32, 'err_�����');
       end;
   80 : alg.Attributes['ErrAZ']  := FindMaxErr(alg, 33,   80, 'err_������');
   104: alg.Attributes['ErrAZ5'] := FindMaxErr(alg, 81,  105, 'err_������');
  end;
end;

initialization
  RegisterClass(TFormInclinCheck);
  TRegister.AddType<TFormInclinCheck, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormInclinCheck>;
end.
