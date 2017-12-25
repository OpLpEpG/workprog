unit manager3;

interface

uses debug_except, RootIntf, DeviceIntf, ExtendIntf, tools, Container, System.DateUtils, Actns, System.UITypes,
     RootImpl, AbstractPlugin, PluginAPI, DockIForm, System.SyncObjs, XMLEnumers,
     Vcl.Dialogs, System.Variants, Vcl.Forms, Winapi.Windows, System.IOUtils,
     System.SysUtils, Vcl.Graphics, System.Classes, System.Generics.Collections, System.Generics.Defaults,
     RTTI, System.TypInfo, Xml.XMLIntf;

 const
   T_DEV = 'DEVICES';
   T_CON = 'CONNECTIOS';
   T_OPT = 'OPTIONS';
   T_FILES = 'FILES';

 type
  EManagerexception = class(EBaseException);

  TManager = class(TAbstractPlugin,
                               IManager, IManagerEx,
                               IProjectMetaData,
                               IProjectDataFile,
                               IProjectOptions,
                               IALLMetaDataFactory, IALLMetaData,
                               IGlobalMemory,
                               IMetrology{,
                               IDelayManager})
  private
//    VSetTime, VDelay, VWorkTime: Variant;
//    FDelayStatus: DelayStatus;
   // FDBConnection: IDBConnection;
    FC_TableUpdate: string;

//    FSQLMonitor: TSQLMonitor;
//    DbgMon: TFDMoniRemoteClientLink;

//    procedure ClearDevsAndIOs;
    procedure SetTableUpdate(const Value: string);
//    procedure CreateTables;
//    procedure AddOption(AParams: array of Variant);
//    function Query: TAsyncADQuery; inline;
//    procedure AddOption(AParams: array of Variant);
  protected
    // IGlobalMemory
    function GetMemorySize(Need: Int64): Int64;

   // IALLMetaDataFactory
    function Get(const Name: string): IALLMetaData; overload;
    function Get: IALLMetaData; overload;

   // IALLMetaData
    function IALLMetaData.Get = MetaDataGet;
    function MetaDataGet: IXMLDocument;
    procedure Save;

    { IManager }
    procedure ClearItems(ClearItems: EClearItems = [ecIO, ecDevice, ecForm]); { TODO : убрать как устаревшее }
    function ProjectName: string;
    procedure LoadScreen();
    procedure SaveScreen();
    procedure NewProject(const FileName: string; AfterCreateProject: Tproc = nil);
    procedure LoadProject(const FileName: string; AfterCreateProject: Tproc = nil);
    { IManagerEx }
    function GetProjectFilter: string;
    function GetProjectDefaultExt: string;
    function GetProjectDirectory: string;
    // IProjectDataFile,
    procedure SetMetaData(Dev: IDevice; Adr: Integer; MetaData: IXMLInfo);
    procedure SaveLogData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; Row: Pointer; RowLen: Integer);
    procedure SaveRamData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; Row: Pointer; RowLen, CurAdr, CurKadr: Integer; CurTime: TDateTime);
    procedure SaveEnd(Data: IXMLInfo);
    function DataFileExists(Root: IXMLNode; const SubDir: string = ''; const SubName: string = ''): Boolean;
    procedure DataSectionDelete(Root: IXMLNode);
    procedure DeviceDataDelete(Dev: IDevice);
    function ConstructDataDir(Root: IXMLNode; NeedCreate: Boolean = True; const SubDir: string = ''): string;
    function ConstructDataFileName(Root: IXMLNode; const SubName: string = ''): string;

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

    function DelayStart: TDateTime;
    function IntervalWork: TDateTime;
   // IDelayManager = interface
//    procedure InternalInitDelay;
//    procedure SetDelay(SetTime, Delay, WorkTime: Variant);
//    procedure GetDelay(var SetTime, Delay, WorkTime: Variant; var ds: DelayStatus);
//    procedure StopDelay();

    class function GetHInstance: THandle; override;
  public
    FProjectFile: string;
    FProjecDoc: IXMLDocument;
    Froot, FConnect, FDevices, Foptions{, FFiles} : IXMLNode;

    class var This: TManager;
    class function ProjectDir: string;
    constructor Create; override;
//    destructor Destroy; override;
    class function PluginName: string; override;

    property Option[const Name: string]: Variant read GetOption write SetOption;

    property S_ProjectChange: string read FProjectFile write FProjectFile;

    property C_TableUpdate: string read FC_TableUpdate write SetTableUpdate;
    property S_TableUpdate: string read FC_TableUpdate write SetTableUpdate;
  end;

implementation

uses FileCachImpl;//, PrjTool;

const
  IFORMS_INI_DIR = 'IFormObjs';

type
  TALLMetaData = class(TIObject, IALLMetaData)
  private
    XDoc: IXMLDocument;
    FName: string;
  protected
    function Get: IXMLDocument;
    procedure Save;
    constructor Create(const Name: string);
  end;

constructor TALLMetaData.Create(const Name: string);
begin
  XDoc := NewXDocument;
  FName := Name;
  XDoc.LoadFromFile(FName);
end;

function TALLMetaData.Get: IXMLDocument;
begin
  Result := XDoc;
end;

procedure TALLMetaData.Save;
begin
  XDoc.SaveToFile(FName);
end;


{$REGION 'TManager'}

{ TManager }

function TManager.Get(const Name: string): IALLMetaData;
 var
  i: IInterface;
begin
  if GContainer.TryGetInstance(TypeInfo(TALLMetaData), Name, i, False) then Result := i as IALLMetaData
  else
   begin
    Result := TALLMetaData.Create(Name);
    TRegister.AddType<TALLMetaData>.LiveTime(ltSingletonNamed).AddInstance(Name, Result as IInterface);
   end
end;

function TManager.Get: IALLMetaData;
begin
  Result := Self as IALLMetaData;
end;

function TManager.MetaDataGet: IXMLDocument;
begin
  Result := FProjecDoc;
end;

class function TManager.GetHInstance: THandle;
begin
  Result := HInstance;
end;

function TManager.GetMemorySize(Need: Int64): Int64;
 var
  memStatus: TMemoryStatusEx;
begin
  memStatus.dwLength := sizeOf (memStatus);
  GlobalMemoryStatusEx (memStatus);
  Result := memStatus.ullAvailVirtual div 4;
  if Need < Result then Result := Need;  
end;

class function TManager.PluginName: string;
begin
  Result := 'XML Проект';
end;

constructor TManager.Create;
begin
  inherited;
  This := Self;
//  DbgMon := TADMoniRemoteClientLink.Create(nil);
//  TDebug.Log('----------- TManager.Create ---------------------');
end;

{destructor TManager.Destroy;
begin
  TDebug.Log('----------- TManager.Destroy ---------------------');
  DbgMon.Free;
  inherited;
end;}

function TManager.GetProjectDefaultExt: string;
begin
  Result := 'xml';
end;

function TManager.GetProjectDirectory: string;
begin
  Result := ProjectDir;
end;

function TManager.GetProjectFilter: string;
begin
  Result := 'Файл проекта (*.xml)|*.xml';
end;

function TManager.DelayStart: TDateTime;
 var
  v: Variant;
begin
  v := Option['TIME_START'];
  if v = null then Exit(0);
  try
   Result := StrToDateTime(v);
  except
   Result := Double(v);
  end;
end;

function TManager.IntervalWork: TDateTime;
 var
  v: Variant;
begin
  v := Option['WORK_INTERVAL'];
  if v = null then Exit(0);
  try
   Result := StrToDateTime(v);
  except
   Result := Double(v);
  end;
end;

function TManager.GetOption(const Name: string): Variant;
 var
  c, v: IXMLNode;
begin
  Result := null;
  if Assigned(Foptions) then for c in XEnum(Foptions) do
  begin
  // TDebug.Log(c.NodeName);
   v := c.ChildNodes.FindNode(Name);
   if Assigned(v) then
    begin
     if v.HasAttribute('Значение') then Result := v.Attributes['Значение'];
     Break;
    end;
  end;
end;

procedure TManager.SetOption(const Name: string; const Value: Variant);
 var
  c, v: IXMLNode;
begin
  if Assigned(Foptions) then for c in XEnum(Foptions) do
  begin
   v := c.ChildNodes.FindNode(Name);
   if Assigned(v) then
    begin
     v.Attributes['Значение'] := Value;
     save;
     Break;
    end;
  end;
end;

procedure TManager.AddOrIgnore(const Name, Section, Description, SectionDescription, Units: string; Hidden, ReadOnly: Boolean; DataType: Integer);
 var
  c, v: IXMLNode;
begin
   if not Assigned(Foptions) then Exit;
   c := Foptions.ChildNodes.FindNode(Section);
   if not Assigned(c) then
    begin
     c := Foptions.AddChild(Section);// ChildNodes.FindNode(Section);
     c.Attributes['Категория'] := SectionDescription;
    end
   else if Assigned(c.ChildNodes.FindNode(Name)) then Exit;
   v := c.AddChild(Name);
   v.Attributes['Описание'] := Description;
   v.Attributes['Единицы'] := Units;
   v.Attributes['Hidden'] := Hidden;
   v.Attributes['ReadOnly'] := ReadOnly;
   v.Attributes['DataType'] := DataType;
end;

procedure TManager.SetMetaData(Dev: IDevice; Adr: Integer; MetaData: IXMLInfo);
  var
   dv: IXMLNode;
begin
  dv := FDevices.ChildNodes.FindNode(Dev.IName);
//  if not Assigned(dv) {еще не добавлен в enum} then
  if dv <> MetaData.ParentNode then dv.ChildNodes.Add(MetaData);
//  MetaData.OwnerDocument.FileName := FDevices.OwnerDocument.FileName;
  Save;
  dv.OwnerDocument.Resync;
  S_TableUpdate := 'Modul';
end;

procedure TManager.SetMetrol(MetrolID: Integer; TrrData: IXMLInfo; const SourceName: string);
 var
  d: IDevice;
  de: IDeviceEnum;
  info, dev,  trr,  tip,  run: IXMLnode;
      fdev,       ftip, frun: IXMLnode;
  atr: IXMLnode;
  Vnomer, Vtime: Variant;
  id: Integer;
begin
  id := 0;
  de := GContainer as IDeviceEnum;
 { Query.Acquire;
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

     atr := tip.AttributeNodes.FindNode(AT_METR);
     if Assigned(atr) then tip.AttributeNodes.Remove(atr);

  //   tip.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'tip.xml');
  //   ftip.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'ftip.xml');

     if not HasXTree(tip, ftip) then raise EManagerexception.Create('Импортировать метрологию невозможно - неверная структура');

     if Assigned(atr) then tip.AttributeNodes.Add(atr);

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
  end;     }
  (de as IBind).Notify('S_PublishedChanged');
end;

procedure TManager.Save;
begin
  FProjecDoc.SaveToFile(FProjectFile);
end;

procedure TManager.SaveEnd(Data: IXMLInfo);
 var
  f: IFileData;
  c: ICashedData;
begin
  if XSupport(Data, IFileData, f) and Supports(f, ICashedData, c) then c.EndWrite();
end;

procedure TManager.SaveLogData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; Row: Pointer; RowLen: Integer);
 var
  f: IFileData;
begin
  if not XSupport(Data, IFileData, f) then
   begin
    f := GFileDataFactory.Factory(TFileData, Data);
    (Data as IOwnIntfXMLNode).Intf := f;
   end;
  f.Write(RowLen, Row, f.Size);
end;

procedure TManager.SaveRamData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; Row: Pointer; RowLen, CurAdr, CurKadr: Integer; CurTime: TDateTime);
 const
  {$J+} tick: Cardinal = 0;{$J-}
 var
  f: IFileData;
  t: Cardinal;
begin
  t := GetTickCount;
  if not XSupport(Data, IFileData, f) then
   begin
    f := GFileDataFactory.Factory(TFileData, Data);
    (Data as IOwnIntfXMLNode).Intf := f;
   end;
  f.Write(RowLen, Row);
  Data.Attributes[AT_TO_ADR] := CurAdr;
  Data.Attributes[AT_TO_KADR] := CurKadr;
  Data.Attributes[AT_TO_TIME] := CurTime;
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
  if ecForm in ClearItems then (GlobalCore as IFormEnum).Clear;
//  if ecFile in ClearItems then (GlobalCore as IFileEnum).Clear;
end;

    /// <summary>
    ///  Root - <c>WRK RAM GLU</c>
    ///  структура проекта и директорий
    ///      <c>
    ///   <para> DeviceBur1
    ///   <para> -   Modul1
    ///   <para> --    WRK
    ///   <para> ---     ParamBuffer
    ///   <para> --    RAM
    ///   <para> ---     ParamBuffer </para></para></para></para></para></para>
    ///  </c>
    /// </summary>
function TManager.ConstructDataDir(Root: IXMLNode; NeedCreate: Boolean; const SubDir: string): string;
begin
  if Root.OwnerDocument.FileName = '' then Result := TPath.GetDirectoryName(FProjecDoc.FileName)
  else Result := TPath.GetDirectoryName(Root.OwnerDocument.FileName);

  Result := Result + '\' + Root.ParentNode.ParentNode.NodeName + '\' + Root.ParentNode.NodeName + '\' + Root.NodeName+ '\' ;

  if SubDir <> '' then Result := Result +'\' +SubDir +'\';

  if NeedCreate then if not TDirectory.Exists(Result) then TDirectory.CreateDirectory(Result);
end;

function TManager.ConstructDataFileName(Root: IXMLNode; const SubName: string): string;
begin
  Result := Root.ParentNode.NodeName + Root.NodeName + SubName + '.bin'
end;

function TManager.DataFileExists(Root: IXMLNode; const SubDir, SubName: string): Boolean;
 var
  fl: string;
begin
  if Root.HasAttribute(AT_FILE_NAME) and (SubDir ='') then fl := Root.Attributes[AT_FILE_NAME]
  else fl := ConstructDataFileName(Root, SubName);
  Result := Tfile.Exists(ConstructDataDir(Root, False, SubDir) + fl);
end;

procedure TManager.DataSectionDelete(Root: IXMLNode);
 var
  dir: string;
  procedure RemoveIfile;
   var
    f: IFileData;
  begin
  if XSupport(Root, IFileData , f) then
   begin
    (Root as IOwnIntfXMLNode).Intf := nil;
    f := nil;
   end;
  end;
begin
  RemoveIfile;
  dir := ConstructDataDir(Root, False);
  if TDirectory.Exists(dir) then TDirectory.Delete(dir, True);
  if TDirectory.Exists(dir) then raise Exception.Create('Немогу удалить директорию '+ dir);

  RemoveXMLAttr(Root, AT_FILE_NAME);
end;


procedure TManager.DeviceDataDelete(Dev: IDevice);
 var
  dir: string;
  dd: IDataDevice;
  i: IXMLInfo;
begin
  if not Supports(Dev, IDataDevice, dd) then Exit;
  i := dd.GetMetaData.Info;
//  dd.ClearMetaData;
  if not Assigned(i) then Exit;
  dir := TPath.GetDirectoryName(i.OwnerDocument.FileName)+'\'+ i.NodeName;
  i := nil;
  if TDirectory.Exists(dir) then TDirectory.Delete(dir, True);
  if TDirectory.Exists(dir) then raise Exception.Create('Немогу удалить директорию '+ dir);
end;

class function TManager.ProjectDir: string;
begin
  Result := TPath.GetSharedDocumentsPath +'\Горизонт\WorkProg\Projects';
  if not TDirectory.Exists(Result) then TDirectory.CreateDirectory(Result);
end;

function TManager.ProjectName: string;
begin
  Result := FProjectFile;
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

procedure TManager.LoadProject(const FileName: string; AfterCreateProject: Tproc = nil);
begin
  ClearItems([ecIO, ecDevice, ecfile]);
  if FileExists(FileName) then
   begin
    FProjectFile := FileName;
    FProjecDoc := NewXDocument();
    try
      FProjecDoc.LoadFromFile(FProjectFile);
      Froot := FProjecDoc.DocumentElement;
      FConnect := Froot.ChildNodes.FindNode(T_CON);
      FDevices := Froot.ChildNodes.FindNode(T_DEV);
      Foptions := Froot.ChildNodes.FindNode(T_OPT);
//      FFiles := Froot.ChildNodes.FindNode(T_FILES);

      if Assigned(AfterCreateProject) then AfterCreateProject();

      ((GlobalCore as IConnectIOEnum) as IStorable).Load;
      ((GlobalCore as IDeviceEnum) as IStorable).Load;
//      ((GlobalCore as IFileEnum) as IStorable).Load;

    except
      on E: Exception do TDebug.DoException(E, False);
    end;
    Notify('S_ProjectChange');
   end
  else
   begin
    Froot := nil;
    FConnect := nil;
    FDevices := nil;
    Foptions := nil;
//    FFiles := nil;
    FProjecDoc := nil;
    FProjectFile := '';
    if Assigned(AfterCreateProject) then AfterCreateProject();
    Notify('S_ProjectChange');
   end;
end;

procedure TManager.NewProject(const FileName: string; AfterCreateProject: Tproc = nil);
 var
  dir, flName, ladtDir: string;
  last: TArray<string>;
  LDoc: IXMLDocument;
begin
  if FileExists(FileName) then raise EManagerexception.CreateFmt('Проект %s уже существует',[FileName]);

  dir := TPath.GetDirectoryName(FileName);
  flName := TPath.GetFileNameWithoutExtension(FileName);
  last := dir.Split([Tpath.DirectorySeparatorChar], ExcludeEmpty);
  ladtDir := last[High(last)];
  if (not SameText(flName, ladtDir)) {and (MessageDlg('Cоздать директорию ..\'+flName +'\ ?', mtInformation, [mbYes, mbNo], 0) = mrYes)} then
   begin
    dir := dir + Tpath.DirectorySeparatorChar + flName;
    TDirectory.CreateDirectory(dir);
   end;

  ClearItems([ecIO, ecDevice, ecfile]);

  FProjectFile := dir + Tpath.DirectorySeparatorChar + TPath.GetFileName(FileName);
  FProjecDoc := NewXDocument();
  Froot := FProjecDoc.AddChild('PROJECT');
  FConnect := Froot.AddChild(T_CON);
  FDevices := Froot.AddChild(T_DEV);
//  FFiles := Froot.AddChild(T_FILES);
  LDoc := NewXDocument();
  LDoc.LoadFromFile(ExtractFilePath(ParamStr(0))+'Devices\Options.xml');
  Froot.ChildNodes.Add(Ldoc.DocumentElement);
  Foptions := Froot.ChildNodes.FindNode(T_OPT);

  if Assigned(AfterCreateProject) then AfterCreateProject();

  ((GlobalCore as IConnectIOEnum) as IStorable).New;
  ((GlobalCore as IDeviceEnum) as IStorable).New;
//  ((GlobalCore as IFileEnum) as IStorable).New;

  FProjecDoc.FileName := FProjectFile;
  FProjecDoc.SaveToFile(FProjectFile);

  Notify('S_ProjectChange');
end;

{$ENDREGION}

end.
