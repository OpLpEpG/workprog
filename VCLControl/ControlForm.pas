unit ControlForm;

interface

uses RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RootIntf, Container, Actns,
  System.SysUtils, Vcl.Graphics, VirtualTrees, System.Bindings.Expression, Vcl.Forms, Vcl.Dialogs, JvDockControlForm,
  Vcl.ImgList, Vcl.Controls, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, System.Classes;

type
  PNodeExData = ^TNodeExData;
  TNodeExData = record
    Item: IInterface;
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
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure NUpdateClick(Sender: TObject);
    procedure ppMPopup(Sender: TObject);
    procedure NRemoveClick(Sender: TObject);
    procedure NSetupClick(Sender: TObject);
    procedure NAddDevClick(Sender: TObject);
    procedure TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure TreePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure NSetupDevClick(Sender: TObject);
  private
    FEditData: PNodeExData;
    FEditNode: PVirtualNode;

    FDummi: string;
    FProject: string;

    procedure TreeClear;
    procedure TreeUpdate;

    procedure InitMenuConnectIO;

    procedure ShowDevMenus(Flag: Boolean);
    procedure ShowConMenus(Flag: Boolean);
    procedure ConnectClick(Sender: TObject);
    procedure AddNewClick(Sender: TObject);
    procedure IOChange(const Value: string);
    procedure SetDeviceChange(const Value: string);
    procedure SetProjectChange(const Value: string);
  protected
   const
    NICON = 269;
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
  end;

implementation

{$R *.dfm}

uses AbstractPlugin, tools, FormDlgDev;

class function TFormControl.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormControl.DoCreateForm(Sender: IAction);
begin
  GetUniqueForm('GlobalControlForm');
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
  Bind('C_Project', GlobalCore as IManager, ['S_ProjectChange']);
end;

procedure TFormControl.NAddDevClick(Sender: TObject);
begin
 if TFormCreateDev.Execute = mrOk then TreeUpdate;
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
  TreeUpdate;
end;

procedure TFormControl.NSetupClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetupConnectIO>(d) then (d as IDialog<IConnectIO>).Execute(FEditData.Item as IConnectIO);
//  if Supports(FEditData.Item, IComPortConnectIO) then TFormSetupCom.Execute(FEditData.Item as IConnectIO)
//  else if Supports(FEditData.Item, INetConnectIO) then TFormSetupNet.Execute(FEditData.Item as IConnectIO);
end;

procedure TFormControl.NSetupDevClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetupDevice>(d) then (d as IDialog<IDevice>).Execute(FEditData.Item as IDevice);
  //TDlgSetupDev.Execute(FEditData.Item as IDevice);
  Tree.InvalidateNode(FEditNode);
end;

procedure TFormControl.NUpdateClick(Sender: TObject);
begin
  TreeUpdate;
end;

procedure TFormControl.InitMenuConnectIO;
 var
  gc: IGetConnectIO;
begin
  NConnect.Clear;
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
      for s in gc.GetConnectInfo(ConnectID) do AddMenu(root, s, ConnectClick);
    end;
    procedure AddCreateNew(root: TMenuItem);
    begin
      AddMenu(root, 'Новое соединение...', AddNewClick);
      AddMenu(root, '-', nil);
    end;
   var
    Item: TMenuItem;
  begin
    Item := AddMenu(NConnect, ConnectInfo, nil);
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
begin
  if Supports(GlobalCore, IGetConnectIO, gc) then
   begin
    c := gc.ConnectIO(TMenuItem(Sender).Tag);
    if RegisterDialog.TryGet<Dialog_SetupConnectIO>(d) and (d as IDialog<IConnectIO>).Execute(c) then
      begin
       if Supports(GlobalCore, IConnectIOEnum, ce) then ce.Add(c);
       (FEditData.Item as IDevice).IConnect := c;
      end;
    TreeUpdate();
   end;
end;

procedure TFormControl.ConnectClick(Sender: TObject);
 var
  c: IConnectIO;
  gc: IGetConnectIO;
  ce: IConnectIOEnum;
begin
  GlobalCore.QueryInterface(IConnectIOEnum, ce);
  if Supports(GlobalCore, IConnectIOEnum, ce) then for c in ce do if SameText(c.ConnectInfo, TMenuItem(Sender).Caption) then
   begin
    (FEditData.Item as IDevice).IConnect := c;
    TreeUpdate();
    Exit;
   end;
  if Supports(GlobalCore, IGetConnectIO, gc) then
   begin
    c := gc.ConnectIO(TMenuItem(Sender).Tag);
    c.ConnectInfo := TMenuItem(Sender).Caption;
    if Assigned(ce) then ce.Add(c);
    (FEditData.Item as IDevice).IConnect := c;
    TreeUpdate();
   end;
end;

procedure TFormControl.ppMPopup(Sender: TObject);
 var
  d: IDevice;
  c: IConnectIO;
//  am: IAddMenus;
begin
  FEditData := nil;
  FEditNode := nil;
  ShowConMenus(False);
  ShowDevMenus(False);
  if not Assigned(Tree.HotNode) then Exit;
  FEditNode := Tree.HotNode;
  FEditData := Tree.GetNodeData(FEditNode);
  if Supports(FEditData.Item, IDevice, d) then
   begin
    ShowDevMenus(True);
    InitMenuConnectIO;
//    if Supports(FEditData.Item, IAddMenus, am) then am.AddMenus(NControl);
   end
  else if Supports(FEditData.Item, IConnectIO, c) then
   begin
    ShowConMenus(True);
   end;
end;

procedure TFormControl.IOChange(const Value: string);
 var
  pv: PVirtualNode;
begin
  for pv in Tree.LevelNodes(0) do Tree.InvalidateNode(pv);
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

procedure TFormControl.ShowConMenus(Flag: Boolean);
begin
  NSetup.Visible := Flag;
  NSepConn.Visible := Flag;
end;

procedure TFormControl.ShowDevMenus(Flag: Boolean);
begin
  NRemove.Visible := Flag;
  NConnect.Visible := Flag;
  NControl.Visible := Flag;
  NSetupDev.Visible := Flag;
  NSepDEv.Visible := Flag;
end;

procedure TFormControl.TreeClear;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do PNodeExData(Tree.GetNodeData(pv)).Item := nil;
  Tree.Clear;
end;

procedure TFormControl.TreeUpdate;
 var
  c: IConnectIO;
  d: IDevice;
  pv: PVirtualNode;
  de: IDeviceEnum;
  ce: IConnectIOEnum;
  procedure testuseddev;
   var
    d: IDevice;
  begin
   if Assigned(de) then for d in de.Enum do if d.IConnect = c then
    begin
     pv := Tree.AddChild(nil);
     Include(pv.States, vsExpanded);
     PNodeExData(Tree.GetNodeData(pv)).Item := c;
     Bind('C_ConnectIO', c, ['S_Status', 'S_PublishedChanged']);
     Exit;
    end;
   if Assigned(ce) then ce.Remove(c);
  end;
begin
  TBindHelper.RemoveControlExpressions(Self, ['C_ConnectIO', 'C_Device']);
  GlobalCore.QueryInterface(IDeviceEnum, de);
  GlobalCore.QueryInterface(IConnectIOEnum, ce);
  Tree.BeginUpdate;
  try
   TreeClear;
   if Assigned(ce) then for c in ce.Enum do testuseddev();
   if Assigned(de) then for d in de.Enum do
    begin
     pv := nil;
     if Assigned(d.IConnect) then
        for pv in Tree.LevelNodes(0) do
            if PNodeExData(Tree.GetNodeData(pv)).Item = d.IConnect then Break;
     pv := Tree.AddChild(pv);
     PNodeExData(Tree.GetNodeData(pv)).Item := d;
     Bind('C_Device', d, ['S_Status']);
    end;
  finally
   Tree.EndUpdate;
  end;
end;

procedure TFormControl.TreeGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
 var
  xd: PNodeExData;
  d: IDevice;
  c: IConnectIO;
begin
  xd := Sender.GetNodeData(Node);
  if Column = 0 then
   if Supports(xd.Item, IDevice, d) then ImageIndex := 242
   else if Supports(xd.Item, IConnectIO, c) then
    begin
     if iosLock in c.Status then Ghosted := True;
     if iosError in c.Status then ImageIndex := 277
     else if iosOpen in c.Status then ImageIndex := 241
     else ImageIndex := 315;
    end;
end;

procedure TFormControl.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
 const
  DSTA_TO_STR: array [Low(TDeviceStatus)..High(TDeviceStatus)] of string =
                     ('не инициализирован','готов частично', 'готов', 'режим информации', 'постановка на задержку', 'чтение памяти');
 var
  xd: PNodeExData;
  d: IDevice;
  c: IConnectIO;
  cy: ICycle;
begin
  xd := Sender.GetNodeData(Node);
  if Supports(xd.Item, IDevice, d) then
    case Column of
     0: CellText := (d as ICaption).Text;
     1: CellText := DSTA_TO_STR[d.Status];
     2: CellText := TaddressRec(d.GetAddrs).ToNames;
     3: CellText := TaddressRec(d.GetAddrs).ToStr;
     4: if Supports(d, ICycle, cy) then CellText := cy.Period.ToString
        else CellText := '';
    end
  else if Supports(xd.Item, IConnectIO, c) then
    case Column of
     0: CellText := c.ConnectInfo;
     1: if iosLock in c.Status then CellText := 'занят'
        else if iosError in c.Status then CellText := 'ошибка'
        else CellText := '';
     2: CellText := '';
     3: CellText := '';
     4: CellText := c.Wait.ToString;
    end;
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
end;

initialization
  RegisterClass(TFormControl);
  TRegister.AddType<TFormControl, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormControl>;
end.
