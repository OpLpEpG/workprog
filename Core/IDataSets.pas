unit IDataSets;

interface

uses sysutils, Classes, Controls, Data.DB, debug_except, Container, RootImpl, RootIntf, ExtendIntf, DataSetIntf,
     System.Bindings.Helper;

type
  TIDataSet = class(TDataSet, IInterface{!!!!!! иначе _AddRef _Release будут иногда старые}, IManagItem, IBind, IDataSet)
  private
    FRefCount: Integer;
  protected
    FIsBindInit: Boolean;
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: Integer; reintroduce; stdcall;
    function _Release: Integer; reintroduce; stdcall;
  // IManagItem
    function Priority: Integer;
    function Model: ModelType;
    function RootName: String;
    function GetItemName: String;
    procedure SetItemName(const Value: String);
    // IBind
    procedure _EnableNotify;
    procedure Bind(const ControlExprStr: string; Source: IInterface; const SourceExpr: array of string); overload;
    procedure Bind(Control: IInterface; const ControlExprStr: string; const SourceExpr: array of string); overload;

    procedure Notify(const Prop: string);

    function GetDataSet: TDataSet;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
    class function NewInstance: TObject; override;
    procedure AfterConstruction; override;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
  published
    property FieldDefs;
  end;

   TDataSetEnum = class(TRootServiceManager<IDataSet>, IDataSetEnum)
   protected
     const PATH = 'IDataSetObjs';
     procedure Save(); override;
     procedure Load(); override;
   end;

implementation

{ TIDataSet }

constructor TIDataSet.Create;
 var
  i: Integer;
begin
  inherited Create(nil);
  ObjectView := True;
  i:= 1;
  while GContainer.Contains(RootName + i.ToString()) do Inc(i);
  Name := RootName + i.ToString;
end;

destructor TIDataSet.Destroy;
begin
  TBindHelper.RemoveExpressions(Self);
  inherited;
end;

class function TIDataSet.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TIDataSet(Result).FRefCount := 1;
end;

procedure TIDataSet.Notify(const Prop: string);
begin
  if not (csLoading in ComponentState) and FIsBindInit then TBindings.Notify(Self, Prop);
end;

procedure TIDataSet.AfterConstruction;
begin
  inherited;
  AtomicDecrement(FRefCount);
end;

function TIDataSet.SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult;
begin
  Result := TDebug.HandleSafeCallException(Self, ExceptObject, ExceptAddr);
end;

function TIDataSet.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;
  if GetInterface(IID, Obj) then Exit(S_OK)
end;

function TIDataSet._AddRef: Integer;
begin
  Result := AtomicIncrement(FRefCount);
end;

function TIDataSet._Release: Integer;

begin
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then Destroy
  else if Result = 1 then GContainer.RemoveInstance(model, Name);
end;

function TIDataSet.Priority: Integer;
begin
  Result := PRIORITY_IComponent;
end;

function TIDataSet.Model: ModelType;
begin
  Result := ClassInfo;
end;

function TIDataSet.RootName: String;
begin
  Result := ClassName;
  System.Delete(Result, 1, 1);
end;

procedure TIDataSet.SetItemName(const Value: String);
begin
  Name := Value;
end;

function TIDataSet.GetDataSet: TDataSet;
begin
  Result := Self;
end;

function TIDataSet.GetItemName: String;
begin
  Result := Name;
end;

procedure TIDataSet.Bind(const ControlExprStr: string; Source: IInterface; const SourceExpr: array of string);
begin
  TBindHelper.Bind(Self, ControlExprStr, Source, SourceExpr);
end;

procedure TIDataSet.Bind(Control: IInterface; const ControlExprStr: string; const SourceExpr: array of string);
begin
  TBindHelper.Bind((Control as IInterfaceComponentReference).GetComponent, ControlExprStr, Self, SourceExpr);
end;

procedure TIDataSet._EnableNotify;
begin
  FIsBindInit := True;
end;

{ TDataSetEnum }

procedure TDataSetEnum.Load;
begin
  (TRegistryStorable<IDataSet>.Create(Self, PATH) as IStorable).Load;
end;

procedure TDataSetEnum.Save;
begin
  (TRegistryStorable<IDataSet>.Create(Self, PATH) as IStorable).Save;
end;

initialization
  TRegister.AddType<TDataSetEnum, IDataSetEnum>.LiveTime(ltSingleton);
//TRegister.AddType<TIDataSet, IDataSet>.LiveTime(ltSingletonNamed);child mast register
end.
