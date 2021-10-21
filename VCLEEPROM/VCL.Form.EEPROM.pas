unit VCL.Form.EEPROM;

interface

uses Container, tools, XMLLua.EEPROM,  Xml.XMLDoc,  Math,
  RootIntf, DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, FileCachImpl,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Xml.XMLIntf, System.TypInfo,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, VirtualTrees;

type
  PNodeExData = ^TNodeExData;
  TNodeExData = record
   // ParamType:
   // ParamName: string;
   ///   eeprom                 eeprom                   Метрология
   /// [xmlnode(path.Node); attr(path.Node.DEV.VALUE); attr(path.Node) ]
    ColumnValue: TArray<IInterface>;
    ColumnNode: TArray<IInterface>;
    FEdited: Boolean;
    function AsText(Col: Integer): string;
    function AsColor(Col: Integer): TColor;
    function Editable(Col: Integer): boolean;
    procedure FromText(Col: Integer; const NewData: string);
  end;

  EFrmDlgEeprom = class(EBaseException);
  TFormDlgEeprom = class(TDialogIForm, IDialog, IDialog<IXMLNode, TDialogResult>)
    btRead: TButton;
    btWrite: TButton;
    btExit: TButton;
    st: TStatusBar;
    Tree: TVirtualStringTree;
    procedure btExitClick(Sender: TObject);
    procedure btReadClick(Sender: TObject);
    procedure btWriteClick(Sender: TObject);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
  private
    FRes: TDialogResult;
    FModul, Feep, Fmetr: IXMLNode;
    FAddr: Integer;
    FC_MetrologyChange: string;
    function GetDevice: IEepromDevice;
    procedure ClearTree;
    procedure InitTree;
    function GetMetrNode(eepNode: IXMLNode): IXMLNode;
    procedure NCopyMetrClick(Sender: TObject);
//    procedure NCmpMetrClick(Sender: TObject);
    procedure SetC_MetrologyChange(const Value: string);
  protected
    function GetInfo: PTypeInfo; override;
    function Execute(Eep: IXMLNode; Res: TDialogResult): Boolean;
    procedure Loaded; override;
    property Dev: IEepromDevice read GetDevice;
  public
    { Public declarations }
    property C_MetrologyChange: string read FC_MetrologyChange write SetC_MetrologyChange;
  end;


implementation

{$R *.dfm}

{$REGION 'TEditor'}

type
  TEditor = class(TIObject, IVTEditLink)
  private
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
  FData.FromText(FColumn, TEdit(FEdit).Text);
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
    Text := FData.AsText(FColumn);
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


{ TNodeExData }
var
  FReadedFlag: Boolean;

function TNodeExData.AsColor(Col: Integer): TColor;
 var
  e, m: IXMLNode;
begin
  Result := clBlack;
  if (Length(ColumnValue) < 4) and (col <> 1) then Exit;
  if not FReadedFlag then Result := clGray;
  if FEdited then Result := clWebBrown;

  if Supports(ColumnValue[1], IXMLNode, e) and Supports(ColumnValue[3], IXMLNode, m) then
   begin
    if (Trim(e.NodeValue) <>'') and (Trim(m.NodeValue) <>'') then
     try
     if not SameValue(Single(e.NodeValue),Single(m.NodeValue)) then Result := clRed
     except
     if not SameText(e.NodeValue, m.NodeValue) then Result := clRed
     end;
   end;
end;

function TNodeExData.AsText(Col: Integer): string;
 var
  n,r: IXMLNode;
begin
  Result := '';
  if Col >= Length(ColumnValue) then Exit;
  if Col >= Length(ColumnNode) then Exit;
  if Supports(ColumnValue[Col], IXMLNode, n) then
   begin
    if (n.NodeType = ntAttribute) and not VarIsNull(n.NodeValue) then
     begin
      Result := n.NodeValue;
      Result := Result.Trim;
      if (Result <> '') and (n.NodeName = AT_VALUE) and
         Supports(ColumnNode[Col], IXMLNode, r) and
         r.HasAttribute(AT_DIGITS) and
         r.HasAttribute(AT_AQURICY) then
       begin
         Result := FloatToStrF(StrToFloatDef(Result,0), ffFixed, r.Attributes[AT_DIGITS], r.Attributes[AT_AQURICY])
       end;
     end
    else
       Result := n.NodeName;
   end
end;

function TNodeExData.Editable(Col: Integer): boolean;
 var
  n: IXMLNode;
begin
  Result := False;
  if Col >= Length(ColumnValue) then Exit;
  if Supports(ColumnValue[Col], IXMLNode, n) then
   begin
    if (n.NodeType = ntAttribute) and FReadedFlag then Result := true;
   end
end;

procedure TNodeExData.FromText(Col: Integer; const NewData: string);
 var
  n: IXMLNode;
begin
  if Col >= Length(ColumnValue) then Exit;
  if Supports(ColumnValue[Col], IXMLNode, n) then
   begin
    if n.NodeType = ntAttribute then
     begin
      n.NodeValue := NewData;
      FEdited := True;
     end;
   end
end;

{ TFormDlgEeprom }

function TFormDlgEeprom.Execute(Eep: IXMLNode; Res: TDialogResult): Boolean;
begin
  Result := True;
  FRes := Res;
  Feep := Eep;
  FModul := Eep.ParentNode;
  Fmetr := FModul.ChildNodes.FindNode(T_MTR);
  FAddr := FModul.Attributes[AT_ADDR];
  Caption := '[' + FModul.nodeName +'.'+Feep.nodeName +'] Редактор EEPROM';
  IShow;
  InitTree;
end;

function TFormDlgEeprom.GetDevice: IEepromDevice;
 var
  d: IDevice;
begin
  Result := nil;
  d := (GlobalCore as IDeviceEnum).Get(FModul.ParentNode.NodeName);
  if not Assigned(d) then raise EFrmDlgEeprom.CreateFmt('Устройство %s не найдено', [Fmodul.NodeName]);
  if not Supports(d, IEepromDevice, Result) then raise EFrmDlgEeprom.CreateFmt('Устройство %s без EEPROM', [Fmodul.NodeName]);
end;

function TFormDlgEeprom.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_Eep);
end;

procedure TFormDlgEeprom.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize(GetInfo);
end;

procedure TFormDlgEeprom.btReadClick(Sender: TObject);
begin
  FReadedFlag := False;
  st.Panels[0].Text := 'Read BAD';
  Dev.ReadEeprom(procedure (Res: TEepromEventRes)
  begin
    if Res.DevAdr <> FAddr then Exit;
    st.Panels[0].Text := 'Read GOOD';
    FReadedFlag := True;
    for var pv in Tree.Nodes do PNodeExData(Tree.GetNodeData(pv)).FEdited := False;
    Tree.Repaint;
  end);
end;

procedure TFormDlgEeprom.btWriteClick(Sender: TObject);
begin
  if FReadedFlag then
  Dev.WriteEeprom(FAddr, procedure (Res: Boolean)
  begin
    if Res then
     begin
      st.Panels[0].Text := 'write GOOD';
      for var pv in Tree.Nodes do PNodeExData(Tree.GetNodeData(pv)).FEdited := False;
      Tree.Repaint;
     end
    else st.Panels[0].Text := 'write BAD'
  end)
  else MessageDlg('Память EEPROM не считана предыдущие данные будут удалены!!!', mtError, [mbYes, mbCancel], 0)
end;

procedure TFormDlgEeprom.ClearTree;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do
   begin
    SetLength(PNodeExData(Tree.GetNodeData(pv)).ColumnValue, 0);
    SetLength(PNodeExData(Tree.GetNodeData(pv)).ColumnNode, 0);
   end;
  Tree.Clear;
end;

procedure TFormDlgEeprom.InitTree;
   procedure Add(Parent :PVirtualNode; u: IXMLNode);
    var
     chn: PVirtualNode;
     xd: PNodeExData;
     i: Integer;
     nd, nc, an, ac, mtr, eu: IXMLNode;
   begin
     if u.HasAttribute('HIDDEN') and (u.Attributes['HIDDEN'] = True) then Exit;
     chn := Tree.AddChild(Parent);
     Include(chn.States, vsExpanded);
     xd := Tree.GetNodeData(chn);
     xd.ColumnValue := xd.ColumnValue + [u];
     xd.ColumnNode := xd.ColumnNode + [u];
     if u.HasAttribute(AT_SIZE) then
       for I := 0 to u.ChildNodes.Count-1 do Add(chn, u.ChildNodes[i])
     else
       begin
        nd := u.ChildNodes.FindNode(T_DEV);
        nc := u.ChildNodes.FindNode(T_CLC);
        mtr := GetMetrNode(u);
        if Assigned(nd) then
         begin
          if not nd.HasAttribute(AT_VALUE) then nd.Attributes[AT_VALUE] := ' ';
          an := nd.AttributeNodes.FindNode(AT_VALUE);
          eu := nd.AttributeNodes.FindNode(AT_EU);
         end;
        if Assigned(nc) then
         begin
          if not nc.HasAttribute(AT_VALUE) then nc.Attributes[AT_VALUE] := ' ';
          ac := nc.AttributeNodes.FindNode(AT_VALUE);
          eu := nc.AttributeNodes.FindNode(AT_EU);
         end;
        xd.ColumnValue := xd.ColumnValue + [an, ac, mtr, eu];
        xd.ColumnNode  :=  xd.ColumnNode + [nd, nc, nil, nil];
       end;
   end;
var
  i: Integer;
begin
  ClearTree;
  FReadedFlag := False;
  for i:= 0 to Feep.ChildNodes.Count-1 do Add(nil, Feep.ChildNodes[i]);
end;

procedure TFormDlgEeprom.Loaded;
begin
  inherited;
  Bind('C_MetrologyChange', GlobalCore as IManager, ['S_MetrologyChange']);
  AddToNCMenu('-', nil, 0);
  AddToNCMenu('Копировать Метрологию в буфер EEPROM', NCopyMetrClick, 0);
//  AddToNCMenu('Сравнить Метрологию и буфер EEPROM', NCopyMetrClick, 0);
end;

function CheckPath(tst, etalon: IXMLNode; const rootTst, rootEtalon: string): boolean;
begin
  while Assigned(tst) and Assigned(etalon) do
   begin
    if tst.NodeName <> etalon.NodeName then Exit(False);
    tst := tst.ParentNode;
    etalon := etalon.ParentNode;
    if Assigned(tst) and Assigned(etalon) and (etalon.NodeName = rootEtalon) and (tst.NodeName = rootTst) then Exit(True);
   end;
  Result := False;
end;

function TFormDlgEeprom.GetMetrNode(eepNode: IXMLNode): IXMLNode;
 var
  Res: IXMLNode;
begin
  Res := nil;
  ExecXTree(Fmetr, function (n: IXMLNode): boolean
  begin
    if n.HasAttribute(eepNode.NodeName) and CheckPath(eepNode.ParentNode, n, T_EEPROM, T_MTR) then
     begin
      res := n.AttributeNodes.FindNode(eepNode.NodeName);
      Result := True;
     end
    else Result := False;
  end);
  Result := res;
end;

//procedure TFormDlgEeprom.NCmpMetrClick(Sender: TObject);
// var
//  e, m: IXMLNode;
//  pv: PVirtualNode;
//begin
//  for pv in Tree.Nodes do with PNodeExData(Tree.GetNodeData(pv))^ do
//    if (Length(ColumnValue) > 2) and Supports(ColumnValue[1], IXMLNode, e) and (e.NodeType = ntAttribute)
//    and Supports(ColumnValue[2], IXMLNode, m) and (m.NodeType = ntAttribute) then 
//     begin
//       if SameValue(Single(e.NodeValue), Single(m.NodeValue)) then
//       
//       e.NodeValue := m.NodeValue;
//       
//     end;
//  Tree.Repaint;
//end;

procedure TFormDlgEeprom.NCopyMetrClick(Sender: TObject);
 var
  e, m: IXMLNode;
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do with PNodeExData(Tree.GetNodeData(pv))^ do
    if (Length(ColumnValue) > 2) and Supports(ColumnValue[1], IXMLNode, e) and (e.NodeType = ntAttribute)
    and Supports(ColumnValue[2], IXMLNode, m) and (m.NodeType = ntAttribute) then e.NodeValue := m.NodeValue;
  Tree.Repaint;
end;

procedure TFormDlgEeprom.SetC_MetrologyChange(const Value: string);
begin
  FC_MetrologyChange := Value;
  if Assigned(Fmetr.ChildNodes.FindNode(FC_MetrologyChange)) then
   begin
    InitTree;
   end;
end;

procedure TFormDlgEeprom.TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TEditor.Create;
end;

procedure TFormDlgEeprom.TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := PNodeExData(Tree.GetNodeData(Node)).Editable(Column);
end;

procedure TFormDlgEeprom.TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TNodeExData);
end;

procedure TFormDlgEeprom.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := '';
  if Column < 0 then Exit;
  CellText := PNodeExData(Sender.GetNodeData(Node)).AsText(Column);
end;

procedure TFormDlgEeprom.TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if Column < 0 then Exit;
  TargetCanvas.Font.Color := PNodeExData(Sender.GetNodeData(Node)).AsColor(Column)
end;

initialization
  RegisterDialog.Add<TFormDlgEeprom, Dialog_Eep>;
finalization
  RegisterDialog.Remove<TFormDlgEeprom>;
end.
