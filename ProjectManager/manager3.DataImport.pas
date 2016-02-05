unit manager3.DataImport;

interface

uses DataSetIntf, ExtendIntf, CustomPlot, Container, FileDataSet,
     System.SysUtils, Xml.XMLIntf;
                       // WRK RAM  GLU                  //TFileDataSet
procedure CreateDataSet(RootSection: IXMLNode; out DataSet: IDataSet);
                                                            // TFileDataSet
procedure CreatePlotParam(col: TGraphColmn; Node: IXMLNode; DataSet: IDataSet; out PlotParam: TGraphPar);

implementation

uses tools;
                      // WRK RAM GLU
procedure CreateDataSet(RootSection: IXMLNode; out DataSet: IDataSet);
 var
  ds: TFileDataSet;
  flName: string;
  rootrModul: string;
begin
  if not ((RootSection.NodeName = T_WRK)
       or (RootSection.NodeName = T_RAM)
       or (RootSection.NodeName = 'GLU')) then raise Exception.Create('Error Message');
  if not RootSection.HasAttribute(AT_FILE_NAME) then raise Exception.Create('Error Message');
  flName := RootSection.Attributes[AT_FILE_NAME];
  if not FileExists(flName) then raise Exception.Create('Error Message');
  rootrModul := RootSection.ParentNode.NodeName;
  TFileDataSet.New(flName, DataSet);
  ds := TFileDataSet(DataSet);
  ExecXTree(RootSection, procedure(n: IXMLNode)
  begin

  end);
end;
                                                            // TFileDataSet
procedure CreatePlotParam(col: TGraphColmn; Node: IXMLNode; DataSet: IDataSet; out PlotParam: TGraphPar);
begin

end;

end.
