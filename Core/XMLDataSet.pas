unit XMLDataSet;

interface

//{$DEFINE USE_VTARRAY}

uses ExtendIntf, DataSetIntf, Container, debug_except, XMLScript, Parser,  JDtools,
     Xml.XMLIntf,  System.IOUtils,
     System.Classes, sysutils, Data.DB, IDataSets, FileDataSet;

type
  TXMLDataSetDef = class(TIDataSetDef)
  private
    FObjectFields: Boolean;
    FModul: Integer;
    FDevice: string;
    FSection: string;
    FXMLFileName: string;
    FModulName: string;
    FExist: Boolean;
    procedure SetObjectFields(const Value: Boolean);
    function GetPath: string;
    function GetBinFileName: string;
    function TryGetSection(out n: IXMLNode): Boolean;
  public
    constructor CreateUser(AXMLSection: IXMLNode; AObjectFields: Boolean);
    function TryGet(out ids: IDataSet): Boolean; override;
    function CreateNew(out ids: IDataSet; UniDirectional: Boolean = True): Boolean; override;
    [ShowProp('Путь', True)] property Path: string read GetPath;
    [ShowProp('BIN файл', True)] property BINFileName: string read GetBinFileName;
  published
    property Device: string read FDevice write FDevice;
    property ModulAdress: Integer read FModul write FModul;
    property ModulName: string read FModulName write FModulName;
    property Section: string read FSection write FSection;
    [ShowProp('XML файл', True)] property XMLFileName: string read FXMLFileName write FXMLFileName;
    [ShowProp('Объектные поля')] property ObjectFields: Boolean read FObjectFields write SetObjectFields;
  end;

  TXMLDataSet = class(TFileDataSet{, IXMLDataSet})
  public
   type
    TInternalCalcData = record
     Data: IXMLNode;
     Offset: Integer;
     constructor Create(AOffset: Integer; AData: IXMLNode);
    end;
  private
    FDevice: string;
    FSection: string;
    FModul: Integer;
    FXMLFileName: string;
    FXMLSection: IXMLNode;
    FScript: TXmlScript;
    FInternalCalcData: TArray<TInternalCalcData>;
//    FInternalCalcDataLen: Word; // syka abto sozdaetca
    function GetXMLSection: IXMLNode;
    function GetScript: TXmlScript;
    function GetInternalCalcDataLen: Word; inline;
    function GetIsActive: Boolean;
  protected
    function GetTempDir: string; override;
    function InternalCalcRecBuffer(Buffer: PRecBuffer): Boolean; override;
  public
    procedure CreateFieldDefs(AXMLSection: IXMLNode; AObjectFields: Boolean);
                    // WRK RAM  GLU            //TXMLDataSet
    class procedure Get(RootSection: IXMLNode; out DataSet: IDataSet; ObjectFields: Boolean = True); overload;
    class procedure CreateNew(RootSection: IXMLNode; out DataSet: IDataSet; ObjectFields: Boolean = True); overload;

    function TryGetX(const FullName: string; out X: IXMLNode): Boolean;

    property IsActive: Boolean read GetIsActive;
    property XMLSection: IXMLNode read GetXMLSection;
    property Script: TXmlScript read GetScript;
// published неподдерживаются
  public
    property Device: string read FDevice;// write FDevice;
    property ModulAdress: Integer read FModul;// write FModul;
    property Section: string read FSection;// write FSection;
    property XMLFileName: string read FXMLFileName;// write FXMLFileName;
    property CalcDataLen: Word read GetInternalCalcDataLen;// write FInternalCalcDataLen;
  end;


implementation

uses tools;

{ TXMLDataSetDef }

function TXMLDataSetDef.CreateNew(out ids: IDataSet; UniDirectional: Boolean): Boolean;
 var
  n: IXMLNode;
begin
  ids := nil;
  if not TryGetSection(n) then Exit(False);
  TXMLDataSet.CreateNew(n, ids, ObjectFields);
  Result := Assigned(ids);
  FExist := Result;
  if Result then TXMLDataSet(ids.DataSet).SetUniDirectional(UniDirectional);
end;

constructor TXMLDataSetDef.CreateUser(AXMLSection: IXMLNode; AObjectFields: Boolean);
begin
  ObjectFields := AObjectFields;
  FSection := AXMLSection.NodeName;
  FXMLFileName := AXMLSection.OwnerDocument.FileName;
  FModul := AXMLSection.ParentNode.Attributes[AT_ADDR];
  FModulName := AXMLSection.ParentNode.NodeName;
  FDevice := AXMLSection.ParentNode.ParentNode.NodeName;
end;

function TXMLDataSetDef.TryGet(out ids: IDataSet): Boolean;
 var
  n: IXMLNode;
begin
  ids := nil;
  if not TryGetSection(n) then Exit(False);
  TXMLDataSet.Get(n, ids, ObjectFields);
  Result := Assigned(ids);
  FExist := Result;
end;

function TXMLDataSetDef.TryGetSection(out n: IXMLNode): Boolean;
begin
  n := GetIDeviceMeta((GContainer as IALLMetaDataFactory).Get(XMLFileName).Get, Device);
  if not Assigned(n) then Exit(False);
  n := FindDev(n, ModulAdress);
  if not Assigned(n) then Exit(False);
  n := n.ChildNodes.FindNode(Section);
  if not Assigned(n) then Exit(False);
  Result := True;
end;

function TXMLDataSetDef.GetBinFileName: string;
 var
  n: IXMLNode;
  pdf: IProjectDataFile;
begin
  if not Supports(GContainer, IProjectDataFile, pdf) then raise Exception.Create('Error IProjectDataFile не поддерживается');
  n := GetIDeviceMeta((GContainer as IALLMetaDataFactory).Get(XMLFileName).Get, Device);
  if not Assigned(n) then Exit('');
  n := FindDev(n, ModulAdress);
  if not Assigned(n) then Exit('');
  n := n.ChildNodes.FindNode(Section);
  if not Assigned(n) or not n.HasAttribute(AT_FILE_NAME) then Exit('')
  else Result := pdf.ConstructDataDir(n) + n.Attributes[AT_FILE_NAME];
end;

function TXMLDataSetDef.GetPath: string;
begin
  Result := Format('%s.%s[%d].%s',[Device, ModulName, ModulAdress, Section])
end;

procedure TXMLDataSetDef.SetObjectFields(const Value: Boolean);
 var
  ids: IDataSet;
begin
  if FObjectFields <> Value then
   begin
    FObjectFields := Value;
    if FExist then TryGet(ids);
   end;
end;


{ TXMLDataSet.TInternalCalcData }

constructor TXMLDataSet.TInternalCalcData.Create(AOffset: Integer; AData: IXMLNode);
begin
  Data := AData;
  Offset := AOffset;
end;

{ TXMLDataSet }

class procedure TXMLDataSet.CreateNew(RootSection: IXMLNode; out DataSet: IDataSet; ObjectFields: Boolean);
 var
  pdf: IProjectDataFile;
begin
  if not Supports(GContainer, IProjectDataFile, pdf) then raise Exception.Create('Error IProjectDataFile не поддерживается');
  inherited CreateNew(pdf.ConstructDataDir(RootSection) + RootSection.Attributes[AT_FILE_NAME], RootSection.Attributes[AT_SIZE], DataSet);
  with TXMLDataSet(DataSet.DataSet) do CreateFieldDefs(RootSection, ObjectFields);
end;

class procedure TXMLDataSet.Get(RootSection: IXMLNode; out DataSet: IDataSet; ObjectFields: Boolean);
 var
  pdf: IProjectDataFile;
begin
  if not Supports(GContainer, IProjectDataFile, pdf) then raise Exception.Create('Error IProjectDataFile не поддерживается');
  inherited Get(pdf.ConstructDataDir(RootSection) + RootSection.Attributes[AT_FILE_NAME], RootSection.Attributes[AT_SIZE], DataSet);
  if not (DataSet.DataSet is TXMLDataSet) then raise Exception.Create('DataSet is not TXMLDataSet');
  with TXMLDataSet(DataSet.DataSet) do if (FieldDefs.Count = 0) or (ObjectFields <> ObjectView) then CreateFieldDefs(RootSection, ObjectFields);
end;

function TXMLDataSet.GetInternalCalcDataLen: Word;
begin
  Result := FInternalCalcDataLen;
end;

function TXMLDataSet.GetIsActive: Boolean;
begin
  Result := (Section = T_WRK) and (XMLFileName = (GContainer as IALLMetaDataFactory).Get.Get.FileName)
end;

function TXMLDataSet.TryGetX(const FullName: string; out X: IXMLNode): Boolean;
  function RemoveRoot(const s: string): string;
  begin
   if s.Contains('.') then Result := s.Remove(0, s.IndexOf('.')+1)
   else Result := s;
  end;
begin
  Result := tools.TryGetX(FXMLSection, RemoveRoot(FullName), X);
end;

procedure TXMLDataSet.CreateFieldDefs(AXMLSection: IXMLNode; AObjectFields: Boolean);
 var
  RootName: string;
  ClcOffset: Word;
  procedure AddFieldDef(n: IXMLNode; fs: TFieldDefs);
   var
    f: TFileFieldDef;
    sz, aq, off, arsz: Integer;
    ft: TFieldType;
  begin
    f := TFileFieldDef(fs.AddFieldDef);

    sz := TPars.VarTypeToLength(n.Attributes[AT_TIP]);
    ft := TPars.VarTypeToDBField(n.Attributes[AT_TIP]);
    if n.HasAttribute(AT_AQURICY) then aq := n.Attributes[AT_AQURICY] else aq := 0;

    // смещение в файловом буфере
    if n.HasAttribute(AT_INDEX) then off := n.Attributes[AT_INDEX]
    else if n.NodeName = T_CLC then
      begin
     // смещение в буфере DataSet
       off := ClcOffset;
       inc(ClcOffset, sz);
       f.CalcField := True;
      end
      // ХЗ
    else off := 0;

    if AObjectFields then f.Name := n.NodeName else f.Name := RootName+'.'+GetPathXNode(n);
    f.DataType := ft;
    f.DataOffset := off;
    f.Precision := aq;

    if n.ParentNode.HasAttribute(AT_ARRAY) then
     begin
      arsz := n.ParentNode.Attributes[AT_ARRAY];
     {$IFDEF  USE_VTARRAY}
      f.DataType := ftArray;
      f.Size := arsz;
      for i := 0 to arsz-1 do with TFileFieldDef(f.ChildDefs.AddFieldDef) do
       begin
        DataType := ft;
        DataOffset := off + sz*i;
        Precision := aq;
       end;
     {$ELSE}
      f.DataType := ftBlob;
      f.Size := arsz*sz;
     {$ENDIF}
      f.ArraySize := arsz;
      f.ArrayType := n.Attributes[AT_TIP];
     end;
  end;
  procedure recur(n: IXMLNode; fs: TFieldDefs);
   var
    fsc: TFieldDefs;
    m: IXMLNode;
  begin
   if n.HasAttribute(AT_TIP) then
    begin
     if (n.NodeName = T_CLC) or ((n.NodeName = T_DEV) and n.HasAttribute(AT_INDEX)) {нужно ли строгое условие ?} then AddFieldDef(n, fs);
    end
   else
    begin
     if AObjectFields then with fs.AddFieldDef do
      begin
        Name := n.NodeName;
        DataType := ftADT;
        fsc := ChildDefs;
      end
     else fsc := fs;
     for m in XEnum(n) do recur(m, fsc);
    end;
  end;
   var
    m: IXMLNode;
    fsc: TFieldDefs;
begin
  Close;
  Fields.Clear;
  FieldDefs.Clear;
  FXMLSection := nil;
  ClcOffset := 0;

  ObjectView := AObjectFields;

  FSection := AXMLSection.NodeName;
//  BinFileName := AXMLSection.Attributes[AT_FILE_NAME];
//  RecordLength := AXMLSection.Attributes[AT_SIZE];
  FXMLFileName := AXMLSection.OwnerDocument.FileName;
  FModul := AXMLSection.ParentNode.Attributes[AT_ADDR];
  RootName := AXMLSection.ParentNode.NodeName;
  FDevice := AXMLSection.ParentNode.ParentNode.NodeName;

  FieldDefs.Add('ID', ftInteger);
  if AObjectFields then with FieldDefs.AddFieldDef do
   begin
    Name := RootName;
    DataType := ftADT;
    fsc := ChildDefs;
   end
  else fsc := FieldDefs;
  for m in XEnum(AXMLSection) do recur(m, fsc);
  FInternalCalcDataLen := ClcOffset;
end;

function TXMLDataSet.GetScript: TXmlScript;
begin
  if Assigned(FScript) then Exit(FScript);
  FScript := TXmlScript.Create(Self);
  Result := FScript;
end;

function TXMLDataSet.GetTempDir: string;
begin
  Result := Format('%s_%s_%d_%s', [TPath.GetDirectoryName(XMLFileName), Device, ModulAdress, Section]);
end;

function TXMLDataSet.GetXMLSection: IXMLNode;
 var
  root: IXMLNode;
  f: TFileFieldDef;
  i: integer;
  n: IXMLNode;
begin
  if not Assigned(FXMLSection) then
   begin
    root := GetIDeviceMeta((GContainer as IALLMetaDataFactory).Get(XMLFileName).Get, Device);
   // root := root.CloneNode(True);
    TPars.SetMetr(root, Script, False);
    root := FindDev(root, ModulAdress);
    root := root.ChildNodes.FindNode(Section);
    FXMLSection := root;
    // bind to meta data
    SetLength(FInternalCalcData, 0);
    for i := 0 to FieldDefList.Count-1 do
     begin
      f := TFileFieldDef(FieldDefList[i]);
      if f.CalcField then
       begin
        if not TryGetX(f.GetPath, n) then n := nil;
        CArray.Add<TInternalCalcData>(FInternalCalcData, TInternalCalcData.Create(f.DataOffset, n));
       end;
     end;
   end;
   Result := FXMLSection;
end;

function TXMLDataSet.InternalCalcRecBuffer(Buffer: PRecBuffer): Boolean;
 var
  buf, clcbuf: PByte;
  d: TInternalCalcData;
begin
  buf := GetRecData(Buffer);
  if not Assigned(buf) or not Assigned(XMLSection) or (Length(FInternalCalcData) = 0) then Exit(False);
  TPars.SetData(FXMLSection, buf, false);
  Script.Execute(Section, FModul);
//  pb := Pbyte(Buffer) + SizeOf(TRecBuffer);
  clcbuf := Pbyte(Buffer) + SizeOf(TRecBuffer); //pb + Sizeof(Boolean);
  for d in FInternalCalcData do
   begin
    if Assigned(d.Data) then TPars.FromVar(d.Data.Attributes[AT_VALUE], Integer(d.Data.Attributes[AT_TIP]), clcbuf + d.Offset);
   end;
  Buffer.AutoCalculated := True;
  Result := True;
end;


initialization
  RegisterClasses([TXMLDataSet, TXMLDataSetDef]);
  TRegister.AddType<TXMLDataSet, IDataSet>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TXMLDataSet>;
end.
