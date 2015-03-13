unit Unit4;

interface

uses CustomPlot, System.IOUtils,
  RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RTTI, Container, RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm4 = class(TForm)
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button1: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    Plot: TCustomPlot;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

uses DlgEditParam;

procedure TForm4.Button1Click(Sender: TObject);
 var
  c: TPlotColumn;
  p: TPlotParam;
begin
  c := Plot.Columns.Add<TPlotColumn>;
  p := c.Params.Add<TPlotParam>;
  p.Title := 'p1';
  p.link := TFileDataLink.Create(p);
  TFileDataLink(p.Link).FileName := 'FileName_p1';
  TFileDataLink(p.Link).XParamPath := 'X_p1';
  TFileDataLink(p.Link).YParamPath := 'X_p1';
  p := c.Params.Add<TPlotParam>;
  p.Title := 'p2';
//  p.link := TFileDataLink.Create(p);
//  TFileDataLink(p.Link).FileName := 'FileName_p2';
//  TFileDataLink(p.Link).XParamPath := 'X_p2';
//  TFileDataLink(p.Link).YParamPath := 'X_p2';
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

procedure TForm4.Button5Click(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TPlotParam>).Execute(Plot.Columns[0].Params[0]);
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
