unit JDtools;

interface

uses
     debug_except, RootIntf, PluginAPI, ExtendIntf, Container, RootImpl,  System.UITypes,
     Vcl.Controls, Vcl.Graphics, Vcl.ComCtrls, Winapi.Messages, Vcl.Forms, Winapi.Windows, JvInspector,JvResources,
     System.SyncObjs,

     System.Classes, System.SysUtils, System.TypInfo,
     System.Generics.Defaults,
     System.Generics.Collections,
     System.Bindings.Expression,
     System.Bindings.EvalProtocol,
     System.Bindings.Helper,
     System.Bindings.Outputs,
     RTTI;

type
  TJvInspectorStringItemEx = class(TJvInspectorStringItem)
  protected
    procedure Apply; override;
  public
    procedure DrawValue(const ACanvas: TCanvas); override;
  end;

  TJvInspectorIntegerItemEx = class(TJvInspectorIntegerItem)
  protected
    procedure Apply; override;
  public
    procedure DrawValue(const ACanvas: TCanvas); override;
  end;

  TJvInspectorFloatItemEx = class(TJvInspectorFloatItem)
  protected
    procedure Apply; override;
  public
    procedure DrawValue(const ACanvas: TCanvas); override;
  end;

  EnumCaptionsAttribute = class;
  TJvInspectorEnumCaptionsItem = class(TJvInspectorEnumItem)
  private
    FCaptions: TArray<string>;
  protected
    procedure Apply; override;
    function GetDisplayValue: string; override;
    procedure GetValueList(const Strings: TStrings); override;
    procedure SetDisplayValue(const Value: string); override;
  public
    constructor Create(const AParent: TJvCustomInspectorItem; const AData: TJvCustomInspectorData); override;
    procedure DrawValue(const ACanvas: TCanvas); override;
  end;

  EnumCaptionsAttribute = class (TCustomAttribute)
  private
    FCaptions: TArray<string>;
  public
    constructor Create(const ACaptions: string);
    property Captions: TArray<string> read FCaptions;
  end;



  TJvInspectorArrayPropData = class(TJvInspectorPropData)
   type
    TGetPropProc<T> = function(Instance: TObject; PropInfo: PPropInfo): T;
  private
    FInstances: TArray<TObject>;
    FLastGetAsDifferent: Boolean;
    FApplyin: Boolean;
  protected
    function GetAsFloat: Extended; override;
    function GetAsInt64: Int64; override;
    function GetAsOrdinal: Int64; override;
    function GetAsString: string; override;
    function GetAsVariant: Variant; override;
    function GetAs<T>(a0: T; GetProp: TGetPropProc<T>): T;

    procedure SetAsFloat(const Value: Extended); override;
    procedure SetAsInt64(const Value: Int64); override;
    procedure SetAsOrdinal(const Value: Int64); override;
    procedure SetAsString(const Value: string); override;
    procedure SetAsVariant(const Value: Variant); override;
  public
    class function New(const AParent: TJvCustomInspectorItem; const AObjs: TArray<TObject>; PropInfo: PPropInfo): TJvCustomInspectorItem; reintroduce;
    function IsAssigned: Boolean; override;
  end;

  ShowPropAttribute = class (TCustomAttribute)
  private
    FDisplayName: string;
    FReadOnly: Boolean;
    class var RttiContext : TRttiContext;
    class function StrObj2Str(const s: string): string;
    class procedure ApplyItem(root: TJvCustomInspectorItem; o: TObject); static;
    class procedure ApplyItemArray(root: TJvCustomInspectorItem; o: TArray<TObject>); static;
    class procedure ApplyICollection(root: TJvCustomInspectorItem; cl: TICollection); static;
  public
   constructor Create(const ADisplayName: String; AReadOnly: Boolean = False);
   class procedure Apply(Obj: TObject; Insp: TJvInspector); overload;
   class procedure Apply(Obj: TArray<TObject>; Insp: TJvInspector); overload;
   property DisplayName: string read FDisplayName write FDisplayName;
   property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;


implementation

uses tools;

{$REGION 'TJvInspectorXXXXXItemEx'}

{ TJvInspectorStringItemEx }

procedure SetInspectorItemFont(Item: TJvCustomInspectorItem; const ACanvas: TCanvas);
begin
  with Item do if (Data is TJvInspectorArrayPropData) and Data.IsAssigned then
   begin
    DisplayValue;
    if TJvInspectorArrayPropData(Data).FLastGetAsDifferent then
     begin
      ACanvas.Font.Color := clGrayText;
      ACanvas.Font.Style := ACanvas.Font.Style - [fsBold];
     end;
   end;
end;

procedure TJvInspectorStringItemEx.Apply;
begin
  if Data is TJvInspectorArrayPropData then TJvInspectorArrayPropData(Data).FApplyin := True;
  inherited Apply;
end;

procedure TJvInspectorStringItemEx.DrawValue(const ACanvas: TCanvas);
begin
  SetInspectorItemFont(Self, ACanvas);
  inherited DrawValue(ACanvas);
end;


{ TJvInspectorIntegerItemEx }

procedure TJvInspectorIntegerItemEx.Apply;
begin
  if Data is TJvInspectorArrayPropData then TJvInspectorArrayPropData(Data).FApplyin := True;
  inherited Apply;
end;

procedure TJvInspectorIntegerItemEx.DrawValue(const ACanvas: TCanvas);
begin
  SetInspectorItemFont(Self, ACanvas);
  inherited DrawValue(ACanvas);
end;


{ TJvInspectorFloatItemEx }

procedure TJvInspectorFloatItemEx.Apply;
begin
  if Data is TJvInspectorArrayPropData then TJvInspectorArrayPropData(Data).FApplyin := True;
  inherited Apply;
end;

procedure TJvInspectorFloatItemEx.DrawValue(const ACanvas: TCanvas);
begin
  SetInspectorItemFont(Self, ACanvas);
  inherited DrawValue(ACanvas);
end;


{ EnumCaptionsAttribute }

constructor EnumCaptionsAttribute.Create(const ACaptions: string);
 var
  i: Integer;
begin
  FCaptions := ACaptions.Split([',',';']);
  for I := 0 to High(FCaptions) do FCaptions[i] := FCaptions[i].Trim;
end;

{ TJvInspectorEnumCaptionsItem }

procedure TJvInspectorEnumCaptionsItem.Apply;
begin
  if Data is TJvInspectorArrayPropData then TJvInspectorArrayPropData(Data).FApplyin := True;
  inherited Apply;
end;

constructor TJvInspectorEnumCaptionsItem.Create(const AParent: TJvCustomInspectorItem; const AData: TJvCustomInspectorData);
 var
  c: TRttiContext;
  a : TCustomAttribute;
begin
  inherited;
  c := TRttiContext.Create;
  try
  for a in c.GetType(Data.TypeInfo).GetAttributes do if a is EnumCaptionsAttribute then
   begin
    FCaptions := EnumCaptionsAttribute(a).Captions;
    Break;
   end;
  finally
    c.Free;
  end;
end;

procedure TJvInspectorEnumCaptionsItem.DrawValue(const ACanvas: TCanvas);
begin
  SetInspectorItemFont(Self, ACanvas);
  inherited DrawValue(ACanvas);
end;

function TJvInspectorEnumCaptionsItem.GetDisplayValue: string;
begin
  if Length(FCaptions) = 0 then Result := inherited
  else Result := FCaptions[Data.AsOrdinal];
end;

procedure TJvInspectorEnumCaptionsItem.GetValueList(const Strings: TStrings);
 var
  s: string;
begin
  if Length(FCaptions) = 0 then inherited
  else for s in FCaptions do Strings.Add(s)
end;

procedure TJvInspectorEnumCaptionsItem.SetDisplayValue(const Value: string);
 var
  i: Integer;
begin
  if Length(FCaptions) = 0 then inherited
  else
   begin
    for I := 0 to High(FCaptions) do if SameText(Value, FCaptions[i]) then
     begin
      Data.AsOrdinal := i;
      Exit;
     end;
    i := StrToIntDef(Value, -1);
    if i >= 0 then Data.AsOrdinal := i;
   end;
end;
{$ENDREGION}

{$REGION 'ShowPropAttribute'}

{ ShowPropAttribute }
type
 TCustomInspectorDataClassName = class(TJvCustomInspectorData)
 private
   FData: string;
 protected
   function GetAsString: string; override;
  public
   function HasValue: Boolean; override;
   function IsAssigned: Boolean; override;
   function IsInitialized: Boolean; override;
   class function New(const AParent: TJvCustomInspectorItem; const Data: string; pt: PTypeInfo): TJvCustomInspectorItem;
 end;
function TCustomInspectorDataClassName.IsAssigned: Boolean;
begin
  Result := True;
end;
function TCustomInspectorDataClassName.IsInitialized: Boolean;
begin
  Result := True
end;
function TCustomInspectorDataClassName.HasValue: Boolean;
begin
  Result := True;
end;
function TCustomInspectorDataClassName.GetAsString: string;
begin
  Result := FData;
end;
class function TCustomInspectorDataClassName.New(const AParent: TJvCustomInspectorItem; const Data: string; pt: PTypeInfo): TJvCustomInspectorItem;
 var
  dat: TCustomInspectorDataClassName;
begin
  Dat := CreatePrim(Data, pt);
  Dat.FData := Data;
  Dat := TCustomInspectorDataClassName(DataRegister.Add(Dat));
  if Dat <> nil then Result := Dat.NewItem(AParent)
  else Result := nil;
end;

constructor ShowPropAttribute.Create(const ADisplayName: String; AReadOnly: Boolean);
begin
  FDisplayName := ADisplayName;
  FReadOnly := AReadOnly;
end;

class procedure ShowPropAttribute.Apply(Obj: TObject; Insp: TJvInspector);
begin
  Insp.Clear;
  RttiContext := TRttiContext.Create;
  try
   ApplyItem(Insp.Root, Obj);
  finally
   RttiContext.Free;
  end;
end;

class procedure ShowPropAttribute.Apply(Obj: TArray<TObject>; Insp: TJvInspector);
 var
  i: Integer;
begin
  for i := Length(Obj)-1 downto 0 do if not Assigned(Obj[i]) then Delete(Obj, 0, 1);
  if Length(Obj) = 0 then Exit
  else if Length(Obj) = 1 then Apply(Obj[0], Insp)
  else
   begin
    Insp.Clear;
    RttiContext := TRttiContext.Create;
    try
     ApplyItemArray(Insp.Root, Obj);
    finally
     RttiContext.Free;
    end;
   end;
end;

class function ShowPropAttribute.StrObj2Str(const s: string): string;
begin
  Result := '('+s+')';
end;

class procedure ShowPropAttribute.ApplyItem(root: TJvCustomInspectorItem; o: TObject);
 var
  t : TRttiType;
  p : TRttiProperty;
  a : TCustomAttribute;
  ii: TJvCustomInspectorItem;
  oo: TObject;
  s: string;
begin
  if not Assigned(o) then Exit;
  t := RttiContext.GetType(o.ClassType);
  for p in t.getProperties do
  for a in p.GetAttributes do
   if a is ShowPropAttribute then
     if p.PropertyType.TypeKind = tkClass then
      begin
       oo := p.GetValue(o).AsObject;
       if not Assigned(oo) then s := string(p.PropertyType.Handle.Name)
       else s := oo.ClassName;
       ii := TCustomInspectorDataClassName.New(Root, StrObj2Str(s), TypeInfo(string));
       ii.DisplayName := ShowPropAttribute(a).DisplayName;
       ii.SortKind := iskNone;
       ii.Expanded := True;
       ii.ReadOnly := True;
       if Assigned(oo) and (oo is TICollection) then ApplyICollection(ii,  TICollection(oo));
       ApplyItem(ii, oo);
      end
     else
      begin
       ii := TJvInspectorPropData.New(Root, o, TRttiInstanceProperty(p).PropInfo);
       ii.DisplayName := ShowPropAttribute(a).DisplayName;
       ii.ReadOnly := ShowPropAttribute(a).ReadOnly or not p.IsWritable;
       if ii is TJvInspectorBooleanItem then TJvInspectorBooleanItem(ii).ShowAsCheckbox := True;
      end;
end;

class procedure ShowPropAttribute.ApplyICollection(root: TJvCustomInspectorItem; cl: TICollection);
 var
  ii: TJvCustomInspectorItem;
  ci: TCollectionItem;
  s: string;
  ca: ICaption;
begin
  if Supports(cl, ICaption, ca) then s := ca.Text
  else s := 'Items';
  Root := TCustomInspectorDataClassName.New(Root, '', TypeInfo(string));
  Root.DisplayName := s;
  Root.SortKind := iskNone;
  Root.Expanded := True;
  Root.ReadOnly := True;
  for ci in cl do
   begin
    if Supports(ci, ICaption, ca) then s := ca.Text
    else s := 'Item';
    ii := TCustomInspectorDataClassName.New(Root, StrObj2Str(ci.ClassName), TypeInfo(string));
    ii.DisplayName := s;
    ii.SortKind := iskNone;
    ii.Expanded := True;
    ii.ReadOnly := True;
    ApplyItem(ii, ci);
   end;
end;

class procedure ShowPropAttribute.ApplyItemArray(root: TJvCustomInspectorItem; o: TArray<TObject>);
 type
  Tsp = record
   a: ShowPropAttribute;
   p: TRttiProperty;
   cnt: Integer;
  end;
 var
  t : TRttiType;
  p : TRttiProperty;
  a : TCustomAttribute;
  ii: TJvCustomInspectorItem;
  i, j: Integer;
  aa: TArray<Tsp>;
  function GetTsp(atr: TCustomAttribute; prp: TRttiProperty): Tsp;
  begin
    Result.a := ShowPropAttribute(atr);
    Result.p := prp;
    Result.cnt := 0;
  end;
begin
  SetLength(aa, 0);
  t := RttiContext.GetType(o[0].ClassType);
  // заполнение
  for p in t.getProperties do
   for a in p.GetAttributes do
    if (a is ShowPropAttribute) and (p.PropertyType.TypeKind <> tkClass) then Carray.add<Tsp>(aa, GetTsp(a,p));
  // удаление не найденых
  for i := 1 to Length(o)-1 do
   begin
    t := RttiContext.GetType(o[i].ClassType);
     for p in t.getProperties do
      for a in p.GetAttributes do
       if (a is ShowPropAttribute) and (p.PropertyType.TypeKind <> tkClass) then
         for j := 0 to Length(aa)-1 do if (aa[j].a = ShowPropAttribute(a)) and (aa[j].p = p) then
          begin
           inc(aa[j].cnt);
           Break
          end;
    for j := Length(aa)-1 downto 0 do
     if aa[j].cnt = 0 then Delete(aa, 0, 1)
     else aa[j].cnt := 0;
   end;
  // отрисовка
  for i := 0 to Length(aa)-1 do
   begin
    ii := TJvInspectorArrayPropData.New(Root, o, TRttiInstanceProperty(aa[i].p).PropInfo);
    ii.DisplayName := aa[i].a.DisplayName;
    ii.ReadOnly := aa[i].a.ReadOnly or not aa[i].p.IsWritable;
    if ii is TJvInspectorBooleanItem then TJvInspectorBooleanItem(ii).ShowAsCheckbox := True;
   end;
  SetLength(aa, 0);
end;
{$ENDREGION}

{$REGION 'TJvInspectorArrayPropData'}

{ TJvInspectorArrayPropData }

class function TJvInspectorArrayPropData.New(const AParent: TJvCustomInspectorItem; const AObjs: TArray<TObject>; PropInfo: PPropInfo): TJvCustomInspectorItem;
var
  Data: TJvInspectorArrayPropData;
  RegItem: TJvCustomInspectorRegItem;
begin
  if PropInfo = nil then  raise EJvInspectorData.CreateRes(@RsEJvAssertPropInfo);
  Data := CreatePrim(string(PropInfo.Name), PropInfo.PropType^);
  Data.Instance := AObjs[0];
  Data.FInstances := AObjs;
  Data.Prop := PropInfo;
  Data := TJvInspectorArrayPropData(DataRegister.Add(Data));
  if Data <> nil then
   begin
    RegItem := TypeInfoMapRegister.FindMatch(Data);
    if (RegItem <> nil) and (RegItem is TJvInspectorTypeInfoMapperRegItem) then
      Data.TypeInfo := TJvInspectorTypeInfoMapperRegItem(RegItem).NewTypeInfo;
    Result := Data.NewItem(AParent);
   end
  else
    Result := nil;
end;

function TJvInspectorArrayPropData.GetAs<T>(a0: T; GetProp: TGetPropProc<T>): T;
 var
  a: TArray<T>;
  i: Integer;
begin
  SetLength(a, Length(FInstances));
  FLastGetAsDifferent := False;
  a[0] := a0;
  for i := 1 to High(a) do
   begin
    a[i] := GetProp(FInstances[i], Prop);
    if not TEqualityComparer<T>.Default.Equals(a[i], a0) then FLastGetAsDifferent := True;
   end;
  TArray.Sort<T>(a);
  Result := a[Length(a) div 2];
end;

function TJvInspectorArrayPropData.GetAsFloat: Extended;
begin
  Result := GetAs<Extended>(inherited, GetFloatProp);
end;

function TJvInspectorArrayPropData.GetAsInt64: Int64;
begin
  Result := GetAs<Int64>(inherited, GetInt64Prop);
end;

function TJvInspectorArrayPropData.GetAsOrdinal: Int64;
begin
  Result := GetAs<NativeInt>(inherited, GetOrdProp);
end;

function TJvInspectorArrayPropData.GetAsString: string;
begin
  Result := GetAs<string>(inherited, GetStrProp);
end;

function TJvInspectorArrayPropData.GetAsVariant: Variant;
begin
  Result := GetAs<Variant>(inherited, GetVariantProp);
end;

function TJvInspectorArrayPropData.IsAssigned: Boolean;
begin
  Result := inherited and not (FApplyin and FLastGetAsDifferent);
  FApplyin := False;
end;

procedure TJvInspectorArrayPropData.SetAsFloat(const Value: Extended);
 var
  o: TObject;
begin
  inherited;
  for o in FInstances do SetFloatProp(o, Prop, Value)
end;

procedure TJvInspectorArrayPropData.SetAsInt64(const Value: Int64);
 var
  o: TObject;
begin
  inherited;
  for o in FInstances do SetInt64Prop(o, Prop, Value)
end;

procedure TJvInspectorArrayPropData.SetAsOrdinal(const Value: Int64);
 var
  o: TObject;
begin
  inherited SetAsOrdinal(Value);
  for o in FInstances do
   if GetTypeData(Prop.PropType^).OrdType = otULong then
      SetOrdProp(o, Prop, Cardinal(Value))
    else
      SetOrdProp(o, Prop, Value);
end;

procedure TJvInspectorArrayPropData.SetAsString(const Value: string);
 var
  o: TObject;
begin
  inherited;
  for o in FInstances do SetStrProp(o, Prop, Value)
end;

procedure TJvInspectorArrayPropData.SetAsVariant(const Value: Variant);
 var
  o: TObject;
begin
  inherited;
  for o in FInstances do SetVariantProp(o, Prop, Value)
end;

{$ENDREGION TJvInspectorArrayPropData}

initialization
  with TJvCustomInspectorData.ItemRegister do
   begin
    Delete(TJvInspectorEnumItem);
    Delete(TJvInspectorFloatItem);
    Delete(TJvInspectorIntegerItem);
    Delete(TJvInspectorStringItem);
    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorEnumCaptionsItem, tkEnumeration));
    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorFloatItemEx, tkFloat));

    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorIntegerItemEx, tkInteger));
    {$IFDEF UNICODE}
    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorStringItemEx, tkUString));
    {$ENDIF UNICODE}
    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorStringItemEx, tkLString));
    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorStringItemEx, tkWString));
    Add(TJvInspectorTypeKindRegItem.Create(TJvInspectorStringItemEx, tkString));

    Add(TJvInspectorTypeInfoRegItem.Create(TJvInspectorBooleanItem, System.TypeInfo(Boolean)));
    Add(TJvInspectorTypeInfoRegItem.Create(TJvInspectorBooleanItem, System.TypeInfo(ByteBool)));
    Add(TJvInspectorTypeInfoRegItem.Create(TJvInspectorBooleanItem, System.TypeInfo(WordBool)));
    Add(TJvInspectorTypeInfoRegItem.Create(TJvInspectorBooleanItem, System.TypeInfo(LongBool)));
   end;
end.
