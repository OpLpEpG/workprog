unit VCL.Telesis.Decoder.FindSP_1;

interface

uses VCL.ControlRootForm, Math.Telesistem,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrameFindSP = class(TControlRootFrame<PTelesistemDecoderData>)
    Chart: TChart;
    SeriesSP: TLineSeries;
    SeriesCorr: TFastLineSeries;
  private
    { Private declarations }
  public
    procedure DoData(Data: PTelesistemDecoderData); override;
  end;

implementation

{$R *.dfm}

uses VCL.Telesis.Decoder;

{ TFrameFindSP }

procedure TFrameFindSP.DoData(Data: PTelesistemDecoderData);
 var
  d: Double;
begin
  if Data.KadrLen <> Chart.BottomAxis.Maximum then  Chart.BottomAxis.Maximum := Data.KadrLen;
  if SeriesCorr.Count >= Data.KadrLen then SeriesCorr.Clear;
  for d in Data.FindSpData^ do SeriesCorr.Add(d);
end;

end.
