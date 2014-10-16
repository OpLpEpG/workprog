unit DBEnumers;

interface

uses System.SysUtils, System.Generics.Collections, System.Classes, DBIntf, DBImpl,
  debug_except, RootIntf, DeviceIntf, ExtendIntf, Container, RootImpl, AbstractPlugin, PluginAPI, DockIForm, DButil;

type
  TDBEnum<T: IManagItem> = class(TRootServiceManager<T>)
  private
    FRootTableName: string;
  protected
    class function SupportPublishedChanged: Boolean; override;
    procedure SetItemChanged(const Value: string); override;
    procedure DoAfterAdd(mi: IManagItem); override;
    procedure DoAfterRemove(mi: IManagItem); override;
    procedure New; override;
    procedure Load; override;
    function Query: TAsyncADQuery; inline;
  public
    constructor CreateWithName(const TableName: string);
  end;

  TConnectIOs = class(TDBEnum<IConnectIO>, IConnectIOEnum);

  TDevices = class(TDBEnum<IDevice>, IDeviceEnum)
  protected
    procedure DoAfterAdd(mi: IManagItem); override;
    procedure DoAfterRemove(mi: IManagItem); override;
    procedure New; override;
  end;


implementation

uses tools;

{$REGION 'TDBEnum<T>'}

{ TDBEnum<T> }

class function TDBEnum<T>.SupportPublishedChanged: Boolean;
begin
  Result := True;
end;

{procedure TDBEnum<T>.AfteActionManagerLoad;
 var
  i: T;
  ml: I N o tifyAfteActionManagerLoad;
  a: TArray<T>;
begin
  a := GContainer.InstancesAsArray<T>(true);
  TArray.Sort<T>(a, TManagItemComparer<T>.Create);
  for i in a do if Supports(i, IN otifyAf teActionManagerLoad, ml) then ml.AfteActionManagerLoad();
end;}

constructor TDBEnum<T>.CreateWithName(const TableName: string);
begin
  Create();
  FRootTableName := TableName;
end;

procedure TDBEnum<T>.DoAfterAdd(mi: IManagItem);
 var
  ir: TInstanceRec;
begin
  if GContainer.TryGetInstRec(mi.Model, mi.IName, ir) then
  begin
   Query.Acquire;
   try
    Query.ExecSQL(Format(ADD_VAL, [FRootTableName, mi.IName, mi.Priority, ir.Text]));
   finally
    Query.Release;
   end;
  end;
  inherited;
end;

procedure TDBEnum<T>.DoAfterRemove(mi: IManagItem);
begin
  Query.Acquire;
  try
   Query.ExecSQL(Format(DEL_VAL, [FRootTableName, mi.IName]));
  finally
   Query.Release;
  end;
  inherited;
end;

procedure TDBEnum<T>.SetItemChanged(const Value: string);
 var
  ir: TInstanceRec;
begin
  inherited;
  if not GContainer.TryGetInstRecKnownServ(TypeInfo(T), Value, ir) then Exit;
  Query.Acquire;
  try
   Query.ExecSQL(Format(CHNG_VAL, [FRootTableName, ir.Text, Value]));
  finally
   Query.Release;
  end;
end;

procedure TDBEnum<T>.Load;
 var
  v: variant;
  Q: TAsyncADQuery;
begin
  Q := TAsyncADQuery.Create();
  Q.Connection := Query.Connection;
  Q.Acquire;
  try
   Q.Open(Format(LOAD_TBL, [FRootTableName]));
   for v in Q do
    try
     DoLoadItem(v.ObjData);
    except
     on E: Exception do TDebug.DoException(E, False);
    end;
  finally
   Q.Release;
   Q.Free;
  end;
end;

procedure TDBEnum<T>.New;
begin
  Query.Acquire;
  try
   Query.ExecSQL(Format(CREATE_TBL, [FRootTableName]));
  finally
   Query.Release;
  end;
end;

function TDBEnum<T>.Query: TAsyncADQuery;
begin
  Result := ConnectionsPool.Query;
end;

{$ENDREGION}

{$REGION 'TDevices'}

{ TDevices }

procedure TDevices.New;
begin
  inherited;
  Query.Acquire;
  try
   Query.ExecSQL(ALTER_DEV);
   Query.ExecSQL(ALTER_DEV2);
   Query.ExecSQL(ALTER_DEV3);
   Query.ExecSQL(CREATE_MODULE_TBL);
   Query.ExecSQL(CREATE_TRR_TBL);
   Query.ExecSQL(CREA_EVENTS_TBL);
   Query.ExecSQL(CREATE_TRR_VIEW);
   Query.ExecSQL(CREATE_RAM_VIEW);
  finally
   Query.Release;
  end;
end;

procedure TDevices.DoAfterAdd(mi: IManagItem);
 var
  a: Integer;
  aa: INotifyAfterAdd;
  ir: TInstanceRec;
begin
  GContainer.TryGetInstRec(mi.Model, mi.IName, ir);
  Query.Acquire;
  try
   Query.ExecSQL(Format(ADD_DEV, [mi.IName, mi.Priority, ir.Text, (mi as ICaption).Text]));
  finally
   Query.Release;
  end;
  Query.Acquire;
  try
   for a in (mi as IDevice).GetAddrs do Query.ExecSQL(Format(ADD_MODUL, [a, mi.IName]));
  finally
   Query.Release;
  end;
  Notify('S_AfterAdd');
  if Supports(mi, INotifyAfterAdd, aa) then aa.AfterAdd();
end;

procedure TDevices.DoAfterRemove(mi: IManagItem);
 var
  a, id: Integer;
begin
  if not GetDevID(Query, mi as IDevice, id) then Exit;
  Query.Acquire;
  try
   for a in (mi as IDevice).GetAddrs do
    begin
     Query.ExecSQL(Format(DROP_TABLE_VAL, ['Log', a, id]));
     Query.ExecSQL(Format(DROP_TABLE_VAL, ['Ram', a, id]));
    end;
  finally
   Query.Release;
  end;
  inherited;
  Query.Acquire;
  try
   Query.ExecSQL('VACUUM;');
  finally
   Query.Release;
  end;
end;

{$ENDREGION}

initialization
  RegisterClasses([TDevices, TConnectIOs]);
  TRegister.AddType<TDevices, IDeviceEnum>
           .LiveTime(ltSingletonNamed)
           .AddInstance(TDevices.CreateWithName('Device') as IInterface);
  TRegister.AddType<TConnectIOs, IConnectIOEnum>
           .LiveTime(ltSingletonNamed)
           .AddInstance(TConnectIOs.CreateWithName('ConnectIO') as IInterface);
finalization
  GContainer.RemoveModel<TDevices>;
  GContainer.RemoveModel<TConnectIOs>;
end.
