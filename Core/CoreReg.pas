unit CoreReg;

interface

uses System.Classes, RootImpl, Plot, Plot.DB, EditControl;//, DBGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Горизонт', [TCPageControl, TPlot, TPlotDB, TDataExchangeEdit]);
end;

end.
