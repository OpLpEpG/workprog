unit XMLDataSet;

interface

//{$DEFINE USE_VTARRAY}

uses ExtendIntf, DataSetIntf, Container, debug_except, XMLScript, Parser,
     Xml.XMLIntf,
     System.Classes, sysutils, Data.DB, IDataSets, FileDataSet;

type
  TXMLDataSet = class(TFileDataSet)
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
    function GetXMLSection: IXMLNode;
    function GetScript: TXmlScript;
  protected
    function InternalCalcRecBuffer(Buffer: PRecBuffer): Boolean; override;
    property XMLSection: IXMLNode read GetXMLSection;
    property Script: TXmlScript read GetScript;
  public
    procedure CreateFieldDefs(AXMLSection: IXMLNode; AObjectFields: Boolean);
                    // WRK RAM  GLU            //TXMLDataSet
    class procedure New(RootSection: IXMLNode; out DataSet: IDataSet; ObjectFields: Boolean = True); overload;
// published неподдерживаются
  public
    property Device: string read FDevice;// write FDevice;
    property ModulAdress: Integer read FModul;// write FModul;
    property Section: string read FSection;// write FSection;
    property XMLFileName: string read FXMLFileName;// write FXMLFileName;
    property CalcDataLen: Word read FInternalCalcDataLen;// write FInternalCalcDataLen;
  end;


implementation

uses tools;

{ TXMLDataSet.TInternalCalcData }

constructor TXMLDataSet.TInternalCalcData.Create(AOffset: Integer; AData: IXMLNode);
begin
  Data := AData;
  Offset := AOffset;
end;

{ TXMLDataSet }

class procedure TXMLDataSet.New(RootSection: IXMLNode; out DataSet: IDataSet; ObjectFields: Boolean);
begin
  inherited New(RootSection.Attributes[AT_FILE_NAME], RootSection.Attributes[AT_SIZE], DataSet);
  if not (DataSet.DataSet is TXMLDataSet) then raise Exception.Create('DataSet is not TXMLDataSet');
  with TXMLDataSet(DataSet.DataSet) do if (FieldDefs.Count = 0) or (ObjectFields <> ObjectView) then CreateFieldDefs(RootSection, ObjectFields);
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
      f.DataType := ftBytes;
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
  FieldDefs.Clear;
  FXMLSection := nil;
  ClcOffset := 0;

  ObjectView := AObjectFields;

  FSection := AXMLSection.NodeName;
  BinFileName := AXMLSection.Attributes[AT_FILE_NAME];
  RecordLength := AXMLSection.Attributes[AT_SIZE];
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

function TXMLDataSet.GetXMLSection: IXMLNode;
 var
  root: IXMLNode;
  f: TFileFieldDef;
  i: integer;
  n: IXMLNode;
  function RemoveRoot(const s: string): string;
  begin
   Result := s.Remove(0, s.IndexOf('.')+1);
  end;
begin
  if not Assigned(FXMLSection) then
   begin
    root := GetIDeviceMeta((GContainer as IALLMetaDataFactory).Get(XMLFileName).Get, Device);
    root := root.CloneNode(True);
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
        if not TryGetX(FXMLSection, RemoveRoot(f.GetPath), n) then n := nil;
        CArray.Add<TInternalCalcData>(FInternalCalcData, TInternalCalcData.Create(f.DataOffset, n));
       end;
     end;
   end;
   Result := FXMLSection;
end;

function TXMLDataSet.InternalCalcRecBuffer(Buffer: PRecBuffer): Boolean;
 var
  buf, pb, clcbuf: PByte;
  d: TInternalCalcData;
begin
  buf := GetRecData(Buffer);
  if not Assigned(buf) or not Assigned(XMLSection) or (Length(FInternalCalcData) = 0) then Exit(False);
  TPars.SetData(FXMLSection, buf, false);
  Script.Execute(Section, FModul);
  pb := Pbyte(Buffer) + SizeOf(TRecBuffer);
  clcbuf := pb + Sizeof(Boolean);
  for d in FInternalCalcData do
   begin
    if Assigned(d.Data) then TPars.FromVar(d.Data.Attributes[AT_VALUE], Integer(d.Data.Attributes[AT_TIP]), clcbuf + d.Offset);
   end;
  PBoolean(pb)^ := True;
  Result := True;
end;

initialization
  RegisterClass(TXMLDataSet);
  TRegister.AddType<TXMLDataSet, IDataSet>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TXMLDataSet>;
end.
