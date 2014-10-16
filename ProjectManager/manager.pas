unit manager;

interface

uses debug_except, RootIntf, DeviceIntf, ExtendIntf, Container, DBIntf, DBImpl, System.DateUtils,
     RootImpl, AbstractPlugin, PluginAPI, DockIForm, DButil, System.SyncObjs, DBEnumers,
     Vcl.Dialogs, System.Variants, Vcl.Forms, Winapi.Windows,
     System.SysUtils, Vcl.Graphics, System.Classes, System.Generics.Collections, System.Generics.Defaults, RTTI, System.TypInfo, Xml.XMLIntf,
     FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
     FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite;

 type
  EManagerexception = class(EBaseException);

  TManager = class(TAbstractPlugin,
                               IManager,
                               IProjectData,
                               IProjectOptions,
                               IMetrology{,
                               IDelayManager})
  private
//    VSetTime, VDelay, VWorkTime: Variant;
//    FDelayStatus: DelayStatus;
    FProject: string;
    FDBConnection: IDBConnection;
    FC_TableUpdate: string;

//    FSQLMonitor: TSQLMonitor;
//    DbgMon: TFDMoniRemoteClientLink;

//    procedure ClearDevsAndIOs;
    procedure SetTableUpdate(const Value: string);
    procedure CreateTables;
//    procedure AddOption(AParams: array of Variant);
    function Query: TAsyncADQuery; inline;
    procedure AddOption(AParams: array of Variant);
  protected
    { IManager }
    procedure ClearItems(ClearItems: EClearItems = [ecIO, ecDevice, ecForm]); { TODO : убрать как устаревшее }
    function ProjectName: string;
    procedure LoadScreen();
    procedure SaveScreen();
    procedure NewProject(const FileName: string);
    procedure LoadProject(const FileName: string);

    // IProjectData,
    procedure SetMetaData(Dev: IDevice; Adr: Integer; MetaData: IXMLInfo);
    procedure SaveLogData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; StdOnly: Boolean = False);
    procedure SaveRamData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; CurAdr, CurKadr: Integer; CurTime: TDateTime; FModulID: Integer);

    procedure IMetrology.Setup = SetMetrol;
    procedure SetMetrol(MetrolID: Integer; TrrData: IXMLInfo; const SourceName: string);

    // IProjectOptions
    function GetOption(const Name: string): Variant;
    procedure SetOption(const Name: string; const Value: Variant);
    procedure AddOrIgnore(const Name, Section: string;
                          const Description: string = '';
                          const SectionDescription: string ='';
                          const Units: string = '';
                          Hidden: Boolean = True;
                          ReadOnly: Boolean = False;
                          DataType: Integer = -1);

    // IDelayManager = interface
//    procedure InternalInitDelay;
//    procedure SetDelay(SetTime, Delay, WorkTime: Variant);
//    procedure GetDelay(var SetTime, Delay, WorkTime: Variant; var ds: DelayStatus);
//    procedure StopDelay();

    class function GetHInstance: THandle; override;
  public
//    constructor Create; override;
//    destructor Destroy; override;
    class function PluginName: string; override;

    property Option[const Name: string]: Variant read GetOption write SetOption;

    property S_ProjectChange: string read FProject write FProject;

    property C_TableUpdate: string read FC_TableUpdate write SetTableUpdate;
    property S_TableUpdate: string read FC_TableUpdate write SetTableUpdate;
  end;

implementation

uses tools, PrjTool;

const
  IFORMS_INI_DIR = 'IFormObjs';

{$REGION 'TManager'}

{ TManager }

class function TManager.GetHInstance: THandle;
begin
  Result := HInstance;
end;

class function TManager.PluginName: string;
begin
  Result := 'Управление динамическими объектами';
end;

{constructor TManager.Create;
begin
  inherited;
  DbgMon := TADMoniRemoteClientLink.Create(nil);
  TDebug.Log('----------- TManager.Create ---------------------');
end;}

{destructor TManager.Destroy;
begin
  TDebug.Log('----------- TManager.Destroy ---------------------');
  DbgMon.Free;
  inherited;
end;}

{procedure TManager.GetDelay(var SetTime, Delay, WorkTime: Variant; var ds: DelayStatus);
begin
  ds := FDelayStatus;
  SetTime := VSetTime;
  Delay := VDelay;
  WorkTime := VWorkTime;
end;

procedure TManager.SetDelay(SetTime, Delay, WorkTime: Variant);
begin
  VSetTime := SetTime;
  VDelay := Delay;
  VWorkTime := WorkTime;
  FDelayStatus := dsSetDelay;
  Option['DelayStatus'] := FDelayStatus;
  Option['Постановка'] := VSetTime;
  Option['Задержка'] := VDelay;
  Option['Работа'] := VWorkTime;
end;

procedure TManager.StopDelay;
begin
  Option['DelayStatus'] := 2;
  FDelayStatus := dsEndDelay;
end;

procedure TManager.InternalInitDelay;
begin
  FDelayStatus := DelayStatus(Integer(Option['DelayStatus']));
  VSetTime := Option['Постановка'];
  VDelay := Option['Задержка'];
  VWorkTime := Option['Работа'];
end; }

function TManager.GetOption(const Name: string): Variant;
begin
  Query.Acquire;
  try
   Result := TFDConnection(Query.Connection).ExecSQLScalar('SELECT Значение FROM Options WHERE Имя = :P',[Name], [ftString]);
  finally
   Query.Release;
  end;
end;

procedure TManager.SetOption(const Name: string; const Value: Variant);
 var
  v: Variant;
begin
  Query.Acquire;
  try
   if VarIsType(Value, varDate) then v := VarAsType(Value, varDouble)
   else v := Value;
   Query.ExecSQL('UPDATE Options SET Значение = :P1 WHERE Имя = :P2', [v, Name], [ftString, ftString]);
  finally
   Query.Release;
  end;
end;

procedure TManager.SetMetaData(Dev: IDevice; Adr: Integer; MetaData: IXMLInfo);
 var
  id: Integer;
  function CreaTbl(root: IXMLNode; const nme, sql: string): string;
   var
    vl: string;
  begin
    if not Assigned(root) then Exit;
    Result := Format('%s_%d_%d', [nme, Adr, id]);
    vl := (THelperXMLtoDB.Create(Root) as IHelperXMLtoDB).FieldNamesWithTypes;//  TSaveData.ToValues(root);
    Query.ExecSQL(Format(sql, [Result, vl]));
  end;
  procedure AddMetr(root: IXMLNode);
   var
    n: IXMLNode;
  begin
    if not Assigned(root) then Exit;
    for n in XEnum(root) do Query.ExecSQL(Format(ADD_TRR, [n.NodeName, adr, id]));
  end;
begin
  if not GetDevID(Query, Dev, id) then Exit;
  Query.Acquire;
  try
   { TODO : добавить атрибуты проекта (пока для фильтра SQL SELECT) ???????}
   Query.ExecSQL(Format(CHNG_MODUL_META, [MetaData.XML, Adr, id]));
//   TDebug.Log(Query.Connection.ExecSQLScalar('SELECT max(id) FROM Modul'));
   Query.ExecSQL(Format(CHNG_MODUL_NAME, [MetaData.NodeName, Adr, id]));
   if MetaData.HasAttribute(AT_INFO) then Query.ExecSQL(Format(CHNG_MODUL_INF, [MetaData.Attributes[AT_INFO], Adr, id]));
   if MetaData.HasAttribute(AT_CHIP) then Query.ExecSQL(Format(CHNG_MODUL_CHIP, [Integer(MetaData.Attributes[AT_CHIP]), Adr, id]));
   if MetaData.HasAttribute(AT_SERIAL) then Query.ExecSQL(Format(CHNG_MODUL_SERIAL, [Integer(MetaData.Attributes[AT_SERIAL]), Adr, id]));
   CreaTbl(MetaData.ChildNodes.FindNode(T_WRK),'Log', CREA_LOG_VAL);
   CreaTbl(MetaData.ChildNodes.FindNode(T_RAM),'Ram', CREA_RAM_VAL);
   AddMetr(MetaData.ChildNodes.FindNode(T_MTR));
  finally
   Query.Release;
  end;
  S_TableUpdate := 'Modul';
end;

procedure TManager.SetMetrol(MetrolID: Integer; TrrData: IXMLInfo; const SourceName: string);
 var
  d: IDevice;
  de: IDeviceEnum;
  info, dev,  trr,  tip,  run: IXMLnode;
      fdev,       ftip, frun: IXMLnode;
  Vnomer, Vtime: Variant;
  id: Integer;
begin
  id := 0;
  de := GContainer as IDeviceEnum;
  Query.Acquire;
  try
   Query.Open(Format(GET_TRR_FROM_METR_ID, [MetrolID]));
    try
     // проверка аргкмннтов
     Query.First;
     if Query.Eof then raise EManagerexception.CreateFmt('Нет Устройства %d в базе данных',[MetrolID]);
     d := de.Get(Query['IName']);
     if not Assigned(d) then raise EManagerexception.CreateFmt('Нет Устройства %s',[Query['IName']]);

    info := (d as IDataDevice).GetMetaData.Info;
    if Assigned(info) then  dev := FindDev(info, Query['Адрес']);

     if not Assigned(dev) then raise EManagerexception.CreateFmt('Нет у %s модуля %d',[Query['IName'], Query['Адрес']]);

     trr := dev.ChildNodes.FindNode(T_MTR);
     tip := trr.ChildNodes.FindNode(Query['Тип']);
     if not Assigned(tip) then raise EManagerexception.CreateFmt('У %s модуля %d, нет метрологии %s',[Query['IName'], Query['Адрес'], Query['Тип']]);

     fdev := TrrData.ChildNodes[0];
     ftip := fdev.ChildNodes.FindNode(T_MTR).ChildNodes.FindNode(Query['Тип']);
     if not Assigned(ftip) then raise EManagerexception.CreateFmt('У импортируемой метрологии нет %s',[Query['Тип']]);
     if not HasXTree(tip, ftip) then raise EManagerexception.Create('Импортировать метрологию невозможно - неверная структура');
     // проверка без исключения
     if (fdev.NodeName <> 'ANY_DEVICE') and (fdev.NodeName <> dev.NodeName)  then
          MessageDlg(Format('Текущий файл тарировки прибора %s а выбран прибор %s',[fdev.NodeName, dev.NodeName]),
          TMsgDlgType.mtWarning, [mbOK], 0)
     else if fdev.HasAttribute(AT_SERIAL) and dev.HasAttribute(AT_SERIAL) and (fdev.Attributes[AT_SERIAL] <> dev.Attributes[AT_SERIAL]) then
          MessageDlg(Format('Текущий файл тарировки прибора с номером %s а выбран прибор с номером %s', [fdev.Attributes[AT_SERIAL], fdev.Attributes[AT_SERIAL]]),
          TMsgDlgType.mtWarning, [mbOK], 0);
     // выполнение
     // присвоение новых значений
     HasXTree(tip, ftip, procedure(EtalonRoot, EtalonAttr, TestRoot, TestAttr: IXMLNode)
     begin
       EtalonAttr.NodeValue := TestAttr.NodeValue;
     end);
     run := tip.ChildNodes.FindNode('RUN');
     frun := ftip.ChildNodes.FindNode('RUN');
     if Assigned(run) then tip.ChildNodes.Remove(run);
     if Assigned(frun) then tip.ChildNodes.Add(frun.CloneNode(True));
     id := Query['id'];
    finally
     Query.Close;
    end;
   if fdev.HasAttribute(AT_SERIAL) then Vnomer := Integer(fdev.Attributes[AT_SERIAL]);
   if ftip.HasAttribute(AT_TIMEATT) then Vtime := ftip.Attributes[AT_TIMEATT];
    // запись БД
   Query.ExecSQL(Format(CHNG_MODUL_META2, [dev.XML, id]));
   Query.ExecSQL(CHNG_TRR_SRC, [SourceName, fdev.NodeName, Vnomer, Vtime, MetrolID], [ftString, ftString, ftInteger, ftDateTime, ftInteger]);
  finally
   Query.Release;
  end;
  (de as IBind).Notify('S_PublishedChanged');
end;

procedure TManager.SaveLogData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; StdOnly: Boolean = False);
 var
  d: IOwnIntfXMLNode;
  Id: Integer;
begin
  d := (Data as IOwnIntfXMLNode);
  if not Assigned(d.Intf) then
   begin
    GetDevID(Query, dev, Id);
    d.Intf := TSaveLogData.Create(Data, ADD_LOG_VAL, Adr, id);
   end;
  (d.Intf as ISaveLogDataCash).SetStdOnly(StdOnly);
//  Tdebug.Log('SaveLogData START %d, %s    ', [adr, Data.ParentNode.NodeName]);
  (d.Intf as ISaveLogDataCash).SaveData(nil);{  procedure
   begin
     Tdebug.Log('SaveLogData END %d, %s    ', [adr, Data.ParentNode.NodeName]);
   end);}
end;

procedure TManager.SaveRamData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; CurAdr, CurKadr: Integer; CurTime: TDateTime; FModulID: Integer);
const
  {$J+} tick: Cardinal = 0;{$J-}
 var
  d: IOwnIntfXMLNode;
  Id: Integer;
  t: Cardinal;
begin
  t := GetTickCount;
  Query.Acquire;
  try
    d := (Data as IOwnIntfXMLNode);
    if not Assigned(d.Intf) then
     begin
      GetDevID(Query, dev, Id);
      d.Intf := TSaveData.Create(Data, ADD_RAM_VAL, Adr, id);
     end;
    (d.Intf as ISaveDataCash).SaveData(nil);
    Query.ExecSQL('UPDATE Modul SET ToAdr=:p1, ToKadr=:p2, ToTime=:p3 WHERE id = :p4', [CurAdr, CurKadr, DateTimeToJulianDate(CurTime), FModulID],
                                                                                        [ftInteger, ftFloat, ftTime, ftInteger]);
  finally
   Query.Release;
  end;
  if (t - tick) > 1000 then
   begin
    S_TableUpdate := 'Ram';
    tick := t;
   end;
end;

procedure TManager.ClearItems(ClearItems: EClearItems);
begin
  if ecIO in ClearItems then (GlobalCore as IConnectIOEnum).Clear;
  if ecDevice in ClearItems then (GlobalCore as IDeviceEnum).Clear;
  if ecForm in ClearItems then (GlobalCore as IFormEnum).Clear;//  FFormEnum.Clear;
end;

function TManager.ProjectName: string;
begin
  Result := FProject;
end;

function TManager.Query: TAsyncADQuery;
begin
  Result := ConnectionsPool.Query
end;

procedure TManager.LoadScreen;
 var
  sa: TArray<IStorable>;
  s: IStorable;
begin
  sa := GContainer.InstancesAsArray<IStorable>(true);
  TArray.Sort<IStorable>(sa, TManagItemComparer<IStorable>.Create);
  for s in sa do s.Load;
end;

procedure TManager.SaveScreen();
 var
  s: IStorable;
begin
  for s in GContainer.Enum<IStorable>() do s.Save;
end;

procedure TManager.SetTableUpdate(const Value: string);
begin
  FC_TableUpdate := Value;
  Notify('S_TableUpdate');
end;

procedure TManager.AddOption(AParams: array of Variant);
 var
  i: Integer;
begin
  for i := 0 to  Length(AParams)-1 do if AParams[i] = '' then AParams[i] := null;
  Query.ExecSQL(ADD_OPTION, AParams, [ftString, ftString, ftString, ftString, ftString, ftString, ftString, ftString, ftString]);
end;

procedure TManager.AddOrIgnore(const Name, Section, Description, SectionDescription, Units: string; Hidden, ReadOnly: Boolean; DataType: Integer);
 var
  p: array[0..8] of Variant;
begin
  Query.Acquire;
  try
   if Query.Connection.ExecSQLScalar('SELECT Count(*) FROM Options WHERE Имя = :P1',[Name], [ftString]) > 0 then Exit;
   p[0] := Name;
   p[1] := '';
   if Description = '' then p[2] := Name else p[2] := Description;
   p[3] := Section;
   if SectionDescription = '' then p[4] := Section else p[4] := SectionDescription;
   p[5] := Units;
   if Hidden then p[6] := '1' else p[6] := '';
   if ReadOnly then p[7] := '1' else p[7] := '';
   if DataType = -1 then p[8] := '' else p[8] := DataType.ToString;
   AddOption(p);
  finally
   Query.Release;
  end;
end;

procedure TManager.CreateTables;
 var
  LDoc: IXMLDocument;
  ct, n: IXMLNode;
begin
  Query.Acquire;
  try
//   Query.ExecSQL(CREA_VIRTUAL_RAM_TBL);
   Query.ExecSQL(CREA_RAM_TBL);
   Query.ExecSQL(CREATE_OPTIONS_TBL);
   LDoc := NewXDocument();
   LDoc.LoadFromFile(ExtractFilePath(ParamStr(0))+'Devices\Options.xml');
   for ct in XEnum(LDoc.DocumentElement) do
    for n in XEnum(ct) do AddOption([n.NodeName,
                                     n.Attributes['Значение'],
                                     n.Attributes['Описание'],
                                     ct.NodeName,
                                     ct.Attributes['Категория'],
                                     n.Attributes['Единицы'],
                                     n.Attributes['Hidden'],
                                     n.Attributes['ReadOnly'],
                                     n.Attributes['DataType']]);
  finally
   Query.Release;
  end;
end;

procedure TManager.LoadProject(const FileName: string);
begin
  FDBConnection := nil;
  ClearItems([ecIO, ecDevice]);
  if FileExists(FileName) then
   begin
    FProject := FileName;
    FDBConnection := ConnectionsPool.GetConnection(FileName, True);
//    InternalInitDelay;
    ((GlobalCore as IConnectIOEnum) as IStorable).Load;
    ((GlobalCore as IDeviceEnum) as IStorable).Load;
    Notify('S_ProjectChange');
   end
  else
   begin
    FProject := '';
    Notify('S_ProjectChange');
   end;
end;

procedure TManager.NewProject(const FileName: string);
begin
  if FileExists(FileName) then raise EManagerexception.CreateFmt('Проект %s уже существует',[FileName]);
  FileClose(FileCreate(FileName));
  FDBConnection := nil;
  ClearItems([ecIO, ecDevice]);
  FProject := FileName;
  FDBConnection := ConnectionsPool.GetConnection(FileName, True);
  CreateTables; //project
//  InternalInitDelay;
  ((GlobalCore as IConnectIOEnum) as IStorable).New;
  ((GlobalCore as IDeviceEnum) as IStorable).New;
  Notify('S_ProjectChange');
end;

{$ENDREGION}

end.
