unit MetrUAKI;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, UakiIntf, RootImpl,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Menus,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UakiUI, UakiUI.Ten, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormUAKI = class(TCustomFontIForm, INotifyCanClose, INotifyBeforeRemove)
    Panel1: TPanel;
    btZero: TButton;
    Button1: TButton;
    edDvis: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure btZeroClick(Sender: TObject);
    procedure edDvisKeyPress(Sender: TObject; var Key: Char);
  private
    FBinded: Boolean;
    FC_AxisUpdate: Integer;
    FuiA: TFrameUakiUI;
    FuiZ: TFrameUakiUI;
    FuiV: TFrameUakiUI;
    FuiT: TFrameUakiTEN;
    FC_PublishedChanged: string;
    FC_TenUpdate: Integer;
    function GetUaki: IUaki;
    procedure NetSetupClick(Sender: TObject);
    procedure SetC_AxisUpdate(const Value: Integer);
    procedure btGoClick(Sender: TObject);
    procedure NToleranceClick(Sender: TObject);
    procedure btReperClick(Sender: TObject);
    procedure InitFrame(var Frame: TFrameUakiUI; const Capt, Nm: string; Addr: Integer);
    procedure SetC_PublishedChanged(const Value: string);
    procedure NetSetupConnection(u: IUaki);
    procedure SetC_TenUpdate(const Value: Integer);
  protected
   const
    NICON = 273;
    procedure CanClose(var CanClose: Boolean);
    procedure BeforeRemove();
    procedure InitializeNewForm; override;
    procedure Loaded; override;
    class function ClassIcon: Integer; override;
  public
    [StaticAction('УАК-СИ-АЗВ-Т', 'Метрология', NICON, '0:Метрология.Инклинометры:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
    property Uaki: IUaki read GetUaki;
    property C_AxisUpdate: Integer read FC_AxisUpdate write SetC_AxisUpdate;
    property C_TenUpdate: Integer read FC_TenUpdate write SetC_TenUpdate;
    property C_PublishedChanged: string read FC_PublishedChanged write SetC_PublishedChanged;
  end;


implementation

{$R *.dfm}

uses tools, MetrUAKI.ToleranceForm;

{ TFormUAKI }

procedure TFormUAKI.BeforeRemove;
begin
  (Uaki as ICycle).Cycle := False;
  while (Uaki as ICycle).Cycle do
   begin
//    TDebug.Log('%s', ['--------------------------NOP---------------------']);
    Application.ProcessMessages;
   end;
end;

procedure TFormUAKI.btGoClick(Sender: TObject);
begin
  with TFrameUakiUI(TButton(Sender).Parent) do
  case Adr of
   ADR_AXIS_AZI: Uaki.Azi.GotoAngle(StrToFloat(edNeed.Text));
   ADR_AXIS_ZU: Uaki.Zen.GotoAngle(StrToFloat(edNeed.Text));
   ADR_AXIS_VIZ: Uaki.Viz.GotoAngle(StrToFloat(edNeed.Text));
  end;
end;

procedure TFormUAKI.btReperClick(Sender: TObject);
begin
  with TFrameUakiUI(TButton(Sender).Parent) do
  case Adr of
   ADR_AXIS_AZI: Uaki.Azi.FindMarker;
   ADR_AXIS_ZU: Uaki.Zen.FindMarker;
   ADR_AXIS_VIZ: Uaki.Viz.FindMarker;
  end;
end;

procedure TFormUAKI.Button1Click(Sender: TObject);
begin
  Uaki.Azi.TermimateMoving;
  Uaki.Zen.TermimateMoving;
  Uaki.Viz.TermimateMoving;
end;

procedure TFormUAKI.CanClose(var CanClose: Boolean);
begin
  BeforeRemove;
end;

procedure TFormUAKI.btZeroClick(Sender: TObject);
// var
//  f: Boolean;
begin
  Uaki.Viz.ClearDeltaAngle;
  edDvis.Text := Uaki.Viz.DeltaAngle.ToString
//  f := (Uaki as ICycle).Cycle;
//  (Uaki as ICycle).Cycle := not f;
//  if f then  btCycl.Caption := 'Опрос-'
//  else  btCycl.Caption := 'Опрос+'
end;

class function TFormUAKI.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormUAKI.DoCreateForm(Sender: IAction);
begin
  GetUniqueForm('GlobalUakiForm');
end;

procedure TFormUAKI.edDvisKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #$D then
   begin
    Uaki.Viz.DeltaAngle := StrToFloat(edDvis.Text);
    Key := #0;
   end;
end;

procedure TFormUAKI.InitFrame(var Frame: TFrameUakiUI; const Capt, Nm: string; Addr: Integer);
begin
  if not Assigned(Frame) then
   begin
    Frame := CreateUnLoad<TFrameUakiUI>;
    Frame.Name := Nm;
    Frame.Parent := Self;
    Frame.Show;
   end;
  Frame.NTolerance.OnClick := NToleranceClick;
  Frame.btGo.OnClick := btGoClick;
  Frame.lbReper.OnClick := btReperClick;
  Frame.lbName.Caption := Capt;
  Frame.Adr := addr;
  SetC_AxisUpdate(Addr)
end;

procedure TFormUAKI.InitializeNewForm;
 var
  m: TMenuItem;
begin
  inherited;
  AddToNCMenu('Установки соединения...', NetSetupClick, m);
end;

procedure TFormUAKI.Loaded;
begin
  inherited Loaded;
  FuiT := CreateUnLoad<TFrameUakiTEN>;
  FuiT.Name := 'FuiT';
  FuiT.Parent := Self;
  FuiT.FuncUaki := GetUaki;
  FuiT.Show;
//  btCycl.Caption := 'Опрос+';
  InitFrame(FuiV, 'Визир','FuiV', ADR_AXIS_VIZ);
  InitFrame(FuiZ, 'Зенит','FuiZ', ADR_AXIS_ZU);
  InitFrame(FuiA, 'Азимут','FuiA', ADR_AXIS_AZI);
  (Uaki as ICycle).Cycle := True;
end;

procedure TFormUAKI.NetSetupClick(Sender: TObject);
begin
  NetSetupConnection(Uaki);
end;

procedure TFormUAKI.NetSetupConnection(u: IUaki);
 var
  c: IConnectIO;
  ge: IConnectIOEnum;
  gc: IGetConnectIO;
  d: IDialog;
begin
  if Assigned(u) and not Assigned(u.IConnect) then
   begin
    if Supports(GlobalCore, IConnectIOEnum, ge) and Supports(GlobalCore, IGetConnectIO, gc) then
     begin
       c := gc.ConnectIO(4);
       if RegisterDialog.TryGet<Dialog_SetupConnectIO>(d) then (d as IDialog<IConnectIO>).Execute(c);
       u.IConnect := c;
       ge.Add(c);
     end
   end
   else if RegisterDialog.TryGet<Dialog_SetupConnectIO>(d) then (d as IDialog<IConnectIO>).Execute(u.IConnect);
end;

procedure TFormUAKI.NToleranceClick(Sender: TObject);
begin
  TDebug.Log(Sender.ClassName);
  with TFrameUakiUI(TMenuItem(Sender).Owner) do
  case Adr of
   ADR_AXIS_AZI: TFormUAKItolerance.Execute(Uaki.Azi);
   ADR_AXIS_ZU:  TFormUAKItolerance.Execute(Uaki.Zen);
   ADR_AXIS_VIZ: TFormUAKItolerance.Execute(Uaki.Viz);
  end;
end;

procedure TFormUAKI.SetC_AxisUpdate(const Value: Integer);
begin
  FC_AxisUpdate := Value;
  case FC_AxisUpdate of
   ADR_AXIS_AZI: FuiA.UpdateScreen(Uaki.Azi);
   ADR_AXIS_ZU: FuiZ.UpdateScreen(Uaki.Zen);
   ADR_AXIS_VIZ: FuiV.UpdateScreen(Uaki.Viz);
  end;
end;

procedure TFormUAKI.SetC_PublishedChanged(const Value: string);
begin
  FC_PublishedChanged := Value;
  if StrToFloat(FuiA.edNeed.Text) <> Uaki.Azi.NeedAngle.Angle then FuiA.edNeed.Text := Uaki.Azi.NeedAngle.ToString;
  if StrToFloat(FuiZ.edNeed.Text) <> Uaki.Zen.NeedAngle.Angle then FuiZ.edNeed.Text := Uaki.Zen.NeedAngle.ToString;
  if StrToFloat(FuiV.edNeed.Text) <> Uaki.Viz.NeedAngle.Angle then FuiV.edNeed.Text := Uaki.Viz.NeedAngle.ToString;
  edDvis.Text := Uaki.Viz.DeltaAngle.ToString;
end;

procedure TFormUAKI.SetC_TenUpdate(const Value: Integer);
begin
  FC_TenUpdate := Value;
  FuiT.UpdateScreen(Value, Uaki);
end;

function TFormUAKI.GetUaki: IUaki;
 var
  g: IGetDevice;
  de: IDeviceEnum;
  d: IDevice;
  a: TAddressArray;
begin
  try
  if Supports(GlobalCore, IGetDevice, g) and Supports(GlobalCore, IDeviceEnum, de) then
   begin
    for d in de.Enum() do if Supports(d, IUaki, Result) then Exit;
    SetLength(a, 1);
    a[0] := ADR_UAKI;
    d := g.Device(a, 'UAKI');
    de.Add(d);
    FBinded := False;
    Result := d as IUaki;
    NetSetupConnection(Result);
   end;
  finally
   if not FBinded then
    begin
     Bind('C_AxisUpdate', d, ['S_AxisUpdate']);
     Bind('C_TenUpdate', d, ['S_TenUpdate']);
     Bind('C_PublishedChanged', d, ['S_PublishedChanged']);
     FBinded := True;
    end;
  end;
end;

initialization
  RegisterClass(TFormUAKI);
  TRegister.AddType<TFormUAKI, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormUAKI>;
end.
