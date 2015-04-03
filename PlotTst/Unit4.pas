unit Unit4;

interface

uses CustomPlot, System.IOUtils, Plot.GR32, gr32,
  Plot.DataSet,
  RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RTTI, Container, RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, JvMemoryDataset;

type
  TForm4 = class(TForm)
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button1: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox3: TCheckBox;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    ms: TJvMemoryData;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Plot: TCustomPlot;
    ds: TplotDataSet;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

uses DlgEditParam, Unit1;

procedure TForm4.Button1Click(Sender: TObject);
 var
  c: TPlotColumn;
  p: TPlotParam;
  f: TWaveletFilter;
begin
  c := Plot.Columns.Add<TGR32GraphicCollumn>;
  p := c.Params.Add<TLineParam>;
  p.Title := 'p1';
  p.Color := clRed32;
  p.link := TFileDataLink.Create(p);
  TFileDataLink(p.Link).FileName := 'FileName_p1';
  TFileDataLink(p.Link).XParamPath := 'X_p1';
  TFileDataLink(p.Link).YParamPath := 'X_p1';

  f := P.Filters.Add<TWaveletFilter>;
  f.DisplayName := 'ParamFilter_1';
  f := P.Filters.Add<TWaveletFilter>;
  f.DisplayName := 'ParamFilter_2';

  p := c.Params.Add<TLineParam>;
  p.Title := 'p2';
  p.Color := clBlue32;
  p := c.Params.Add<TLineParam>;
  p.Title := 'p3';
  p.Color := clGreen32;
  p := c.Params.Add<TLineParam>;
  p.Title := 'p4';
  p.Color := clTeal32;
  p := c.Params.Add<TLineParam>;
  p.Title := 'p5';
  p.Color := clAqua32;


//  p := c.Params.Add<TPlotParam>;
//  p.Title := 'p2';
//  p.link := TFileDataLink.Create(p);
//  TFileDataLink(p.Link).FileName := 'FileName_p2';
//  TFileDataLink(p.Link).XParamPath := 'X_p2';
//  TFileDataLink(p.Link).YParamPath := 'X_p2';
  Plot.Repaint;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  Plot.Parent := Form1;
  Plot.Align := alClient;
  Plot.SendToBack;
  Plot.Rows.Add<TGR32LegendRow>;
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

procedure TForm4.Button5Click(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TPlotParam>).Execute(Plot.Columns[0].Params[0]);
end;

procedure TForm4.Button6Click(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TObject>).Execute(Plot);
end;

procedure TForm4.CheckBox1Click(Sender: TObject);
 var
  a: TArray<TPlotRow>;
  r: TPlotRow;
begin
  a := Plot.Rows.FindRows(TCustomPlotLegend);
  for r in a do r.Visible := CheckBox1.Checked;
end;

procedure TForm4.CheckBox2Click(Sender: TObject);
 var
  a: TArray<TPlotRow>;
  r: TPlotRow;
begin
  a := Plot.Rows.FindRows(TCustomPlotInfo);
  for r in a do r.Visible := CheckBox2.Checked;
end;

procedure TForm4.CheckBox3Click(Sender: TObject);
begin
  Plot.YMirror := CheckBox3.Checked;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
  Form1.Show;
  Plot := Form1.Plot;
  ds := TplotDataSet.Create(Plot);
//  DataSource1.DataSet := ds;
  DataSource1.DataSet := ms;
  DataSource1.DataSet.Active := True;
  DataSource1.DataSet.Refresh;
//  DataSource1.DataSet.AppendRecord([1,'1111']);
//  DataSource1.DataSet.AppendRecord([2,'1111']);
//  DataSource1.DataSet.AppendRecord([3,'1111']);
//  DataSource1.DataSet.AppendRecord([4,'1111']);
//  DataSource1.DataSet.AppendRecord([5,'1111']);
//  DataSource1.DataSet.AppendRecord([6,'1111']);
end;

end.
