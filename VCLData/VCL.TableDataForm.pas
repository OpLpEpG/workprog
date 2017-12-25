unit VCL.TableDataForm;

interface

uses IDataSets, Vcl.ActnList, debug_except, Xml.XMLIntf,
     VCL.CustomDataForm, Container, ExtendIntf, Actns, plot.GR32, plot.Controls, Data.DB, XMLDataSet, RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RootImpl, CustomPlot, Vcl.Grids, Vcl.DBGrids;

type
  TTableDataForm = class(TCustomFormData)
    Grid: TDBGrid;
    ds: TDataSource;
  private
    FDataSetFactory: TDataSetFactory;
    FC_Write: Integer;
    procedure SetC_Write(const Value: Integer);
   const
    NICON = 133;
    class procedure Act1Click(Sender: TObject);
    procedure SetBind;
    procedure SetDataSetFactory(const Value: TDataSetFactory);
    { Private declarations }
  protected
    procedure Loaded; override;
    class function ClassIcon: Integer; override;
  public
    class var SubActions: TArray<IAction>;
    constructor Create; override;
    destructor Destroy; override;
    [StaticAction('Новая таблица', 'Окна визуализации', NICON, '0:Показать.Окна визуализации','',False,False,0,True,True)]
    class procedure DoUpdate(Sender: IAction);
    property C_Write: Integer read FC_Write write SetC_Write;
  published
    property DataSetFactory: TDataSetFactory read FDataSetFactory write SetDataSetFactory;
  end;

implementation

{$R *.dfm}

uses tools;

type
  TxmlAct = class(TICustomAction)
    XmlSection: IXMLNode;
  end;

{ TTableDataForm }

class procedure TTableDataForm.Act1Click(Sender: TObject);
 var
  dsdef: TXMLDataSetDef;
  gdf: TTableDataForm;
  f: IForm;
  fe: IFormEnum;
begin
  if Sender is TxmlAct then
   begin
    dsdef := TXMLDataSetDef.CreateUser(TxmlAct(Sender).XmlSection, True);
    if Assigned(dsdef) then
     begin
      gdf := CreateUser();
      f := gdf as IForm; // Сразу создать интерфейс для самоуничтожения формы если ошибки
      gdf.DataSetFactory := TDataSetFactory.CreateUser(dsdef);
      gdf.Caption := 'Таблица '+dsdef.Section+' ' + dsdef.ModulName;
      if Supports(GlobalCore, IFormEnum, fe) then fe.Add(f);
      (GContainer as ITabFormProvider).Tab(f);
      f.Show;
     end;    
   end;  
end;

class function TTableDataForm.ClassIcon: Integer;
begin
  Result := NICON;
end;

constructor TTableDataForm.Create;
begin
  FDataSetFactory := TDataSetFactory.Create;
  inherited;
end;

destructor TTableDataForm.Destroy;
begin
  FDataSetFactory.Free;
  inherited;
end;

class procedure TTableDataForm.DoUpdate(Sender: IAction);
 const
  SWRK = 'Данные Информации';
  SRAM = 'Данные Памяти';
  SPATH = '0:Показать.Окна визуализации.Новая таблица';
  procedure AddMenu(n: IXMLNode; const subpath: string);
   var
    xa: TxmlAct;
    ia: IAction;
  begin
    xa := TxmlAct.CreateUser(ActionAttribute.Create(n.ParentNode.NodeName, 'Окна визуализации', NICON, SPATH+'.'+subpath));
    xa.XmlSection := n;
    xa.OnExecute := Act1Click;
    ia := xa as IAction;
    ia.DefaultShow;
    SubActions := SubActions +[ia];
  end;
 var
  w,r: IAction;
  n: IXMLNode;
  devs: TArray<IXMLNode>;
begin
  SetLength(SubActions, 0); // = Sender.ChildMenuItems.Clear;
  w := TxmlAct.CreateUser(ActionAttribute.Create(SWRK, 'Окна визуализации', NICON, SPATH));
  r := TxmlAct.CreateUser(ActionAttribute.Create(SRAM, 'Окна визуализации', NICON, SPATH));
  SubActions := SubActions +[w, r];
  w.DefaultShow;
  r.DefaultShow;
  devs := FindDevs((GContainer as IALLMetaDataFactory).Get.Get.DocumentElement);
  for n in GetDevsSections(devs, T_WRK) do AddMenu(n, SWRK);
  for n in GetDevsSections(devs, T_RAM) do AddMenu(n, SRAM);
end;

procedure TTableDataForm.Loaded;
begin
  inherited;
  SetBind;
end;

procedure TTableDataForm.SetBind;
begin
  if Assigned(DataSetFactory) then
   begin
    if (DataSetFactory.DataSet is TXMLDataSet) and TXMLDataSet(DataSetFactory.DataSet).IsActive then
     begin
      Bind('C_Write', TXMLDataSet(DataSetFactory.DataSet).FileData, ['S_Write']);
     end;
    ds.DataSet := DataSetFactory.DataSet;
    ds.DataSet.Open;
   end;
end;

procedure TTableDataForm.SetC_Write(const Value: Integer);
begin
  FC_Write := Value;
  ds.DataSet.Last;
end;

procedure TTableDataForm.SetDataSetFactory(const Value: TDataSetFactory);
begin
  if Assigned(FDataSetFactory) then FDataSetFactory.Free;
  FDataSetFactory := Value;
  SetBind;
end;

initialization
  RegisterClass(TTableDataForm);
  TRegister.AddType<TTableDataForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TTableDataForm>;
end.
