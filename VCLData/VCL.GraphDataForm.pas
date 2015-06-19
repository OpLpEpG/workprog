unit VCL.GraphDataForm;

interface

uses  VCL.CustomDataForm, Container, ExtendIntf, Actns, plot.GR32,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RootImpl, CustomPlot;

type
  TGraphDataForm = class(TCustomFormData)
    Graph: TGraph;
  private
   const
    NICON = 115;
  protected
    class function ClassIcon: Integer; override;
  public
    [StaticAction('Новый график', 'Окна визуализации', NICON, '0:Показать.Окна визуализации')]
    class procedure DoCreateForm(Sender: IAction); override;
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
  gdf.Graph.Rows.Add<TCustomGraphData>;
  gdf.Graph.Rows.Add<TCustomGraphInfo>;
  gdf.Graph.Columns.Add<TGR32GraphicCollumn>;
  gdf.Caption := 'График';
  f := gdf as IForm;
  if Supports(GlobalCore, IFormEnum, fe) then fe.Add(f);
  (GContainer as ITabFormProvider).Tab(f);
  f.Show;
end;

initialization
  RegisterClass(TGraphDataForm);
  TRegister.AddType<TGraphDataForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TGraphDataForm>;
end.
