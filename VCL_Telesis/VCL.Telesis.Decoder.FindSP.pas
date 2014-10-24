unit VCL.Telesis.Decoder.FindSP;

interface

uses VCL.ControlRootForm, Math.Telesistem,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrameFindSP = class(TControlRootFrame<TTelesistemDecoder>)
    Chart: TChart;
    SeriesSP: TLineSeries;
    SeriesCorr: TFastLineSeries;
    procedure ChartAfterDraw(Sender: TObject);
  private
    Fdata: TTelesistemDecoder;
  public
    procedure DoData(Data: TTelesistemDecoder); override;
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

  with Fdata.FindSPData do
   begin
    s := Format(FMTT, [Max1Index, Max1]);
    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), 0, s);
    s := Format(FMTT, [Max2Index, Max2]);
    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.Canvas.TextHeight(s), s);

    s := Format(FMTT, [Min2Index, Min2]);
    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.BottomAxis.PosAxis - Chart.Canvas.TextHeight(s)*2, s);
    s := Format(FMTT, [Min1Index, Min1]);
    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.BottomAxis.PosAxis - Chart.Canvas.TextHeight(s), s);
   end;
end;

procedure TFrameFindSP.DoData(Data: TTelesistemDecoder);
 var
  d: Double;
begin
  FData :=  Data;
  if Data.KadrLen <> Chart.BottomAxis.Maximum then  Chart.BottomAxis.Maximum := Data.KadrLen;
  if SeriesCorr.Count >= Data.KadrLen then SeriesCorr.Clear;
  for d in Data.FindSpData.Corr do SeriesCorr.Add(d);
  SeriesSP.Clear;
  with Fdata.FindSPData do
   begin
    SeriesSP.AddNullXY(Max1Index, 0);
    SeriesSP.AddXY(Max1Index, 0);
    SeriesSP.AddXY(Max1Index, Max1, '', clRed);
    SeriesSP.AddNullXY(Max2Index, 0);
    SeriesSP.AddXY(Max2Index, 0);
    SeriesSP.AddXY(Max2Index, Max2, '', clMaroon);
    SeriesSP.AddNullXY(Min1Index, 0);
    SeriesSP.AddXY(Min1Index, 0);
    SeriesSP.AddXY(Min1Index, Min1, '', clBlue);
    SeriesSP.AddNullXY(Min2Index, 0);
    SeriesSP.AddXY(Min2Index, 0);
    SeriesSP.AddXY(Min2Index, Min2, '', clNavy);
   end;
end;

end.
