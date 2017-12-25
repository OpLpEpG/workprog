unit FormDlgDev;

interface

uses  RootIntf, debug_except,ExtendIntf, DeviceIntf, Container, Tools, RootImpl,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, VirtualTrees, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, CPortCtl;

type
  TFormCreateDev = class(TForm)
    ButtonOK: TButton;
    Button1: TButton;
    Tree: TVirtualStringTree;
    Label1: TLabel;
    edCaption: TEdit;
    Label3: TLabel;
    cbTree: TCheckBox;
    btConnection: TButton;
    ppConnection: TPopupMenu;
    procedure FormShow(Sender: TObject);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure ButtonOKClick(Sender: TObject);
    procedure TreeChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
    procedure TreeChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btConnectionClick(Sender: TObject);
  private
   var
    FSelectIO: IConnectIO;
    FDevice: IDevice;
   type
    ChekDevs = (cdNone, cdBur, cdPSK);
    function CheckState: ChekDevs;
    function Selected: TAddressArray;
  public
    class function Execute(out d: IDevice): TModalResult;
  end;

implementation

{$R *.dfm}

uses AbstractPlugin,  ConnectDeviceHelper;

function TFormCreateDev.CheckState: ChekDevs;
 var
  pv: PVirtualNode;
begin
  Result := cdNone;
  for pv in Tree.LevelNodes(0) do
   if pv.CheckState = csCheckedNormal then
    if TAddressRec.Devices[pv.Index].Adr < 16 then Exit(cdBur) else Exit(cdPSK)
end;

class function TFormCreateDev.Execute(out d: IDevice): TModalResult;
begin
  with TFormCreateDev.Create(nil) do
   try
    Result := ShowModal();
    d := FDevice;
   finally
    Free;
   end;
end;

procedure TFormCreateDev.btConnectionClick(Sender: TObject);
begin
  btConnection.Caption := 'Подключить';
  FSelectIO := nil;
  TMenuConnectIO.Apply(ppConnection.Items,
    procedure(c: IConnectIO)
    begin
      FselectIO := c;
      btConnection.Caption := c.ConnectInfo;
      (GlobalCore as IconnectIOEnum).Add(c);
    end,
    procedure(c: IConnectIO)
    begin
      FselectIO := c;
      btConnection.Caption := c.ConnectInfo;
    end);
  ppConnection.Popup(btConnection.ClientOrigin.X, btConnection.ClientOrigin.Y+btConnection.Height)
end;

procedure TFormCreateDev.ButtonOKClick(Sender: TObject);
 var
  g: IGetDevice;
  de: IDeviceEnum;
  pv: PVirtualNode;
  wf: IForm;
  function SetToEmptyWorkWindow: Boolean;
   var
    isd: ISetDevice;
  begin
    for isd in GContainer.Enum<ISetDevice> do if isd.DataDevice = '' then
     begin
       isd.DataDevice := FDevice.IName;
       Exit(True);
     end;
    Result := False;
  end;
begin
  if CheckState = cdNone then
  begin
   ModalResult := mrAbort;
   raise EBaseException.Create('Не выбраны устройства');
  end;
  if Supports(GlobalCore, IGetDevice, g) and Supports(GlobalCore, IDeviceEnum, de) then
   begin
    FDevice := g.Device(Selected, edCaption.Text);
    FDevice.IConnect := FSelectIO;
    de.Add(FDevice);
    MainScreenChanged;
    for pv in Tree.LevelNodes(0) do pv.CheckState := csUnCheckedNormal;
    if cbTree.Checked and not SetToEmptyWorkWindow then
     begin
      wf := GContainer.CreateValuedInstance<string>('TFormWrok', 'CreateUser', '') as IForm;
      (GContainer as IFormEnum).Add(wf);
      (wf as ISetDevice).SetDataDevice(FDevice.IName);
      wf.Show;
      (GContainer as ITabFormProvider).Dock(wf, 0);
     end;
    (GlobalCore as IActionProvider).SaveActionManager;
    ((GlobalCore as IActionEnum) as IStorable).Save;
   end;
end;

procedure TFormCreateDev.FormShow(Sender: TObject);
 var
  pv: PVirtualNode;
begin
  Tree.Clear;
  Tree.RootNodeCount := Length(TAddressRec.Devices);
  for pv in Tree.LevelNodes(0) do
   begin
    pv.CheckType := ctCheckBox;
   end;
end;

function TFormCreateDev.Selected: TAddressArray;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.LevelNodes(0) do
   if pv.CheckState = csCheckedNormal then CArray.Add<Integer>(Result, TAddressRec.Devices[pv.Index].Adr);
end;

procedure TFormCreateDev.TreeChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
 var
  pv: PVirtualNode;
  s: string;
begin
  s := '';
  for pv in Tree.LevelNodes(0) do
    if pv.CheckState = csCheckedNormal then s := s + ' ' + TAddressRec.Devices[pv.Index].Name;
  edCaption.Text := s.Trim;
end;

procedure TFormCreateDev.TreeChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
begin
  if NewState = csCheckedNormal then
   if (CheckState = cdPSK) or ((CheckState = cdBur) and (TAddressRec.Devices[Node.Index].Adr >= 100)) then Allowed := False

end;

procedure TFormCreateDev.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
begin
  case Column of
   0: CellText := TAddressRec.Devices[node.Index].Name;
   1: CellText := TAddressRec.Devices[node.Index].Info;
   2: CellText := TAddressRec.Devices[node.Index].Adr.ToString;
  end;
end;

end.
