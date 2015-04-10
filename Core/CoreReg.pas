unit CoreReg;

interface

uses System.Classes, RootImpl, Plot, Plot.DB, EditControl, OtklonitelPaintClass;//, DBGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Горизонт', [TCPageControl, TPlot, TPlotDB, TDataExchangeEdit, TOtklonitelPaint]);
end;

end.
