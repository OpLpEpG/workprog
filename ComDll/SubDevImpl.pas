unit SubDevImpl;

interface

uses System.SysUtils,  System.Classes, System.TypInfo, System.Rtti,
     System.Bindings.Helper,
     Actns, DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl, RootIntf;

type
   ISetCollection = interface
   ['{2248E634-5DD9-48B1-B525-035E06AA3755}']
     procedure SetCollection(Value: TCollection);
     procedure SetIndex(Value: Integer);
   end;

   TRootDevice = class;
   TSubDev = class(TICollectionItem, ISubDevice, ISetCollection, ICaption)
   private
     FIName: string;
   protected
     FSubDevice: TSubDev;
//     procedure SetChild(SubDevice: ISubDevice); virtual;

     function GetItemName: string;
     function GetCategory: TSubDeviceInfo; virtual; abstract;
     function GetCaption: string; virtual; abstract;

     function GetDeviceName: string;
     procedure SetDeviceName(const Value: string);
     function ICaption.GetCaption = GetDeviceName;
     procedure ICaption.SetCaption = SetDeviceName;

     procedure BeforeRemove(); virtual;

     procedure OnUserRemove; virtual;
   public
     procedure InputData(Data: Pointer; DataSize: integer); virtual; abstract;
     procedure DeleteData(DataSize: integer); virtual;
     constructor Create; reintroduce; overload; virtual;
     constructor Create(Collection: TCollection); overload; override; final;
     destructor Destroy; override;
     function Owner: TRootDevice; inline;
     property Category: TSubDeviceInfo read GetCategory;
     property Caption: string read GetCaption;
   published
     property IName: String read GetItemName write FIName;
   end;

   TSubDev<T> = class(TSubDev, ISubDevice<T>)
   protected
     FS_Data: T;
     function GetData: T;
//     procedure BeforeRemove(); override;
//     procedure OnUserRemove; override;
     procedure NotifyData;
   public
     property S_Data: T read FS_Data write FS_Data;
   end;

   TSubDevWithForm<T> = class(TSubDev<T>)
   private
     FFormClass, FPrefixFormName{, FPropertyName}: string;
   protected
//     FormData: IForm;
     function TryGetSubDevForm(const model, prefix: string; out F: IForm; NeedCreate: Boolean = False): Boolean;
     procedure InitConst(const aFormClass, aPrefixFormName{, aPropertyName}: string);
     procedure RemoveUserForm; virtual;
     procedure BeforeRemove(); override;
     procedure OnUserRemove; override;
     procedure DoSetup(Sender: IAction); virtual;
   end;

  TSubDevCollection = class(TICollection)
  private
    FOwner: TIComponent;
  public
    constructor Create(Owner: TIComponent); reintroduce;
   public
     property OwnerDevice: TIComponent read FOwner;
  end;

  TRootDevice = class(TDevice, IRootDevice, INotifyBeforeRemove)
  private
    function TryFindAvailIndex(const Category: string; out idx: Integer; needFreeUniqe: boolean): Boolean;
    procedure UpdateParents;
  protected
    FSubDevs: TSubDevCollection;
    procedure DefineProperties(Filer: TFiler); override;
    function GetSubDevices: TArray<ISubDevice>;
    procedure Remove(SubDevice: ISubDevice);
    function AddOrReplase(SubDeviceType: ModelType): ISubDevice;
    function TryMove(SubDevice: ISubDevice; UpTrueDownFalse: Boolean): Boolean;
    function GetService: PTypeInfo; virtual; abstract;
    function GetStructure: TArray<TSubDeviceInfo>; virtual; abstract;
    procedure Loaded; override;
    procedure BeforeRemove(); virtual;
  public
    constructor Create(); override;
    destructor Destroy; override;
    procedure DoSetup(Sender: IAction); virtual;
  end;

implementation

procedure TRootDevice.BeforeRemove;
 var
  c: TCollectionItem;
begin
  for c in FSubDevs do TSubDev(c).BeforeRemove();
  ((GContainer as IFormEnum) as IStorable).Save;
end;

constructor TRootDevice.Create;
begin
  inherited;
  FSubDevs := TSubDevCollection.Create(Self);
  FStatus := dsReady;
end;

procedure TRootDevice.DefineProperties(Filer: TFiler);
begin
  inherited;
  FSubDevs.RegisterProperty(Filer, 'SubDevs');
end;

procedure TRootDevice.UpdateParents;
 var
  i: Integer;
begin
  for i := 1 to FSubDevs.Count-1 do
   begin
    TDebug.Log('%d ', [i]);
    TSubDev(FSubDevs.Items[i-1]).FSubDevice := TSubDev(FSubDevs.Items[i]);
   end;
  TSubDev(FSubDevs.Items[FSubDevs.Count-1]).FSubDevice := nil;
end;

destructor TRootDevice.Destroy;
 var
  c: TCollectionItem;
begin
  for c in FSubDevs do GContainer.RemoveInstance(c.ClassInfo, TSubDev(c).IName);
  FSubDevs.Free;
  if Assigned(IConnect) then
   begin
    ConnectIO.FTimerRxTimeOut.Enabled := False;
    ConnectIO.FEventReceiveData := nil;
   end;
  inherited;
//  try
//   (GContainer as IActionProvider).UpdateWidthBars;
//  except
//   on E: Exception do TDebug.DoException(E);
//  end;
end;

function TRootDevice.AddOrReplase(SubDeviceType: ModelType): ISubDevice;
 var
  i: Integer;
  II:IInterface;
  c: string;
begin
  Result := nil;
  if GContainer.TryGetInstance(SubDeviceType, ii) then
   begin
    Supports(II, ISubDevice, Result);
    if TryFindAvailIndex(Result.Category.Category, i, True) then
     begin
      (Result as ISetCollection).SetCollection(FSubDevs);
      (Result as ISetCollection).SetIndex(i);
      TRegistration.Create(SubDeviceType).LiveTime(ltTransientNamed).Add(GetService).AddInstance(Result.IName, Result as IInterface);
      UpdateParents;
      MainScreenChanged;
     end
    else
     begin
      c := Result.Category.Category;
      TObject(Result).Free;
      raise EBaseException.CreateFmt('Категория неподдерживается %s', [c]);
     end;
   end;
end;

procedure TRootDevice.DoSetup(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_SetupRootDevice>(d) then (d as IDialog<IRootDevice>).Execute(Self as IRootDevice);
end;

function TRootDevice.GetSubDevices: TArray<ISubDevice>;
 var
  i: Integer;
begin
  SetLength(Result, FSubDevs.Count);
  for i := 0 to FSubDevs.Count-1 do Result[i] := TICollectionItem(FSubDevs.Items[i]) as ISubDevice;
end;

procedure TRootDevice.Loaded;
 var
  c: TCollectionItem;
begin
  inherited;
  for c in FSubDevs do TRegistration.Create(c.ClassInfo).Add(GetService).AddInstance(TSubDev(c).IName, TSubDev(c) as IInterface);
  UpdateParents;
end;

procedure TRootDevice.Remove(SubDevice: ISubDevice);
 var
  i: Integer;
begin
  for i := 0 to FSubDevs.Count-1 do if TSubDev(FSubDevs.Items[i]) as ISubDevice = SubDevice then
   begin
    GContainer.RemoveInstKnownServ(GetService(), SubDevice.IName);
    TSubDev(FSubDevs.Items[i]).OnUserRemove;
    FSubDevs.Delete(i);
    UpdateParents;
    MainScreenChanged;
    Break;
   end;
end;

function TRootDevice.TryFindAvailIndex(const Category: string; out idx: Integer; needFreeUniqe: boolean): Boolean;
 var
  si: TSubDeviceInfo;
begin
  idx := 0;
  for si in GetStructure do if si.Category = Category then
   begin
    if needFreeUniqe and (idx < FSubDevs.Count)
      and (TSubDev(FSubDevs.Items[idx]).GetCategory.Category = Category)
      and (sdtUniqe in TSubDev(FSubDevs.Items[idx]).GetCategory.Typ) then
       begin
        TSubDev(FSubDevs.Items[idx]).BeforeRemove;
        GContainer.RemoveInstKnownServ(GetService(), TSubDev(FSubDevs.Items[idx]).IName);
        FSubDevs.Delete(idx);
       end;
    Exit(True);
   end
   else while (idx < FSubDevs.Count) and (TSubDev(FSubDevs.Items[idx]).GetCategory.Category = si.Category) do inc(idx);
  Result := False;
end;

function TRootDevice.TryMove(SubDevice: ISubDevice; UpTrueDownFalse: Boolean): Boolean;
 var
  i: Integer;
begin
  Result := False;
  for i := 0 to FSubDevs.Count-1 do if TSubDev(FSubDevs.Items[i]) as ISubDevice = SubDevice then
   begin
    if UpTrueDownFalse and (i-1 > 0) and (TSubDev(FSubDevs.Items[i-1]).GetCategory.Category = SubDevice.Category.Category) then
     begin
      FSubDevs.Items[i].Index := i-1;
      UpdateParents;
      Exit(True);
     end;
    if not UpTrueDownFalse and (i+1 < FSubDevs.Count) and (TSubDev(FSubDevs.Items[i+1]).GetCategory.Category = SubDevice.Category.Category) then
     begin
      FSubDevs.Items[i].Index := i+1;
      UpdateParents;
      Exit(True);
     end;
   end;
end;

{ TSubDev }

constructor TSubDev.Create;
begin
end;

constructor TSubDev.Create(Collection: TCollection);
begin
  Create;
  inherited;
end;

destructor TSubDev.Destroy;
begin
  TDebug.Log('TSubDev.Destroy  %s  %s  %s', [IName, Category.Category, Caption]);
  TBindHelper.RemoveExpressions(Self);
  inherited;
end;

procedure TSubDev.DeleteData(DataSize: integer);
begin
end;

procedure TSubDev.BeforeRemove;
begin
end;

procedure TSubDev.OnUserRemove;
begin
end;

function TSubDev.GetDeviceName: string;
begin
  Result := (TSubDevCollection(Collection).FOwner as ICaption).Text;
end;

function TSubDev.GetItemName: string;
begin
  if FIName = '' then FIName := ClassName.Substring(1) + FormatDateTime('yymdhnsz', now);
  Result := FIName;
end;

function TSubDev.Owner: TRootDevice;
begin
  Result := TRootDevice(TSubDevCollection(Collection).OwnerDevice)
end;

//procedure TSubDev.SetChild(SubDevice: ISubDevice);
//begin
//  FSubDevice := TSubDev(SubDevice);
//end;

procedure TSubDev.SetDeviceName(const Value: string);
begin
  raise Exception.Create('Error Writing programm call procedure TSubDev.SetDeviceName(const Value: string);');
end;

{ TSubDevCollection }

constructor TSubDevCollection.Create(Owner: TIComponent);
begin
  inherited Create(TSubDev);
  FOwner := Owner;
end;

{ TSubDevWithForm }

procedure TSubDevWithForm<T>.BeforeRemove;
begin
  RemoveUserForm;
end;

procedure TSubDevWithForm<T>.OnUserRemove;
begin
  RemoveUserForm;
end;

function TSubDevWithForm<T>.TryGetSubDevForm(const model, prefix: string; out F: IForm; NeedCreate: Boolean = False): Boolean;
 var
  m: ModelType;
  s: string;
begin
  Result := False;
  s := prefix + IName;
  F := (Gcontainer as IformEnum).Get(s);
  if Assigned(F) then Exit(True);
  m := GContainer.GetModelType(model);
  if Assigned(m) and NeedCreate then
    begin
     F := TIForm.NewForm(m, s);
     Result := Assigned(F);
     if Result then (Gcontainer as IformEnum).Add(F);
    end
end;

procedure TSubDevWithForm<T>.RemoveUserForm;
 var
  FormData: IForm;
begin
//  TBindHelper.RemoveSourceExpressions(Self, ['S_Data']);
  if TryGetSubDevForm(FFormClass, FPrefixFormName, FormData) then
   begin
    (Gcontainer as IformEnum).Remove(FormData);
    ((Gcontainer as IformEnum) as IStorable).Save;
   end;
end;

procedure TSubDevWithForm<T>.DoSetup(Sender: IAction);
 var
  FormData: IForm;
begin
  if TryGetSubDevForm(FFormClass, FPrefixFormName, FormData, True) then
   begin
    (FormData as IControlForm).ControlName := Owner.Name;
    (FormData as IRootControlForm).SubControlName := IName;
//    TBindHelper.RemoveSourceExpressions(Self, ['S_Data']);
//    TBindHelper.Bind(TObject(FormData),'C_Data', Self as IInterface, ['S_Data']);
    FormData.Show;
   end;
end;

procedure TSubDevWithForm<T>.InitConst(const aFormClass, aPrefixFormName{, aPropertyName}: string);
begin
  FFormClass := aFormClass;
  FPrefixFormName := aPrefixFormName;
//  FPropertyName := aPropertyName;
end;

//procedure TSubDevWithForm<T>.Loaded;
// var
//  FormData: IForm;
//begin
//  if TryGetSubDevForm(FFormClass, FPrefixFormName, FormData) then
//   begin
//    TBindHelper.Bind(TObject(FormData),'C_Data', Self as IInterface, ['S_Data']);
//   end;
//end;

{ TSubDev<T> }

procedure TSubDev<T>.NotifyData;
begin
  TBindings.Notify(Self, 'S_Data');
end;

function TSubDev<T>.GetData: T;
begin
  Result := FS_Data;
end;

//procedure TSubDev<T>.BeforeRemove;
//begin
//  TBindHelper.RemoveSourceExpressions(Self, ['S_Data']);
//end;

//procedure TSubDev<T>.OnUserRemove;
//begin
//  TBindHelper.RemoveSourceExpressions(Self, ['S_Data']);
//end;

end.
