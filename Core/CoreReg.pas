unit CoreReg;

interface

uses System.Classes, RootImpl, Plot, Plot.DB, EditControl;//, DBGrid;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('��������', [TCPageControl, TPlot, TPlotDB, TDataExchangeEdit]);
end;

end.
