unit MetaData2.BParser;

interface

uses sysutils, Classes, Rtti, MetaData2.Classes, Xml.XMLIntf, Xml.XMLDoc,Xml.xmldom;

type

  ITyped = interface
  ['{263513C8-7F81-4127-B511-983AFFF5A5C9}']
    procedure SetTyped(const Value: TTyped);
    function GetTyped: TTyped;
    property Typed: TTyped read GetTyped write SetTyped;
  end;

 TXMLtyped = class(TXMLNode, ITyped)
  private
   FTyped: TTyped;
   procedure SetTyped(const Value: TTyped);
   function GetTyped: TTyped;
  public
   function GetNodeValue: OleVariant; reintroduce;
 end;

  TXTypedDocument = class(TXMLDocument)
  protected
    function GetChildNodeClass(const Node: IDOMNode): TXMLNodeClass; override;
  end;


 TBinaryToXMLParser = class
 private
  //   Глобальные указатель и счетчик
  class var Gptr: PByte;
  class var Availlen: Integer;
  class var StructLen: Integer;
  class var locallen: Integer;
  class var localcnt: Integer;
  class function ParseStr: string;
  class function ParseAttrs: TTypedArray;
  class function ParseData: TTypedArray;
  class function CreateUnknown(t: TmetadataType; ptr: PByte): TTyped;
  class procedure Next(n: Integer = 1);
  class function FactoryStruct(t: TmetadataType): TStructTypedef;
  class function FactoryAttr(t: TmetadataType): TTyped;
  class function FactoryData(t: TmetadataType): TTyped;
  class function FactoryStructData(t: TmetadataType): TDataStruct;
  class function FindStructTypedef(Index: Integer): TStructTypedef;
 public
//  class procedure Exec(proc: TProc<TTyped,TTyped>);
  class var Data: TArray<TStructTypedef>;
  class var XDoc: IXMLDocument;
  class procedure Parse(ptr: Pointer);
  class procedure AssignAndExpandArrayStructData;
  class procedure AsXML(root: IXMLNode);
 end;


function NewXDocument(Version: DOMString = '1.0'): IXMLDocument;

implementation

{ TBinaryToXMLParser }

class function TBinaryToXMLParser.ParseStr: string;
begin
  Result := string(PAnsiChar(Gptr));
  locallen := Length(Result)+1;
  Next(locallen);
end;

class function TBinaryToXMLParser.ParseAttrs: TTypedArray;
 var
  t : TmetadataType;
begin
  Result := [];
  while StructLen > 0 do
   begin
    t := Gptr^;
    if not t.isAttr then Break;
    Result := Result + [FactoryAttr(t)];
   end;
end;

class function TBinaryToXMLParser.ParseData: TTypedArray;
 var
  t : TmetadataType;
begin
  Result := [];
  while StructLen > 0 do
   begin
    t := Gptr^;
    if t.isData then
     begin
      if t.isStructData then Result := Result + [FactoryStructData(t)]
      else Result := Result + [FactoryData(t)];
     end;
   end;
end;

class procedure TBinaryToXMLParser.AsXML(root: IXMLNode);
  function ChekName(const n: string): string;
  begin
    if n = '' then Exit('_')
    else if n.Chars[0] in ['1'..'9'] then Exit('_'+n)
    else Result := n;
  end;
  procedure attrs(p, n: TTyped; r: IXMLNode);
  begin
    for var a in n.Attr do
     begin
      r.Attributes[ChekName(a.TypeName)] := a.SVal;
     end;
  end;
  function ChekSection(tip: TmetadataType; n: TTyped; r: IXMLNode; out s: IXMLNode): Boolean;
  begin
    if n.AttrContains(tip) then
     begin
      for var d in ATR_TYPES do if d.Tip = tip then
       begin
        s := r.AddChild(d.Name);
        n.Remove(n.GetAttr(tip));
        Result := True;
       end;
     end
    else Result := False;
  end;
  procedure rec(p, n: TTyped; r: IXMLNode);
   var
    s: IXMLNode;
  begin
    if ChekSection(ATTR_WRK,n,r,s) then
    else if ChekSection(ATTR_RAM,n,r,s) then
    else if ChekSection(ATTR_EEP,n,r,s) then
    else  s := r.AddChild(ChekName(n.Name));
    attrs(p, n, s);
    if n is TTypedValue then
     begin
      var d := S.AddChild('DEV');
      d.Attributes['typeName'] := n.TypeName;
      d.Attributes['tip'] := Byte(n.Tip).ToHexString;
      if n is TFloat then d.NodeValue := 3.5
      else  d.NodeValue := n.TVal.AsVariant;
//      var c := s.AddChild('CLC');
//      c.NodeValue := 0.0;
       var nv := d.NodeValue;
     end
    else for var sub in n.SubData do rec(n, sub, s);
  end;
begin
  root.ChildNodes.Clear;
  root.AttributeNodes.Clear;
  for var d in Data do if d.AttrContains(ATTR_export) then
   begin
    d.Remove(d.GetAttr(ATTR_export));
    rec(nil, d, root);
    break;
   end;
end;

class function TBinaryToXMLParser.CreateUnknown(t: TmetadataType; ptr: PByte): TTyped;
begin
  if t.isString then Result := TStr.Create(t, ptr)
  else case t.Length of
        0: Result := TNone.Create(t);
        1: Result := TUint8.Create(t, ptr);
        2: Result := TUint16.Create(t, ptr);
        4: Result := TUint32.Create(t, ptr);
        8: Result := TUint64.Create(t, ptr);
       else
         Result := TTyped.Create(t, ptr); // raise ???
       end;
end;

class function TBinaryToXMLParser.FactoryAttr(t: TmetadataType): TTyped;
begin
  Next;
  try
    for var a in ATR_TYPES do
     if a.Tip = t then
      begin
        Result := a.cls.Create(t, Gptr);
        Result.TypeName := a.Name;
        locallen := Result.SizeOf;
        Exit(Result);
      end;
    Result := CreateUnknown(t, Gptr);
    locallen := Result.SizeOf;
  finally
   Next(locallen-1);
  end;
end;

class function TBinaryToXMLParser.FactoryStructData(t: TmetadataType): TDataStruct;
begin
  Next;
  Result := TDataStruct.Create(t);
  Result.TypeName := 'struct_data';
  Result.Index :=  Gptr^;
  Next;
  if t.isNamedData then Result.Name := ParseStr;
  Result.attr := ParseAttrs;
end;

class function TBinaryToXMLParser.FindStructTypedef(Index: Integer): TStructTypedef;
begin
  for var d in Data do if d.Index = Index then Exit(d);
  raise Exception.Create(' StructTypedef not found');
end;

class procedure TBinaryToXMLParser.Next(n: Integer);
begin
  Inc(gptr, n); Dec(Availlen, n); Dec(StructLen, n); inc(localcnt, n);
  if (availLen < 0) or (StructLen < 0) then raise Exception.Create('availLen <> 0 Error Message');
end;

class function TBinaryToXMLParser.FactoryData(t: TmetadataType): TTyped;
  label knoType;
begin
  Next;
  for var d in STD_TYPES do if d.Tip = (t and $F7) then
   begin
     Result := d.cls.Create(t);
     Result.TypeName := d.Name;
     goto knoType;
   end;
  Result := CreateUnknown(t, nil);
  knoType:
  if t.isNamedData then Result.Name := ParseStr;
  Result.attr := ParseAttrs;
end;

class function TBinaryToXMLParser.FactoryStruct(t: TmetadataType): TStructTypedef;
begin
  Result := TStructTypedef.Create(t);
  Result.TypeName := 'struct';
  localcnt := 0;
  StructLen := 1;
  Next();
  StructLen := 0;
  Move(gptr^,StructLen, t.Length);
  Dec(StructLen);
  Next(t.Length);
  if t.isNamedData then Result.Name := ParseStr;
  Result.attr := ParseAttrs;
  Result.SubData := ParseData;
end;

class procedure TBinaryToXMLParser.Parse(ptr: Pointer);
 var
  t: TmetadataType;
begin
  Gptr := ptr;
  Availlen := Pword(Gptr)^;
  Inc(Gptr,2); Dec(Availlen, 2);
  while Availlen > 0  do
   begin
     t := Gptr^;
     if t.isStructTypedef then
      begin
       var s := FactoryStruct(t);
       s.Index := Length(Data);
       Data := Data + [s];
      end
     else raise Exception.Create('Error Message');
   end;
end;

//class procedure TBinaryToXMLParser.Exec(proc: TProc<TTyped,TTyped>);
//  procedure rec(p, s: TTyped);
//  begin
//    proc(p, s);
//    for var ss in s.SubData do rec(s, ss);
//  end;
//begin
//  for var d in Data do rec(nil, d);
//end;

class procedure TBinaryToXMLParser.AssignAndExpandArrayStructData;
begin
  for var d in Data do
   for var s in d.SubData do
    if s.Tip.isStructData then with (s as TDataStruct) do
     begin
       Assign(FindStructTypedef(Index));
       ExpandArray(d);
     end;
  XDoc := NewXDocument;
  XDoc.AddChild('PROJECT');
  AsXML(XDoc.DocumentElement);
  XDoc.SaveToFile('C:\XE\Projects\Device2\CreateMetaData\MetaData.xml')
end;

{ TXTypedDocument }

function TXTypedDocument.GetChildNodeClass(const Node: IDOMNode): TXMLNodeClass;
begin
  Result := TXMLtyped;
end;

{ TXMLtyped }

function TXMLtyped.GetNodeValue: OleVariant;
begin
  Result := inherited GetNodeValue
end;

function TXMLtyped.GetTyped: TTyped;
begin
  Result := FTyped
end;

procedure TXMLtyped.SetTyped(const Value: TTyped);
begin
  FTyped:= Value;
end;

function NewXDocument(Version: DOMString = '1.0'): IXMLDocument;
begin
  Result := TXTypedDocument.Create(nil);
  Result.Active := True;
  if Version <> '' then Result.Version := Version;
end;



end.
