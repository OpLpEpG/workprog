unit VCL.TelesisRetr.FFT;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, JDtools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,  Math.Telesistem,
  Vcl.Graphics, Vcl.ExtCtrls, VCL.ControlRootForm, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Math,
  VCLTee.TeEngine, VCLTee.Series,  VCLTee.TeeProcs, VCLTee.Chart, IndexBuffer, Fifo.FFT,
  VCL.Telesis.Osc;

type
  TFFTOscSeries = class(TOscSeries)
  protected
    procedure SetC_Data(const Value: TIndexBuf); override;
  public
    class procedure ConnectData(Chart: TChart; SubDev: ISubDevice; Ser: TOscSeries); override;
  end;

  TfftRETRForm = class(TControlRootForm<TfifoFFT, ITelesistem_retr>)
    Chart: TChart;
    Splitter: TSplitter;
    ChartT: TChart;
    csInData: TFastLineSeries;
    scOut: TFastLineSeries;
    scFFT: TAreaSeries;
    scFlt: TAreaSeries;
    procedure ChartAfterDraw(Sender: TObject);
  private
    All, Signal: Double;
    procedure EditChart(Sender: TObject);
    procedure SetC_Add(const Value: ISubDevice);
    procedure SetC_Remove(const Value: ISubDevice);
    function GetChartSeriesList: TChartSeriesList;
    function GetShowLegend: Boolean;
    procedure SetShowLegend(const Value: Boolean);
  protected
    procedure UpdateSeries;
    function RootDevice: IRootDevice;
    procedure SetControlName(const AValue: String); override;
    procedure Loaded; override;
    procedure DoData; override;
  public
    [ShowProp('Легенда')] property ShowLegend: Boolean read GetShowLegend write SetShowLegend;
    [ShowProp('Линии')] property Series: TChartSeriesList read GetChartSeriesList;
    property C_Add: ISubDevice write SetC_Add;
    property C_Remove: ISubDevice write SetC_Remove;
  end;

implementation

{$R *.dfm}

procedure TfftRETRForm.ChartAfterDraw(Sender: TObject);
 const
  FMTT = '%2.0f%%';
 var
  s: string;
  df: Double;
begin
  if All = 0 then Exit;
  Chart.Canvas.Font.Name := 'Courier';
  s := Format(FMTT, [100-Signal/All*100]);
  Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), 0, s);

  df := C_Data.Faza64/2 - C_Data.Faza32;
//  dfp := C_Data.Faza64/2 + C_Data.Faza32;
//  if df<0 then df :=  df +360;
//  if df>=360 then df :=  df -360;
//  if dfp<0 then dfp :=  dfp +360;
//  if dfp>=360 then dfp :=  dfp -360;

  s := Format('F32= %1.2f, F64= %1.2f DF= %1.2f', [C_Data.Faza32, C_Data.Faza64/2, df]);
  Chart.Canvas.TextOut(0, 0, s);
end;

procedure TfftRETRForm.DoData;
 var
  i, l, h: Integer;
  s: TChartSeries;
begin
  scFFT.BeginUpdate;
  scFlt.BeginUpdate;
  try
    scFFT.Clear;
    scFlt.Clear;
    All := 0;
    Signal := 0;
    // remove offset
    { TODO : If not Renove Offset fhen i = 0}
   with FC_Data do for I := 1 to AmpLen-1 do
    begin
     scFFT.Add(AmpFF[i]);
     all := All + AmpFF[i];
     scFlt.Add(FilteredFF[i]);
     Signal := Signal + FilteredFF[i];
    end;
  finally
    scFlt.EndUpdate;
    scFFT.EndUpdate;
  end;
  for s in ChartT.SeriesList do s.BeginUpdate;
  try
   for s in ChartT.SeriesList do s.Clear;
   l := FC_Data.FirstFFTIndex;
   h := FC_Data.LastFFTIndex;
   for s in ChartT.SeriesList do
    if s = csInData then for I := l to h do s.Add(FC_Data.InputData[i])
    else if s = scOut then for I := l to h do s.Add(FC_Data.OutputData[i])
    else if s is TOscSeries then
      with TIndexBufDouble(TOscSeries(s).C_Data) do
        for I := Max(FirstIndex, l) to Min(LastIndex, h) do
         s.AddXY(i-l, Data[i])
    else raise Exception.Create('Error Message');
  finally
   for s in ChartT.SeriesList do s.EndUpdate;
  end;
end;

procedure TfftRETRForm.EditChart(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TfftRETRForm>).Execute(Self);
end;

function TfftRETRForm.GetChartSeriesList: TChartSeriesList;
begin
  Result := ChartT.SeriesList;
end;

function TfftRETRForm.GetShowLegend: Boolean;
begin
  Result := chartT.legend.Visible;
end;

{ TBitOscForm }

procedure TfftRETRForm.Loaded;
begin
  inherited;
  AddToNCMenu('Редактировать График', EditChart);
  UpdateSeries;
  if (RootDevice = nil) and (ControlName <> '') then
   begin
    (GlobalCore as IFormEnum).Remove(Self as IForm);
    mainscreenchanged;
    raise EoscFormErr.CreateFmt('Нет Устройства "%s"',[ControlName]);
   end;
end;

function TfftRETRForm.RootDevice: IRootDevice;
 var
  ii: IInterface;
begin
  if not (GContainer.TryGetInstKnownServ(TypeInfo(IDevice), ControlName, ii) and Supports(ii, IRootDevice, Result)) then Result := nil;
end;

procedure TfftRETRForm.SetControlName(const AValue: String);
 var
  d: IRootDevice;
begin
  TbindHelper.RemoveControlExpressions(self, ['C_Add', 'C_Remove']);
  inherited;
  d := RootDevice;
  if Assigned(d) then
   begin
    if not (csLoading in ComponentState) then UpdateSeries;
    Bind('C_Add', d, ['S_Add']);
    Bind('C_Remove', d, ['S_Remove']);
   end;
end;

procedure TfftRETRForm.SetC_Add(const Value: ISubDevice);
 var
  s: TFFTOscSeries;
begin
  if not Supports(Value, IOscDataSubDevice) then Exit;
  if not TFFTOscSeries.TryGetSeries(ChartT, Value, TOscSeries(s)) then
   begin
    s := TFFTOscSeries.Create(ChartT);
    ChartT.AddSeries(s);
   end;
  TFFTOscSeries.ConnectData(ChartT, Value, s);
end;

procedure TfftRETRForm.SetC_Remove(const Value: ISubDevice);
 var
  S: TOscSeries;
begin
  if TOscSeries.TryGetSeries(ChartT, Value, s) then s.Free;
end;

procedure TfftRETRForm.SetShowLegend(const Value: Boolean);
begin
  chartT.legend.Visible := Value;
end;

procedure TfftRETRForm.UpdateSeries;
 var
  d: IRootDevice;
begin
  d := RootDevice;
  if d <> nil then TFFTOscSeries.UpdateSeries(d, ChartT, TFFTOscSeries, function (s: TChartSeries): Boolean
   var
    sd: ISubDevice;
  begin
    if (s = csInData) or (s = scOut) then Exit(False);
    for sd in d.GetSubDevices do if (s is TOscSeries) and SameText(sd.IName, (s as TOscSeries).SubControlIName) then Exit(False);
    Result := True;
  end);
  ChartT.SeriesList.Move(ChartT.SeriesList.IndexOf(csInData), 0);
  ChartT.SeriesList.Move(ChartT.SeriesList.IndexOf(scOut), 1);
end;

{ TFFTOscSeries }

class procedure TFFTOscSeries.ConnectData(Chart: TChart; SubDev: ISubDevice; Ser: TOscSeries);
begin
  if not (Ser is TOscSeries) then Exit;
  Ser.Chart := Chart;
  Ser.SubControlIName := SubDev.IName;
  Ser.LegendTitle := SubDev.Caption;
  Ser.C_Data := (SubDev as ISubDevice<TIndexBuf>).Data;
  Ser.FshowIndex := Ser.C_Data.LastIndex+1;
  Ser.Clear;
end;

procedure TFFTOscSeries.SetC_Data(const Value: TIndexBuf);
begin
  FC_Data := Value;
end;

initialization
  RegisterClasses([TfftRETRForm, TFFTOscSeries]);
  TRegister.AddType<TfftRETRForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TfftRETRForm>;
end.
