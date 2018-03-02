unit VCL.Form.EEPROM;

interface

uses Container, tools, XMLLua.EEPROM,  Xml.XMLDoc,
  RootIntf, DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, SDcardTools, FileCachImpl,
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
    function AsText(Col: Integer): string;
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
  private
    FRes: TDialogResult;
    FModul, Feep, Fmetr: IXMLNode;
    FAddr: Integer;
    function GetDevice: IEepromDevice;
    procedure ClearTree;
    procedure InitTree;
    function GetMetrNode(eepNode: IXMLNode): IXMLNode;
    procedure NCopyMetrClick(Sender: TObject);
    procedure NCmpMetrClick(Sender: TObject);
  protected
    function GetInfo: PTypeInfo; override;
    function Execute(Eep: IXMLNode; Res: TDialogResult): Boolean;
    procedure Loaded; override;
    property Dev: IEepromDevice read GetDevice;
  public
    { Public declarations }
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

function TNodeExData.AsText(Col: Integer): string;
 var
  n: IXMLNode;
begin
  Result := '';
  if Col >= Length(ColumnValue) then Exit;
  if Supports(ColumnValue[Col], IXMLNode, n) then
   begin
    if n.NodeType = ntAttribute then
       Result := n.NodeValue
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
    if n.NodeType = ntAttribute then Result := true;
   end
end;

procedure TNodeExData.FromText(Col: Integer; const NewData: string);
 var
  n: IXMLNode;
begin
  if Col >= Length(ColumnValue) then Exit;
  if Supports(ColumnValue[Col], IXMLNode, n) then
   begin
    if n.NodeType = ntAttribute then n.NodeValue := NewData;
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
  st.Panels[0].Text := 'Read BAD';
  Dev.ReadEeprom(procedure (Res: TEepromEventRes)
  begin
    if Res.DevAdr <> FAddr then Exit;
    st.Panels[0].Text := 'Read GOOD';
    Tree.Repaint;
  end);
end;

procedure TFormDlgEeprom.btWriteClick(Sender: TObject);
begin
  Dev.WriteEeprom(FAddr, procedure (Res: Boolean)
  begin
    if Res then st.Panels[0].Text := 'write GOOD'
    else st.Panels[0].Text := 'write BAD'
  end);
end;

procedure TFormDlgEeprom.ClearTree;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do SetLength(PNodeExData(Tree.GetNodeData(pv)).ColumnValue, 0);
  Tree.Clear;
end;

procedure TFormDlgEeprom.InitTree;
   procedure Add(Parent :PVirtualNode; u: IXMLNode);
    var
     chn: PVirtualNode;
     xd: PNodeExData;
     i: Integer;
     nd: IXMLNode;
   begin
     if u.HasAttribute('HIDDEN') and (u.Attributes['HIDDEN'] = True) then Exit;
     chn := Tree.AddChild(Parent);
     Include(chn.States, vsExpanded);
     xd := Tree.GetNodeData(chn);
     xd.ColumnValue := xd.ColumnValue + [u];
     if u.HasAttribute(AT_SIZE) then
       for I := 0 to u.ChildNodes.Count-1 do Add(chn, u.ChildNodes[i])
     else
       begin
        nd := u.ChildNodes.FindNode(T_DEV);
        if Assigned(nd) then
         begin
          if not nd.HasAttribute(AT_VALUE) then nd.Attributes[AT_VALUE] := ' ';
          xd.ColumnValue := xd.ColumnValue + [nd.AttributeNodes.FindNode(AT_VALUE), GetMetrNode(u)];
         end
        else xd.ColumnValue := xd.ColumnValue + [nil, nil];
       end;
   end;
var
  i: Integer;
begin
  ClearTree;
  for i:= 0 to Feep.ChildNodes.Count-1 do Add(nil, Feep.ChildNodes[i]);
end;

procedure TFormDlgEeprom.Loaded;
begin
  inherited;
  AddToNCMenu('-', nil, 0);
  AddToNCMenu('Копировать Метрологию в буфер EEPROM', NCopyMetrClick, 0);
  AddToNCMenu('Сравнить Метрологию и буфер EEPROM', NCopyMetrClick, 0);
end;

function CheckPath(tst, etalon: IXMLNode; const rootNodeName: string; CheckRootNode: Boolean = False): boolean;
begin
  while Assigned(tst) and Assigned(etalon) do
   begin
    if tst.NodeName <> etalon.NodeName then Exit(False);
    if CheckRootNode and (etalon.NodeName = rootNodeName) then Exit(True);
    tst := tst.ParentNode;
    etalon := etalon.ParentNode;
    if not CheckRootNode and Assigned(etalon) and (etalon.NodeName = rootNodeName) then Exit(True);
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
    if n.HasAttribute(eepNode.NodeName) and CheckPath(eepNode.ParentNode, n, T_MTR) then
     begin
      res := n.AttributeNodes.FindNode(eepNode.NodeName);
      Result := True;
     end
    else Result := False;
  end);
end;

procedure TFormDlgEeprom.NCmpMetrClick(Sender: TObject);
 var
  e, m: IXMLNode;
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do with PNodeExData(Tree.GetNodeData(pv))^ do
    if (Length(ColumnValue) > 3) and Supports(ColumnValue[1], IXMLNode, e) and (e.NodeType = ntAttribute)
    and Supports(ColumnValue[2], IXMLNode, m) and (m.NodeType = ntAttribute) then e.NodeValue := m.NodeValue;
  Tree.Repaint;
end;

procedure TFormDlgEeprom.NCopyMetrClick(Sender: TObject);
 var
  e, m: IXMLNode;
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do with PNodeExData(Tree.GetNodeData(pv))^ do
    if (Length(ColumnValue) > 3) and Supports(ColumnValue[1], IXMLNode, e) and (e.NodeType = ntAttribute)
    and Supports(ColumnValue[2], IXMLNode, m) and (m.NodeType = ntAttribute) then e.NodeValue := m.NodeValue;
  Tree.Repaint;
end;

procedure TFormDlgEeprom.TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TEditor.Create;
end;

procedure TFormDlgEeprom.TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := PNodeExData(Tree.GetNodeData(Node)).Editable(Column);
end;

procedure TFormDlgEeprom.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := '';
  if Column < 0 then Exit;
  CellText := PNodeExData(Sender.GetNodeData(Node)).AsText(Column);
end;

initialization
  RegisterDialog.Add<TFormDlgEeprom, Dialog_Eep>;
finalization
  RegisterDialog.Remove<TFormDlgEeprom>;
end.
