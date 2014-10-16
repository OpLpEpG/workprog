unit VTables;

interface

uses FireDAC.Phys.SQLiteWrapper, FireDAC.Phys.SQLiteCli, DBIntf;

type
  TRowCursor = class(TSQLiteVCursor)
  protected
    FConnection: TCustomAsyncDBConnection;
    Index: Integer;
    MaxIndex: Integer;
    procedure VTabFilter(const AIndex: Integer; const AIndexStr: String); override;
    procedure VTabNext; override;
    function VTabEof: Boolean; override;
    procedure VTabColumn(const AIndex: Integer); override;
    procedure VTabRowid(var ARowid: sqlite3_int64); override;
    procedure VTabClose(); override;
  public
    constructor Create(ATable: TSQLiteVTable; Connection: TCustomAsyncDBConnection); virtual;
  end;
  TRowCursorClass = class of TRowCursor;

  TRowTable = class(TSQLiteVTable)
  private
    FConnection: TCustomAsyncDBConnection;
  protected
    procedure DescribeColumn(const AColName: String; out ANotNull, AInPK, AAutoInc: Boolean); override;
    function DescribeColumns: TSQLiteVColDefs; override;

    procedure VTabDisconnect; override;
    procedure VTabDestroy; override;
    procedure VTabRename(const ANewName: UnicodeString); override;

    procedure VTabSync; override;
    procedure VTabBegin; override;
    procedure VTabCommit; override;
    procedure VTabRollback; override;

    procedure VTabSavepoint(const AVIndex: Integer); override;
    procedure VTabRelease(const AVIndex: Integer); override;
    procedure VTabRollbackTo(const AVIndex: Integer); override;

    function VTabFindFunction(ACount: Integer; const AName: String; var AFunc: Tsqlite3_func_callback; var AArg: Pointer): Boolean; override;
    procedure VTabBestIndex(var AIdxNum: Integer; var AIdxStr: String; var AOrdered, AFiltered: Boolean; var ACost: Double); override;

    procedure VTabInsert(var ARowid: sqlite3_int64; AOrUpdate: Boolean); override;
    procedure VTabUpdate(const AUpdRowid: sqlite3_int64; const ANewRowid: sqlite3_int64); override;
    procedure VTabDelete(const ARowid: sqlite3_int64); override;

    function VTabOpen: TSQLiteVCursor; override;
  public
    constructor Create(AModule: TSQLiteVModule; const AName: String; AConnection: TCustomAsyncDBConnection); virtual;
  end;

  TRowTableClass = class of TRowTable;

  TRowModule = class(TSQLiteVModule)
  private
    FConnection: TCustomAsyncDBConnection;
    procedure SetConnection(const Value: TCustomAsyncDBConnection);
  protected
    function VTabCreate(const AArgs: TSQLiteVArgs): TSQLiteVTable; override;
    function VTabConnect(const AArgs: TSQLiteVArgs): TSQLiteVTable; override;
  public
    property Connection: TCustomAsyncDBConnection read FConnection write SetConnection;
  end;

 var
  ProjectRowCursorClass: TRowCursorClass = TRowCursor;
  ProjectRowTableClass: TRowTableClass = TRowTable;

implementation

uses tools;

{ TRowModule }

procedure TRowModule.SetConnection(const Value: TCustomAsyncDBConnection);
begin
  FConnection := Value;
end;

function TRowModule.VTabConnect(const AArgs: TSQLiteVArgs): TSQLiteVTable;
begin
  Result := VTabCreate(AArgs);
end;

function TRowModule.VTabCreate(const AArgs: TSQLiteVArgs): TSQLiteVTable;
begin
  Result := ProjectRowTableClass.Create(Self, AArgs[2], FConnection);
end;

{ TRowTable }

constructor TRowTable.Create(AModule: TSQLiteVModule; const AName: String; AConnection: TCustomAsyncDBConnection);
begin
  inherited Create(AModule, AName);
  FConnection := AConnection;
end;

procedure TRowTable.DescribeColumn(const AColName: String; out ANotNull, AInPK, AAutoInc: Boolean);
begin
  if AColName = 'ID' then
   begin
    ANotNull := True;
    AInPK := True;
    AAutoInc := True;
   end
  else
   begin
    ANotNull := True;
    AInPK := False;
    AAutoInc := False;
   end;
end;

function TRowTable.DescribeColumns: TSQLiteVColDefs;
 const
  F1: TSQLiteVColDef = (FName: 'ID'; FDataType: 'INTEGER'; FHidden: False);
  F2: TSQLiteVColDef = (FName: 'Time'; FDataType: 'TEXT'; FHidden: False);
begin
  SetLength(Result, 2);
  Result[0] := F1;
  Result[1] := F2;
end;

function TRowTable.VTabOpen: TSQLiteVCursor;
begin
  Result := ProjectRowCursorClass.Create(Self, FConnection);
end;

{$REGION 'NOP'}

procedure TRowTable.VTabBestIndex(var AIdxNum: Integer; var AIdxStr: String; var AOrdered, AFiltered: Boolean; var ACost: Double);
begin
  AIdxNum := 1;
  AIdxStr := 'ID';
  AOrdered := True;
  ACost := 1;
end;

procedure TRowTable.VTabBegin;
begin
end;
procedure TRowTable.VTabCommit;
begin
end;
procedure TRowTable.VTabSync;
begin
end;
procedure TRowTable.VTabRollback;
begin
end;
procedure TRowTable.VTabRollbackTo(const AVIndex: Integer);
begin
end;

procedure TRowTable.VTabDelete(const ARowid: sqlite3_int64);
begin
end;

procedure TRowTable.VTabDestroy;
begin
end;

procedure TRowTable.VTabDisconnect;
begin
end;

function TRowTable.VTabFindFunction(ACount: Integer; const AName: String; var AFunc: Tsqlite3_func_callback; var AArg: Pointer): Boolean;
begin
  Result := False;
end;

procedure TRowTable.VTabInsert(var ARowid: sqlite3_int64; AOrUpdate: Boolean);
begin
end;

procedure TRowTable.VTabRelease(const AVIndex: Integer);
begin
end;

procedure TRowTable.VTabRename(const ANewName: UnicodeString);
begin
end;

procedure TRowTable.VTabSavepoint(const AVIndex: Integer);
begin
end;

procedure TRowTable.VTabUpdate(const AUpdRowid, ANewRowid: sqlite3_int64);
begin
end;

{ TRowCursor }

procedure TRowCursor.VTabFilter(const AIndex: Integer; const AIndexStr: String);
begin
end;

procedure TRowCursor.VTabClose; // cursor
begin
end;

procedure TRowCursor.VTabRowid(var ARowid: sqlite3_int64);
begin
end;

{$ENDREGION}

constructor TRowCursor.Create(ATable: TSQLiteVTable; Connection: TCustomAsyncDBConnection);
begin
  inherited Create(ATable);
  Index := 1;
  MaxIndex := 1000;
  FConnection := Connection;
end;

procedure TRowCursor.VTabColumn(const AIndex: Integer);
begin
  ColsOUT[AIndex].AsInteger := Index;
//  case AIndex of
//   0: ColsOUT[AIndex].AsInteger := Index;
//   1: ColsOUT[AIndex].AsTime :=  CTime.FromKadr(Index);
//   1: ColsOUT[AIndex].AsString := CTime.AsString(CTime.FromKadr(Index));
//  end;
end;

function TRowCursor.VTabEof: Boolean;
begin
  Result := Index >= MaxIndex;
end;

procedure TRowCursor.VTabNext;
begin
  Inc(Index);
end;

end.
