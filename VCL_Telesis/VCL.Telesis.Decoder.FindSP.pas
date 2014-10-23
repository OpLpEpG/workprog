unit VCL.Telesis.Decoder.FindSP;

interface

uses VCL.ControlRootForm, Math.Telesistem,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrameFindSPAbstr = TControlRootFrame<PTelesistemDecoderData>;

  TFrameFindSP = class(TFrameFindSPAbstr)
    Chart: TChart;
    SeriesSP: TLineSeries;
    SeriesCorr: TFastLineSeries;
    procedure ChartAfterDraw(Sender: TObject);
  private
    Fdata: PTelesistemDecoderData;
  public
    procedure DoData(Data: PTelesistemDecoderData); override;
  end;

implementation

{$R *.dfm}

{ TFrame1 }

procedure TFrameFindSP.ChartAfterDraw(Sender: TObject);
 const
  FMTT = '%4d:%7.1f';
 var
  s: string;
begin
  if not Assigned(FData) then Exit;
  Chart.Canvas.Font.Name := 'Courier';

  s := Format(FMTT, [FData.Max1Index, FData.Max1]);
  Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), 0, s);
  s := Format(FMTT, [FData.Max2Index, FData.Max2]);
  Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.Canvas.TextHeight(s), s);

  s := Format(FMTT, [FData.Min2Index, FData.Min2]);
  Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.BottomAxis.PosAxis - Chart.Canvas.TextHeight(s)*2, s);
  s := Format(FMTT, [FData.Min1Index, FData.Min1]);
  Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.BottomAxis.PosAxis - Chart.Canvas.TextHeight(s), s);
end;

procedure TFrameFindSP.DoData(Data: PTelesistemDecoderData);
 var
  d: Double;
begin
  FData :=  Data;
  if Data.KadrLen <> Chart.BottomAxis.Maximum then  Chart.BottomAxis.Maximum := Data.KadrLen;
  if SeriesCorr.Count >= Data.KadrLen then SeriesCorr.Clear;
  for d in Data.FindSpData^ do SeriesCorr.Add(d);
  SeriesSP.Clear;
  SeriesSP.AddNullXY(Data.Max1Index, 0);
  SeriesSP.AddXY(Data.Max1Index, 0);
  SeriesSP.AddXY(Data.Max1Index, Data.Max1, '', clRed);
  SeriesSP.AddNullXY(Data.Max2Index, 0);
  SeriesSP.AddXY(Data.Max2Index, 0);
  SeriesSP.AddXY(Data.Max2Index, Data.Max2, '', clMaroon);
  SeriesSP.AddNullXY(Data.Min1Index, 0);
  SeriesSP.AddXY(Data.Min1Index, 0);
  SeriesSP.AddXY(Data.Min1Index, Data.Min1, '', clBlue);
  SeriesSP.AddNullXY(Data.Min2Index, 0);
  SeriesSP.AddXY(Data.Min2Index, 0);
  SeriesSP.AddXY(Data.Min2Index, Data.Min2, '', clNavy);

  Chart.Canvas.TextOut(100, 100, Format('max %d %1.1f ',[Data.Max1Index, Data.Max1]));
end;

end.
