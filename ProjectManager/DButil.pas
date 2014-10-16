unit DButil;

interface

uses Winapi.Windows, DateUtils, DBIntf, DBImpl, FireDAC.Phys.Intf, System.Classes, RootIntf,
    System.SysUtils, Xml.XMLIntf, RootImpl, Data.DB, FireDAC.Comp.Client, DeviceIntf, ExtendIntf, debug_except, System.Variants;

const // �� �����������
     CREATE_TBL = 'CREATE TABLE IF NOT EXISTS %s(id INTEGER PRIMARY KEY,'+
                                                'IName TEXT,'+
                                                'Ptiority INT,'+
                                                'ObjData TEXT)';
     LOAD_TBL   = 'SELECT * FROM %s ORDER BY Ptiority ASC, IName ASC';
     ADD_VAL    = 'INSERT INTO %s VALUES(NULL, "%s", %d, "%s")';
     CHNG_VAL   = 'UPDATE %s SET ObjData = "%s" WHERE IName = "%s"';
     DEL_VAL    = 'DELETE FROM %s WHERE IName = "%s"';

     ALTER_DEV  = 'ALTER TABLE Device ADD COLUMN ��� TEXT';
     ALTER_DEV2  ='ALTER TABLE Device ADD COLUMN Znd FLOAT';
     ALTER_DEV3  ='ALTER TABLE Device ADD COLUMN TimeSetupDelay DATETIME'; // julian datetime
     ADD_DEV    = 'INSERT INTO Device VALUES(NULL, "%s", %d, "%s", "%s", 0, NULL)';
     CHNG_NAME  = 'UPDATE Device SET ��� = "%s" WHERE IName = "%s"';

     // ��������
//     CREATE_DELAY_TBL = 'CREATE TABLE IF NOT EXISTS Delay(Status INT NOT NULL, ���������� TIMESTAMP, �������� TIMESTAMP, ������ TIMESTAMP)';
//     CREATE_DELAY_TBL2 = 'INSERT INTO Delay VALUES(0,NULL,NULL,NULL)';

     // ����� ������� (LAS format)
     CREATE_OPTIONS_TBL = 'CREATE TABLE IF NOT EXISTS Options(��� TEXT PRIMARY KEY, �������� TEXT, �������� TEXT NOT NULL,'+
                           'Section TEXT NOT NULL, ��������� TEXT NOT NULL, ������� TEXT, Hidden INT, ReadOnly INT, DataType INT)';

     ADD_OPTION         = 'REPLACE INTO Options VALUES(:P1, :P2, :P3, :P4, :P5, :P6, :P7, :P8, :P9)';
     // �� ������� ���������
     CREATE_MODULE_TBL =
     'CREATE TABLE IF NOT EXISTS Modul(id INTEGER PRIMARY KEY,'+
                                      '����� INTEGER NOT NULL,'+
                                      'fk INTEGER NOT NULL REFERENCES Device(id) ON DELETE CASCADE,'+
                                      '������ TEXT,'+
                                      '���������� TEXT,'+
                                      '����� INT,'+
                                      '���������� INT,'+ //NOT NULL REFERENCES TipChip(id),'+
                                      'MetaData XML,'+
                                      'FromAdr INT,'+
                                      'ToAdr INT,'+
                                      'FromKadr INT,'+
                                      'ToKadr INT,'+
                                      'FromTime DATETIME,'+  // julian datetime(DDDDDDDDD) ��� ��������������� ����������� �������
                                      'ToTime DATETIME,'+   // julian datetime(DDDDDDDDD) ��� ��������������� ����������� �������
                                      'TimeKoeff FLOAT DEFAULT 1 NOT NULL'+
                                      ')';
    SEL_ALL_META = 'SELECT �����, MetaData FROM Modul WHERE fk = (SELECT id FROM Device WHERE IName = "%s")';
    ADD_MODUL = 'INSERT INTO Modul(�����, fk) VALUES(%d, (SELECT id FROM Device WHERE IName = "%s"))';
    CHNG_MODUL_META =   'UPDATE Modul SET MetaData = ''%s'' WHERE (����� = %d) AND (fk = %d)';
    CHNG_MODUL_META2 =  'UPDATE Modul SET MetaData = ''%s'' WHERE id = %d';
    CHNG_MODUL_NAME =   'UPDATE Modul SET ������ = ''%s'' WHERE (����� = %d) AND (fk = %d)';
    CHNG_MODUL_INF =    'UPDATE Modul SET ���������� = ''%s'' WHERE (����� = %d) AND (fk = %d)';
    CHNG_MODUL_CHIP =   'UPDATE Modul SET ���������� = %d WHERE (����� = %d) AND (fk = %d)';
    CHNG_MODUL_SERIAL = 'UPDATE Modul SET ����� = %d WHERE (����� = %d) AND (fk = %d)';
    DEL_MODUL_DEVICE  = 'DELETE FROM Modul WHERE fk = %d';

     CREATE_RAM_VIEW =
     'CREATE VIEW IF NOT EXISTS Customer_Ram AS SELECT '+
     ' Modul.id, Device.���, Modul.������,'+
//     ' Modul.TimeKoeff AS "��������� ������",'+
     ' Modul.FromKadr AS "�(����)", Modul.ToKadr AS "��(����)", '+
     ' Modul.FromTime AS "�(�����)", Modul.ToTime AS "��(�����)", Modul.TimeKoeff AS "�����." '+
     ' FROM  Modul, Device '+
     ' WHERE Modul.fk = Device.id';
     // �� ���������� �������
     CREATE_TRR_TBL =
     'CREATE TABLE IF NOT EXISTS Metrol(id INTEGER PRIMARY KEY,'+
                                      'fk INTEGER NOT NULL REFERENCES Modul(id) ON DELETE CASCADE,'+
                                      '��� TEXT NOT NULL,'+
                                      '�������� TEXT,'+
                                      '������ TEXT,'+
                                      '����� INT,'+
                                      '"���� ����������" DATETIME)'; // // julian datetime(DDDDDDDDD) ��� ��������������� ����������� �������
     CREATE_TRR_VIEW =
     'CREATE VIEW IF NOT EXISTS Customer_Metrol AS SELECT '+
     ' Metrol.id, Device.���, Metrol.���, Modul.������, Metrol.������ AS ''��� ���������'', Metrol.�����, Metrol."���� ����������", Metrol.�������� '+
     ' FROM Metrol, Modul, Device '+
     ' WHERE Metrol.fk = Modul.id AND Modul.fk = Device.id';

    ADD_TRR = 'INSERT INTO Metrol(���, fk) VALUES("%s", (SELECT id FROM Modul WHERE (����� = %d) AND (Modul.fk = %d)))';
    GET_TRR_FROM_METR_ID = 'SELECT IName, �����, ���, Modul.id'+
                                ' FROM Device,Modul,Metrol'+
                                ' WHERE Modul.fk = Device.id AND Metrol.fk = Modul.id AND Metrol.id = %d';

    CHNG_TRR_SRC = 'UPDATE Metrol SET �������� = :src, ������ = :mdl, ����� = :nomer, "���� ����������" = :tme WHERE id = :idrec';

    DEL_TRR_DEVICE  = 'DELETE FROM Metrol WHERE fk = (SELECT id FROM Modul WHERE Modul.fk = %d)';


//    CREA_VIRTUAL_RAM_TBL = 'CREATE VIRTUAL TABLE IF NOT EXISTS Ram USING v_rowid_module';
    CREA_RAM_TBL = 'CREATE TABLE IF NOT EXISTS Ram (id INTEGER PRIMARY KEY, "����� �������" DATETIME NOT NULL)';
    ADD_RAM = 'INSERT INTO Ram VALUES(:P1, :P2)';
    DEL_RAM = 'DELETE FROM Ram WHERE id > %d';

    CREA_EVENTS_TBL = 'CREATE TABLE IF NOT EXISTS Events (id INTEGER PRIMARY KEY, "����� �������" DATETIME NOT NULL)'; // julian datetime(DDDDDDDDD) ��� ��������������� ����������� �������
    ADD_EVENT_VAL =  'INSERT INTO Events VALUES(NULL, :P1)';

    CREA_LOG_VAL = 'CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY,'+
                                                  'ev INTEGER NOT NULL UNIQUE REFERENCES Events(id) ON DELETE CASCADE, %s)';
//    CREA_LOG_TRR_VAL = 'CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY, ev INTEGER NOT NULL REFERENCES Events(id),%s)';
    CREA_RAM_VAL = 'CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY, %s)';
//    CREA_RAM_TRR_VAL = 'CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY, %s)';
    DROP_TABLE_VAL =  'DROP TABLE IF EXISTS %s_%d_%d';

    ADD_LOG_VAL =  'INSERT INTO Log_%d_%d VALUES(NULL, (SELECT MAX(id) FROM Events), %s)';
//    ADD_LOG_TRR_VAL =  'INSERT INTO %s VALUES(last_insert_rowid(), %s)';
    ADD_RAM_VAL =  'INSERT INTO Ram_%d_%d VALUES(NULL, %s)';
//    ADD_RAM_TRR_VAL =  'INSERT INTO %s VALUES(last_insert_rowid(), %s)';


//type
//  IEvents = interface
//  ['{271FC083-ACC4-467E-BCFA-E001173D3DBF}']
//    function GetEventTick: Cardinal;
//    procedure SetEventTick(const Value: Cardinal);
//    procedure UpdateEvent(Con: TAsyncADQuery);
//    property EventTick: Cardinal read GetEventTick write SetEventTick;
//  end;
//
//  TEvents = class (TIObject, IEvents)
//  private
//    FEventTick: Cardinal;
//    FLastTime: Cardinal;
//  protected
//    function GetEventTick: Cardinal;
//    procedure SetEventTick(const Value: Cardinal);
//    procedure UpdateEvent(Con: TAsyncADQuery);
//  public
//    constructor Create(AEventTime: Cardinal = 1000);
//  end;
//
//  ISaveDataCash = interface
//  ['{94446C5E-2EC2-48A4-90BD-6A003F3EB6E2}']
//    procedure SaveData(OnEnd: TThreadProcedure);
//  end;
//
//  ESaveDataCash = class(EBaseException);
//
//  TSaveData = class (TIObject, ISaveDataCash)
//   type Tparam = record
//     array_len: Integer;
//     Value: IXMLNode;
//     constructor Create(AValue: IXMLNode; Alen: Integer=0);
//    end;
//  private
//    FParams: TArray<Tparam>;
//    FFields: TArray<TFieldType>;
//    FQuery: TAsyncADQuery;
//    FSql: string;
//  protected
//    procedure SaveData(OnEnd: TThreadProcedure); virtual;
//  public
//    constructor Create(Connection: TFDConnection; root: IXMLNode; const sql: string);
//    destructor Destroy; override;
//    class function ToValues(wrk: IXMLNode): string;
//    class function FieldTxtToFieldType(const txt: string):TFieldType;
//  end;
//
//  ISaveLogDataCash = interface(ISaveDataCash)
//  ['{5F41A98B-A2BB-4109-B734-73C586CDC6FF}']
//    procedure SetStdOnly(StdOnly: Boolean);
//  end;
//
//  TSaveLogData = class (TSaveData, ISaveLogDataCash)
//    FStdOnly: Boolean;
//  protected
//    procedure SaveData(OnEnd: TThreadProcedure); override;
//    procedure SetStdOnly(StdOnly: Boolean);
//  end;

function GetDevID(Con: TAsyncADQuery; dev: IDevice; out Id: Integer): Boolean;

implementation

uses tools,Parser, FireDAC.Stan.Intf, forms;

function GetDevID(Con: TAsyncADQuery; dev: IDevice; out Id: Integer): Boolean;
begin
  Con.Acquire;
  try
   id := Con.Connection.ExecSQLScalar(Format('SELECT id FROM Device WHERE IName = "%s"', [(dev as IManagItem).IName]));
   Result := True;
  finally
   Con.Release;
  end;
end;

{ TEvents }

{constructor TEvents.Create(AEventTime: Cardinal);
begin
  FEventTick := AEventTime;
end;

function TEvents.GetEventTick: Cardinal;
begin
  Result := FEventTick;
end;

procedure TEvents.SetEventTick(const Value: Cardinal);
begin
  FEventTick := Value;
end;

procedure TEvents.UpdateEvent(Con: TAsyncADQuery);
  var
   t: Cardinal;
begin
  t := GetTickCount;
  if (t - FLastTime) >= FEventTick then
   begin
    Con.AsyncSQL(Format(ADD_EVENT_VAL, [DateTimeToJulianDate(Now)]),[],[], qcExecute, nil);
    FLastTime := t;
   end;
end;

{ TSaveData.Tparam }

{constructor TSaveData.Tparam.Create(AValue: IXMLNode; Alen: Integer);
begin
  Value := AValue;
  array_len := Alen;
end;

{ TSaveData }

//constructor TSaveData.Create(Connection: TFDConnection; root: IXMLNode; const{ Attr,} sql: string);
// var
//  cnt: Integer;
//  spar: string;
//begin
{  FQuery := TAsyncADQuery.Create();
  FQuery.Connection := Connection;
//  FQuery.FormatOptions.DefaultParamDataType := ftString;
  cnt := 1;
  spar := '';
  ExecXTree(root, procedure(n: IXMLNode)
    procedure AddFieldType(tp: Integer; isArray: boolean);
    begin
      if isArray then CArray.Add<TFieldType>(FFields, ftBytes)
      else CArray.Add<TFieldType>(FFields, FieldTxtToFieldType(Tpars.VarTypeToDBField(tp)))
    end;
  begin
    if n.HasAttribute(AT_ROW) then
     begin
      spar := spar + ':param'+cnt.ToString+',';
      Inc(cnt);
      if n.HasAttribute(AT_ARRAY) then
           CArray.Add<Tparam>(FParams, Tparam.Create(n.AttributeNodes.FindNode(AT_ROW), n.Attributes[AT_ARRAY]))
      else CArray.Add<Tparam>(FParams, Tparam.Create(n.AttributeNodes.FindNode(AT_ROW)));
      AddFieldType(n.Attributes[AT_TIP], n.HasAttribute(AT_ARRAY));
     end;
    if n.HasAttribute(AT_TRR) then
     begin
      spar := spar + ':param'+cnt.ToString+',';
      Inc(cnt);
      if n.HasAttribute(AT_ARRAY) then
           CArray.Add<Tparam>(FParams, Tparam.Create(n.AttributeNodes.FindNode(AT_TRR), n.Attributes[AT_ARRAY]))
      else CArray.Add<Tparam>(FParams, Tparam.Create(n.AttributeNodes.FindNode(AT_TRR)));
      if n.HasAttribute(AT_TIP_TRR) then AddFieldType(n.Attributes[AT_TIP_TRR], False)
      else AddFieldType(n.Attributes[AT_TIP], False)
     end;
  end);
  if Length(spar) > 0 then Delete(spar, Length(spar), 1);
  FSql := Format(sql, [Trim(spar)]);
//  FQuery.Prepared := True;
end;

destructor TSaveData.Destroy;
begin
  FQuery.Destroy;
  inherited;
end;

class function TSaveData.FieldTxtToFieldType(const txt: string): TFieldType;
begin
  if txt = 'TEXT' then Exit(ftString)
  else if txt = 'REAL' then Exit(ftFloat)
  else if txt = 'INT' then Exit(ftInteger)
  else Result := ftUnknown;
end;

//class function TSaveData.ToValues(wrk: IXMLNode{; Func: TValFunc}//): string;
// var
//  R: string;
//begin
{  R := '';
  ExecXTree(wrk, procedure(n: IXMLNode)
   var
    s, d: string;
  begin
    if n.HasAttribute(AT_TIP) or n.HasAttribute(AT_TRR) then
     begin
      s := n.ParentNode.NodeName;
      if not ((S = AT_WRK) or (s = AT_RAM)) then s := s + '_' + n.NodeName
      else s := n.NodeName;
      if n.HasAttribute(AT_INDEX) then
       begin
        if n.HasAttribute(AT_ARRAY) then d := 'BLOB'
        else d := Tpars.VarTypeToDBField(n.Attributes[AT_TIP]);
        R := R + 'R_'+ s +' ' + d+ ','
       end;
      if n.HasAttribute(AT_TRR) then
       begin
        if n.HasAttribute(AT_TIP_TRR) then d := Tpars.VarTypeToDBField(n.Attributes[AT_TIP_TRR])
        else d := Tpars.VarTypeToDBField(n.Attributes[AT_TIP]);
        R := R +'T_' + s +' ' + d+ ','
       end;
     end;
  end);
  if Length(R) > 0 then Delete(R, Length(R), 1);
  Result := R;
end;

procedure TSaveData.SaveData(OnEnd: TThreadProcedure);
 var
  i: Integer;
  v: TArray<Variant>;
begin
  SetLength(v, Length(FParams));
  for i := 0 to Length(FParams)-1 do
   if FParams[i].array_len = 0 then
        V[i] := FParams[i].Value.NodeValue
   else V[i] := TPars.ArrayValToVar(Pointer(Integer(FParams[i].Value.NodeValue)), FParams[i].array_len);
    FQuery.AsyncSQL(FSql, V, FFields, qcExecute, OnEnd);
end;

{ TSaveLogData }

{procedure TSaveLogData.SaveData(OnEnd: TThreadProcedure);
 var
  i: Integer;
  v: TArray<Variant>;
begin
  if FStdOnly then
   begin
    SetLength(v, Length(FParams));
    for i := 0 to Length(V)-1 do if i > 0 then V[i] := Null
    else V[i].Value := FParams[i].Value.NodeValue;
    FQuery.AsyncSQL(FSql, V, FFields, qcExecute, OnEnd);
   end
  else inherited;
end;

procedure TSaveLogData.SetStdOnly(StdOnly: Boolean);
begin
  if FStdOnly <> StdOnly then
   begin
    FStdOnly := StdOnly;
   end;
end;}

end.

