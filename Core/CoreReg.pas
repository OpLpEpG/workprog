unit CoreReg;

interface

uses System.Classes, RootImpl, Plot, Plot.DB, EditControl, OtklonitelPaintClass, CustomPlot, DataImportImpl;//, DBGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Горизонт', [TCPageControl, TPlot, TPlotDB, TDataExchangeEdit, TOtklonitelPaint, TGraph]);
end;

end.
