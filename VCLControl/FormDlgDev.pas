unit FormDlgDev;

interface

uses  RootIntf, debug_except,ExtendIntf, DeviceIntf, Container,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, VirtualTrees, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup;

type
  TFormCreateDev = class(TForm)
    ButtonOK: TButton;
    Button1: TButton;
    Tree: TVirtualStringTree;
    Label1: TLabel;
    Label2: TLabel;
    edAdr: TEdit;
    ppM: TPopupActionBar;
    NAdd: TMenuItem;
    edCaption: TEdit;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure NAddClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    class function Execute(): TModalResult;
  end;

implementation

{$R *.dfm}

uses AbstractPlugin, Tools;

class function TFormCreateDev.Execute: TModalResult;
begin
  with TFormCreateDev.Create(nil) do
   try
    Result := ShowModal();
   finally
    Free;
   end;
end;

procedure TFormCreateDev.ButtonOKClick(Sender: TObject);
 var
  g: IGetDevice;
  de: IDeviceEnum;
begin
  if Trim(edAdr.Text) = '' then raise EBaseException.Create('Не выбраны устройства');
  if Supports(GlobalCore, IGetDevice, g) and Supports(GlobalCore, IDeviceEnum, de) then
   begin
    de.Add(g.Device(TAddressRec(edAdr.Text), edCaption.Text));
    (GlobalCore as IActionProvider).SaveActionManager;
    ((GlobalCore as IActionEnum) as IStorable).Save;
   end;
end;

procedure TFormCreateDev.FormShow(Sender: TObject);
begin
  Tree.Clear;
  Tree.RootNodeCount := Length(TAddressRec.Devices);
end;

procedure TFormCreateDev.NAddClick(Sender: TObject);
 var
  pv: PVirtualNode;
begin
  for pv in Tree.SelectedNodes do edAdr.Text := edAdr.Text + TAddressRec.Devices[pv.Index].Adr.ToString + ';';
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
