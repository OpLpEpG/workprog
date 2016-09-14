unit MetrForm;

interface

uses system.UITypes,  JDtools,   JvInspector,
  DeviceIntf, PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, tools,XMLScript, Parser, RootImpl, System.IOUtils,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls, Xml.XMLDoc,   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, System.Bindings.Expression,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Xml.XMLIntf, VirtualTrees,
  Vcl.ActnPopup, ImportExport, Winapi.mmSystem;

type
 EFormMetrolog = class(EBaseException);

 MetrologState = (mstInitDev, mstInitFile, mstAttr, mstLockUpdate, mstAutomat);
 MetrologStates = set of MetrologState;

  PNodeExData = ^TNodeExData;
  TNodeExData = record
    XMNode: IXMLNode;
  end;

 TAutomatMetrology = class;
 TGetTextNode = reference to function (XMNode: IXMLNode; Column: Integer): string;
 TSetTextNode = reference to procedure (XMNode: IXMLNode; Column: Integer; const text: string);
 TAllowEditNode = reference to procedure (XMNode: IXMLNode; Column: Integer; var allow: Boolean);

 TFormMetrolog = class(TCustomFontIForm, ISetDevice)
  private
    FImportExport: IImportExport;
    FStepTree: TVirtualStringTree;
    FexeScript: TXmlScript;
    FStatusBar: TStatusBar;
    FDataDevice: string;
    FTrrFile: string;
    FImportFile: string;
    FMetaDataInfo: TInfoEventRes;
    FBindWorkRes: TWorkEventRes;
    NTrrApply: TMenuItem;
    NConnect: TMenuItem;
    NFileNew: TMenuItem;
    NFileOpen: TMenuItem;
    NFileSaveAs: TMenuItem;
    FPanel: TPanel;

    FLabel: TLabel;
    FLabelAuto: TLabel;
    FEtalonData: IXMLNode;
    FEtalonAlg: IXMLNode;
    FDevData: IXMLNode;
    FFileData: IXMLNode;
    FAttOld: IXMLNode;
    FAttSum: IXMLNode;
    FAttCnt, FAttN: Integer;
//    FAttCount: Integer;
    FState: MetrologStates;
    BAttStart: TButton;
    BAttStop: TButton;
    BAttCancel: TButton;

    BAutoStart: TButton;
    BAutoStop: TButton;

    FStepTreePopupMenu : TPopupActionBar;

    FGetText: TGetTextNode;
    FSetText: TSetTextNode;
    FAllowEditNode: TAllowEditNode;
//    FIsMedian: Boolean;

    procedure BAttStartClick(Sender: TObject);
    procedure BAttCancelClick(Sender: TObject);
    procedure BAttStopClick(Sender: TObject);

    procedure BAutoStartClick(Sender: TObject);
    procedure BAutoStopClick(Sender: TObject);

//    procedure NIsMedianClick(Sender: TObject);
    procedure NConnectClick(Sender: TObject);
    procedure NFileOpenClick(Sender: TObject);
    procedure NFileSaveAsClick(Sender: TObject);
    procedure NFileNewClick(Sender: TObject);
    procedure NStandartSetupClick(Sender: TObject);
    procedure NTreeHeaderClick(Sender: TObject);
    procedure NTrrApplyClick(Sender: TObject);
    procedure NTrrSetClick(Sender: TObject);
    procedure NTrrResetClick(Sender: TObject);
    procedure NSetExecutedClick(Sender: TObject);
    procedure SetBindWorkRes(const Value: TWorkEventRes);
    procedure SetDataDevice(const Value: string);
    procedure SetMetaDataInfo(const Value: TInfoEventRes);
    procedure SetRemoveDevice(const Value: string);
    procedure SetUpdateDeviceMetrology(const Value: TInfoEventRes);
    procedure SetTrrFile(const Value: string);
    function NewFFileData(const DevName: string): IXMLNode;
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    function GetAttCount: Integer;
    function GetIsMedian: Boolean;
    function GetOptions: IXMLNode;
    procedure TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    function GetOption(const index: string): variant;
  protected
//    NIsMedian: TMenuItem;
    FlagNoUpdateFromEtalon: boolean;
    procedure AutoReport(Status: TStatusAutomatMetrology; const info: string);

    procedure DoStandartSetup(Item: TJvCustomInspectorItem; Option: IXMLNode; var Data: IXMLNode); virtual;

    procedure InitializeNewForm; override;
    procedure Loaded; override;
    procedure DoSetFont(const AFont: TFont); override;
    function GetCurrentNode: IXMLNode; virtual;
    procedure DoUpdateData(NewFileData: Boolean = False); virtual;
    procedure DoUpdateEtalonData(EtlNode: IXMLNode); virtual;

    procedure DoStopAuto(); virtual;

    procedure DoStopAtt(AttNode: IXMLNode); virtual;
    procedure DoRunAtt(AttNode: IXMLNode); virtual;
    procedure DoStartAtt(AttNode: IXMLNode); virtual;
    procedure DoCancelAtt(AttNode: IXMLNode); virtual;
    procedure NCPopup(Sender: TObject); override;
    procedure ReCalc(NeedSave: Boolean = True);
    function UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean; virtual;
    function UserSetupAlg(alg: IXMLNode): Boolean; virtual;
    procedure TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex); virtual;
    procedure TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType); virtual;
    procedure TreeClear;
    procedure TreeUpdate; virtual;
    procedure TreeSetFont(T: TVirtualStringTree);
    procedure SetupStepTree(Tree: TVirtualStringTree);
    function GetFileOrDevData: IXMLNode;
    procedure AddDefaultOptions(RootTrr, RootOption: IXMLNode);
//    procedure UpdateRunXmlDir;
  public
    destructor Destroy; override;

    function GetMetr(nm: array of string; Root: IXMLNode): IXMLNode;

    procedure SetupEditor(Allow: TAllowEditNode; GetText: TGetTextNode; SetText: TSetTextNode);



    class function MetrolMame: string; virtual;
    class function MetrolType: string; virtual;

    property StatusBar: TStatusBar read FStatusBar;
    property AttestatPanel: TPanel read FPanel;
    property AttestatLabel: TLabel read FLabel;
    property AutoLabel: TLabel read FLabelAuto;

    property FileData: IXMLNode read FFileData;
    property DevData: IXMLNode read FDevData;

    property State: MetrologStates read FState;

    property C_BindWorkRes: TWorkEventRes read FBindWorkRes write SetBindWorkRes;
    property C_MetaDataInfo: TInfoEventRes read FMetaDataInfo write SetMetaDataInfo; //live binding
    property C_RemoveDevice: string read FDataDevice write SetRemoveDevice;
    property C_UpdateDeviceMetrology: TInfoEventRes read FMetaDataInfo write SetUpdateDeviceMetrology;

    property AttCount: Integer read GetAttCount;// write FAttCount default 5;
    property IsMedian: Boolean read GetIsMedian;// write FIsMedian default False;

    property Option[const index: string]: variant read GetOption;
  published
    property DataDevice: string read FDataDevice write SetDataDevice;
    property TrrFile: string read FTrrFile write SetTrrFile;
end;

  TAutomatMetrology = class(TAggObject, IAutomatMetrology)
  private
    FRep: TStepMetrologyEvent;
    FDelayCadrData:
    record
     n: Integer;
     ev: TProc;
    end;
  protected
    FKadrEvent: Boolean;
    FDelayKadr: Integer;
    FStep, FMetr: IXMLNode;
   //IAutomatMetrology
    procedure StartStep(Step: IXMLNode); virtual;
    procedure KadrEvent(); virtual;
    procedure SetDeviceData(WorkInfo: IXMLNode);
    procedure Stop(); virtual;
    procedure DoEndMetrology(); virtual;

//    function GetDelayKadr: Integer;
//    procedure SetDelayKadr(Value : Integer);

  ///	<summary>
  ///	  �� ������ ����������
  ///   ��������� ������ ��������
  ///	</summary>
    procedure DoStop();  virtual;

    procedure DelayKadr(NCadr: Integer; Res: TProc);
    procedure Error(const TextErr: string);

    function Owner: TFormMetrolog;
  public
    property Report: TStepMetrologyEvent read FRep write FRep;
//    property DelayKadr: Integer read GetDelayKadr write SetDelayKadr;
end;

implementation

uses MetrFormSetup, MetrInclin.Math;

{$REGION 'TEditor'}

type
  TEditor = class(TIObject, IVTEditLink)
  private
    FForm: TFormMetrolog;
    FEdit: TWinControl;        // One of the property editor classes.
    FTree: TVirtualStringTree; // A back reference to the tree calling.
    FNode: PVirtualNode;       // The node being edited.
    FData: PNodeExData;
    FColumn: Integer;          // The column of the node being edited.
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  public
    destructor Destroy; override;
  end;

destructor TEditor.Destroy;
begin
  //FEdit.Free; casues issue #357. Fix:
  if FEdit.HandleAllocated then PostMessage(FEdit.Handle, CM_RELEASE, 0, 0);
  inherited;
end;

procedure TEditor.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  CanAdvance: Boolean;
begin
  CanAdvance := true;
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;//ESC will be handled in EditKeyUp()
      end;
    VK_RETURN:
      if CanAdvance then
      begin
        FTree.EndEditNode;
        Key := 0;
      end;
    VK_UP,
    VK_DOWN:
      begin
        // Consider special cases before finishing edit mode.
        CanAdvance := Shift = [];
{        if FEdit is TComboBox then
          CanAdvance := CanAdvance and not TComboBox(FEdit).DroppedDown;
        if FEdit is TDateTimePicker then
          CanAdvance :=  CanAdvance and not TDateTimePicker(FEdit).DroppedDown;
}
        if CanAdvance then
        begin
          // Forward the keypress to the tree. It will asynchronously change the focused node.
          PostMessage(FTree.Handle, WM_KEYDOWN, Key, 0);
          Key := 0;
        end;
      end;
  end;
end;

procedure TEditor.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        FTree.CancelEditNode;
        Key := 0;
      end;//VK_ESCAPE
  end;//case
end;

function TEditor.BeginEdit: Boolean;
begin
  Result := True;
  FEdit.Show;
  FEdit.SetFocus;
end;

function TEditor.CancelEdit: Boolean;
begin
  Result := True;
  FEdit.Hide;
end;

function TEditor.EndEdit: Boolean;
begin
  Result := True;
  if Assigned(FForm.FSetText) then FForm.FSetText(FData.XMNode, FColumn, TEdit(FEdit).Text);
  FEdit.Hide;
  FTree.SetFocus;
end;

function TEditor.GetBounds: TRect;
begin
  Result := FEdit.BoundsRect;
end;

function TEditor.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
begin
  Result := True;
  FTree := Tree as TVirtualStringTree;
  FForm := FTree.Owner as TFormMetrolog;
  FNode := Node;
  FColumn := Column;
  FData := FTree.GetNodeData(FNode);
  // determine what edit type actually is needed
  FEdit.Free;
  FEdit := nil;
  FEdit := TEdit.Create(nil);
  with FEdit as TEdit do
  begin
    Visible := False;
    Parent := Tree;
    if Assigned(FForm.FGetText) then Text := FForm.FGetText(FData.XMNode, FColumn);
    OnKeyDown := EditKeyDown;
    OnKeyUp := EditKeyUp;
  end;
end;

procedure TEditor.ProcessMessage(var Message: TMessage);
begin
  FEdit.WindowProc(Message);
end;

procedure TEditor.SetBounds(R: TRect);
var
  Dummy: Integer;
begin
  // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
  // we have to set the edit's width explicitly to the width of the column.
  FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
  FEdit.BoundsRect := R;
end;
{$ENDREGION}

type
 IUpdateDeviceMetrol = interface
 ['{573AEDB0-8DA1-4698-A12E-9ECEB1BB5176}']
   procedure Update(Data: TInfoEventRes);
 end;

 TUpdateDeviceMetrol = class(TIComponent, IUpdateDeviceMetrol)
  private
    FS_UpdateDeviceMetrology: TInfoEventRes;
 protected
   procedure Update(Data: TInfoEventRes);
 public
   property S_UpdateDeviceMetrology: TInfoEventRes read FS_UpdateDeviceMetrology write FS_UpdateDeviceMetrology;
 end;

{ TIUpdateDeviceMetrol }

procedure TUpdateDeviceMetrol.Update(Data: TInfoEventRes);
begin
  FS_UpdateDeviceMetrology := Data;
  Notify('S_UpdateDeviceMetrology');
end;


{ TAutomatMetrology }

//function TAutomatMetrology.GetDelayKadr: Integer;
//begin
//  Result := FDelayKadr;
//end;

//procedure TAutomatMetrology.SetDelayKadr(Value: Integer);
//begin
//  if (FDelayKadr = 1) and (Value = 0) and (mstAutomat in Owner.FState) then DoStop();
//  FDelayKadr := Value;
//end;

procedure TAutomatMetrology.DelayKadr(NCadr: Integer; Res: TProc);
begin
  FDelayCadrData.n := NCadr;
  FDelayCadrData.ev := Res;
  Owner.AutoReport(samEnd, Format('��������, �������� %d ������',[FDelayCadrData.n]));
end;

procedure TAutomatMetrology.KadrEvent();
begin
  FKadrEvent := True;
  if FDelayCadrData.n > 0 then
   begin
    Dec(FDelayCadrData.n);
    if FDelayCadrData.n = 0 then FDelayCadrData.ev()
    else Owner.AutoReport(samEnd, Format('��������, �������� %d ������',[FDelayCadrData.n]));
   end;
end;

procedure TAutomatMetrology.DoEndMetrology;
begin
end;

procedure TAutomatMetrology.DoStop;
begin
  Owner.BAttStart.Click;
  Owner.AutoReport(samEnd, '����������');
end;

function TAutomatMetrology.Owner: TFormMetrolog;
begin
  Result := TFormMetrolog(Controller);
end;

procedure TAutomatMetrology.SetDeviceData(WorkInfo: IXMLNode);
begin
  FMetr := WorkInfo;
end;

procedure TAutomatMetrology.StartStep(Step: IXMLNode);
begin
  FDelayKadr := 0;
  if Boolean(step.Attributes['EXECUTED']) then
   if (MessageDlg(Format('��������� ��� %s ������?'#$D#$A'%s', [step.Attributes['STEP'], step.Attributes['INFO']]), TMsgDlgType.mtWarning, [mbYes, mbCancel], 0) = mrCancel) then
   begin
    Owner.BAutoStop.Click;
    raise EAbort.Create('�������� �������������');
   end
   else
    begin
     step.Attributes['EXECUTED'] := False;
     Owner.ReCalc();
    end;
  FStep := Step.ChildNodes.FindNode('TASK');
  if not Assigned(FStep) then raise EFormMetrolog.Create('����� TASK ���������');
end;

procedure TAutomatMetrology.Stop;
begin
  FDelayKadr := 0;
  FDelayCadrData.n := 0;
end;

procedure TAutomatMetrology.Error(const TextErr: string);
 var
  hResource: HGLOBAL;
  p: Pointer;
begin
  hResource := LoadResource(hInstance, FindResource(hInstance, 'AutomatErr', RT_RCDATA));
  try
   p := LockResource(hResource);
   try
    PlaySound(p, 0, SND_MEMORY + SND_ASYNC + SND_LOOP);
    MessageDlg(TextErr, mtError, [mbOk], 0);
    PlaySound(nil, 0, 0);
   finally
    UnLockResource(hResource);
   end;
  finally
   FreeResource(hResource);
  end;
end;


{ TFormMetrolog }

class function TFormMetrolog.MetrolMame: string;
begin
  raise EFormMetrolog.Create('�� ������ ��� ����������');
end;

class function TFormMetrolog.MetrolType: string;
begin
  raise EFormMetrolog.Create('�� ����� ��� ����������');
end;

procedure TFormMetrolog.InitializeNewForm;
 procedure AddButton(Ind, col: Integer; const Capt: string; ev: TNotifyEvent; var bt: TButton);
 begin
   bt := TButton.Create(FPanel);
   with bt do
    begin
     Parent := FPanel;
     ParentFont := False;
     Enabled := False;
     SetBounds(5 + 85*ind, (5+col*(24+3)), 80, 24);
     Caption := Capt;
     OnClick := ev;
    end;
 end;
 var
  n: TMenuItem;
  Doc: IXMLDocument;
  ie: IXMLNode;
begin
  inherited;
//  FAttCount := 5;
  FAttCnt := 0;

  FStatusBar := CreateUnLoad<TStatusBar>;
  FStatusBar.OnDrawPanel := StatusBarDrawPanel;
  FStatusBar.Panels.Add.Width := 150;
  FStatusBar.Panels.Add.Width := 200;
  FStatusBar.Panels[0].Text := '���������� �� ������';
  FStatusBar.Panels[0].Style := psOwnerDraw;
  FStatusBar.Panels[1].Text := '���� ��������� �� �����';
  FStatusBar.Parent := Self;

  FPanel := CreateUnLoad<TPanel>;
  FPanel.Parent := Self;
  FPanel.ShowCaption := False;
  FPanel.BevelOuter := bvNone;

  if Supports(self, IAutomatMetrology) then FPanel.SetBounds(0, 0, 333, 55)
  else FPanel.SetBounds(0, 0, 333, 33);

  AddButton(0,0, '����������', BAttStartClick, BAttStart);
  AddButton(1,0, '���������', BAttStopClick, BAttStop);
  AddButton(2,0, '������', BAttCancelClick, BAttCancel);

  if Supports(self, IAutomatMetrology) then
   begin
    AddButton(0,1, '�����', BAutoStartClick, BAutoStart);
    AddButton(1,1, '����', BAutoStopClick, BAutoStop);
    FLabelAuto := TLabel.Create(FPanel);
    FLabelAuto.Parent := FPanel;
    FLabelAuto.SetBounds(260, 30, 60, 13);
    FLabelAuto.Caption := '�������';
   end;

  FLabel := TLabel.Create(FPanel);
  FLabel.Parent := FPanel;
  FLabel.SetBounds(260, 1, 60, 13);
  FLabel.Caption := '����������';

  AddToNCMenu('-');
  n := AddToNCMenu('����');
  NFileNew := AddToNCMenu('������� ����� ���� ���������...', NFileNewClick, -1, -1, n);
  NFileOpen := AddToNCMenu('������� ������������...', NFileOpenClick, -1, -1, n);
  NFileSaveAs:= AddToNCMenu('��������� ���...', NFileSaveAsClick, -1, -1, n);
  NFileNew.Enabled := False;
  NFileSaveAs.Enabled := False;

  AddToNCMenu('-');
  NConnect := AddToNCMenu('���������� � ����������');
  NTrrApply := AddToNCMenu('���������� �������� � ����������', NTrrApplyClick);
  NTrrApply.Enabled := False;
//  NIsMedian := AddToNCMenu('��������� ����� ����������', NIsMedianClick, -1, 0);
//  NIsMedian.Visible := False;

  AddToNCMenu('-');
  AddToNCMenu('���������...', NStandartSetupClick);

  Doc := NewXDocument();
  FEtalonData := Doc.AddChild(MetrolMame);
  ScriptExec(FEtalonData, FEtalonData, MetrolMame,'','SETUP_METR');
  DoUpdateEtalonData(FEtalonData);

  Doc := NewXDocument();
  FEtalonAlg := Doc.AddChild(MetrolType);

  AddDefaultOptions(FEtalonAlg, GetOptions);

  if not UserSetupAlg(FEtalonAlg) then ScriptExec(FEtalonAlg, FEtalonAlg, MetrolMame, MetrolType,'SETUP_METR');

 // FEtalonAlg.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'NNK_ALG.xml');

  ie := GetXNode(TPars.XMLScript, MetrolMame+'.MODEL.'+ MetrolType);
  if Assigned(ie) then FImportExport := TImportExport.Create(ie);
end;

procedure TFormMetrolog.Loaded;
 var
  d: IDevice;
  de: IDeviceEnum;
  ex: IXMLNode;
begin
  Include(FState, mstLockUpdate);
  inherited;
//  NIsMedian.Checked := IsMedian;
  GlobalCore.QueryInterface(IDeviceEnum, de);
  if Assigned(de) then  Bind('C_RemoveDevice', de, ['S_BeforeRemove']);// (de as IBind).CreateManagedBinding(Self, , ['S_BeforeRemove']);
  FStatusBar.Top := ClientHeight;

  FexeScript := CreateUnLoad<TXmlScript>;


  ex := GetXNode(TPars.XMLScript.ChildNodes.FindNode(MetrolMame), 'MODEL.'+ MetrolType);

  if not Assigned(ex) then raise EFormMetrolog.CreateFmt('���������� %s %s �� �������', [MetrolMame, MetrolType]);

  if ex.HasAttribute('EXEC_METR') then
   begin
    FexeScript.Lines.Text := ex.Attributes['EXEC_METR'];
    if not FexeScript.Compile then MessageDlg('������ ���������� '+MetrolType+' '+FexeScript.ErrorMsg+':'+FexeScript.ErrorPos,TMsgDlgType.mtError, [mbOK], 0);
   end;

  if Assigned(de) then d := de.Get(FDataDevice);
  if Assigned(d) and Supports(d, IDataDevice) then C_MetaDataInfo := (d as IDataDevice).GetMetaData();

  Exclude(FState, mstLockUpdate);
  DoUpdateData(True);

//  BAttStop.Enabled := True;
end;

procedure TFormMetrolog.SetTrrFile(const Value: string);
 var
  GDoc: IXMLDocument;
  m, t: IXMLNode;
  procedure LoadFile;
  begin
    if HasXTree(FEtalonData, m) then
     begin
      if not Assigned(t) then
       begin
        m.ChildNodes.Add(FEtalonAlg.CloneNode(True));
        GDoc.SaveToFile(Value);
       end;
      FTrrFile := Value;
      FStatusBar.Panels[1].Text := FTrrFile;
      FFileData := GDoc.DocumentElement;
      Include(FState, mstInitFile);
      NTrrApply.Click;
      NFileSaveAs.Enabled := True;
//        UpdateRunXmlDir;
      if not (csLoading in ComponentState) then DoUpdateData(True);
      (GlobalCore as IUpdateDeviceMetrol).Update(FMetaDataInfo);
     end
    else MessageDlg('������� ���� �� ������� - �������� ���������', TMsgDlgType.mtError, [mbOK], 0);
  end;
begin
  if FTrrFile = Value then Exit;
  if FileExists(Value) then
   begin
    GDoc := NewXDocument();
    GDoc.LoadFromFile(Value);
    m := GetMetr([], GDoc.DocumentElement);
    if Assigned(m) then
     begin
      t := m.ChildNodes.FindNode(MetrolType);
      if Assigned(t) and not HasXTree(FEtalonAlg, t) then
       if mrYes = MessageDlg('������� ���� �� ������� - �������� ��������� ��������� ����������,'
                            +'������� � ����� ������?', TMsgDlgType.mtError, [mbYes, mbNo], 0) then LoadFile
       else Exit
      else LoadFile
     end
    else MessageDlg('������� ���� �� ������� - �� ������� ����������', TMsgDlgType.mtError, [mbOK], 0);
   end
  else MessageDlg('������� ���� �� ������� - ��� �����', TMsgDlgType.mtError, [mbOK], 0);
end;

procedure TFormMetrolog.SetUpdateDeviceMetrology(const Value: TInfoEventRes);
 var
  Res: Integer;
begin
  Res := 0;
  if not (Assigned(FFileData) and Assigned(FDevData) and (Value.Info = FDevData)
     and HasXTree(GetMetr([], FDevData), GetMetr([], FileData),
     procedure(devroot, dev, failRoot, fail: IXMLNode)
     begin
       if dev.NodeValue <> fail.NodeValue then
        begin
         Res := Res or 1;
        end;
     end, false)) then
      begin
       Res := Res or 2;
      end;
  if Res = 0 then  FStatusBar.Panels[0].Text := '�������� � ����������:G'
  else if Res = 1 then FStatusBar.Panels[0].Text := '�������� ������!!!:RB';
end;

procedure TFormMetrolog.TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TEditor.Create;
end;

procedure TFormMetrolog.TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  if Assigned(FAllowEditNode) then FAllowEditNode(PNodeExData(FStepTree.GetNodeData(Node)).XMNode, Column, Allowed)
end;

procedure TFormMetrolog.SetupEditor(Allow: TAllowEditNode; GetText: TGetTextNode; SetText: TSetTextNode);
begin
  FAllowEditNode := Allow;
  FGetText := GetText;
  FSetText := SetText;
  FStepTree.OnCreateEditor := TreeCreateEditor;
  FStepTree.OnEditing := TreeEditing;
end;

procedure TFormMetrolog.SetupStepTree(Tree: TVirtualStringTree);
 var
  ip: IImagProvider;
  n: TMenuItem;
  i: Integer;
begin
  FStepTree := Tree;
  FStepTree.NodeDataSize := SizeOf(TNodeExData);
  if Supports(GlobalCore, IImagProvider, ip) then FStepTree.Images := ip.GetImagList;
  FStepTree.OnGetImageIndex := TreeGetImageIndex;
  FStepTree.OnPaintText := TreePaintText;

  FStepTree.Header.PopupMenu := CreateUnLoad<TPopupActionBar>;
  with FStepTree.Header do for i := 0 to Columns.Count-1 do
   begin
    n := TMenuItem.Create(PopupMenu);
    n.AutoCheck := True;
    n.Checked :=  coVisible in Columns[i].Options;
    n.OnClick := NTreeHeaderClick;
    n.Caption := Columns[i].Text;
    n.Tag := i;
    PopupMenu.Items.Add(n);
   end;
  FStepTreePopupMenu := CreateUnLoad<TPopupActionBar>;
  n := TMenuItem.Create(PopupMenu);
  n.OnClick := NTrrResetClick;
  n.Caption := '�������� ���� ������� � ����������';
  FStepTreePopupMenu.Items.Add(n);

  n := TMenuItem.Create(PopupMenu);
  n.OnClick := NSetExecutedClick;
  n.Caption := '������� ��������� ��� �����������';
  FStepTreePopupMenu.Items.Add(n);

  n := TMenuItem.Create(PopupMenu);
  n.OnClick := NTrrSetClick;
  n.Caption := '������� ���� �� ���������� ������������';
  FStepTreePopupMenu.Items.Add(n);
end;

procedure TFormMetrolog.StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
 var
  s: TArray<string>;
begin
  s := Panel.Text.Split([':']);
  if Length(s) >= 2 then
   begin
    case s[1].Chars[0] of
     'R': StatusBar.Canvas.Font.Color := clRed;
     'G': StatusBar.Canvas.Font.Color := clGreen;
    end;
    case s[1].Chars[1] of
     'B': StatusBar.Canvas.Font.Style :=  StatusBar.Canvas.Font.Style + [fsBold];
    end
   end
  else StatusBar.Canvas.Font := StatusBar.Font;
  StatusBar.Canvas.TextOut(Rect.Left, Rect.Top, s[0]);
end;

procedure TFormMetrolog.NSetExecutedClick(Sender: TObject);
 var
  pv: PVirtualNode;
  cur: IXMLNode;
begin
  for pv in FStepTree.SelectedNodes do
   begin
    cur := PNodeExData(FStepTree.GetNodeData(pv)).XMNode;
    cur.Attributes['EXECUTED'] := True;
    ReCalc();
    DoUpdateData;
   end;
end;

procedure TFormMetrolog.NTrrApplyClick(Sender: TObject);
begin
  HasXTree(GetMetr([], FDevData), GetMetr([], FileData), procedure(devroot, dev, failRoot, fail: IXMLNode)
  begin
    dev.NodeValue := fail.NodeValue;
  end);
  (GlobalCore as IUpdateDeviceMetrol).Update(FMetaDataInfo);
end;

procedure TFormMetrolog.NTrrResetClick(Sender: TObject);
 var
  pv: PVirtualNode;
  cur: IXMLNode;
  s: string;
  t: IXMLNode;
  function Fet(): Boolean;
  begin
    t := cur.ParentNode.ChildNodes.FindNode(s);
    Result := Assigned(t);
  end;
begin
  for pv in FStepTree.SelectedNodes do
   begin
    cur := PNodeExData(FStepTree.GetNodeData(pv)).XMNode;
    s := cur.NodeName;
    while Fet do
     begin
      t.Attributes['EXECUTED'] := False;
      s := 'STEP'+ (Integer(t.Attributes['STEP'])+1).ToString;
     end;
    ReCalc();
    DoUpdateData;
   end;
end;

procedure TFormMetrolog.NTrrSetClick(Sender: TObject);
 var
  pv: PVirtualNode;
  cur: IXMLNode;
  i: Integer;
begin
  for pv in FStepTree.SelectedNodes do
   begin
    cur := PNodeExData(FStepTree.GetNodeData(pv)).XMNode;
    for i := 1 to cur.Attributes['STEP'] do cur.ParentNode.ChildNodes.FindNode('STEP'+i.ToString).Attributes['EXECUTED'] := True;
    ReCalc();
    DoUpdateData;
   end;
end;

procedure TFormMetrolog.TreeClear;
 var
  pv: PVirtualNode;
begin
  for pv in FStepTree.Nodes do PNodeExData(FStepTree.GetNodeData(pv)).XMNode := nil;
  FStepTree.Clear;
end;

procedure TFormMetrolog.TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
 var
  xd: PNodeExData;
begin
  xd := Sender.GetNodeData(Node);
  if (Column = 0) and Assigned(xd.XMNode) and xd.XMNode.HasAttribute('EXECUTED') and Boolean(xd.XMNode.Attributes['EXECUTED']) then ImageIndex := 304
end;

procedure TFormMetrolog.TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
 var
  xd: PNodeExData;
begin
  xd := Sender.GetNodeData(Node);
  if Assigned(xd.XMNode) and xd.XMNode.HasAttribute('EXECUTED') then
    if Sender.Selected[Node] then TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold]
    else if not Boolean(xd.XMNode.Attributes['EXECUTED']) then TargetCanvas.Font.Color := clLtGray
end;

procedure TFormMetrolog.TreeSetFont(T: TVirtualStringTree);
 var
  pv: PVirtualNode;
begin
  T.DefaultNodeHeight := Abs(Font.Height) + T.TextMargin*2;
  T.Header.Height := T.DefaultNodeHeight;
  for pv in T.Nodes do T.NodeHeight[pv] := T.DefaultNodeHeight;
end;

procedure TFormMetrolog.TreeUpdate;
 var
  alg, n: IXMLNode;
begin
  FStepTree.BeginUpdate;
  try
   TreeClear;
   alg := GetMetr([MetrolType], FileData);
   if not Assigned(alg) then Exit;
   for n in XEnum(alg) do PNodeExData(FStepTree.GetNodeData(FStepTree.AddChild(nil))).XMNode := n;
  finally
   FStepTree.EndUpdate;
  end;
end;

function TFormMetrolog.UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean;
begin
  Result := False;
end;

function TFormMetrolog.UserSetupAlg(alg: IXMLNode): Boolean;
begin
  Result := False;
end;

procedure TFormMetrolog.SetDataDevice(const Value: string);
 var
  d: IDevice;
  InfoNil: TInfoEventRes;
  de: IDeviceEnum;
  udm: IUpdateDeviceMetrol;
begin
  if FDataDevice = Value then Exit;
  TBindHelper.RemoveControlExpressions(Self, ['C_UpdateDeviceMetrology, C_MetaDataInfo', 'C_BindWorkRes']);//  Bind.RemoveManagedBinding(['MetaDataInfo', 'BindWorkRes']);
  FDataDevice := Value;
  if FDataDevice <> '' then
   begin
    if Supports(GlobalCore, IUpdateDeviceMetrol, udm) then Bind( 'C_UpdateDeviceMetrology', udm, ['S_UpdateDeviceMetrology']);
    if Supports(GlobalCore, IDeviceEnum, de) then d := de.Get(FDataDevice);
    if Assigned(d) and Supports(d, IDataDevice) then
     begin
      Caption := (d as ICaption).Text +'.'+ MetrolMame;
      Bind( 'C_MetaDataInfo', d, ['S_MetaDataInfo']);
      Bind( 'C_BindWorkRes', d, ['S_WorkEventInfo']);
      if not (csLoading in ComponentState) then
       begin
        C_MetaDataInfo := (d as IDataDevice).GetMetaData();
        C_UpdateDeviceMetrology := C_UpdateDeviceMetrology;
       end;
      Exit;
     end
   end;
  FDataDevice := '';
  InfoNil.Info := nil;
  C_MetaDataInfo := InfoNil;
  Caption := '���������� �� ����������';
end;

procedure TFormMetrolog.SetMetaDataInfo(const Value: TInfoEventRes);
begin
  if C_MetaDataInfo.Info = Value.Info then Exit;
  FMetaDataInfo := Value;
  if not Assigned(GetMetr([], C_MetaDataInfo.Info)) then
   begin
    FStatusBar.Panels[0].Text := '���������� �� ������';
    FDevData := nil;
    NTrrApply.Enabled := False;
    NFileNew.Enabled := False;
    FStepTree.PopupMenu := nil;
    Exclude(FState, mstInitDev);
   end
  else
   begin
    FStatusBar.Panels[0].Text := '���������� ����������.';
    FDevData := C_MetaDataInfo.Info;
    NTrrApply.Enabled := True;
    NTrrApply.Click;
    NFileNew.Enabled := True;
    FStepTree.PopupMenu := FStepTreePopupMenu;
//    UpdateRunXmlDir;
    Include(FState, mstInitDev);
   end;
  if not (csLoading in ComponentState) then DoUpdateData(True);
end;

procedure TFormMetrolog.NCPopup(Sender: TObject);
 var
  d: IDevice;
  dd: IDataDevice;
  Item: TMenuItem;
  de: IDeviceEnum;
begin
  inherited;
  NConnect.Clear;
  if Supports(GlobalCore, IDeviceEnum, de) then for d in de do
   if Supports(d, IDataDevice, dd) and Assigned(GetMetr([], dd.GetMetaData().Info)) then
   begin
    Item := TMenuItem.Create(NConnect);
    Item.Name := (d as ImanagItem).IName;
    Item.Caption := (d as ICaption).Text;
    Item.OnClick := NConnectClick;
    if SameText(Item.Name, DataDevice) then Item.Checked := True;
    NConnect.Add(Item);
   end;
  NConnect.Visible := NConnect.Count <> 0;
end;

function TFormMetrolog.GetMetr(nm: array of string; Root: IXMLNode): IXMLNode;
 var
  n: IXMLNode;
  s: string;
begin
//  if Assigned(Root) then Root.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'TrrTst.xml');

  if not Assigned(Root) then Exit(nil);
  for n in XEnum(Root) do
   begin
    Result := n.ChildNodes.FindNode(T_MTR);
    if not Assigned(Result) then Continue;
    Result := Result.ChildNodes.FindNode(MetrolMame);
    if not Assigned(Result) then Continue;
    for s in nm do
     begin
      Result := Result.ChildNodes.FindNode(s);
      if not Assigned(Result) then Exit;
     end;
    Break;
   end;
end;

function TFormMetrolog.GetOption(const index: string): variant;
begin
   Result := GetMetr([MetrolType], FileData).Attributes[index];
end;

function TFormMetrolog.GetOptions: IXMLNode;
 var
  Ldoc: IXMLdocument;
  optFile: string;
begin
  optFile := Format('%sDevices\����������.%s.%s.xml', [ExtractFilePath(ParamStr(0)), MetrolMame, MetrolType]);
  if not FileExists(optFile) then optFile := Format('%sDevices\����������.%s.xml', [ExtractFilePath(ParamStr(0)), MetrolMame]);
  if not FileExists(optFile) then optFile := Format('%sDevices\����������.xml', [ExtractFilePath(ParamStr(0))]);
  LDoc := NewXDocument();
  LDoc.LoadFromFile(optFile);
  Result := Ldoc.DocumentElement;
end;

function TFormMetrolog.GetAttCount: Integer;
 var
  rm: IXMLNode;
begin
  try
   Result := GetMetr([MetrolType], FileData).Attributes['AttCount'];
  except
   Result := 5;
  end;
end;

function TFormMetrolog.GetIsMedian: Boolean;
 var
  rm: IXMLNode;
begin
  try
   Result := GetMetr([MetrolType], FileData).Attributes['IsMedian'];
  except
   Result := False;
  end;
end;

function TFormMetrolog.GetCurrentNode: IXMLNode;
 var
  pv: PVirtualNode;
begin
  Result := nil;
  for pv in FStepTree.SelectedNodes do Result := PNodeExData(FStepTree.GetNodeData(pv)).XMNode;
end;

function TFormMetrolog.GetFileOrDevData: IXMLNode;
begin
  if Assigned(FFileData) then Result := FFileData
  else if Assigned(FDevData) then Result := FDevData
  else Result := nil
end;

function TFormMetrolog.NewFFileData(const DevName: string): IXMLNode;
 var
  GDoc: IXMLDocument;
  d: IXMLNode;
  i: integer;
begin
  FTrrFile := '';
  GDoc := NewXDocument();
  FFileData := GDoc.AddChild('TRR');
  d := FFileData.AddChild(DevName);
  d := d.AddChild(T_MTR);
  i := d.ChildNodes.Add(FEtalonData.CloneNode(True));
  d.ChildNodes[i].ChildNodes.Add(FEtalonAlg.CloneNode(True));
  Result := FFileData;
end;

procedure TFormMetrolog.NFileNewClick(Sender: TObject);
begin
  with TSaveDialog.Create(nil) do
   try
    InitialDir := ExtractFilePath(ParamStr(0)) + T_MTR;
    DefaultExt := 'xml';
    Options := Options + [ofOverwritePrompt, ofPathMustExist];
    Filter := '���� ��������� (*.xml)|*.xml';
    if Execute(Handle) then
     begin
      NewFFileData(GetMetr([], C_MetaDataInfo.Info).ParentNode.ParentNode.NodeName);
      FFileData.OwnerDocument.SaveToFile(FileName);
      TrrFile := FileName;
     end;
   finally
    Free;
   end;
end;

procedure TFormMetrolog.NFileOpenClick(Sender: TObject);
begin
  with TOpenDialog.Create(nil) do
   try
    InitialDir := ExtractFilePath(ParamStr(0)) + T_MTR;
    Options := Options + [ofPathMustExist, ofFileMustExist];
    DefaultExt := 'xml';
    Filter := '���� ��������� (*.xml)|*.xml';

    if Assigned(FImportExport) then Filter := Filter + FImportExport.GetImportFilters;

    if Execute(Handle) then
      if FilterIndex = 1 then TrrFile := FileName
      else
       begin
        FImportExport.ExecuteImport(FilterIndex-1, FileName, GetMetr([MetrolType], NewFFileData('ANY_DEVICE')));
        ReCalc(False);
        DoUpdateData(True);
        FStatusBar.Panels[1].Text := FileName;
        NFileSaveAs.Enabled := True;
        FImportFile := FileName;
       end;
   finally
    Free;
   end;
end;

procedure TFormMetrolog.NFileSaveAsClick(Sender: TObject);
begin
  with TSaveDialog.Create(nil) do
   try
    InitialDir := ExtractFilePath(ParamStr(0)) + T_MTR;
    if TrrFile <> '' then FileName := TPath.GetFileNameWithoutExtension(TrrFile)
    else if FImportFile <> '' then FileName := TPath.GetFileNameWithoutExtension(FImportFile);
    Options := Options + [ofOverwritePrompt, ofPathMustExist];
    DefaultExt := 'xml';
    Filter := '���� ��������� (*.xml)|*.xml';
    if Assigned(FImportExport) then Filter := Filter + FImportExport.GetExportFilters;
    if Execute(Handle) then
     begin
      if FilterIndex = 1 then
       begin
        FFileData.OwnerDocument.SaveToFile(FileName);
        TrrFile := FileName;
       end
      else FImportExport.ExecuteExport(FilterIndex-1, FileName, GetMetr([], FFileData));// NewFFileData(GetMetr([], GetFileOrDevData).ParentNode.ParentNode.NodeName)));
     end;
   finally
    Free;
   end;
end;

//procedure TFormMetrolog.NIsMedianClick(Sender: TObject);
//begin
//  FIsMedian := NIsMedian.Checked;
//end;

procedure TFormMetrolog.NTreeHeaderClick(Sender: TObject);
 var
  co: TVTColumnOptions;
  n: TMenuItem;
begin
  n := TMenuItem(Sender);
  co :=  FStepTree.Header.Columns[n.Tag].Options;
  if n.Checked then Include(co, coVisible) else Exclude(co, coVisible);
  FStepTree.Header.Columns[n.Tag].Options := co;
end;

procedure TFormMetrolog.DoUpdateData(NewFileData: Boolean);
 var
  md, mf: IXMLNode;
begin
  if mstLockUpdate in FState then Exit;
  if NewFileData then
   begin
    BAttStop.Enabled := False;
    BAttCancel.Enabled := False;
    Exclude(FState, mstAttr);
    if Assigned(FDevData) and Assigned(FFileData) then
     begin
      BAttStart.Enabled := True;
      if Supports(Self, IAutomatMetrology) then BAutoStart.Enabled := True;
      md := GetMetr([], FDevData).ParentNode.ParentNode;
      mf := GetMetr([], FFileData).ParentNode.ParentNode;
      if (mf.NodeName <> 'ANY_DEVICE') and (md.NodeName <> mf.NodeName) then
       MessageDlg(Format('������� ���� ��������� ������� %s � ������ ������ %s',[mf.NodeName, md.NodeName]), TMsgDlgType.mtWarning, [mbOK], 0)
      else if mf.HasAttribute(AT_SERIAL) and md.HasAttribute(AT_SERIAL) and (mf.Attributes[AT_SERIAL] <> md.Attributes[AT_SERIAL]) then
       MessageDlg(Format('������� ���� ��������� ������� � ������� %s � ������ ������ � ������� %s', [mf.Attributes[AT_SERIAL], md.Attributes[AT_SERIAL]]), TMsgDlgType.mtWarning, [mbOK], 0);
     end
    else
     begin
      BAttStart.Enabled := False;
      if Supports(Self, IAutomatMetrology) then BAutoStart.Enabled := False;
     end;
   end;
  TreeUpdate;
end;

//procedure TFormMetrolog.UpdateRunXmlDir;
// var
//  md, mf, rd: IXMLNode;
//begin
//  if not (Assigned(FDevData) and Assigned(FFileData)) then Exit;
//  md := GetMetr([], FDevData);
//  mf := GetMetr([], FFileData);
//  mf := mf.ChildNodes.FindNode('RUN');
//  rd := md.ChildNodes.FindNode('RUN');
//  if Assigned(rd) then md.ChildNodes.Remove(rd);
//  if Assigned(mf) then md.ChildNodes.Add(mf.CloneNode(True));

 // FDevData.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'TrrTst.xml');
//end;

procedure TFormMetrolog.DoUpdateEtalonData(EtlNode: IXMLNode);
begin

end;

procedure TFormMetrolog.NStandartSetupClick(Sender: TObject);
 var
  d: IDialog;
  rm, ro: IXMLNode;
//  Ldoc: IXMLdocument;
//  optFile: string;
begin
  rm := GetMetr([MetrolType], FileData);

  Assert(Assigned(rm));

 { optFile := Format('%sDevices\����������.%s.%s.xml', [ExtractFilePath(ParamStr(0)), MetrolMame, MetrolType]);
  if not FileExists(optFile) then optFile := Format('%sDevices\����������.%s.xml', [ExtractFilePath(ParamStr(0)), MetrolMame]);
  if not FileExists(optFile) then optFile := Format('%sDevices\����������.xml', [ExtractFilePath(ParamStr(0))]);
  LDoc := NewXDocument();
  LDoc.LoadFromFile(optFile);}

  rm.Attributes['DevName'] := rm.ParentNode.ParentNode.ParentNode.NodeName +'.'+rm.ParentNode.NodeName;

  if RegisterDialog.TryGet<Dialog_SetupOptions>(d) then (d as IDialogOptions).Execute(GetOptions{LDoc.DocumentElement}, rm, DoStandartSetup,
  procedure(d: IDialog; Res: TModalResult)
  begin
    if (Res = mrOk) and (FTrrFile <> '') then FFileData.OwnerDocument.SaveToFile(FTrrFile)
  end);
  //TFormMetrSetup.Execute(Self);
end;

procedure TFormMetrolog.NConnectClick(Sender: TObject);
begin
  DataDevice := TMenuItem(Sender).Name;
end;

procedure TFormMetrolog.SetRemoveDevice(const Value: string);
begin
  if DataDevice = Value then DataDevice := '';
end;

procedure TFormMetrolog.SetBindWorkRes(const Value: TWorkEventRes);
 var
  d, cur: IXMLNode;
  am: IAutomatMetrology;
  a: IFindAnyData;
begin
  FBindWorkRes := Value;
  d := FBindWorkRes.Work.ChildNodes.FindNode(MetrolMame);
  if not Assigned(d) then Exit;
  if Supports(Self, IAutomatMetrology ,am) then am.SetDeviceData(d);
  if mstAutomat in FState then (Self as IAutomatMetrology).KadrEvent();
  if FAttCnt <= 0 then Exit;
  HasXTree(FAttSum, d, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
  begin
    if EtalonAttr.NodeName <> AT_VALUE then EtalonAttr.NodeValue := TestAttr.NodeValue
    else if EtalonRoot.ParentNode.HasAttribute(AT_METR) and (EtalonRoot.ParentNode.Attributes[AT_METR] = ME_ANGLE) then
     if IsMedian then TMetrInclinMath.AddSum<TAngleMedianSum>(EtalonRoot, Double(TestAttr.NodeValue))
     else TMetrInclinMath.AddSum<TAngleSum>(EtalonRoot, Double(TestAttr.NodeValue))
    else
     if IsMedian then TMetrInclinMath.AddSum<TMedianSum>(EtalonRoot, Double(TestAttr.NodeValue))
     else EtalonAttr.NodeValue := Double(EtalonAttr.NodeValue) + Double(TestAttr.NodeValue)
  end);
  cur := GetCurrentNode;
  Dec(FAttCnt);
  HasXTree(cur, FAttSum, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
  begin
    if EtalonAttr.NodeName <> AT_VALUE then EtalonAttr.NodeValue := TestAttr.NodeValue
    else if XSupport(TestRoot, IFindAnyData, a) then EtalonAttr.NodeValue := a.Data
         else EtalonAttr.NodeValue := Double(TestAttr.NodeValue) / (FAttN - FAttCnt);
  end);
  if FAttCnt = 0 then DoStopAtt(cur)
  else DoRunAtt(cur);
end;

destructor TFormMetrolog.Destroy;
begin
  TreeClear;
  inherited;
end;

procedure TFormMetrolog.DoCancelAtt(AttNode: IXMLNode);
begin
  FStepTree.SelectionLocked := False;
  FStepTree.Repaint;
end;

procedure TFormMetrolog.DoRunAtt(AttNode: IXMLNode);
begin
//AccessViolation    Access violation at address 0508796B in module 'Metrol.dlp'. Read of address 00000000
//[0508796B]{Metrol.dlp  } MetrForm.TFormMetrolog.DoRunAtt$qqr48System.%DelphiInterface$t20Xml.Xmlintf.IXMLNode% (Line 702, "MetrForm.pas")
 { TODO : AttNode =0 }
  FLabel.Caption := Format('���: %s-���������� �������� %d',[AttNode.Attributes['STEP'], FAttCnt]);
  BAttStop.Enabled := not (mstAutomat in Fstate);
  FStepTree.Repaint;
end;

procedure TFormMetrolog.DoSetFont(const AFont: TFont);
begin
  inherited;
  TreeSetFont(FStepTree);
end;

procedure TFormMetrolog.DoStandartSetup(Item: TJvCustomInspectorItem; Option: IXMLNode; var Data: IXMLNode);
begin
  if Option.NodeName = AT_SERIAL then Data := Data.ParentNode.ParentNode.ParentNode;
end;

procedure TFormMetrolog.DoStartAtt(AttNode: IXMLNode);
begin
  FStepTree.SelectionLocked := True;
  FStepTree.Repaint;
end;

procedure TFormMetrolog.ReCalc(NeedSave: Boolean = True);
 var
  alg, n, df: IXMLNode;
begin
  // reset file trr data
  df := GetMetr([], FileData);
  if not FlagNoUpdateFromEtalon then HasXTree(FEtalonData, df, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
  begin
    TestAttr.NodeValue := EtalonAttr.NodeValue;
  end);
  // execute trr too last none executed step
  alg := GetMetr([MetrolType], FileData);
  for n in XEnum(alg) do
   if not Boolean(n.Attributes['EXECUTED']) then Break
   else if not UserExecStep(n.Attributes['STEP'], alg, df) then FexeScript.CallFunction('execute_step', VarArrayOf([Integer(n.Attributes['STEP']), XToVar(alg), XToVar(df)]));
  // copy file trr to dev
  HasXTree(GetMetr([], FDevData), df, procedure(dev, devAttr, fRoot, fAttr: IXMLNode)
  begin
    devAttr.NodeValue := fAttr.NodeValue;
  end);
//  UpdateRunXmlDir;
  if NeedSave then
   if FTrrFile <> '' then FFileData.OwnerDocument.SaveToFile(FTrrFile)
   else NFileSaveAsClick(nil);
  (GlobalCore as IUpdateDeviceMetrol).Update(FMetaDataInfo);
end;

procedure TFormMetrolog.DoStopAtt(AttNode: IXMLNode);
 var
  pv: PVirtualNode;
  md,mf: IXMLNode;
  s: string;
  f: Boolean;
begin
  BAttStart.Enabled := not (mstAutomat in Fstate);
  BAttCancel.Enabled := False;
  BAttStop.Enabled := False;
  FAttCnt := 0;
  AttNode.Attributes['EXECUTED'] := True;
  Exclude(FState, mstAttr);

  ReCalc();

  FLabel.Caption := Format('���: %s-���������� ��������', [AttNode.Attributes['STEP']]);
  FAttOld := nil;
  FAttSum := nil;

  FStepTree.SelectionLocked := False;// mstAutomat in Fstate;
  s := 'STEP'+ (Integer(AttNode.Attributes['STEP'])+1).ToString();
  f := False;
  try
   for pv in FStepTree.Nodes do
    if PNodeExData(FStepTree.GetNodeData(pv)).XMNode.NodeName = s then
     begin
      FStepTree.Selected[pv] := True;
      FStepTree.ScrollIntoView(pv, True);
      f := True;
      if mstAutomat in Fstate then
       begin
        FStepTree.SelectionLocked := True;
        (Self as IAutomatMetrology).StartStep(PNodeExData(FStepTree.GetNodeData(pv)).XMNode);
       end;
      Break;
     end;
   if not f and (mstAutomat in Fstate) then
    begin
     (Self as IAutomatMetrology).DoEndMetrology();
     DoStopAuto();
    end;
  finally
   md := FBindWorkRes.Work.ParentNode.ChildNodes.FindNode(T_MTR);
   md := md.ChildNodes.FindNode(MetrolMame);
   mf := GetMetr([], FFileData);
   HasXTree(md, mf, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
   begin
     EtalonAttr.NodeValue := TestAttr.NodeValue;
   end);
   FStepTree.Repaint;
  end;
end;

procedure TFormMetrolog.BAttCancelClick(Sender: TObject);
 var
  cur: IXMLNode;
begin
  BAttStart.Enabled := not (mstAutomat in Fstate);
  BAttCancel.Enabled := False;
  BAttStop.Enabled := False;
  cur := GetCurrentNode;
  FLabel.Caption := Format('���: %s-������ ����������',[cur.Attributes['STEP']]);
  HasXTree(cur, FAttOld, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
  begin
    EtalonAttr.NodeValue := TestAttr.NodeValue;
  end);
  Exclude(FState, mstAttr);
  FAttCnt := 0;
  FAttOld := nil;
  FAttSum := nil;
  DoCancelAtt(cur);
end;

procedure TFormMetrolog.BAttStartClick(Sender: TObject);
 var
  cur: IXMLNode;
begin
  cur := GetCurrentNode;
  if not Assigned(cur) then MessageDlg('�� ������ ��� ���������', TMsgDlgType.mtError, [mbOK], 0)
  else
   begin
    if Boolean(cur.Attributes['EXECUTED']) and (MessageDlg(Format('��������� ��� %s ������?'#$D#$A'%s', [cur.Attributes['STEP'], cur.Attributes['INFO']]), TMsgDlgType.mtWarning, [mbYes, mbCancel], 0) = mrCancel) then Exit;
    BAttStart.Enabled := False;
    BAttStop.Enabled := False;
    BAttCancel.Enabled := not (mstAutomat in Fstate);
    FAttOld := cur.CloneNode(True);
    if cur.HasAttribute('ATT_COUNT') then FAttCnt := cur.Attributes['ATT_COUNT']
    else FAttCnt := AttCount;
    FAttN := FAttCnt;
    FLabel.Caption := Format('���: %s-������ ����������',[cur.Attributes['STEP']]);
    Include(FState, mstAttr);
    HasXTree(cur, cur, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
    begin
      if EtalonAttr.NodeName = AT_VALUE then TestAttr.NodeValue := 0;
    end);
    FAttSum := cur.CloneNode(True);
    DoStartAtt(cur);
   end;
end;

procedure TFormMetrolog.BAttStopClick(Sender: TObject);
begin
  DoStopAtt(GetCurrentNode);
end;

procedure TFormMetrolog.BAutoStartClick(Sender: TObject);
 var
  cur: IXMLNode;
begin
  if mstAttr in FState then Exit;
  cur := GetCurrentNode;
  if not Assigned(cur) then MessageDlg('�� ������ ��� ���������', TMsgDlgType.mtError, [mbOK], 0)
  else
   begin
    (Self as IAutomatMetrology).StartStep(cur);
    FStepTree.SelectionLocked := True;
    BAutoStart.Enabled := False;
    BAutoStop.Enabled := True;
    BAttStart.Enabled := False;
    Include(FState, mstAutomat);
   end;
end;

procedure TFormMetrolog.BAutoStopClick(Sender: TObject);
begin
  DoStopAuto();
  (Self as IAutomatMetrology).Stop();
  if mstAttr in FState then BAttCancelClick(nil);
end;

procedure TFormMetrolog.DoStopAuto;
begin
  FStepTree.SelectionLocked := False;
  BAutoStart.Enabled := True;
  BAutoStop.Enabled := False;
  BAttStart.Enabled := True;
  Exclude(FState, mstAutomat);
end;

procedure TFormMetrolog.AddDefaultOptions(RootTrr, RootOption: IXMLNode);
 var
  c,o: IXMLNode;
begin
  for c in XEnum(RootOption) do
    for o in XEnum(c) do
      if (o.NodeName <> AT_SERIAL) and o.HasAttribute('��������') then RootTrr.Attributes[o.NodeName] := o.Attributes['��������']
end;

procedure TFormMetrolog.AutoReport(Status: TStatusAutomatMetrology; const info: string);
begin
  FLabelAuto.Caption := info;
end;

initialization
  TRegister.AddType<TUpdateDeviceMetrol, IUpdateDeviceMetrol>.LiveTime(ltSingleton);
end.
