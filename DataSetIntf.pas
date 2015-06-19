unit DataSetIntf;

interface

uses RootIntf, Data.DB;

type
  IDataSet = interface(IManagItem)
  ['{62A17AE5-4665-4DB2-8CE8-2C56174B9642}']
    function GetDataSet: TDataSet;
    property DataSet: TDataSet read GetDataSet;
  end;

  IDataSetEnum = interface(IServiceManager<IDataSet>)
  ['{5CAF18C6-B981-4456-BAEE-1691DD752D6B}']
  end;

implementation

end.
