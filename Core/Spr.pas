unit Spr;

interface

uses
     debug_except, RootIntf, DeviceIntf, PluginAPI, ExtendIntf, intf,

     Vcl.Controls, Vcl.Graphics, Vcl.ComCtrls, Winapi.Messages, Vcl.Forms, Winapi.Windows,

     System.Classes, System.SysUtils, System.TypInfo,
     System.Generics.Defaults,
     System.Generics.Collections,
     System.Bindings.Expression,
     System.Bindings.Helper,
     System.Bindings.Outputs,
     RTTI;
type
  TManagItemData<T: IManagItem> = record
   private
    fValue: T;
    fClassName: string;
    fName: string;
    fText: string;
    function GetValue: T;
    function GetClassName: string;
    function GetName: string;
    function GetText: string;
    class var GUID: TGUID;
    class constructor Create;
    constructor CreateFromValue(Val: T);
   public
    constructor Create(Txt: string);
    function IsValueCreated: Boolean;
    property Value: T read GetValue;
    property Name: string read GetName;
    property ClassName: string read GetClassName;
    property Text: string read GetText;
    class operator Implicit(const ManagItemData: TManagItemData<T>): T;
    class operator Implicit(const ValueT: T): TManagItemData<T>;
  end;

  TLazyEnumer<T: IManagItem> = class(TIComponent, IEnumer<T>)
  private
    FItems: TList<TManagItemData<T>>;
  protected
  // IEnumer<T>
    procedure Add(const Item: T);
    procedure Remove(const Item: T);
    function Get(const ItemName: string): T;
    procedure ClearItems; virtual;
   public
    constructor Create; override;
    destructor Destroy; override;
    procedure LazyLoad(ss: array of string);
    function GetEnumerator: IEnum<T>;
  end;

implementation

{ TManagItemData<T> }

constructor TManagItemData<T>.Create(Txt: string);
begin
  fText := Txt;
end;

constructor TManagItemData<T>.CreateFromValue(Val: T);
begin
  fValue := Val;
  if fValue.Priority >= 0 then fValue.IName := fValue.RootName + FormatDateTime('yymdhnsz', now);
end;

class constructor TManagItemData<T>.Create;
 var
  pinfo: PTypeInfo;
begin
  pinfo := TypeInfo(T);
  if not Assigned(pinfo) or not (ifHasGuid in GetTypeData(pinfo).IntfFlags) then raise EEnumer_T_exception.Create('нет GUIDа');
  GUID := GetTypeData(pinfo).Guid;
end;

function TManagItemData<T>.GetClassName: string;
begin
  if fClassName <> '' then Exit(fClassName);
  if fText = '' then
   if not Assigned(fValue) then Exit('')
   else Exit('T'+ fValue.RootName);
  fClassName := Trim(Copy(fText, Pos(':',fText)+1, Pos(#$A, fText)- Pos(':', fText)-1));
  Result := fClassName;
end;

function TManagItemData<T>.GetName: string;
begin
  if fName <> '' then Exit(fName);
  if not Assigned(fValue) then
   if fText = '' then Exit('')
   else Exit(Trim(Copy(fText, Pos('object',fText)+1, Pos('object',fText)+1 - Pos(':', fText))))
  else Exit(fValue.IName)
end;

function TManagItemData<T>.GetText: string;
 var
  ss: TStringStream;
  ms: TMemoryStream;
  icr: IInterfaceComponentReference;
begin
  if Assigned(fValue) then
   begin
    ss := TStringStream.Create;
    ms := TMemoryStream.Create;
    try
     if not Supports(fValue, IInterfaceComponentReference, icr) then raise EEnumer_T_exception.Create('IInterfaceComponentReference не поддерживается');
     ms.WriteComponent((icr as IInterfaceComponentReference).GetComponent);
     ms.Position := 0;
     ObjectBinaryToText(ms, ss);
     Result := ss.DataString;
    finally
     ss.Free;
     ms.Free;
    end;
   end
  else Exit(fText)
end;

function TManagItemData<T>.GetValue: T;
 var
  ss: TStringStream;
  ms: TMemoryStream;
  cc: TClass;
  c: TComponent;
begin
  if Assigned(fValue) then Exit(fValue);
  cc := GetClass(ClassName);
  if not Assigned(cc) then raise EEnumer_T_exception.CreateFmt('класс %s не найден',[ClassName]);
  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ss.WriteString(Text);
   ss.Position := 0;
   ObjectTextToBinary(ss, ms);
   if cc.InheritsFrom(TForm) then c := TFormClass(cc).CreateNew(nil)  else c := TIComponentClass(cc).Create();
   c.GetInterface(GUID, Result); // - ВАЖННЫЙ МОМЕНТ чтобы не вызвать деструктор при чтении компонента (если например будет (self as IBind) )
   try
    ms.Position := 0;
    ms.ReadComponent(c);
   except
    c.Free;
    raise;
   end;
  finally
   ss.Free;
   ms.Free;
  end;
end;

class operator TManagItemData<T>.Implicit(const ValueT: T): TManagItemData<T>;
begin
  Result := TManagItemData<T>.CreateFromValue(ValueT);
end;

function TManagItemData<T>.IsValueCreated: Boolean;
begin
  Result := Assigned(fValue);
end;

class operator TManagItemData<T>.Implicit(const ManagItemData: TManagItemData<T>): T;
begin
  Result := ManagItemData.Value;
end;

{ TLazyEnumer<T> }

constructor TLazyEnumer<T>.Create;
begin
  inherited;
  FItems := TList<TManagItemData<T>>.Create;
end;

destructor TLazyEnumer<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TLazyEnumer<T>.Add(const Item: T);
begin

end;

procedure TLazyEnumer<T>.ClearItems;
begin

end;

function TLazyEnumer<T>.Get(const ItemName: string): T;
 var
  m: TManagItemData<T>;
begin
  Result := nil;
  for m in FItems do if SameText(m.Name, ItemName) then Exit(m.Value)
end;

function TLazyEnumer<T>.GetEnumerator: IEnum<T>;
begin

end;

procedure TLazyEnumer<T>.LazyLoad(ss: array of string);
 var
  s: string;
begin
  for s in ss do FItems.Add(TManagItemData<T>.Create(s))
end;

procedure TLazyEnumer<T>.Remove(const Item: T);
begin

end;

end.
