unit Unit1;

interface

uses Plot.Controls,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, CustomPlot,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.DBGrids, Vcl.Grids, Data.DB, Datasnap.DBClient, JvMemoryDataset;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    Plot: TGraph;
    Popup: TPlotMenu;
    procedure OnData(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses Unit4;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Plot := TGraph.Create(Self);
  Plot.OnDataAdded := OnData;
  Popup := TPlotMenu.Create(Self);
  Plot.PopupMenu := Popup;
//  Form4.Button3Click(Self);
end;

procedure TForm1.OnData(Sender: TObject);
begin
  Plot.UpdateData;
  Plot.Repaint;
end;

procedure TForm1.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

end.
