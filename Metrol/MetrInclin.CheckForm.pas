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
    PanelP: TPanel;
    Splitter2: TSplitter;
    TreeA: TVirtualStringTree;
    TreeH: TVirtualStringTree;
    Splitter: TSplitter;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeAHGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FAutomatMetrology: TinclAuto;
    FStolVizir: Double;
    FStolAzimut: Double;
    FStolZenit: Double;
    procedure NParamClick(Sender: TObject);
    procedure NShowTrrClick(Sender: TObject);
    procedure NAziCorrClick(Sender: TObject);
    procedure NZenCorrClick(Sender: TObject);
  protected
    FStep: record
            stp: Integer;
            root: Variant;
           end;
    FAziCorr: Double;
    FZenCorr: Double;
    function NAziCorrCaption: string;
    function NZenCorrCaption: string;
    function FindMaxErr(alg: IXMLNode; from, too: Integer; const attr: string): Double;
    function AddStep(const Info: string; const Args: array of const): Variant;
    procedure Loaded; override;
    procedure DoSetFont(const AFont: TFont); override;
    procedure DoUpdateData(NewFileData: Boolean = False); override;
   const
    NICON = 86;
    procedure DoStopAtt(AttNode: IXMLNode); override;
    function UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean; override;
//    procedure UserExecStepUpdateStolAngle(Step: Integer; alg, trr: IXMLNode);
    function UserSetupAlg(alg: IXMLNode): Boolean; override;
    class function ClassIcon: Integer; override;
  public
    destructor Destroy; override;
    property StolVizir: Double read FStolVizir;
    property StolZenit: Double read FStolZenit;
    property StolAzimut: Double read FStolAzimut;

    [StaticAction('����� �������', '����������', NICON, '0:����������.������������:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
    class function MetrolMame: string; override;
    class function MetrolType: string; override;
    property AutomatMetrology: TinclAuto read FAutomatMetrology implements IAutomatMetrology;
  end;

implementation

{$R *.dfm}

uses tools, MetrInclin.CheckFormSetup, MetrInclin;

{ TFormInclinCheck }

function TFormInclinCheck.NAziCorrCaption: string;
begin
  Result := Format('�������� ������� ����� [%g]...', [FAziCorr])
end;



procedure TFormInclinCheck.NAziCorrClick(Sender: TObject);
begin
  FAziCorr := InputBox('�������� ������� �����', '����� ��������', FAziCorr.ToString()).ToDouble;
  TMenuItem(Sender).Caption := NAziCorrCaption;
  ReCalc();
end;

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

procedure TFormInclinCheck.DoSetFont(const AFont: TFont);
begin
  inherited;
  TreeSetFont(TreeH);
  TreeSetFont(TreeA);
end;

procedure TFormInclinCheck.DoStopAtt(AttNode: IXMLNode);
 var
  v: Variant;
  n: IXMLNode;
  crZenit: Double;
begin
  if TryGetX(AttNode, 'TASK', n) then
   begin
    if n.HasAttribute('Vizir_Stol') then FStolVizir := Double(n.Attributes['Vizir_Stol']);
    if n.HasAttribute('Azimut_Stol') then FStolAzimut := Double(n.Attributes['Azimut_Stol']);
    if n.HasAttribute('Zenit_Stol') then FStolZenit := Double(n.Attributes['Zenit_Stol']);
   end;
  v := XToVar(AttNode);
  if FAutomatMetrology.UakiExists then
   begin
    v.����.������ := Double(FAutomatMetrology.uaki.Azi.CurrentAngle);
    v.����.����� := Double(FAutomatMetrology.uaki.Zen.CurrentAngle);
   end
  else
   begin
    v.����.������ := StolAzimut;
    v.����.����� := StolZenit;
   end;
  v.����.err_������ := TMetrInclinMath.DeltaAngle(v.������.CLC.VALUE - (v.����.������ + FAziCorr));
  crZenit := (v.����.����� + FZenCorr);
  if crZenit > 180 then v.����.err_����� := TMetrInclinMath.DeltaAngle(v.�����.CLC.VALUE -(360 - crZenit))
  else v.����.err_����� := TMetrInclinMath.DeltaAngle(v.�����.CLC.VALUE - crZenit);
  inherited;
  TFormInclin.UpdateAH(TreeA, GetMetr(['accel','m3x4'], GetFileOrDevData), '%1.5f', '%1.3f', '%1.5f');
  TFormInclin.UpdateAH(TreeH, GetMetr(['magnit','m3x4'], GetFileOrDevData), '%1.5f', '%1.3f', '%1.5f');
end;

procedure TFormInclinCheck.DoUpdateData(NewFileData: Boolean);
begin
  inherited DoUpdateData(NewFileData);
  TFormInclin.UpdateAH(TreeA, GetMetr(['accel','m3x4'], GetFileOrDevData), '%1.5f', '%1.3f', '%1.5f');
  TFormInclin.UpdateAH(TreeH, GetMetr(['magnit','m3x4'], GetFileOrDevData), '%1.5f', '%1.3f', '%1.5f');
end;

procedure TFormInclinCheck.Loaded;
// var
//  n: TMenuItem;
begin
  FlagNoUpdateFromEtalon := True;
  SetupStepTree(Tree);
  TFormInclin.InitT(TreeA);
  TFormInclin.InitT(TreeH);
  inherited;
  NIsMedian.Visible := True;
  AddToNCMenu('-');
  AddToNCMenu(NAziCorrCaption, NAziCorrClick);
  AddToNCMenu(NZenCorrCaption, NZenCorrClick);
  AddToNCMenu('���������� ��������', NShowTrrClick, 9, AUTO_CHECK[PanelP.Visible]);
  //n.Checked := PanelP.Visible;
  AddToNCMenu('��������� �������...', NParamClick);
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

procedure TFormInclinCheck.NShowTrrClick(Sender: TObject);
begin
  PanelP.Visible := TMenuItem(Sender).Checked;
  Splitter.Top := PanelM.Height;
end;

function TFormInclinCheck.NZenCorrCaption: string;
begin
  Result := Format('�������� ������ ����� [%g]...', [FZenCorr])
end;

procedure TFormInclinCheck.NZenCorrClick(Sender: TObject);
begin
  FZenCorr := InputBox('�������� ������ �����', '����� ��������', FZenCorr.ToString()).ToDouble;
  TMenuItem(Sender).Caption := NZenCorrCaption;
  ReCalc();
end;

procedure TFormInclinCheck.TreeAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  lbInfo.Caption := PNodeExData(Tree.GetNodeData(Node)).XMNode.Attributes['INFO'];
end;


procedure TFormInclinCheck.TreeAHGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
 var
  p: PNodeTData;
begin
  p := Sender.GetNodeData(Node);
  case Column of
   0: CellText := p.Item;
   1: CellText := p.x;
   2: CellText := p.y;
   3: CellText := p.z;
   4: CellText := p.d4;
  end;
end;


procedure TFormInclinCheck.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
 var
  p: PNodeExData;
  r: IXMLNode;
  procedure SetData(const path, attr, fmt: string; Correction: Double = 0);
   var
    V: IXMLNode;
  begin
    if TryGetX(p.XMNode, path, V, attr) then CellText := Format(fmt,[Double(V.NodeValue) + Correction])
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
    1: SetData('����',             '������',     '%7.2f', FaziCorr);
    2: SetData('������.CLC',       AT_VALUE,     '%6.1f');
    3: SetData('����',             'err_������', '%6.2f');
    4: SetData('����',             '�����',      '%7.2f', FZenCorr);
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
//  UserExecStepUpdateStolAngle(Step, alg, trr);
  case Step of
   32 :
       begin
        alg.Attributes['ErrZU']  := FindMaxErr(alg, 1,    32, 'err_�����');
       end;
   80 : alg.Attributes['ErrAZ']  := FindMaxErr(alg, 33,   80, 'err_������');
   104: alg.Attributes['ErrAZ5'] := FindMaxErr(alg, 81,  105, 'err_������');
  end;
end;

{procedure TFormInclinCheck.UserExecStepUpdateStolAngle(Step: Integer; alg, trr: IXMLNode);
 var
  n: IXMLNode;
begin
  if TryGetX(alg, Format('STEP%d.TASK',[Step]), n) then
   begin
     if n.HasAttribute('Vizir_Stol') then FStolVizir := Double(n.Attributes['Vizir_Stol']);
     if n.HasAttribute('Azimut_Stol') then FStolAzimut := Double(n.Attributes['Azimut_Stol']);
     if n.HasAttribute('Zenit_Stol') then FStolZenit := Double(n.Attributes['Zenit_Stol']);
   end;
end;}

initialization
  RegisterClass(TFormInclinCheck);
  TRegister.AddType<TFormInclinCheck, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormInclinCheck>;
end.
