unit VCL.GraphDataForm;

interface

uses  VCL.CustomDataForm, Container, ExtendIntf, Actns, plot.GR32, plot.Controls, Data.DB, XMLDataSet, RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RootImpl, CustomPlot;

type
  TGraphDataForm = class(TCustomFormData)
    Graph: TGraph;
    procedure GraphParamsAdded(d: TDataSet);
    procedure FormShow(Sender: TObject);
  private
    FActiveDataSetBinds: Tarray<string>;
    FC_Write: Integer;
    function IsBinded(ds: TXMLDataSet): boolean;
    procedure SetC_Write(const Value: Integer);
   const
    NICON = 135;
  protected
    procedure Loaded; override;
    class function ClassIcon: Integer; override;
  public
    [StaticAction('Новый график', 'Окна визуализации', NICON, '0:Показать.Окна визуализации')]
    class procedure DoCreateForm(Sender: IAction); override;
    property C_Write: Integer read FC_Write write SetC_Write;
  end;

implementation

{$R *.dfm}

{ TGraphDataForm }

class function TGraphDataForm.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TGraphDataForm.DoCreateForm(Sender: IAction);
 var
  gdf: TGraphDataForm;
  f: IForm;
  fe: IFormEnum;
begin
  gdf := CreateUser();
  gdf.Graph.Rows.Add<TGR32LegendRow>;
  gdf.Graph.Rows.Add<TCustomGraphDataRow>;
  gdf.Graph.Rows.Add<TCustomGraphInfoRow>;
  gdf.Graph.Columns.Add<TGR32GraphicCollumn>;
  gdf.Caption := 'График';
  f := gdf as IForm;
  if Supports(GlobalCore, IFormEnum, fe) then fe.Add(f);
  (GContainer as ITabFormProvider).Tab(f);
  f.Show;
end;

procedure TGraphDataForm.FormShow(Sender: TObject);
begin
  Graph.DeFrost;
end;

procedure TGraphDataForm.GraphParamsAdded(d: TDataSet);
begin
  if (d is TXMLDataSet) and TXMLDataSet(d).IsActive and not IsBinded(TXMLDataSet(d)) then
   begin
    Bind('C_Write', TXMLDataSet(d).FileData, ['S_Write']);
    FActiveDataSetBinds := FActiveDataSetBinds +[TXMLDataSet(d).BinFileName];
   end;
end;

function TGraphDataForm.IsBinded(ds: TXMLDataSet): boolean;
 var
  s: string;
begin
  for s in FActiveDataSetBinds do if SameText(s, ds.BinFileName) then Exit(True);
  Result := False;
end;

procedure TGraphDataForm.Loaded;
var
  c: TGraphColmn;
  p: TGraphPar;
begin
  inherited;
  Graph.PopupMenu := CreateUnLoad<TPlotMenu>;
  for c in Graph.Columns do
    for p in c.Params do GraphParamsAdded(p.Link.DataSet);
end;

procedure TGraphDataForm.SetC_Write(const Value: Integer);
begin
  FC_Write := Value;
  Graph.UpdateData;
end;

initialization
  RegisterClass(TGraphDataForm);
  TRegister.AddType<TGraphDataForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TGraphDataForm>;
end.
