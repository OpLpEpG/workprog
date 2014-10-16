unit FrameInclinGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, VCLTee.TeEngine, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs,
  VCLTee.Chart;

type
  TFrmInclinGraph = class(TFrame)
    sb: TStatusBar;
    cht: TChart;
    srData: TLineSeries;
    srIst: TLineSeries;
    srErrSin: TLineSeries;
    srErr: TLineSeries;
  end;

implementation

{$R *.dfm}

end.
