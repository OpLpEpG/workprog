unit VCL.Telesis.Osc;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, JDtools, IndexBuffer,
  Winapi.Windows, Winapi.Messages, Math.Telesistem,   System.Rtti,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VCL.ControlRootForm,  Vcl.Menus,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
              //(psSolid, psDash, psDot, psDashDot, psDashDotDot, psClear, psInsideFrame, psUserStyle, psAlternate);
  [EnumCaptions('сплошная, тире, точка, точка тире, точка точка тире, чисто, рамка, пользовательск, альтерн')]
  TExPenStyle = type TPenStyle;

  TOscSeriesClass = class of TOscSeries;
  TOscSeries = class(TFastLineSeries, Icaption)
  private
    FSubControlIName: string;
    procedure SetSubControlIName(const Value: string);
    procedure SetStyle(const Value: TExPenStyle);
    procedure SetWidth(const Value: integer);
    function GetStyle: TExPenStyle;
    function GetWidth: integer;
  protected
    FC_Data: TIndexBuf;
    procedure SetC_Data(const Value: TIndexBuf); virtual;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
  public
    Chart: TChart;
    FShowIndex: Integer;
    destructor Destroy; override;
    class procedure ConnectData(Chart: TChart; SubDev: ISubDevice; Ser: TOscSeries); virtual;
    class function TryGetSeries(Chart: TChart; Value: ISubDevice; out S: TOscSeries): Boolean;
    class function TryGetSubDev(Root: IRootDevice; Series: TOscSeries; out Value: ISubDevice): Boolean;
    type
     TNeedDeleteSeries = reference to function(s: TChartSeries): Boolean;
    class procedure UpdateSeries(Root: IRootDevice; Chart: TChart; const NewSeriesClass: TOscSeriesClass; del: TNeedDeleteSeries);
    property C_Data: TIndexBuf read FC_Data write SetC_Data;
  published
    property SubControlIName: string read FSubControlIName write SetSubControlIName;
    [ShowProp('Показать')] property Visible;
    [ShowProp('Ширина линии')] property Width: integer read GetWidth write SetWidth;
    [ShowProp('Стиль штрихов')] property Style: TExPenStyle read GetStyle write SetStyle;
    [ShowProp('Цвет')] property Color;
  end;


  EoscFormErr = EBaseException;
  TOscForm = class(TCustomFontIForm, IControlForm)
    Chart: TChart;
  private
    FControlName: String;
    FpauseMenu: TMenuItem;
    function GetChartSeriesList: TChartSeriesList;
    procedure EditChart(Sender: TObject);
    procedure PauseChart(Sender: TObject);
    function GetShowLegend: Boolean;
    procedure SetShowLegend(const Value: Boolean);
    procedure SetC_Add(const Value: ISubDevice);
    procedure SetC_Remove(const Value: ISubDevice);
  protected
    procedure UpdateSeries;
    function RootDevice: IRootDevice;
    function GetControlName: String;
    procedure SetControlName(const Value: String);
    procedure Loaded; override;
    procedure DoSetFont(const AFont: TFont); override;
  public
    [ShowProp('Легенда')] property ShowLegend: Boolean read GetShowLegend write SetShowLegend;
    [ShowProp('Линии')] property Series: TChartSeriesList read GetChartSeriesList;
    property C_Add: ISubDevice write SetC_Add;
    property C_Remove: ISubDevice write SetC_Remove;
  published
    property ControlName: String read FControlName write SetControlName;
  end;

implementation

{$R *.dfm}

{ TOscForm }

procedure TOscForm.DoSetFont(const AFont: TFont);
begin
  inherited;
  Chart.BottomAxis.LabelsFont.Assign(Afont);
  Chart.LeftAxis.LabelsFont.Assign(Afont);
  Chart.Legend.Font.Assign(Afont);
end;

procedure TOscForm.EditChart(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TOscForm>).Execute(Self);
end;

function TOscForm.GetChartSeriesList: TChartSeriesList;
begin
  Result := Chart.SeriesList;
end;

function TOscForm.GetControlName: String;
begin
  Result := FControlName;
end;

function TOscForm.GetShowLegend: Boolean;
begin
  Result := chart.legend.Visible;
end;

procedure TOscForm.UpdateSeries;
 var
  d: IRootDevice;
begin
  d := RootDevice;
  if d <> nil then TOscSeries.UpdateSeries(d, Chart, TOscSeries, function (s: TChartSeries): Boolean
   var
    sd: ISubDevice;
  begin
    for sd in d.GetSubDevices do if SameText(sd.IName, (s as TOscSeries).SubControlIName) then Exit(False);
    Result := True;
  end);
end;

procedure TOscForm.Loaded;
begin
  inherited;
  AddToNCMenu('Редактировать График', EditChart);
  FpauseMenu := AddToNCMenu('Пауза', PauseChart, 0, 0);
  UpdateSeries;
  if (RootDevice = nil) and (FControlName <> '') then
   begin
    (GlobalCore as IFormEnum).Remove(Self as IForm);
    mainscreenchanged;
    raise EoscFormErr.CreateFmt('Нет Устройства "%s"',[FControlName]);
   end;
end;

procedure TOscForm.PauseChart(Sender: TObject);
begin
  Chart.Tag := Integer(FpauseMenu.checked);
end;

function TOscForm.RootDevice: IRootDevice;
 var
  ii: IInterface;
begin
  if not (GContainer.TryGetInstKnownServ(TypeInfo(IDevice), FControlName, ii) and Supports(ii, IRootDevice, Result)) then Result := nil;
end;

procedure TOscForm.SetControlName(const Value: String);
 var
  d: IRootDevice;
begin
  TbindHelper.RemoveControlExpressions(self, ['C_Add', 'C_Remove']);
  FControlName := Value;
  d := RootDevice;
  if Assigned(d) then
   begin
    if not (csLoading in ComponentState) then UpdateSeries;
    Bind('C_Add', d, ['S_Add']);
    Bind('C_Remove', d, ['S_Remove']);
   end;
end;

procedure TOscForm.SetC_Add(const Value: ISubDevice);
 var
  s: TOscSeries;
begin
  if not Supports(Value, IOscDataSubDevice) then Exit;
  if not TOscSeries.TryGetSeries(Chart, Value, s) then
   begin
    s := TOscSeries.Create(Chart);
    Chart.AddSeries(s);
   end;
  TOscSeries.ConnectData(Chart, Value, s);
end;

procedure TOscForm.SetC_Remove(const Value: ISubDevice);
 var
  S: TOscSeries;
begin
  if TOscSeries.TryGetSeries(Chart, Value, s) then s.Free;
end;

procedure TOscForm.SetShowLegend(const Value: Boolean);
begin
  chart.legend.Visible := Value;
end;

{ TOscSeries }

class procedure TOscSeries.ConnectData(Chart: TChart; SubDev: ISubDevice; Ser: TOscSeries);
 var
  s: TOscSeries;
  d: ISubDevice<TIndexBuf>;
  i: Integer;
begin
  d := SubDev as ISubDevice<TIndexBuf>;
  TBindHelper.RemoveControlExpressions(Ser, ['C_Data']);
  Ser.Chart := Chart;
  Ser.SubControlIName := SubDev.IName;
  Ser.LegendTitle := SubDev.Caption;
  Ser.FshowIndex := d.Data.LastIndex+1;
  Ser.Clear;
  for i := 0 to Round(Chart.BottomAxis.Maximum)-1 do Ser.add(0);
  TBindHelper.Bind(Ser, 'C_Data', d, ['S_Data']);
end;

destructor TOscSeries.Destroy;
begin
  TBindHelper.RemoveExpressions(Self);
  inherited;
end;

function TOscSeries.GetCaption: string;
begin
  if Assigned(FC_Data) and (FC_Data.Name <> LegendTitle) then LegendTitle := FC_Data.Name;
   Result := LegendTitle;
end;

function TOscSeries.GetStyle: TExPenStyle;
begin
  Result := Pen.Style;
end;

function TOscSeries.GetWidth: integer;
begin
  Result := Pen.Width;
end;

procedure TOscSeries.SetCaption(const Value: string);
begin
  raise Exception.Create('TOscSeries.SetCaption(const Value: string) = ''' + Value +'''');
end;

procedure TOscSeries.SetC_Data(const Value: TIndexBuf);
 var
  i: Integer;
begin
  if Chart.tag <> 0 then Exit;
  FC_Data := Value;
  if FShowIndex < FC_Data.FirstIndex then FShowIndex := FC_Data.FirstIndex;
  BeginUpdate;
  try
   while FShowIndex <= FC_Data.LastIndex do
    begin
     YValues[FShowIndex mod Count] := TIndexBufDouble(FC_Data).Data[FShowIndex];
     inc(FShowIndex);
    end;
  finally
   EndUpdate;
  end;
  Chart.Repaint;
end;

procedure TOscSeries.SetStyle(const Value: TExPenStyle);
begin
  Pen.Style := Value;
end;

procedure TOscSeries.SetSubControlIName(const Value: string);
begin
  FSubControlIName := Value;
end;

procedure TOscSeries.SetWidth(const Value: integer);
begin
  Pen.Width := Value;
end;

class function TOscSeries.TryGetSeries(Chart: TChart; Value: ISubDevice; out S: TOscSeries): Boolean;
 var
  cs: TchartSeries;
begin
  Result := False;
  for cs in Chart.SeriesList do if (cs is TOscSeries) and (TOscSeries(cs).SubControlIName = Value.IName) then
   begin
    s := TOscSeries(cs);
    Exit(True);
   end;
end;

class function TOscSeries.TryGetSubDev(Root: IRootDevice; Series: TOscSeries; out Value: ISubDevice): Boolean;
 var
  sd: ISubDevice;
begin
  Result := False;
  Value := nil;
  for sd in Root.GetSubDevices do if SameText(sd.IName, Series.SubControlIName) then
   begin
    Value := sd;
    Exit(True);
   end;
end;

class procedure TOscSeries.UpdateSeries(Root: IRootDevice; Chart: TChart; const NewSeriesClass: TOscSeriesClass; del: TNeedDeleteSeries);
 var
  ii: IInterface;
  s: ISubDevice;
  i: Integer;
  sr: TOscSeries;
begin
  // update and create not exists connections
  for s in Root.SubDevices do if Supports(s, IOscDataSubDevice) then
   begin
    if not TryGetSeries(Chart, s, sr) then
     begin
      sr := NewSeriesClass.Create(Chart);
      Chart.AddSeries(sr);
      mainscreenchanged;
     end;
    ConnectData(Chart, s, sr);
   end;
  // remove unconnected
  for i := Chart.SeriesCount-1 downto 0 do if del(Chart[i]) then
   begin
    Chart.SeriesList.Delete(i);
    mainscreenchanged;
   end;
  Chart.SeriesList.Sort( TComparer<TChartSeries>.Construct(function(const Left, Right: TChartSeries): Integer
   var
    l, r: ISubDevice;
  begin
    if (Left is TOscSeries) and (Right is TOscSeries)
       and TryGetSubDev(Root, Left as TOscSeries, l) and TryGetSubDev(Root, Right as TOscSeries, r)  then
         Result := Root.Index(l) - Root.Index(r)
    else Result := 0;
  end));
end;

initialization
  RegisterClasses([TOscForm, TOscSeries]);
  TRegister.AddType<TOscForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TOscForm>;
end.
