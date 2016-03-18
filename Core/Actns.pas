unit Actns;

interface

uses RootIntf, ExtendIntf, debug_except, Container, RootImpl,  RTTI, System.UITypes,
     System.Classes, System.SysUtils, System.Actions, Vcl.ActnList, Vcl.Forms;

 type
  ActionAttribute = class(TDependenceAttribute)
  private
    FPaths: string;
    FCaption: string;
    FCategory: string;
    FHint: string;
//    FMenuIndex: integer;
    FImagIndex: integer;
    FGroupIndex: Integer;
    FEnabled: Boolean;
    FAutoCheck: Boolean;
    FChecked: Boolean;
    FDivider: Boolean;
  public
    ///	<param name="Capt">
    ///	  им€
    ///	</param>
    ///	<param name="Categ">
    ///	  категори€
    ///	</param>
    ///	<param name="AImageIndex">
    ///	  икомка
    ///	</param>
    ///	<param name="APaths">
    ///	  пути отображени€ 'BAR1:Path1:MenuIndex1;BAR2:Path2:MenuIndex2'††
    ///	  пример:† '0:”правление.&lt;I&gt;;2:'† &lt;I&gt;-им€ хоз€ина действи€
    ///	  хоз€ин поддерживает ICaption
    ///	</param>
    constructor Create(const Capt, Categ: string; AImageIndex: Integer; const APaths: string; const AHint: string = '';
    AAutoCheck: Boolean = False; AChecked: Boolean = False; AGroupIndex: Integer = 0; AEnabled: Boolean = True); virtual;

    property Caption: string read FCaption;
    property Category: string read FCategory;
    property Hint: string read FHint;
    property ImagIndex: integer read FImagIndex;
    property AutoCheck: Boolean read FAutoCheck;
    property Checked: Boolean read FChecked;
    property GroupIndex: Integer read FGroupIndex;
    property Enabled: Boolean read FEnabled;
    property Paths: string read FPaths;
  end;

  StaticActionAttribute = class(ActionAttribute)
  public
    constructor Create(const Capt, Categ: string; AImageIndex: Integer; const APaths: string; const AHint: string = '';
    AAutoCheck: Boolean = False; AChecked: Boolean = False; AGroupIndex: Integer = 0; AEnabled: Boolean = True); override;
  end;

  DynamicActionAttribute = class(ActionAttribute)
  public
    constructor Create(const Capt, Categ: string; AImageIndex: Integer; const APaths: string; const AHint: string = '';
    AAutoCheck: Boolean = False; AChecked: Boolean = False; AGroupIndex: Integer = 0; AEnabled: Boolean = True); override;
  end;

  TShowInfo = record
   Bar: Integer;
   MenuIndex: Integer;
   path: TArray<TMenuPath>;
  end;

  TShowInfos = record
   Data: TArray<TShowInfo>;
   class operator Implicit(const Value: string): TShowInfos;
  end;


  TICustomAction = class(TCustomAction, IInterface{!!!!!! иначе _AddRef _Release будут иногда старые}, IManagItem, IAction)
  private
    FRefCount: Integer;
    FPaths: string;
    FDivider: Boolean;
  protected
    FPriority: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: Integer; reintroduce; stdcall;
    function _Release: Integer; reintroduce; stdcall;
  // IManagItem
    function Priority: Integer;
    function Model: ModelType;
    function RootName: String;
    function GetItemName: String;
    procedure SetItemName(const Value: String);
    // IAction
    function GetCaption: String;
    function GetCategory: String;
    function GetChecked: Boolean;
    function GetAutoCheck: Boolean;
    function GetEnabled: Boolean;
    function GetHint: String;
    function GetImageIndex: System.UITypes.TImageIndex;
    function GetGroupIndex: Integer;
    procedure SetCategory(const AValue: String);

    procedure DefaultShow;
    function OwnerExists: Boolean; virtual; abstract;
    function GetPath: String;
    function DividerBefore: Boolean;

    procedure Loaded; override;
  public
    constructor Create; reintroduce; virtual;
    constructor CreateUser(atr: ActionAttribute); overload;
    constructor CreateUser(const ACaption, ACategory: String; AImagIndex: Integer; AGroupIndex: Integer = 0; const AHint: string = ''); overload;
    destructor Destroy; override;

    class function NewInstance: TObject; override;
    procedure AfterConstruction; override;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
  published
    property Paths: string read FPaths write FPaths;
    property Caption;
    property Hint;
    property ImageIndex;
    property GroupIndex;
    property AutoCheck;
//    property Enabled;
//    property Checked;
  end;
  TICustomActionClass = class of TICustomAction;

  TICustRTTIAction = class(TICustomAction)
  private
    FInstanceType: TRttiInstanceType;
    FMethodName: string;
    FInstanceName: string;
    FActionClass: string;
    FMethod: TRttiMethod;
    FModelType: ModelType;
    FLiveTime: TLiveTime;
    function CheckMethod: Boolean;
  public
    function Execute: Boolean; override;
    property InstanceName: string read FInstanceName write FInstanceName;
    property ActionMethodName: string read FMethodName write FMethodName;
    property ActionComponentClass: string read FActionClass write FActionClass;
  end;

  TStaticAction = class(TICustRTTIAction)
  protected
    function OwnerExists: Boolean; override;
  public
    constructor Create; override;
  published
    property ActionMethodName;
    property ActionComponentClass;
  end;

  TIDynamicAction = class(TICustRTTIAction)
  protected
    function OwnerExists: Boolean; override;
  published
    property ActionMethodName;
    property InstanceName;
    property ActionComponentClass;
  end;

  TDynamicAction = class(TICustRTTIAction)
  protected
//    Fattr: DynamicActionAttribute;
    function OwnerExists: Boolean; override;
  public
    constructor CreateUser(atr: ActionAttribute; const InstName: string); reintroduce; overload;
  published
    property ActionMethodName;
    property InstanceName;
    property ActionComponentClass;
  end;

 TActionEnum = class(TRootServiceManager<IAction>, IActionEnum)
 protected
   const PATH = 'IActionsObjs';
   procedure Save(); override;
   procedure Load(); override;
 public
   constructor Create; override;
 end;

implementation

uses tools;

{ ActionAttribute }

constructor ActionAttribute.Create(const Capt, Categ: string; AImageIndex: Integer; const APaths, AHint: string; AAutoCheck, AChecked: Boolean; AGroupIndex: Integer; AEnabled: Boolean);
begin
  FService := TypeInfo(IAction);
  FCategory := Categ;
  FImagIndex := AImageIndex;
  FHint := AHint;
  FPaths := APaths;
  FAutoCheck := AAutoCheck;
  FChecked := AChecked;
  FEnabled := AEnabled;
  FGroupIndex := AGroupIndex;
  if not Capt.StartsWith('-') then FCaption := Capt
  else
   begin
    FCaption := Capt.Substring(1);
    FDivider := True;
   end;
end;


{ StaticActionAttribute }

constructor StaticActionAttribute.Create(const Capt, Categ: string; AImageIndex: Integer; const APaths, AHint: string; AAutoCheck, AChecked: Boolean; AGroupIndex: Integer; AEnabled: Boolean);
begin
  inherited;
  FModel := TypeInfo(TStaticAction);
end;

{ DinamicActionAttribute }

constructor DynamicActionAttribute.Create(const Capt, Categ: string; AImageIndex: Integer; const APaths, AHint: string; AAutoCheck, AChecked: Boolean; AGroupIndex: Integer; AEnabled: Boolean);
begin
  inherited;
  FModel := TypeInfo(TDynamicAction);
end;

{ TShowInfos }

class operator TShowInfos.Implicit(const Value: string): TShowInfos;
 var
  bar, s: string;
  all, pf: TArray<string>;
  si: TShowInfo;
  mp: TMenuPath;
begin
  SetLength(Result.Data, 0);
  for bar in Value.Split([';'], ExcludeEmpty) do // bar paths
   begin
    all := bar.Trim.Split([':']);
    si.Bar := all[0].Trim.ToInteger;
    SetLength(si.path, 0);
    if Length(all) > 1 then for s in all[1].Split(['.'], ExcludeEmpty) do
     begin
      pf := s.Split(['|'], ExcludeEmpty);
      mp.Caption := pf[0];
      if Length(pf) > 1 then mp.Index := pf[1].Trim.ToInteger() else mp.Index := -1;
      CArray.Add<TMenuPath>(si.path, mp);
     end;
    if Length(all) > 2 then si.MenuIndex := all[2].Trim.ToInteger else si.MenuIndex := -1;
    CArray.Add<TShowInfo>(Result.Data, si);
   end;
end;

{$REGION 'TICustomAction'}

{ TICustomAction }

class function TICustomAction.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TICustomAction(Result).FRefCount := 1;
end;

constructor TICustomAction.Create;
begin
  inherited Create(Application.MainForm);
  FPriority := PRIORITY_IComponent;
end;

constructor TICustomAction.CreateUser(const ACaption, ACategory: String; AImagIndex, AGroupIndex: Integer;const AHint: string);
begin
  Create;
  Caption := ACaption;
  FDivider := Caption = '-';

  Category := ACategory;
  Hint := AHint;
  ImageIndex := AImagIndex;
  GroupIndex := AGroupIndex;
end;

constructor TICustomAction.CreateUser(atr: ActionAttribute);
begin
  Create;
  FPaths := atr.Paths;
  Caption := atr.Caption;
  Category := atr.Category;
  Hint := atr.Hint;
  ImageIndex := atr.ImagIndex;
  GroupIndex := atr.GroupIndex;
  Enabled := atr.Enabled;
  AutoCheck := atr.AutoCheck;
  Checked := atr.Checked;
  FDivider := atr.FDivider;
end;

procedure TICustomAction.DefaultShow;
 var
  s: TShowInfo;
  am : IActionProvider;
begin
  if Supports(GlobalCore, IActionProvider, am) then
  for s in TShowInfos(FPaths).Data do am.ShowInBar(s.Bar, s.Path, Self, s.MenuIndex);
end;

destructor TICustomAction.Destroy;
begin
  TDebug.Log('TICustomAction.Destroy %s', [Caption]);
  inherited;
end;

function TICustomAction.DividerBefore: Boolean;
begin
  Result := FDivider;
end;

procedure TICustomAction.AfterConstruction;
begin
  inherited;
  AtomicDecrement(FRefCount);
end;

procedure TICustomAction.SetCategory(const AValue: String);
begin
  Category := AValue;
end;
function TICustomAction.GetImageIndex: System.UITypes.TImageIndex;
begin
  Result := ImageIndex;
end;
function TICustomAction.GetAutoCheck: Boolean;
begin
  Result := AutoCheck;
end;
function TICustomAction.GetCaption: String;
begin
  Result := Caption;
end;
function TICustomAction.GetCategory: String;
begin
  Result := Category;
end;
function TICustomAction.GetChecked: Boolean;
begin
  Result := Checked;
end;

function TICustomAction.GetEnabled: Boolean;
begin
  Result := Enabled;
end;
function TICustomAction.GetGroupIndex: Integer;
begin
  Result := GroupIndex;
end;
function TICustomAction.GetHint: String;
begin
  Result := Hint;
end;

function TICustomAction.GetItemName: String;
begin
  Result := Name;
end;

function TICustomAction.GetPath: String;
begin
  Result := FPaths;
end;

procedure TICustomAction.Loaded;
begin
  inherited Loaded;
  (GlobalCore as IActionProvider).RegisterAction(Self as IAction);
end;

function TICustomAction.Model: ModelType;
begin
  Result := ClassInfo;
end;

procedure TICustomAction.SetItemName(const Value: String);
begin
  Name := Value;
end;
function TICustomAction.Priority: Integer;
begin
  Result := FPriority;
end;
function TICustomAction.RootName: String;
begin
  Result := ClassName;
  Delete(Result, 1, 1);
end;
function TICustomAction.SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult;
begin
  Result := TDebug.HandleSafeCallException(Self, ExceptObject, ExceptAddr);
end;
// Iinterface
function TICustomAction.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := E_NOINTERFACE;
  if GetInterface(IID, Obj) then Exit(S_OK)
end;
function TICustomAction._AddRef: Integer;
begin
  Result := AtomicIncrement(FRefCount);
end;
function TICustomAction._Release: Integer;
begin
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then Destroy;
end;

{$ENDREGION}

{$REGION 'TICustRTTIAction TStaticAction TIDynamicAction TDynamicAction'}

{ TICustRTTIAction }

function TICustRTTIAction.CheckMethod: Boolean;
 var
  ct: TRttiContext;
begin
  if Assigned(FMethod) then Exit(True);
  ct := TRttiContext.Create;
  FModelType := GContainer.GetModelType(FActionClass);
  FLiveTime := GContainer.GetModelLiveTime(FModelType);
  FInstanceType := ct.GetType(FModelType).AsInstance;
  FMethod := FInstanceType.GetMethod(FMethodName);
  Result := Assigned(FMethod);
end;

function TICustRTTIAction.Execute: Boolean;
 var
  i: IInterface;
begin
  if Caption = '-' then Exit(inherited Execute);
  if not CheckMethod then Exit(False);
  Result := True;
  if FMethod.IsClassMethod then FMethod.Invoke(FInstanceType.MetaclassType, [TValue.From<IAction>(Self as IAction)])
  else if ((FLiveTime in [ltSingletonNamed, ltTransientNamed]) and GContainer.TryGetInstance(FModelType, InstanceName, i))
       or ((FLiveTime = ltSingleton) and GContainer.TryGetInstance(FModelType, i)) then
            FMethod.Invoke(TObject(i), [TValue.From<IAction>(Self as IAction)])
  else Result := False;
  ActionComponent := nil;
end;

{ TStaticAction }

constructor TStaticAction.Create;
begin
  inherited;
  FPriority := PRIORITY_NoStore;
end;

function TStaticAction.OwnerExists: Boolean;
begin
  Result := Assigned(GContainer.GetModelType(ActionComponentClass));
end;

{ TIDynamicAction }

function TIDynamicAction.OwnerExists: Boolean;
 var
   m: ModelType;
begin
  m := GContainer.GetModelType(ActionComponentClass);
  Result := Assigned(m) and GContainer.Contains(m, InstanceName)
end;

{ TDynamicAction }

constructor TDynamicAction.CreateUser(atr: ActionAttribute; const InstName: string);
begin
  inherited CreateUser(atr);
  Paths := StringReplace(Paths,'<I>', InstName, [rfReplaceAll]);
  Caption := StringReplace(Caption,'<I>', InstName, [rfReplaceAll]);
  Category := StringReplace(Category,'<I>', InstName, [rfReplaceAll]);
  Hint := StringReplace(Hint,'<I>', InstName, [rfReplaceAll]);
end;

function TDynamicAction.OwnerExists: Boolean;
 var
  m: ModelType;
begin
  m := GContainer.GetModelType(ActionComponentClass);
  Result := Assigned(m) and GContainer.Contains(m, InstanceName)
end;

{$ENDREGION}

{ TActionEnum }

constructor TActionEnum.Create;
begin
  inherited;
  FPriority := PRIORITY_IComponent-10;
end;

procedure TActionEnum.Load;
begin
  (TRegistryStorable<IAction>.Create(Self, PATH) as IStorable).Load;
end;

procedure TActionEnum.Save;
begin
  (TRegistryStorable<IAction>.Create(Self, PATH) as IStorable).Save;
end;

{$REGION ' ActionResolver '}

{ TSaticActionResolver }

type
  TStaticActionResolver = class(TCustomAttributeInjection)
  protected
    function Support(a: TCustomAttribute): Boolean; override;
    procedure Inject(RootModel: TRttiInstanceType; RttiMember: TRttiMember; Atr: TCustomAttribute); override;
  end;

function TStaticActionResolver.Support(a: TCustomAttribute): Boolean;
begin
  Result := a is StaticActionAttribute;
end;

procedure TStaticActionResolver.Inject(RootModel: TRttiInstanceType; RttiMember: TRttiMember; Atr: TCustomAttribute);
 var
  sa: TStaticAction;
  s: string;
//  ap: IActionProvider;
begin
  s:= Format('%s_%s',[RootModel.Name, RttiMember.Name]);
  if GContainer.Contains(TypeInfo(TStaticAction), s) then Exit;
  sa := TStaticAction.CreateUser(StaticActionAttribute(Atr));
  sa.Name := s;
  sa.ActionComponentClass := RootModel.Name;
  sa.ActionMethodName := RttiMember.Name;
  TRegister.AddType<TStaticAction>.AddInstance(s, sa as IInterface);
  (GlobalCore as IActionProvider).RegisterAction(sa);
  // создаютс€ при при загрузке будет позднее вызван ResetActions в основной программе
end;

{ TDynamicActionResolver }

type
  TDynamicActionResolver = class(TCustomAttributeInjection)
  protected
    function Support(a: TCustomAttribute): Boolean; override;
    procedure Inject(RootModel: TRttiInstanceType; RttiMember: TRttiMember; Atr: TCustomAttribute; const InstName: string); override;
  end;

function TDynamicActionResolver.Support(a: TCustomAttribute): Boolean;
begin
  Result := a is DynamicActionAttribute;
end;

procedure TDynamicActionResolver.Inject(RootModel: TRttiInstanceType; RttiMember: TRttiMember; Atr: TCustomAttribute; const InstName: string);
 var
  da: TDynamicAction;
  s, txt: string;
  i: IInterface;
  ic: ICaption;
begin
  s:= Format('%s_%s',[InstName, RttiMember.Name]);
  if GContainer.Contains(TypeInfo(TDynamicAction), s) then Exit;
  // при создании зависимости ActionComponent должен быть создан
  if GContainer.TryGetInstance(RootModel.Handle, InstName, i, true) and Supports(i, ICaption, ic) then txt := ic.Text else txt := InstName;
  da := TDynamicAction.CreateUser(DynamicActionAttribute(Atr), txt);
  da.Name := s;
  da.ActionComponentClass := RootModel.Name;
  da.ActionMethodName := RttiMember.Name;
  da.InstanceName := InstName;
  TRegister.AddType<TDynamicAction>.AddInstance(s, da as IInterface);
  (GlobalCore as IActionProvider).RegisterAction(da);
  // создаютс€ пользователем необходимо записать изменени€ в реестр SaveActionManager  IActionEnum.Save  !!!!
  // отображение действий на Bars
  da.DefaultShow;
  (GlobalCore as IActionProvider).UpdateWidthBars;
end;

{$ENDREGION}

initialization
  RegisterClass(TIDynamicAction);
  GContainer.RegisterAttrInjection(TStaticActionResolver.Create);
  GContainer.RegisterAttrInjection(TDynamicActionResolver.Create);
  TRegister.AddType<TActionEnum, IActionEnum, IStorable>.LiveTime(ltSingleton);
  TRegister.AddType<TStaticAction, IAction>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TIDynamicAction, IAction>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TDynamicAction, IAction>.LiveTime(ltSingletonNamed);
end.
