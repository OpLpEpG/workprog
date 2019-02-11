unit VCL.FormShowArray;

interface

uses  DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, GR32_VectorUtils,
  Vcl.Menus, System.Generics.Collections,  JDtools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Xml.XMLIntf,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCLTee.TeEngine, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFormShowArray = class;
  TZSeries = class(TLineSeries)
  protected
    procedure Loaded; override;
  public
    FsaForm: TFormShowArray;
    FLenArray: Integer;
    FLineCount: Integer;
    FclR, FclG, FclB: Byte;
    class function New(ASaForm: TFormShowArray; const ATitle: string): TZSeries;
    procedure AddZArray(const AArray: string);
    procedure UpdateDept(deptcnt: Integer);
  end;

  TFormShowArray = class(TDockIForm)
    ChartCode: TChart;
    procedure ChartCodeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    FDataDevice: string;
    FBindWorkRes: TWorkEventRes;
    FXMLPath: string;
    N3DMenu: TMenuItem;
    FDept: Integer;
    FProcX: Integer;
    FProcY: Integer;
    procedure SetBindWorkRes(const Value: TWorkEventRes);
    procedure SetRemoveDevice(const Value: string);
    function SetBind: IDevice;
    procedure UpdateLegend(Root: IXMLNode);
    procedure NPropClick(Sender: TObject);
    procedure SetD3View(const Value: boolean);
    function GetD3View: boolean;
    procedure SetDept(const Value: Integer);
  protected
    procedure InitializeNewForm; override;
    procedure Loaded; override;
  public
    FVX, FVY: Double;
    clR, clG, clB: Byte;
    procedure UpdateVXY;
    destructor Destroy; override;
    class procedure Execute(const ADataDevice, AXMLPath: string);
    property C_BindWorkRes: TWorkEventRes read FBindWorkRes write SetBindWorkRes;
    property C_RemoveDevice: string read FDataDevice write SetRemoveDevice;
  published
    property DataDevice: string read FDataDevice write FDataDevice;
    property XMLPath: string read FXMLPath write FXMLPath;
    [ShowProp('Вид 3D')] property D3View: boolean read GetD3View write SetD3View;
    [ShowProp('Глубина')] property Dept: Integer read FDept write SetDept default 10;
    [ShowProp('Сдвиг по X %')] property ProcX: Integer read FProcX write FProcX default 10;
    [ShowProp('Сдвиг по Y %')] property ProcY: Integer read FProcY write FProcY default 30;
  end;

implementation

{$R *.dfm}

uses tools, Parser;

{ TFormShowArray }

function TFormShowArray.SetBind: IDevice;
 var
  de: IDeviceEnum;
begin
  if FDataDevice = '' then Exit;
  Result := nil;
  if Supports(GlobalCore, IDeviceEnum, de) then
   begin
    Bind('C_RemoveDevice', de, ['S_BeforeRemove']);
    Result := de.Get(FDataDevice);
    if Assigned(Result) then Bind('C_BindWorkRes',Result, ['S_WorkEventInfo']);
   end;
end;

procedure TFormShowArray.ChartCodeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
 var
  s: TChartSeries;
  SeriesIndex: Integer;
begin
  for s in ChartCode.SeriesList do
   begin
    SeriesIndex := s.Clicked(X, Y);
    ChartCode.ShowHint := SeriesIndex <> -1;
    if ChartCode.ShowHint then
     ChartCode.Hint:='X='+FormatFloat('#.00',s.XScreenToValue(X)) +' Y='+FormatFloat('#.00',s.YScreenToValue(y)) + ' : '+s.ValueMarkText[SeriesIndex+1];
   end;
end;

destructor TFormShowArray.Destroy;
begin
  inherited;
end;

class procedure TFormShowArray.Execute(const ADataDevice, AXMLPath: string);
 var
  f: TFormShowArray;
  d: IDevice;
begin
  f := CreateUser();
  (GContainer as IFormEnum).Add(f as Iform);
  f.DataDevice := ADataDevice;
  f.XMLPath := AXMLPath;
  f.Caption := AXMLPath;
  d := f.SetBind;
  f.UpdateLegend(FindWork((d as IDataDevice).GetMetaData.Info, d.Addrs[0]));
  f.IShow;
end;

function TFormShowArray.GetD3View: boolean;
begin
  Result := N3DMenu.Checked
end;

procedure TFormShowArray.InitializeNewForm;
begin
  inherited;
  N3DMenu := AddToNCMenu('Вид 3D', nil, 0, 2);
  AddToNCMenu('Свойства...', NPropClick, 0);
  FDept := 10;
  FVX := 1;
  FVY := 1;
  FProcX := 10;
  FProcY := 30;
end;

procedure TFormShowArray.Loaded;
 var
  s: TChartSeries;
  cl: TColor;
begin
  inherited;
  cl := ColorToRGB(ChartCode.Color);
  clR := GetRValue(cl);
  clG := GetGValue(cl);
  clB := GetBValue(cl);
  for s in ChartCode.SeriesList do TZSeries(s).FsaForm := Self;
  SetBind;
end;

procedure TFormShowArray.NPropClick(Sender: TObject);
 var
  d: IDialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TFormShowArray>).Execute(Self);
end;

procedure TFormShowArray.SetBindWorkRes(const Value: TWorkEventRes);
 var
  n: IXMLNode;
  s: TChartSeries;
begin
  FBindWorkRes := Value;
  for s in ChartCode.SeriesList do s.BeginUpdate;
  try
   for s in ChartCode.SeriesList do
     if TryGetX(FBindWorkRes.Work, s.Title+'.'+T_DEV, n, AT_VALUE)
       and (n.NodeValue <> null)
         and (n.NodeValue <> '') then TZSeries(s).AddZArray(n.NodeValue);
  finally
   for s in ChartCode.SeriesList do s.EndUpdate;
  end;
  UpdateVXY;
end;

procedure TFormShowArray.SetD3View(const Value: boolean);
begin
  N3DMenu.Checked := Value;
end;

procedure TFormShowArray.SetDept(const Value: Integer);
 var
  s: TChartSeries;
begin
  FDept := Value;
  if csLoading in ComponentState then Exit;
  for s in ChartCode.SeriesList do s.BeginUpdate;
  try
   for s in ChartCode.SeriesList do TZSeries(s).UpdateDept(Value);
  finally
   for s in ChartCode.SeriesList do s.EndUpdate;
  end;
end;

procedure TFormShowArray.SetRemoveDevice(const Value: string);
begin
  if DataDevice = Value then
   begin
    (GContainer as IMainScreen).Changed;
    (GlobalCore as IFormEnum).Remove(Self as Iform);
   end;
end;

procedure TFormShowArray.UpdateLegend(Root: IXMLNode);
 var
  X: IXMLNode;
begin
  if TryGetX(root, XMLPath, X) then ExecXTree(X, procedure (n: IXMLNode)
  begin
    if n.HasAttribute(AT_ARRAY) then TZSeries.New(Self, GetPathXNode(n));
  end);
end;

procedure TFormShowArray.UpdateVXY;
 var
  dx, dy: double;
begin
  if ChartCode.Axes.Left.Items.Count >=2 then
    dy := Abs(ChartCode.Axes.Left.Items[1].Value - ChartCode.Axes.Left.Items[0].Value)
  else
    dy := 1;
  if ChartCode.Axes.Bottom.Items.Count >=2 then
    dx := Abs(ChartCode.Axes.Bottom.Items[1].Value - ChartCode.Axes.Bottom.Items[0].Value)
  else
    dx := 1;
  FVY := dy * (FProcY)/100;
  FVX := dx * (FProcX)/100;
end;

{ TZSeries }

procedure TZSeries.AddZArray(const AArray: string);
 var
  a: TArray<Double>;
  i,j,ccnt: Integer;
  c: TColor;
  function DecColor(n, dep: Integer): TColor;
   var
    r, g, b: Byte;
  begin
    r := FsaForm.clR + MulDiv(n, FclR - FsaForm.clR, dep);
    g := FsaForm.clG + MulDiv(n, FclG - FsaForm.clG, dep);
    b := FsaForm.clB + MulDiv(n, FclB - FsaForm.clB, dep);
    Result := RGB(r, g, b);
  end;
begin
  a := TPars.ArrayStrToArray(AArray);
  FLenArray := Length(a)+1;
  if FsaForm.D3View then
   begin
    UpdateDept(FsaForm.Dept-1);
    for I := 0 to Count-1 do
     begin
      XValue[i] := XValue[i] + FsaForm.FVX;
      YValue[i] := YValue[i] + FsaForm.FVY;
     end;
    ccnt := (Count div FLenArray);
    for I := 0 to ccnt-1 do
     begin
      c := DecColor(i+1, ccnt);
      for j := i*FLenArray to i*FLenArray+FLenArray-1-1 do ValueColor[j] := c;
//      ColorRange(ValuesList[0], i*FLenArray, FLenArray-1, c);
     end;
   end
  else
   begin
    Clear;
    FLineCount := 0;
   end;
  for i := 0 to FLenArray-2 do AddXY(i, a[i]);
  AddNullXY(0,0);
  Inc(FLineCount);
end;

procedure TZSeries.Loaded;
 var
  cl: TColor;
begin
  inherited;
  cl := ColorToRGB(Color);
  FclR := GetRValue(cl);
  FclG := GetGValue(cl);
  FclB := GetBValue(cl);
end;

class function TZSeries.New(ASaForm: TFormShowArray; const ATitle: string): TZSeries;
begin
  Result := TZSeries(ASaForm.ChartCode.AddSeries(TZSeries));
  with Result do
   begin
    FsaForm := ASaForm;
    Title := ATitle;
    XValues.Order := TChartListOrder.loNone;
    TreatNulls := tnDontPaint;
   end;
end;

procedure TZSeries.UpdateDept(deptcnt: Integer);
begin
  while FLineCount > deptcnt do
   begin
    Delete(0, FLenArray);
    Dec(FLineCount);
   end;
end;

initialization
  RegisterClasses([TFormShowArray, TZSeries]);
  TRegister.AddType<TFormShowArray, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormShowArray>;
end.
