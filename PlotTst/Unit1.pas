unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, CustomPlot,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.DBGrids, Vcl.Grids, Data.DB, Datasnap.DBClient, JvMemoryDataset, VirtualTrees;

type
  TForm1 = class(TForm)
    VirtualStringTree1: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
  private
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    Plot: TCustomGraph;
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
