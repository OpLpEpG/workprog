unit MetaData2.BParser;

interface

uses sysutils, Classes, MetaData2.Classes, Xml.XMLIntf;

type
 TBinaryToXMLParser = class
 public
  class var Data: TArray<TStructTypedef>;
  class function FactoryStruct(t: TmetadataType; ptr: Pointer; out len: Integer; out dataLen: Integer): TStructTypedef;
  class function FactoryAttr(t: TmetadataType; ptr: Pointer; out len: Integer): TTyped;
  class function FactoryData(t: TmetadataType; ptr: Pointer; out len: Integer; out dataLen: Integer): TTyped;

  class procedure Parse(ptr: Pointer);
 end;

implementation



{ TBinaryToXMLParser }

class function TBinaryToXMLParser.FactoryAttr(t: TmetadataType; ptr: Pointer; out len: Integer): TTyped;
begin
      begin

       rlen := 0;
       var l := t.Length;
       Move(p^, rlen, l);
       Inc(p, l); Dec(len, l);
       if t.isNamedData then

      end
end;

class function TBinaryToXMLParser.FactoryData(t: TmetadataType; ptr: Pointer; out len, dataLen: Integer): TTyped;
begin

end;

class function TBinaryToXMLParser.FactoryStruct(t: TmetadataType; ptr: Pointer; out len,
  dataLen: Integer): TStructTypedef;
begin

end;

class procedure TBinaryToXMLParser.Parse(ptr: Pointer);
 var
  r, MetaLen, DataLen, MataAllLen: Integer;
  p: PByte;
  t: TmetadataType;
begin
  p := ptr;
  MataAllLen := Pword(p)^;
  Inc(p,2); Dec(MataAllLen, 2);
  while MataAllLen > 0  do
   begin
     t := p^; Inc(p); Dec(MataAllLen);
     if t.isStructTypedef then
      begin
       FactoryStruct(t,p, MetaLen, DataLen);

      end
     else raise Exception.Create('Error Message');
   end;
end;

end.
