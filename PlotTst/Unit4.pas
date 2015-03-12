unit Unit4;

interface

uses CustomPlot, System.IOUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
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
  Plot.Repaint;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  Plot.Parent := Self;
  Plot.Align := alClient;
  Plot.SendToBack;
  Plot.Rows.Add<TCustomPlotLegend>;
  Plot.Rows.Add<TCustomPlotData>;
  Plot.Rows.Add<TCustomPlotInfo>;
end;

procedure TForm4.Button3Click(Sender: TObject);
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ss.LoadFromFile(Tpath.GetDirectoryName(ParamStr(0))+'\plot.txt');
   ss.Position := 0;
   ObjectTextToBinary(ss, ms);
   ms.Position := 0;
   ms.ReadComponent(Plot);
  finally
   ss.Free;
   ms.Free;
  end;
  Plot.SendToBack;
  Plot.Repaint;
end;

procedure TForm4.Button4Click(Sender: TObject);
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ms.WriteComponent(Plot);
   ms.Position := 0;
   ObjectBinaryToText(ms, ss);
   ss.DataString;
   ss.SaveToFile(Tpath.GetDirectoryName(ParamStr(0))+'\plot.txt');
  finally
   ss.Free;
   ms.Free;
  end;
end;

procedure TForm4.CheckBox1Click(Sender: TObject);
 var
  a: TArray<TPlotRow>;
  r: TPlotRow;
begin
  a := Plot.Rows.FindRows(TCustomPlotLegend);
  for r in a do r.Visible := CheckBox1.Checked;
  Plot.Repaint;
end;

procedure TForm4.CheckBox2Click(Sender: TObject);
 var
  a: TArray<TPlotRow>;
  r: TPlotRow;
begin
  a := Plot.Rows.FindRows(TCustomPlotInfo);
  for r in a do r.Visible := CheckBox2.Checked;
  Plot.Repaint;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  Plot := TPlot.Create(Self);
end;

end.
