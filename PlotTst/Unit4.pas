unit Unit4;

interface

uses CustomPlot, System.IOUtils, Plot.GR32, gr32, DataSetIntf, Plot.Controls, LasDataSet, XMLDataSet, XMLScript.Math,
  Plot.DataSet, Xml.XMLIntf,
  RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RTTI, Container, RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB, JvMemoryDataset, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteVDataSet, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, IDataSets, JvExDBGrids, JvDBGrid;

type
  TForm4 = class(TForm, IALLMetaDataFactory, IALLMetaData)
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
    FDTable1: TFDTable;
    FDLocalSQL1: TFDLocalSQL;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
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
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    Graph: TCustomGraph;
    ids, ilds: IdataSet;
    d: IXMLDocument;
  public
    function Get(const Name: string): IALLMetaData; overload;
    function Get: IALLMetaData; overload;
    function IALLMetaData.Get = ALLMetaDataGet;
    function ALLMetaDataGet: IXMLDocument;
    procedure Save;
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

uses tools, Unit1, DlgEditParam, manager3.DataImport;

procedure TForm4.Button1Click(Sender: TObject);
 var
  c: TGraphColmn;
  p: TGraphPar;
  f: TWaveletFilter;
begin
  Graph.Frost;
  try
    c := Graph.Columns.Add<TGR32GraphicCollumn>;
    p := c.Params.Add<TLineParam>;
    p.Title := 'p1';
    p.Color := clRed32;
    p.link := TFileDataLink.Create(p);
    TFileDataLink(p.Link).FileName := 'FileName_p1';
    TFileDataLink(p.Link).XParamPath := 'X_p1';
   // TFileDataLink(p.Link).YParamPath := 'X_p1';

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


//  p := c.Params.Add<TGraphParam>;
//  p.Title := 'p2';
//  p.link := TFileDataLink.Create(p);
//  TFileDataLink(p.Link).FileName := 'FileName_p2';
//  TFileDataLink(p.Link).XParamPath := 'X_p2';
//  TFileDataLink(p.Link).YParamPath := 'X_p2';

  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  Graph.Frost;
  try
   Graph.Parent := Form1;
   Graph.Align := alClient;
   Graph.SendToBack;
   Graph.Rows.Add<TGR32LegendRow>;
   Graph.Rows.Add<TCustomGraphData>;
   Graph.Rows.Add<TCustomGraphInfo>;
  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.Button3Click(Sender: TObject);
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  Graph.Frost;
  try
   ss := TStringStream.Create;
   ms := TMemoryStream.Create;
   try
    ss.LoadFromFile(Tpath.GetDirectoryName(ParamStr(0))+'\Graph.txt');
    ss.Position := 0;
    ObjectTextToBinary(ss, ms);
    ms.Position := 0;
    ms.ReadComponent(Graph);
   finally
    ss.Free;
    ms.Free;
   end;
   Graph.SendToBack;
  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.Button4Click(Sender: TObject);
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ms.WriteComponent(Graph);
   ms.Position := 0;
   ObjectBinaryToText(ms, ss);
   ss.DataString;
   ss.SaveToFile(Tpath.GetDirectoryName(ParamStr(0))+'\Graph.txt');
  finally
   ss.Free;
   ms.Free;
  end;
end;

procedure TForm4.Button5Click(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TGraphPar>).Execute(Graph.Columns[0].Params[0]);
end;

procedure TForm4.Button6Click(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TObject>).Execute(Graph);
end;

procedure TForm4.Button7Click(Sender: TObject);
begin
  Graph.Frost;
  try
   Graph.Rows.Add<TCustomGraphInfo>;
  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.Button8Click(Sender: TObject);
begin
  Graph.Frost;
  try
   Graph.Rows.Delete(Graph.Rows.Count-1);
  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.Button9Click(Sender: TObject);
begin
  Graph.Frost;
  try
   Graph.Columns.Delete(Graph.Columns.Count-1);
  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.CheckBox1Click(Sender: TObject);
 var
  a: TArray<TGraphRow>;
  r: TGraphRow;
begin
  Graph.Frost;
  try
   a := Graph.Rows.FindRows(TCustomGraphLegend);
   for r in a do r.Visible := CheckBox1.Checked;
  finally
   Graph.DeFrost;
  end;
end;

procedure TForm4.CheckBox2Click(Sender: TObject);
 var
  a: TArray<TGraphRow>;
  r: TGraphRow;
begin
  Graph.Frost;
  Try
   a := Graph.Rows.FindRows(TCustomGraphInfo);
   for r in a do r.Visible := CheckBox2.Checked;
  Finally
   Graph.DeFrost;
  End;
end;

procedure TForm4.CheckBox3Click(Sender: TObject);
begin
  Graph.YMirror := CheckBox3.Checked;
end;

procedure TForm4.FormShow(Sender: TObject);
 var
  xds, lds: TDataSet;
  n: IXMLNode;
  i: Integer;
begin
  TXMLScriptMath.Hypot3D(1,1,1);
  FormatSettings.DecimalSeparator := '.';
  TRegister.AddType<TForm4, IALLMetaDataFactory>.LiveTime(ltSingleton).AddInstance(Self);

  TLasDataSet.New('c:\XE\Projects\Device2\VCL_Vizard_Sucop\Win32\Debug\723.las', ids);
  lds := ids.DataSet;

  d := NewXDocument();
  d.LoadFromFile('C:\Users\Public\Documents\Горизонт\WorkProg\Projects\TEST\TEST.xml');


  Form1.Show;
  Graph := Form1.Plot;

  TXMLDataSet.New(GetDevsSections(FindDevs(d.DocumentElement), T_WRK)[0], ilds, false);


//  TDebug.Log('RFS = %d   ', [ilds._AddRef -1]);
//  ilds._Release;

  xds := ilds.DataSet;
  xds.SparseArrays := True;

//  for I := 0 to xds.FieldDefList.Count-1 do xds.FieldDefList[i].Name := 'Fild'+i.ToString;


//  xds.Active := True;

 // xds.FieldDefList.SaveToFile(Tpath.GetDirectoryName(ParamStr(0))+'\xds.txt');
  //lds.ObjectView := True;

//  lds.FieldDefs.Find('Hx').Free;
//  lds.FieldDefs.Find('Hy').Free;
//  lds.FieldDefs.Find('Hz').Free;
//  lds.FieldDefs.Find('Gx').Free;
//  lds.FieldDefs.Find('Gy').Free;
//  lds.FieldDefs.Find('Gz').Free;

  FDLocalSQL1.DataSets.Add(xds, '', 'x');
  FDLocalSQL1.DataSets.Add(lds, '', 'l');

  DataSource1.DataSet := FDQuery1;
//  DataSource1.DataSet := ds;
//  DataSource1.DataSet := ms;
//  DataSource1.DataSet := xds;

  DataSource1.DataSet.Active := True;
  TDebug.Log('RFS = %d   ', [ilds._AddRef -1]);
  ilds._Release;
  DataSource1.DataSet.Refresh;
//  DataSource1.DataSet.AppendRecord([1,'1111']);
//  DataSource1.DataSet.AppendRecord([2,'1111']);
//  DataSource1.DataSet.AppendRecord([3,'1111']);
//  DataSource1.DataSet.AppendRecord([4,'1111']);
//  DataSource1.DataSet.AppendRecord([5,'1111']);
//  DataSource1.DataSet.AppendRecord([6,'1111']);
end;

function TForm4.ALLMetaDataGet: IXMLDocument;
begin
  Result := d;
end;

function TForm4.Get(const Name: string): IALLMetaData;
begin
  Result := Self;
end;

function TForm4.Get: IALLMetaData;
begin
  Result := Self;
end;

procedure TForm4.Save;
begin

end;

end.
