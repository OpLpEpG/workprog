unit DBIntf;

interface

uses System.SysUtils, System.Classes, DB, debug_except, RootIntf, Xml.XMLIntf,
     FireDAC.Stan.Intf,
     FireDAC.Stan.Option,
     FireDAC.Stan.Error,
     FireDAC.UI.Intf,
     FireDAC.Phys.Intf,
     FireDAC.Stan.Def,
     FireDAC.Stan.Pool,
     FireDAC.Stan.Async,
     FireDAC.Phys,
     FireDAC.Comp.Client;
type
  TQueryCommand = (qcOpen, qcExecute, qcRefresh);

  TCustomAsyncDBConnection = class(TFDConnection)
  public
    procedure Acquire; virtual; abstract;
    procedure Release; virtual; abstract;
  end;

  TCustomAsyncMemTable = class(TFDMemTable)
  public
    procedure Acquire; virtual; abstract;
    procedure Release; virtual; abstract;
  end;

  IQuery = interface(IInterfaceComponentReference)
  ['{E6104805-4A5E-4E67-9C84-F86CCD60B1AC}']
    procedure Acquire;
    procedure Release;
    procedure AsyncSQL(const ASQL: String; const AParams: array of Variant; const ATypes: array of TFieldType; cmd: TQueryCommand; ARes: TThreadProcedure; Unic: Boolean = True);
  end;

  IMemQuery = interface(IQuery)
  ['{BEC8F833-4BF4-4BCD-87AD-287AE751F9BC}']
   // rivate
    function GetFromData: Double;
    function GetToData: Double;
    procedure SetFromData(const Value: Double);
    procedure SetToData(const Value: Double);
   // public
    function GetXParam(const FieldName: string): IXMLNode;
    procedure Update();

    property FromData: Double read GetFromData write SetFromData;
    property ToData: Double read GetToData write SetToData;
  end;

  IRamQuery = interface(IMemQuery)
  ['{5CD97705-211A-48EE-B169-67670641DD36}']
//    function GetMaxID: Integer;
//    procedure UpdateRam;
  end;

  ///	<summary>
  ///	  Команды Async sync управления для удобства
  ///	</summary>
  TCustomAsyncADQuery = class(TFDQuery, IQuery)
  private
    function GetConnection: TFDCustomConnection;
  protected
    procedure SetConnection(const Value: TFDCustomConnection); virtual;
  public
    constructor Create(); reintroduce; virtual;
    procedure Acquire;
    procedure Release;
    procedure AsyncSQL(const ASQL: String; const AParams: array of Variant; const ATypes: array of TFieldType; cmd: TQueryCommand; ARes: TThreadProcedure; Unic: Boolean = True); virtual; abstract;
  published
    property Connection: TFDCustomConnection read GetConnection write SetConnection stored False;
  end;

  TCustomAsyncADQueryClass = class of TCustomAsyncADQuery;

  ///	<summary>
  ///   (Устарело)
  ///	  хранится в Форме (Окне просмотра данных) реализован в агрегате
  ///	</summary>
  IDBConnection_old = interface
  ['{D27FBF49-A488-4A0C-8250-B3D4B1876A6D}']
   function DBName: string;
   function Connection: Pointer;

   function GetActive: Boolean;
   procedure SetAcvtve(const Active: Boolean);

   procedure BeginTrans;
   procedure CommitTrans;
   procedure RollbackTrans;
//    function ExecSQL(const SQL: string): Variant; overload;
   function ExecSQL(const SQL: string; const NotifyTbl: string = ''): TCustomAsyncADQuery;
   procedure SimpleSQL(const SQL: string; const NotifyTbl: string = ''); overload;
   procedure SimpleSQL(const SQL: string; const Params: array of Variant; const NotifyTbl: string = ''); overload;
   function ProjectConnection(): TCustomAsyncDBConnection;
//   function NewDBConnection(const FileName: string): IDBConnection;  // ?????

   property Active: Boolean read GetActive write SetAcvtve;
  end;


  ///	<remarks>
  ///	  контейнер  хранит утекающую именную ссылку на интерфейс при удалении
  ///	  удаляенся и именная ссылка  пользователи интерфейса сами хранят его для
  ///	  предотвращения уничтожения
  ///	</remarks>
  IDBConnection = interface
  ['{D5C4702A-B634-4928-8F4D-A3A4FADDA588}']
    function DataBase: string;
    ///	<summary>
    ///	  если ДА то это подключение открытого проекта
    ///	</summary>
    function IsActive: Boolean;
    ///	<summary>
    ///	  создает или выдает запрос
    ///	</summary>
    ///	<param name="StdName">
    ///	  Имена стандартные 'Log', 'Ram' , 'Glu' или другие пользовательские
    ///	</param>
    function AddOrGetQuery(const StdName: string = ''): TCustomAsyncADQuery; overload;  { TODO : return IQuery }
    ///	<summary>
    ///	  Создание Query пользовательским классом
    ///	</summary>
//    function AddOrGetQuery(const StdName: string; QueryClass: TCustomAsyncADQueryClass): TCustomAsyncADQuery; overload;
    procedure RemoveQuery(const StdName: string);
    property Active: Boolean read IsActive;
  end;

//  IDBConnectionEnum = interface(IServiceManager<IDBConnection>)
//  ['{71909CC1-CC4B-4800-BEE3-E6E84CE0D22F}']
//    function AddActiveQuery(const StdName: string =''): TCustomAsyncADQuery;
//    procedure RemoveActiveQuery(const StdName: string);
//    function GetConnection(const DataBase: string; SetActive: boolean): IDBConnection;
//  end;

//  var
//   ActiveQuery: TCustomAsyncADQuery = nil;

implementation

{ TCustomAsyncADQuery }

constructor TCustomAsyncADQuery.Create;
begin
  inherited Create(nil);
  ResourceOptions.CmdExecMode := amBlocking;
  FetchOptions.Mode := fmAll;
end;

function TCustomAsyncADQuery.GetConnection: TFDCustomConnection;
begin
  Result := inherited Connection;
end;

procedure TCustomAsyncADQuery.Acquire;
begin
  TCustomAsyncDBConnection(Connection).Acquire;
end;

procedure TCustomAsyncADQuery.Release;
begin
  TCustomAsyncDBConnection(Connection).Release;
end;

procedure TCustomAsyncADQuery.SetConnection(const Value: TFDCustomConnection);
begin
  inherited Connection := Value;
end;

end.
