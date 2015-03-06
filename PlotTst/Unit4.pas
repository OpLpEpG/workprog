unit Unit4;

interface

uses CustomPlot,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    Plot: TCustomPlot;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.Button1Click(Sender: TObject);
begin
  Plot.Columns.Add<TPlotColumn>;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  Plot := TCustomPlot.Create(Self);
  Plot.Parent := Self;
  Plot.Align := alClient;
  Button1.BringToFront;
  Plot.Rows.Add<TCustomPlotLegend>;
  Plot.Rows.Add<TCustomPlotData>;
  Plot.Rows.Add<TCustomPlotInfo>;
end;

end.
