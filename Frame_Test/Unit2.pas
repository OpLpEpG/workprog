unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCLTee.Series, VCLTee.TeEngine, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrame2 = class(TFrame)
    Chart1: TChart;
    Series1: TBarSeries;
    Series2: TLineSeries;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
