unit VCL.Telesis.FFT;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,  Math.Telesistem,
  Vcl.Graphics, Vcl.ExtCtrls, VCL.ControlRootForm, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  VCLTee.TeEngine, VCLTee.Series,  VCLTee.TeeProcs, VCLTee.Chart;

type
  TFFTForm = class(TControlRootForm<TFFTData, ITelesistem>)
    Chart: TChart;
    Splitter: TSplitter;
    ChartT: TChart;
    csInData: TFastLineSeries;
    scOut: TFastLineSeries;
    csBit: TFastLineSeries;
    scFFT: TAreaSeries;
    scFlt: TAreaSeries;
    csOI: TFastLineSeries;
    procedure ChartAfterDraw(Sender: TObject);
  private
    All, Signal: Double;
    FC_Bit: TUsoData;
    FC_Pals: TUsoData;
    procedure SetC_Bit(const Value: TUsoData);
    procedure SetC_Pals(const Value: TUsoData);
  protected
    procedure Loaded; override;
    procedure DoData; override;
  public
    property C_Bit: TUsoData read FC_Bit write SetC_Bit;
    property C_Pals: TUsoData read FC_Pals write SetC_Pals;
  end;

implementation

{$R *.dfm}

procedure TFFTForm.ChartAfterDraw(Sender: TObject);
 const
  FMTT = '%2.0f%%';
 var
  s: string;
begin
  if All = 0 then Exit;  
  Chart.Canvas.Font.Name := 'Courier';
  s := Format(FMTT, [100-Signal/All*100]);
  Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), 0, s);
end;

procedure TFFTForm.DoData;
begin
  scFFT.Clear;
  scFlt.Clear;
  Inc(FC_Data.FF);
  Inc(FC_Data.FFFiltered);
  Dec(FC_Data.FFTSize);
//  All := 0;
//  Signal := 0;
  while FC_Data.FFTSize > 0 do
   begin
    scFFT.Add(FC_Data.FF^);
    scFlt.Add(FC_Data.FFFiltered^);
    all := All + FC_Data.FF^;
    Signal := Signal + FC_Data.FFFiltered^;
    Inc(FC_Data.FF);
    Inc(FC_Data.FFFiltered);
    Dec(FC_Data.FFTSize);
   end;
  csInData.Clear;
  scOut.Clear;
  while FC_Data.SampleSize > 0 do
   begin
    csInData.Add(FC_Data.InData^);
    scOut.Add(FC_Data.OutData^);
    Inc(FC_Data.InData);
    Inc(FC_Data.OutData);
    Dec(FC_Data.SampleSize);
   end;
end;

{ TBitOscForm }

procedure TFFTForm.Loaded;
 var
  d: IRootDevice;
  s: ISubDevice;
  i: IInterface;
begin
  inherited;
  if GContainer.TryGetInstKnownServ(TypeInfo(IDevice), ControlName, i) and Supports(i, IRootDevice, d) then
   begin
    if ExistsSubDev(d, 'Ôèëüòðû-2', 'Ôèëüòð BIT', s) then Bind('C_Bit', s, ['S_Data']);
    if ExistsSubDev(d, 'Ôèëüòðû-2', 'Ôèëüòð ÎÈ',  s) then Bind('C_Pals', s, ['S_Data']);
   end;
end;

procedure TFFTForm.SetC_Bit(const Value: TUsoData);
begin
  FC_Bit := Value;
  csBit.Clear;
  while FC_Bit.Size > 0 do
   begin
    csBit.Add(FC_Bit.Data^);
    Inc(FC_Bit.Data);
    Dec(FC_Bit.Size);
   end;
end;

procedure TFFTForm.SetC_Pals(const Value: TUsoData);
begin
  FC_Pals := Value;
  csOI.Clear;
  while FC_Pals.Size > 0 do
   begin
    csOI.Add(FC_Pals.Data^);
    Inc(FC_Pals.Data);
    Dec(FC_Pals.Size);
   end;
end;

initialization
  RegisterClass(TFFTForm);
  TRegister.AddType<TFFTForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFFTForm>;
end.
