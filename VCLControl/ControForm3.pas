unit ControForm3;

interface

uses RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RootIntf, Container, Actns,
  Winapi.Windows, Winapi.Messages, Xml.XMLIntf, System.UITypes,
  System.SysUtils, Vcl.Graphics, VirtualTrees, System.Bindings.Expression, Vcl.Forms, Vcl.Dialogs, JvDockControlForm,
  Vcl.ImgList, Vcl.Controls, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, System.Classes, Vcl.StdCtrls;

type
  PNodeExData = ^TNodeExData;
  TNodeExData = record
    Item: IInterface;
    ImagIndex: Integer;
    Color: TColor;
    Data: array[0..2]of string;
    ReadOnly: array[0..2]of Boolean;
  end;

  EFormControlException = class(EBaseException);


  TFormControl = class(TDockIForm)
    Tree: TVirtualStringTree;
    ppM: TPopupActionBar;
    NUpdate: TMenuItem;
    NSepConn: TMenuItem;
    NRemove: TMenuItem;
    NSetup: TMenuItem;
    NAddDev: TMenuItem;
    NSetupDev: TMenuItem;
    NSepDEv: TMenuItem;
    NConnect: TMenuItem;
    NControl: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    NReadRam: TMenuItem;
    NInfo: TMenuItem;
    NGlu: TMenuItem;
    Neep: TMenuItem;
    NMetrol: TMenuItem;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure NUpdateClick(Sender: TObject);
    procedure ppMPopup(Sender: TObject);
    procedure NRemoveClick(Sender: TObject);
    procedure NSetupClick(Sender: TObject);
    procedure NAddDevClick(Sender: TObject);
    procedure TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure NSetupDevClick(Sender: TObject);
    procedure TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure NReadRamClick(Sender: TObject);
  private
    FEditData: PNodeExData;
    FEditNode: PVirtualNode;

    FDummi: string;
    FProject: string;

    FNotUpdate: Boolean;

    FAddCon: string;
    FAddDev: string;
    FC_TableUpdate: string;

    procedure TreeClear;
    procedure TreeUpdate;

    class procedure InitMenuConnectIO(RootControl: TMenuItem; ClickEvent, AddNewClick: TNotifyEvent); static;
    procedure SetReadOnly(pd: PNodeExData; r0: Boolean = True; r1: Boolean = True; r2: Boolean = True);
    procedure SetData(pd: PNodeExData; const d0: string = ''; const d1: string = ''; const d2: string = '');

    procedure ShowModulMenus(Flag: Boolean; node: IXMLnode = nil);
    procedure ShowDevMenus(Flag: Boolean; dev: IDevice = nil);
    procedure ShowConMenus(Flag: Boolean);
    procedure ConnectClick(Sender: TObject);
    procedure AddNewClick(Sender: TObject);
    procedure IOChange(const Value: string);
    procedure SetDeviceChange(const Value: string);
    procedure SetProjectChange(const Value: string);
    procedure AddMetaData(d: IDataDevice; Rt: PVirtualNode);
    procedure AddDevice(d: IDevice; Rt: PVirtualNode);
    function AddControl(c: IConnectIO; PVDev: PVirtualNode): PVirtualNode;
    function GetControl(c: IConnectIO): PVirtualNode;
    procedure DeleteUnUsed;
    procedure SetAddCon(const Value: string);
    procedure SetAddDev(const Value: string);
    class procedure ViewRamData(Sender: TFormControl; Root: PVirtualNode; node: IXMLNode); static;
    class procedure ViewWrkData(Sender: TFormControl; Root: PVirtualNode; node: IXMLNode); static;
    procedure SetC_TableUpdate(const Value: string);
  protected
   const
    NICON = 269;
    function Priority: Integer; override;
    class function ClassIcon: Integer; override;
    procedure Loaded; override;
  public
    //Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
    [StaticAction('Окно управления устройствами', 'Показать', NICON, '0:Показать:2')]
    class procedure DoCreateForm(Sender: IAction); override;
    destructor Destroy; override;
    property C_ConnectIO: string read FDummi write IOChange;
    property C_Device: string read FDummi write SetDeviceChange;
    property C_Project: string read FProject write SetProjectChange;
    property C_AddDev: string read FAddDev write SetAddDev;
    property C_AddCon: string read FAddCon write SetAddCon;
    property C_TableUpdate: string read FC_TableUpdate write SetC_TableUpdate;
  end;

  TRunMetrFunc = procedure (Sender: TFormControl; Root: PVirtualNode; node: IXMLNode);

implementation

{$R *.dfm}

uses AbstractPlugin, tools, FormDlgDev;

const
  AVAIL_ATTR: array[0..4] of string = (AT_ADDR, AT_INFO, AT_SERIAL, AT_CHIP, AT_SPEED);
  AVAIL_ATTR_Caption: array[0..4] of string = ('Адрес', 'Инфо', 'Серийный номер', 'Чип', 'Маска скорости порта');
  AVAIL_T: array[0..4] of string = (T_WRK, T_RAM, T_EEPROM, T_GLU, T_MTR);
  AVAIL_T_Caption: array[0..4] of string = ('Режим информации', 'Чтение памяти', 'EEPROM', 'Данные по глубине', 'Метрология');
  AVAIL_T_Func: array[0..4] of TRunMetrFunc = (TFormControl.ViewWrkData, TFormControl.ViewRamData, nil, nil, nil);
  IMG_ATTR = 306;
  CLR_ATTR = TColors.Brown;

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
    class function GetTextNode(xd: PNodeExData; Column: Integer): string;
    class procedure SetTextNode(xd: PNodeExData; Column: Integer; const text: string);
  end;


class procedure TEditor.SetTextNode(xd: PNodeExData; Column: Integer; const text: string);
 var
  d: IDevice;
  c: IConnectIO;
  n: IXMLNode;
  cy: ICycle;
begin
  if Column < 0 then Exit;
  if not Assigned(xd.Item) then xd.Data[Column] := text
  else if Supports(xd.Item, IXMLNode, n) then
    case Column of
     1: if n.NodeType = ntAttribute then n.NodeValue := text
    end
  else if Supports(xd.Item, IDevice, d) then
    case Column of
     0: (d as ICaption).Text := text;
     2: if Supports(d, ICycle, cy) then cy.Period := Text.ToInteger()
    end
  else if Supports(xd.Item, IConnectIO, c) then
    case Column of
     2: c.Wait := Text.ToInteger();
    end
end;

class function TEditor.GetTextNode(xd: PNodeExData; Column: Integer): string;
 const
  DSTA_TO_STR: array [Low(TDeviceStatus)..High(TDeviceStatus)] of string =
                     ('не инициализирован','готов частично', 'готов', 'режим информации', 'постановка на задержку', 'чтение памяти');
 var
  d: IDevice;
  c: IConnectIO;
  n: IXMLNode;
  cy: ICycle;
begin
  Result := '';
  if Column < 0 then Exit;
  if not Assigned(xd.Item) then Result := xd.Data[Column]
  else if Supports(xd.Item, IXMLNode, n) then
    case Column of
     0: if xd.Data[0] <> '' then Result := xd.Data[0]
        else Result := n.NodeName;
     1: if n.NodeType = ntAttribute then Result := n.NodeValue
        else Result := xd.Data[1];
     2: Result := xd.Data[2];
    end
  else if Supports(xd.Item, IDevice, d) then
    case Column of
     0: Result := (d as ICaption).Text;
     1: Result := DSTA_TO_STR[d.Status];
     2: if Supports(d, ICycle, cy) then Result := cy.Period.ToString
        else Result := '';
    end
  else if Supports(xd.Item, IConnectIO, c) then
    case Column of
     0: Result := c.ConnectInfo;
     1: if iosLock in c.Status then Result := 'занят'
        else if iosError in c.Status then Result := 'ошибка'
        else Result := '';
     2: Result := c.Wait.ToString;
    end
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
  SetTextNode(FData, FColumn, TEdit(FEdit).Text);
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
    Text := TEditor.GetTextNode(FData, FColumn);
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


{$REGION 'TFormControl'}
function TFormControl.GetControl(c: IConnectIO): PVirtualNode;
 var
  pv: PVirtualNode;
  c1: IConnectIO;
begin
  for pv in Tree.LevelNodes(0) do if Supports(PNodeExData(Tree.GetNodeData(pv)).Item, IConnectIO, c1) and (c = c1) then Exit(pv);
  Result := nil;
end;

class function TFormControl.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormControl.DoCreateForm(Sender: IAction);
begin
  GetUniqueForm('GlobalControlForm');
end;

procedure TFormControl.DeleteUnUsed;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.LevelNodes(0) do if pv.ChildCount = 0 then Tree.DeleteNode(pv);
end;

destructor TFormControl.Destroy;
begin
  TreeClear;
  inherited;
end;

procedure TFormControl.Loaded;
 var
  ip: IImagProvider;
begin
  inherited;
  Tree.NodeDataSize := SizeOf(TNodeExData);
  if Supports(GlobalCore, IImagProvider, ip) then
   begin
    Tree.Images := ip.GetImagList;
    ppM.Images := ip.GetImagList;
   end;
  TreeUpdate();
  Bind('C_TableUpdate', GlobalCore as IManager, ['S_TableUpdate']);
  Bind('C_Project', GlobalCore as IManager, ['S_ProjectChange']);
  Bind('C_AddDev', GlobalCore as IDeviceEnum, ['S_AfterAdd']);
  Bind('C_AddCon', GlobalCore as IConnectIOEnum, ['S_AfterAdd']);
end;

procedure TFormControl.NReadRamClick(Sender: TObject);
 var
  d: Idialog;
  dr: IDialog<IXMLNode, TDialogResult>;
begin
  if RegisterDialog.TryGet<Dialog_RamRead>(d) then IDialog<IXMLNode, TDialogResult>(d).Execute(FEditData.Item as IXMLNode,
  procedure(Sender: IDialog; Res: TModalResult)
  begin

  end);
end;

procedure TFormControl.NAddDevClick(Sender: TObject);
 var
  d: IDevice;
  pvc: PVirtualNode;
begin
  FNotUpdate := True;
  try
   if TFormCreateDev.Execute(d) = mrOk then
    begin
     if Assigned(d.IConnect) then
      begin
       pvc := GetControl(d.IConnect);
       if not Assigned(pvc) then pvc := AddControl(d.IConnect, nil);
       AddDevice(d, pvc);
       end
     else AddDevice(d, nil);
    end;
  finally
   FNotUpdate := False;
  end;
end;

procedure TFormControl.NRemoveClick(Sender: TObject);
 var
  de: IDeviceEnum;
begin
  if not ((FEditData.Item as IDevice).Status in [dsNoInit, dsPartReady, dsReady]) then
    if not (FEditData.Item as IDevice).CanClose then
    raise EFormControlException.Create('Необходимо завершить операцию обмена данными');
  if Supports(GlobalCore, IDeviceEnum, de) then
   begin
    de.Remove(FEditData.Item as IDevice);
    (GlobalCore as IActionProvider).HideUnusedMenus;
    (GlobalCore as IActionProvider).UpdateWidthBars;
    (GlobalCore as IActionProvider).SaveActionManager;
    ((GlobalCore as IActionEnum) as IStorable).Save;
   end;
  FEditData.Item := nil;
  Tree.DeleteNode(FEditNode);
  DeleteUnUsed;
  Tree.Repaint;
end;

procedure TFormControl.NSetupClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetupConnectIO>(d) then (d as IDialog<IConnectIO>).Execute(FEditData.Item as IConnectIO);
end;

procedure TFormControl.NSetupDevClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetupDevice>(d) then (d as IDialog<IDevice>).Execute(FEditData.Item as IDevice);
  Tree.InvalidateNode(FEditNode);
end;

procedure TFormControl.NUpdateClick(Sender: TObject);
begin
  TreeUpdate;
end;

class procedure TFormControl.InitMenuConnectIO(RootControl: TMenuItem; ClickEvent, AddNewClick: TNotifyEvent);
 var
  gc: IGetConnectIO;
begin
  RootControl.Clear;
  if Supports(GlobalCore, IGetConnectIO, gc) then gc.Enum(procedure(ConnectID: Integer; const ConnectName, ConnectInfo: string)
    function AddMenu(root: TMenuItem; const Capt: string; ev: TNotifyEvent): TMenuItem;
    begin
      Result := TMenuItem.Create(Root);
      Result.Caption := Capt;
      Result.Tag := ConnectID;
      Result.OnClick := ev;
      root.Add(Result);
    end;
    procedure AddAvail(root: TMenuItem);
     var
      s: string;
    begin
      for s in gc.GetConnectInfo(ConnectID) do AddMenu(root, s, ClickEvent);
    end;
    procedure AddCreateNew(root: TMenuItem);
    begin
      AddMenu(root, 'Новое соединение...', AddNewClick);
      AddMenu(root, '-', nil);
    end;
   var
    Item: TMenuItem;
  begin
    Item := AddMenu(RootControl, ConnectInfo, nil);
    if gc.IsManualCreate(ConnectID) then AddCreateNew(Item);
    AddAvail(Item);
  end);
end;

procedure TFormControl.AddNewClick(Sender: TObject);
 var
  c: IConnectIO;
  gc: IGetConnectIO;
  ce: IConnectIOEnum;
  d: Idialog;
  dv: IDevice;
begin
  if Supports(GlobalCore, IGetConnectIO, gc) then
   begin
    c := gc.ConnectIO(TMenuItem(Sender).Tag);
    if RegisterDialog.TryGet<Dialog_SetupConnectIO>(d) and (d as IDialog<IConnectIO>).Execute(c) then
      begin
       dv := FEditData.Item as IDevice;
       FNotUpdate := True;
       if Supports(GlobalCore, IConnectIOEnum, ce) then ce.Add(c);
       dv.IConnect := c;
       AddControl(c, FEditNode);
       Tree.Repaint;
       FNotUpdate := False;
      end;
   end;
end;

procedure TFormControl.ConnectClick(Sender: TObject);
 var
  c: IConnectIO;
  gc: IGetConnectIO;
  ce: IConnectIOEnum;
  dv: IDevice;
begin
  GlobalCore.QueryInterface(IConnectIOEnum, ce);
  dv := FEditData.Item as IDevice;
  if Supports(GlobalCore, IConnectIOEnum, ce) then for c in ce do if SameText(c.ConnectInfo, TMenuItem(Sender).Caption) then
   begin
    dv.IConnect := c;
    Tree.MoveTo(FEditNode, GetControl(c), amAddChildLast, False);
    DeleteUnUsed;
    Tree.Repaint;
    Exit;
   end;
  if Supports(GlobalCore, IGetConnectIO, gc) then
   begin
    c := gc.ConnectIO(TMenuItem(Sender).Tag);
    c.ConnectInfo := TMenuItem(Sender).Caption;
    FNotUpdate := True;
    if Assigned(ce) then ce.Add(c);
    dv.IConnect := c;
    AddControl(c, FEditNode);
    Tree.Repaint;
    FNotUpdate := False;
   end;
end;

procedure TFormControl.ppMPopup(Sender: TObject);
 var
  d: IDevice;
  c: IConnectIO;
  x: IXMLNode;
//  am: IAddMenus;
begin
  FEditData := nil;
  FEditNode := nil;
  ShowConMenus(False);
  ShowDevMenus(False);
  ShowModulMenus(False);
  if not Assigned(Tree.HotNode) then Exit;
  FEditNode := Tree.HotNode;
  FEditData := Tree.GetNodeData(FEditNode);
  if Supports(FEditData.Item, IDevice, d) then
   begin
    ShowDevMenus(True, d);
    InitMenuConnectIO(NConnect, ConnectClick, AddNewClick);
//    if Supports(FEditData.Item, IAddMenus, am) then am.AddMenus(NControl);
   end
  else if Supports(FEditData.Item, IConnectIO, c) then
   begin
    ShowConMenus(True);
   end
  else if Supports(FEditData.Item, IXMLNode, x) then
   begin
    ShowModulMenus(True, x);
   end;
end;

function TFormControl.Priority: Integer;
begin
  Result := PRIORITY_IForm - 100;
end;

procedure TFormControl.IOChange(const Value: string);
 var
  pv: PVirtualNode;
begin
  for pv in Tree.LevelNodes(0) do Tree.InvalidateNode(pv);
end;

procedure TFormControl.SetAddCon(const Value: string);
begin
  FAddCon := Value;
  TreeUpdate;
end;

procedure TFormControl.SetAddDev(const Value: string);
begin
  FAddDev := Value;
  TreeUpdate;
end;

procedure TFormControl.SetC_TableUpdate(const Value: string);
begin
  FC_TableUpdate := Value;
  TreeUpdate;
end;

procedure TFormControl.SetData(pd: PNodeExData; const d0, d1, d2: string);
begin
  pd.ImagIndex := IMG_ATTR;
  pd.Color := CLR_ATTR;
  pd.Data[0] := d0;
  pd.Data[1] := d1;
  pd.Data[2] := d2;
end;

procedure TFormControl.SetDeviceChange(const Value: string);
 var
  pv: PVirtualNode;
begin
  for pv in Tree.LevelNodes(1) do Tree.InvalidateNode(pv)
end;

procedure TFormControl.SetProjectChange(const Value: string);
begin
  if Value = '' then TreeClear
  else TreeUpdate;
end;

procedure TFormControl.SetReadOnly(pd: PNodeExData; r0, r1, r2: Boolean);
begin
  pd.ReadOnly[0] := r0;
  pd.ReadOnly[1] := r1;
  pd.ReadOnly[2] := r2;
end;

procedure TFormControl.ShowConMenus(Flag: Boolean);
begin
  NSetup.Visible := Flag;
  NSepConn.Visible := Flag;
end;

procedure TFormControl.ShowDevMenus(Flag: Boolean; dev: IDevice);
 var
  ga: IGetActions;
  a: IAction;
  m: TMenuItem;
begin
  NRemove.Visible := Flag;
  NConnect.Visible := Flag;
  NControl.Clear;
  NControl.Visible := Flag;
  NSetupDev.Visible := Flag;
  NSepDEv.Visible := Flag;
  if flag and Supports(dev, IGetActions, ga) then for a in ga.GetActions do
   begin
    m := TMenuItem.Create(NControl);
    m.Action := TBasicAction(a.GetComponent);
    NControl.Add(m);
   end;
end;

procedure TFormControl.ShowModulMenus(Flag: Boolean; node: IXMLnode);
  function Chld(const Attr: string): Boolean;
  begin
    Result := Assigned(node) and Assigned(node.ChildNodes.FindNode(Attr))
  end;
begin
  NReadRam.Visible := Flag and Chld(T_RAM);
  NInfo.Visible := Flag and Chld(T_WRK);
  Neep.Visible := Flag and Chld(T_EEPROM);
  NGlu.Visible := Flag and Chld(T_GLU);
  NMetrol.Visible := Flag and Chld(T_MTR);
end;

procedure TFormControl.TreeClear;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do PNodeExData(Tree.GetNodeData(pv)).Item := nil;
  Tree.Clear;
end;

procedure TFormControl.TreeCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
  EditLink := TEditor.Create;
end;

procedure TFormControl.TreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := not PNodeExData(Tree.GetNodeData(Node)).ReadOnly[Column];
end;

function TFormControl.AddControl(c: IConnectIO; PVDev: PVirtualNode): PVirtualNode;
begin
  Result := Tree.AddChild(nil);
  Include(Result.States, vsExpanded);
  PNodeExData(Tree.GetNodeData(Result)).Item := c;
  SetReadOnly(PNodeExData(Tree.GetNodeData(Result)), True, True, False);
  if Assigned(PVDev) then Tree.MoveTo(PVDev, Result, amAddChildLast, False);
  Bind('C_ConnectIO', c, ['S_Status', 'S_PublishedChanged']);
end;

procedure TFormControl.AddDevice(d: IDevice; Rt: PVirtualNode);
 var
  dd: IDataDevice;
  pv: PVirtualNode;
begin
  pv := Tree.AddChild(rt);
  Include(pv.States, vsExpanded);
  PNodeExData(Tree.GetNodeData(pv)).Item := d;
  SetReadOnly(PNodeExData(Tree.GetNodeData(pv)), False, True, not Supports(d, ICycle));
  if Supports(d, IDataDevice, dd) then AddMetaData(dd, pv);
  Bind('C_Device', d, ['S_Status']);
end;

procedure TFormControl.AddMetaData(d: IDataDevice; Rt: PVirtualNode);
 var
  m: TDeviceMetaData;
  v, sv, ssv: PVirtualNode;
  e: PNodeExData;
  i: Integer;
  n, a, s: Ixmlnode;
begin
  m := d.GetMetaData;
  ///  Ошибки инициализации
  if Length(m.ErrAdr) > 0 then
   begin
    v := Tree.AddChild(Rt);
    Include(v.States, vsExpanded);
    e := PNodeExData(Tree.GetNodeData(v));
    e.Item := nil;
    SetData(e,'Не инициализированны', TAddressRec(m.ErrAdr).ToNames);
    SetReadOnly(e);
   end;
  if Assigned(m.Info) then for n in XEnum(m.Info) do
   begin
    ///  модуль
    v := Tree.AddChild(Rt);
    Include(v.States, vsExpanded);
    e := PNodeExData(Tree.GetNodeData(v));
    e.Item := n;
    SetData(e);
    SetReadOnly(e);
    e.Color := TColors.Blueviolet;
    e.ImagIndex := 322;
    ///  модуль атрибуты метаданных
    for i := 0 to High(AVAIL_ATTR) do
     begin
      a := n.AttributeNodes.FindNode(AVAIL_ATTR[i]);
      if Assigned(a) then
       begin
        sv := Tree.AddChild(v);
        Include(sv.States, vsExpanded);
        e := PNodeExData(Tree.GetNodeData(sv));
        e.Item := a;
        SetData(e,AVAIL_ATTR_Caption[i]);
        SetReadOnly(e);
       end;
     end;
    ///  модуль режим информации лог памяти EEPROM  glu  метрология
    for i := 0 to High(AVAIL_T) do
     begin
      a := n.ChildNodes.FindNode(AVAIL_T[i]);
      if Assigned(a) then
       begin
        sv := Tree.AddChild(v);
        Include(sv.States, vsExpanded);
        e := PNodeExData(Tree.GetNodeData(sv));
        e.Item := a;
        SetData(e, AVAIL_T_Caption[i]);
        SetReadOnly(e);
        e.Color := TColors.Blueviolet;
        e.ImagIndex := 315;
        if a.HasAttribute(AT_FILE_NAME) then
         begin
          ssv := Tree.AddChild(sv);
          Include(ssv.States, vsExpanded);
          e := PNodeExData(Tree.GetNodeData(ssv));
          e.Item := a.AttributeNodes.FindNode(AT_FILE_NAME);
          SetData(e,'Файл', a.Attributes[AT_FILE_NAME]);
          SetReadOnly(e);
         end;
        if Assigned(AVAIL_T_Func[i]) then AVAIL_T_Func[i](Self, sv, a);
       end;
     end;
   end;
end;

procedure TFormControl.TreeUpdate;
 var
  c: IConnectIO;
  de: IDeviceEnum;
  ce: IConnectIOEnum;
  function testuseddev(): PVirtualNode;
   var
    d: IDevice;
  begin
    Result := nil;
    for d in de.Enum do if d.IConnect = c then Exit(AddControl(c, nil));
    if Assigned(ce) then ce.Remove(c);
  end;
 var
  d: IDevice;
  pv: PVirtualNode;
begin
  if FNotUpdate or not (Supports(GlobalCore, IDeviceEnum, de) and Supports(GlobalCore, IConnectIOEnum, ce)) then Exit;
  TBindHelper.RemoveControlExpressions(Self, ['C_ConnectIO', 'C_Device']);
  Tree.BeginUpdate;
  try
   TreeClear;
   for c in ce.Enum do testuseddev();
   for d in de.Enum do
    begin
     pv := nil;
     if Assigned(d.IConnect) then for pv in Tree.LevelNodes(0) do if PNodeExData(Tree.GetNodeData(pv)).Item = d.IConnect then Break;
     AddDevice(d, pv);
    end;
  finally
   Tree.EndUpdate;
  end;
end;

class procedure TFormControl.ViewRamData(Sender: TFormControl; Root: PVirtualNode; node: IXMLNode);
  procedure SetData(const Caption, AttrName: string);
   var
    v: PVirtualNode;
    e: PNodeExData;
  begin
    if node.HasAttribute(AttrName) then
     begin
      v := Sender.Tree.AddChild(Root);
      Include(v.States, vsExpanded);
      e := PNodeExData(Sender.Tree.GetNodeData(v));
      e.Item := node.AttributeNodes.FindNode(AttrName);
      Sender.SetData(e, Caption, node.Attributes[AttrName]);
      Sender.SetReadOnly(e);
     end;
  end;
begin
  SetData('с кадра', AT_FROM_KADR);
  SetData('по кадр', AT_TO_KADR);
  SetData('со времени', AT_FROM_TIME);
  SetData('до времени', AT_TO_TIME);
  SetData('с адреса', AT_FROM_ADR);
  SetData('по адрес', AT_TO_ADR);
end;

class procedure TFormControl.ViewWrkData(Sender: TFormControl; Root: PVirtualNode; node: IXMLNode);
begin

end;

procedure TFormControl.TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
 var
  xd: PNodeExData;
  d: IDevice;
  c: IConnectIO;
begin                                  // - 306
  xd := Sender.GetNodeData(Node);
  if Column = 0 then
   if Supports(xd.Item, IDevice, d) then ImageIndex := 242
   else if Supports(xd.Item, IConnectIO, c) then
    begin
     if iosLock in c.Status then Ghosted := True;
     if iosError in c.Status then ImageIndex := 277
     else if iosOpen in c.Status then ImageIndex := 241
     else ImageIndex := 315;
    end
   else ImageIndex := xd.ImagIndex;
end;

procedure TFormControl.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
begin
  if Column < 0 then Exit;
  CellText := TEditor.GetTextNode(Sender.GetNodeData(Node), Column);
end;

procedure TFormControl.TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
 var
  xd: PNodeExData;
  d: IDevice;
  c: IConnectIO;
begin
  xd := Sender.GetNodeData(Node);
  if Supports(xd.Item, IDevice, d) then TargetCanvas.Font.Color := clBlue
  else if Supports(xd.Item, IConnectIO, c) then TargetCanvas.Font.Color := clRed
  else TargetCanvas.Font.Color := xd.Color;
end;
{$ENDREGION}

initialization
  RegisterClass(TFormControl);
  TRegister.AddType<TFormControl, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormControl>;
end.
