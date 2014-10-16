unit Qtools;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections, DB,  debug_except, tools,
     FireDAC.Stan.Intf,
     FireDAC.Stan.Option,
     FireDAC.Stan.Error,
     FireDAC.UI.Intf,
     FireDAC.Phys.Intf,
     FireDAC.Stan.Def,
     FireDAC.Stan.Pool,
     FireDAC.Stan.Async,
     FireDAC.Phys,
     FireDAC.Comp.Client, System.SyncObjs;

type
  TQueryCommand = (qcOpen, qcExecute, qcRefresh);

  TAsyncDBConnection = class(TFDConnection)
  public
   type
    TParams = TArray<Variant>;
    TFields = TArray<TFieldType>;
    TqeRec = record
      Query: TFDQuery;
      sql: string;
      Params: TParams;
      FieldsTypes: TFields;
      Cmd: TQueryCommand;
      Unique: Boolean;
      ResultSQL: TThreadProcedure;
      constructor Create(AQuery: TFDQuery; const Asql: string;
                         const AParams: array of Variant; const ATypes: array of TFieldType;
                         ACmd: TQueryCommand; AUnique: Boolean;
                         AResultSQL: TThreadProcedure);
    end;
  private
   type
    Tth = class(TQeueThread<TqeRec>)
    protected
      procedure Exec(data: TqeRec); override;
    public
      function CompareTask (ToQeTask, InQeTask: TqeRec): Boolean;
    end;
   var
    Fthread: Tth;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Acquire;
    procedure Release;
    { TODO : container for Global Named DataSet = Log, Ram , Glu }
  end;

  ///	<summary>
  ///	  Команды Async sync управления для удобства
  ///	</summary>
  TAsyncADQuery = class(TFDQuery)
  private
  protected
  public
    constructor Create(AOwner: TComponent); override;
    procedure Acquire;
    procedure Release;
    procedure AsyncSQL(const ASQL: String; const AParams: array of Variant; const ATypes: array of TFieldType;
                       cmd: TQueryCommand; ARes: TThreadProcedure; Unic: Boolean = True);
  end;
implementation

uses forms;

{$REGION 'OLD'}

const
  CREATE_XML_TBL = 'CREATE TABLE IF NOT EXISTS %s(node_id INTEGER PRIMARY KEY, Attribute TEXT, Value TEXT)';
         XML_VLE = 'INSERT INTO %s VALUES(NULL, :path, :data)';

{procedure XmlToSQLite(Src: IXMLNode; Dest: TSQLConnection; const TblMame: string = '');
 var
  xn: string;
  c: TSQLQuery;
begin
  if TblMame = '' then xn := Src.NodeName else xn := TblMame;
  c := TSQLQuery.Create(nil);
  try
   c.SQLConnection := Dest;

   Dest.Execute(Format(CREATE_XML_TBL, [xn]), nil);
   Dest.Execute(Format('DELETE FROM %s;',[xn]), nil);

   c.CommandText := Format(XML_VLE, [xn]);
   c.Prepared := True;
   c.ParamByName('path').AsString := xn;
   c.ParamByName('data').AsString := Src.Text;
   c.ExecSQL();
//   ExecXTree(Src, function(n: IXMLNode): boolean
//    var
//     x: IXMLNode;
//     p: string;
//   begin
//     Result := False;
//     if n.AttributeNodes.Count <= 0 then Exit;
//     x := n;
//     p := x.NodeName + '.';
//     while Assigned(x.ParentNode) and (x <> Src) do
//      begin
//       p := x.ParentNode.NodeName + '.' + p;
//       x := x.ParentNode;
//      end;
//     for x in XEnumAttr(n) do
//      begin
//       c.ParamByName('path').AsString := p + x.NodeName;
//       c.ParamByName('data').AsString := x.NodeValue;
//       c.ExecSQL();
//      end;
//   end);
  finally
   c.Free;
  end;
end;     }

{$ENDREGION}

{$REGION 'TAsyncDBConnection'}

{ TAsyncDBConnection.TqeRec }

constructor TAsyncDBConnection.TqeRec.Create(AQuery: TFDQuery; const Asql: string;
                         const AParams: array of Variant; const ATypes: array of TFieldType;
                         ACmd: TQueryCommand; AUnique: Boolean;
                         AResultSQL: TThreadProcedure);
  var
   i: Integer;
begin
  Query    := AQuery;
  sql      := Asql;
  Cmd      := ACmd;
  Unique   := AUnique;
  ResultSQL:= AResultSQL;

  SetLength(Params, Length(AParams));
  for I := 0 to Length(AParams)-1 do Params[i] := AParams[i];

  SetLength(FieldsTypes, Length(ATypes));
  Move(ATypes[0], FieldsTypes[0], Length(ATypes)*SizeOf(TFieldType));
end;

{ TAsyncDBConnection.Tth }

function TAsyncDBConnection.Tth.CompareTask(ToQeTask, InQeTask: TqeRec): Boolean;
begin
  if ToQeTask.Unique then Result := False
  else if (ToQeTask.Query = InQeTask.Query) and (ToQeTask.sql = InQeTask.sql) then Result := True
  else Result := False
end;

procedure TAsyncDBConnection.Tth.Exec(data: TqeRec);
begin
  LockExec.Acquire;
  try
   TDebug.Log( data.sql +' TAsyncDBConnection.Tth.Exec ', []);
   with data do
    case Cmd of
     qcOpen:    Query.Open(   sql, Params, FieldsTypes);
     qcExecute: Query.ExecSQL(sql, Params, FieldsTypes);
     qcRefresh: Query.Refresh;
    end;
  finally
   LockExec.Release;
  end;
  if Assigned(data.ResultSQL) then Synchronize(data.ResultSQL);
end;

{ TAsyncDBConnection }

constructor TAsyncDBConnection.Create(AOwner: TComponent);
begin
  inherited;
  Fthread := Tth.Create(False);
end;

destructor TAsyncDBConnection.Destroy;
begin
  Fthread.Terminate;
  Fthread.WaitFor;
  Fthread.Free;
  inherited;
end;

procedure TAsyncDBConnection.Acquire;
begin
  Fthread.LockExec.Acquire;
end;

procedure TAsyncDBConnection.Release;
begin
  Fthread.LockExec.Release;
end;
{$ENDREGION}

{ TAsyncADQuery }

constructor TAsyncADQuery.Create(AOwner: TComponent);
begin
  inherited;
//  ResourceOptions.CmdExecMode := amAsync;
  ResourceOptions.CmdExecMode := amBlocking;
  FetchOptions.Mode := fmAll;
//  FetchOptions.Mode := fmOnDemand;
//  UpdateOptions.ReadOnly := True;
//  UpdateOptions.FastUpdates := True;
end;

procedure TAsyncADQuery.Acquire;
begin
  TAsyncDBConnection(Connection).Acquire;
end;

procedure TAsyncADQuery.Release;
begin
  TAsyncDBConnection(Connection).Release;
end;

procedure TAsyncADQuery.AsyncSQL(const ASQL: String; const AParams: array of Variant; const ATypes: array of TFieldType;
                                 cmd: TQueryCommand; ARes: TThreadProcedure; Unic: Boolean = True);
begin
  TAsyncDBConnection(Connection).Fthread.Enqueue(TAsyncDBConnection.TqeRec.Create(Self, ASQL, AParams, ATypes, cmd, Unic, ARes));
end;

end.
