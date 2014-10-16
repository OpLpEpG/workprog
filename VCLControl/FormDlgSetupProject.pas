unit FormDlgSetupProject;

interface

uses RootImpl, RootIntf, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, Data.DB,  TypInfo, Xml.XMLIntf, Container,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JvExControls, JvInspector, JvComponentBase, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup;

type
  EFormSetupProject = class(EBaseException);
  TFormSetupProject = class(TDialogIForm, IDialog, IDialog<Pointer>)
    InspectorBorlandPainter: TJvInspectorBorlandPainter;
    btExit: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Insp: TJvInspector;
    InspZ: TJvInspector;
    JvInspectorBorlandPainterZ: TJvInspectorBorlandPainter;
    ppM: TPopupActionBar;
    NReadOnly: TMenuItem;
    procedure btExitClick(Sender: TObject);
    procedure UpdateGlu(Sender: TObject);
  private
  public
  protected
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: Pointer): Boolean;
  end;

var
  FormSetupProject: TFormSetupProject;

implementation

{$R *.dfm}

uses tools, DlgSetupDate, DBImpl;


type
 TCategory = class(TJvInspectorCustomCategoryItem)
 private
   DBCateg: string;
 end;

{$REGION 'TData'}

 TData = class(TJvCustomInspectorData)
 private
   FData: Variant;
   DBName: string;
 protected
   procedure InnerAsString(const Value: string); virtual;
   function GetAsFloat: Extended; override;
   function GetAsInt64: Int64; override;
   function GetAsOrdinal: Int64; override;
   function GetAsString: string; override;
   function GetAsVariant: Variant; override;
   procedure SetAsFloat(const Value: Extended); override;
   procedure SetAsInt64(const Value: Int64); override;
   procedure SetAsOrdinal(const Value: Int64); override;
   procedure SetAsString(const Value: string); override;
   procedure SetAsVariant(const Value: Variant); override;
  public
   function HasValue: Boolean; override;
   function IsAssigned: Boolean; override;
   function IsInitialized: Boolean; override;
   class function New(const AParent: TJvCustomInspectorItem; const DBName, DispName: string;
         Units, Data, ReadOnly, DataTip: Variant): TJvCustomInspectorItem; reintroduce; overload;
 end;

 TDataDev = class(TData)
 protected
   Fid: Integer;
   procedure InnerAsString(const Value: string); override;
  public
   class function New(const AParent: TJvCustomInspectorItem; Data: Variant): TJvCustomInspectorItem; reintroduce; overload;
 end;

 TDataZ = class(TDataDev)
 protected
   FNode: IXMLNode;
   procedure InnerAsString(const Value: string); override;
  public
   class function New(const AParent: TJvCustomInspectorItem; Node: IXMLNode; Id: Integer; ReadOnly: Boolean): TJvCustomInspectorItem; reintroduce; overload;
 end;

{ TData }

class function TData.New(const AParent: TJvCustomInspectorItem; const DBName, DispName: string;
      Units, Data, ReadOnly, DataTip: Variant): TJvCustomInspectorItem;
 var
  Dat: TData;
  dn: string;
  tip: Pointer;
  intTip: Integer;
begin
  if not VarIsNull(Units) and (Units <> '') then dn := Format('%s [%s]', [DispName, string(Units)])
  else dn := DispName;

  if VarIsNull(DataTip) then intTip := 0
  else intTip := Integer(DataTip);

  case intTip of
   PRG_TIP_INT      : tip := System.TypeInfo(Integer);
   PRG_TIP_REAL     : tip := System.TypeInfo(Double);
   PRG_TIP_DATE_TIME: tip := System.TypeInfo(TDateTime);
   PRG_TIP_DATE     : tip := System.TypeInfo(TDate);
   PRG_TIP_TIME     : tip := System.TypeInfo(TTime);
   else               tip := System.TypeInfo(Variant);
  end;

  Dat := CreatePrim(dn, tip);
  Dat.DBName := DBName;
  Dat.FData := Data;
  Dat := TData(DataRegister.Add(Dat));

  if Dat <> nil then
   begin
    Result := Dat.NewItem(AParent);
    if VarIsNull(ReadOnly) then Result.ReadOnly := False
    else Result.ReadOnly := Boolean(ReadOnly);
   end
  else Result := nil;
end;

procedure TData.InnerAsString(const Value: string);
begin
  if  VarIsNull(FData) or (FData <> Value) then
   begin
    FData := Value;
    (GlobalCore as IProjectOptions).Option[DBName] := FData;
   end;
end;

function TData.IsAssigned: Boolean;
begin
  Result := True;
end;
function TData.IsInitialized: Boolean;
begin
  Result := True
end;
function TData.HasValue: Boolean;
begin
  Result := True;
end;
function TData.GetAsFloat: Extended;
begin
  try
   Result := Extended(FData);
  except
   Result := 0;
  end;
end;
function TData.GetAsInt64: Int64;
begin
  try
   Result := Int64(FData);
  except
   Result := 0;
  end;
end;
function TData.GetAsOrdinal: Int64;
begin
  try
   Result := Int64(FData);
  except
   Result := 0;
  end;
end;
function TData.GetAsString: string;
begin
  Result := FData;
end;
function TData.GetAsVariant: Variant;
begin
  Result := FData;
end;
procedure TData.SetAsString(const Value: string);
begin
  InnerAsString(Value)
end;
procedure TData.SetAsFloat(const Value: Extended);
begin
  InnerAsString(FloatToStr(Value));
end;
procedure TData.SetAsInt64(const Value: Int64);
begin
  InnerAsString(IntToStr(Value));
end;
procedure TData.SetAsOrdinal(const Value: Int64);
begin
  InnerAsString(IntToStr(Value));
end;
procedure TData.SetAsVariant(const Value: Variant);
begin
  InnerAsString(VarToStr(Value));
end;

{ TDataDev }

procedure TDataDev.InnerAsString(const Value: string);
begin
  if  VarIsNull(FData) or (FData <> Value) then
   begin
    FData := Value;
    ConnectionsPool.Query.Acquire;
    try
     ConnectionsPool.Query.ExecSQL('UPDATE Device SET Znd = :P1 WHERE id = :P2', [Value, Fid]);
    finally
     ConnectionsPool.Query.Release;
    end;
   end;
end;

class function TDataDev.New(const AParent: TJvCustomInspectorItem; Data: Variant): TJvCustomInspectorItem;
 var
  Dat: TDataDev;
begin
  Dat := CreatePrim(Data.Имя, System.TypeInfo(Double));
  Dat.Fid := Data.id;
  Dat.FData := Double(Data.Znd);
  Dat := TDataDev(DataRegister.Add(Dat));
  if Dat <> nil then
   begin
    Result := Dat.NewItem(AParent);
    Result.Expanded := True;
   end
  else Result := nil;

end;

{ TDataZ }

procedure TDataZ.InnerAsString(const Value: string);
begin
  if  VarIsNull(FData) or (FData <> Value) then
   begin
    FData := Value;
    FNode.Attributes[AT_ZND] := FData;
    ConnectionsPool.Query.Acquire;
    try
     ConnectionsPool.Query.ExecSQL('UPDATE Modul SET MetaData = :P1 WHERE id = :P2', [FNode.OwnerDocument.XML.Text, Fid]);
    finally
     ConnectionsPool.Query.Release;
    end;
   end;
end;

class function TDataZ.New(const AParent: TJvCustomInspectorItem; Node: IXMLNode; Id: Integer; ReadOnly: Boolean): TJvCustomInspectorItem;
 var
  Dat: TDataZ;
begin
  if Node.HasAttribute(AT_ZND) then
   begin
    Dat := CreatePrim(Node.NodeName, System.TypeInfo(Double));
    Dat.FData := Double(Node.Attributes[AT_ZND]);
   end
//  else if not ReadOnly then  Dat := CreatePrim(Node.NodeName, System.TypeInfo(Double))
  else Dat := CreatePrim(Node.NodeName, System.TypeInfo(string));
  Dat.FNode := Node;
  Dat.Fid := Id;
  Dat := TDataZ(DataRegister.Add(Dat));
  if Dat <> nil then
   begin
    Result := Dat.NewItem(AParent);
    Result.ReadOnly := ReadOnly;
   end
  else Result := nil;
end;
{$ENDREGION}

{ TFormSetupProject }

procedure TFormSetupProject.UpdateGlu(Sender: TObject);
 var
  v: Variant;
  i: Integer;
  doc: IXMLDocument;
  procedure rec(const AParent: TJvCustomInspectorItem; r: IXMLNode; rdonly: Boolean);
   var
    n: IXMLNode;
    cii: TJvCustomInspectorItem;
  begin
    if (r.NodeName = T_MTR) or (r.NodeName = T_WRK) then Exit
    else if r.NodeName = T_RAM then cii := AParent
    else cii := TDataZ.New(AParent, r, v.id, rdonly);
    cii.Expanded := not rdonly;
    for n in XEnum(r) do rec(cii, n, NReadOnly.Checked)
  end;
begin
  InspZ.Clear;
  ConnectionsPool.Query.Acquire;
  try
   ConnectionsPool.Query.Open('SELECT * FROM Device');
   for v in ConnectionsPool.Query do TDataDev.New(InspZ.Root, v);
   ConnectionsPool.Query.Close;
  for I := 0 to InspZ.Root.Count-1 do
   begin
    ConnectionsPool.Query.Open('SELECT * FROM Modul WHERE fk ='+ TDataDev(InspZ.Root.Items[i].Data).Fid.ToString);
    try
     for v in ConnectionsPool.Query do if not VarIsNull(v.MetaData) and (v.MetaData <> '') then
      begin
       doc := NewXDocument();
       doc.LoadFromXML(v.MetaData);
       rec(InspZ.Root.Items[i], doc.DocumentElement, NReadOnly.Checked);
      end;
    finally
     ConnectionsPool.Query.Close;
    end;
   end;
  finally
   ConnectionsPool.Query.Release;
  end;
end;

function TFormSetupProject.Execute(InputData: Pointer): Boolean;
 var
  v: Variant;
  ctarr: TArray<TCategory>;
  function GetCategory(): TCategory;
   var
    ii: TCategory;
  begin
    for ii in ctarr do if ii.DBCateg = v.Section then Exit(ii);
    Result := TCategory.Create(Insp.Root, nil);
    Result.SortKind := iskNone;
    Result.DBCateg := v.Section;
    Result.DisplayName := v.Категория;
    Result.Expanded := True;
    CArray.Add<TCategory>(ctarr, Result);
  end;
begin
  Result := True;
  // Свойства проекта
  Insp.Clear;
  ConnectionsPool.Query.Acquire;
  try
   ConnectionsPool.Query.Open('SELECT * FROM Options');
   try
    for v in ConnectionsPool.Query do
       if VarIsNull(v.Hidden) or not Boolean(v.Hidden) then
          TData.New(GetCategory, v.Имя, v.Описание, v.Единицы, v.Значение, v.ReadOnly, v.DataType);
   finally
    ConnectionsPool.Query.Close;
   end;
  finally
   ConnectionsPool.Query.Release;
  end;
  // Cмещение глубины
  UpdateGlu(Self);
  IShow;
end;

function TFormSetupProject.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_SetupProject);
end;

procedure TFormSetupProject.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_SetupProject>;
end;

initialization
  RegisterDialog.Add<TFormSetupProject, Dialog_SetupProject>;
finalization
  RegisterDialog.Remove<TFormSetupProject>;
end.
