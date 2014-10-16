unit ImportExport;

interface

uses System.SysUtils, Vcl.Dialogs, System.Variants, Xml.XMLIntf, RootImpl, debug_except;

type
  IImportExport = interface
  ['{F20F93A8-EB03-4EF4-A57A-8468F5FEF0B2}']
    function GetImportFilters: string;
    function GetExportFilters: string;
    procedure ExecuteImport(FilrerNo: Integer; const ImportFile: string; Etalon: IXMLNode);
    procedure ExecuteExport(FilrerNo: Integer; const ExportFile: string; Data: IXMLNode);
  end;

  TImportExport = class(TIObject, IImportExport)
  private
    Froot: IXMLNode;
    procedure Exec(const Section: string; FilrerNo: Integer; const TrrFile: string; Etalon: IXMLNode);
    function GetFilters(const Section: string): string;
  protected
    function GetImportFilters: string;
    function GetExportFilters: string;
    procedure ExecuteImport(FilrerNo: Integer; const ImportFile: string; Etalon: IXMLNode);
    procedure ExecuteExport(FilrerNo: Integer; const ExportFile: string; Data: IXMLNode);
  public
    constructor Create(Root: IXMLNode);
  end;

implementation

uses tools, XMLScript;

{ TImportExport }

constructor TImportExport.Create(Root: IXMLNode);
begin
  Froot := Root;
end;

function TImportExport.GetFilters(const Section: string): string;
 var
  a: IXMLNode;
  s: TXmlScript;
begin
  Result := '';
  for a in XEnumAttr(FRoot.ChildNodes[Section]) do
   begin
    s := TXmlScript.Create(nil);
    try
     s.Lines.Text := a.NodeValue;
     if not s.Compile then MessageDlg('Ошибка компиляции '+FRoot.NodeName+' '+a.NodeName+':'+s.ErrorPos, TMsgDlgType.mtError, [mbOK], 0)
     else Result := Result + '|'+ s.CallFunction('GetFilterName', 0);
    finally
     s.Free;
    end;
  end;
end;

procedure TImportExport.Exec(const Section: string; FilrerNo: Integer; const TrrFile: string; Etalon: IXMLNode);
 var
  a: IXMLNode;
  s: TXmlScript;
begin
  a := FRoot.ChildNodes[Section].AttributeNodes[Section+(FilrerNo-1).ToString];
  s := TXmlScript.Create(nil);
  try
   s.Lines.Text := a.NodeValue;
   if not s.Compile then MessageDlg('Ошибка компиляции '+FRoot.NodeName+' '+a.NodeName+':'+s.ErrorPos, TMsgDlgType.mtError, [mbOK], 0)
   else s.CallFunction('OnExecuteFilter', VarArrayOf([TrrFile, XToVar(Etalon)]));
  finally
   s.Free;
  end;
end;

procedure TImportExport.ExecuteExport(FilrerNo: Integer; const ExportFile: string; Data: IXMLNode);
begin
  Exec('EXPORT', FilrerNo, ExportFile, Data);
end;

procedure TImportExport.ExecuteImport(FilrerNo: Integer; const ImportFile: string; Etalon: IXMLNode);
begin
  Exec('IMPORT', FilrerNo, ImportFile, Etalon);
end;

function TImportExport.GetImportFilters: string;
begin
  Result := GetFilters('IMPORT');
end;

function TImportExport.GetExportFilters: string;
begin
  Result := GetFilters('EXPORT');
end;

end.
