unit DataSetIntf;

interface

uses RootIntf, Data.DB, Xml.XMLIntf;

type
  IDataSet = interface(IManagItem)
  ['{62A17AE5-4665-4DB2-8CE8-2C56174B9642}']
    function GetDataSet: TDataSet;
    function GetTempDir: string;
    property DataSet: TDataSet read GetDataSet;
  end;

  IDataSetDef = interface
  ['{9031864C-F873-40E1-943E-9D065EEB1577}']
    function TryGet(out ids: IDataSet): Boolean;
    function CreateNew(out ids: IDataSet; UniDirectional: Boolean = True): Boolean;
  end;

//  IXMLDataSet = interface(IDataSet)
//  ['{9FA3ED03-2F98-4077-B354-83326456251A}']
//   function TryGetX(const FullName: string; out X: IXMLNode): Boolean;
//  end;

  IDataSetEnum = interface(IServiceManager<IDataSet>)
  ['{5CAF18C6-B981-4456-BAEE-1691DD752D6B}']
//    function TryFind(const FileName: string; out ds: IDataSet): Boolean;
  end;

  //TDataSetDialogEvent = reference to procedure(DataSet: IDataSet; var DataSetDef: IDataSetDef; SelectedFields: TArray<TField>);

 const
  IMPORT_DB_DIALOG_CATEGORY = 'Импорт данных';

implementation

end.
