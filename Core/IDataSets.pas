unit IDataSets;

interface

uses
     sysutils, Classes, Controls, Data.DB, debug_except, Container, RootImpl, RootIntf, ExtendIntf, DataSetIntf, System.Math,
     System.Bindings.Helper;

type
  TIDataSetDef = class(TInterfacedPersistent, ICaption, IDataSetDef)
  public
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function TryGet(out ids: IDataSet): Boolean; virtual; abstract;
    function CreateNew(out ids: IDataSet; UniDirectional: Boolean = True): Boolean; virtual; abstract;
  end;

  TIDataSet = class(TDataSet, IInterface{!!!!!! ����� _AddRef _Release ����� ������ ������}, IManagItem, IBind, IDataSet)
  private
    FRefCount: Integer;
    FWeekContainerReference: Boolean;
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
    function GetTempDir: string; virtual;

  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
    class function NewInstance: TObject; override;
    procedure AfterConstruction; override;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
/// <summary>
///   ����� ���������� ���������� � ����� ��������� ltSingletonNamed
///  ���� WeekContainerReference = ��, �� ���� �������� ����� ������ � ���������� �� ������� �� ����������
/// </summary>
/// <remarks>
///  �������� WeekContainerReference ������ ����� ���������� � ���������� ���������
///  IEnumXXX.ADD IEnumXXX.REMOVE Isaver - �� ������������
/// </summary>
    property WeekContainerReference: Boolean read FWeekContainerReference write FWeekContainerReference default True;
    // published ����������������
//  published
//    property FieldDefs;
  end;

  PRecBuffer = ^TRecBuffer;
  TRecBuffer = record
  private
//    function GetPtr: TRecordBuffer;
//    function GetBookmark: TBookmark;
//    procedure SetBookmark(const Value: TBookmark);
  public
//   Index: Integer;
   ///Bookmark, Index ??
   BookmarkFlag: TBookmarkFlag;
   ID: Integer;
//   property Ptr: TRecordBuffer read GetPtr;
//   property Bookmark: TBookmark read GetBookmark write SetBookmark;
  end;

  TRLDataSet = class(TIDataSet)
  protected
    // record data and status
    FIsTableOpen: Boolean;
  //  FRecordSize: Integer; // actual data + housekeeping
    FCurrent: Integer;
    FInternalCalcDataLen: Word;
    // �����������
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    function GetRecordSize: Word; override;
    //��������
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    // �������������
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure SetRecNo(Value: Integer); override;
    function GetRecNo: Integer; override;
    // open close
    procedure InternalClose; override;
    procedure InternalOpen; override;
    function IsCursorOpen: Boolean; override;
    procedure InternalInitFieldDefs; override;
    // ������
    procedure InternalHandleException; override;
    /////
    function GetActiveRecBuf(var RecBuf: PRecBuffer): Boolean; virtual;
  end;

  /// <summary>
  /// ���������� �� ��������������
  /// </summary>
   TDataSetEnum = class(TRootServiceManager<IDataSet>, IDataSetEnum)
   protected
     const PATH = 'IDataSetObjs';
     procedure Save(); override;
     procedure Load(); override;
//     function TryFind(const FileName: string; out ds: IDataSet): Boolean;
   end;

implementation


{ TDataSetEnum }

procedure TDataSetEnum.Load;
begin
  raise Exception.Create('���������� �� �������������� !!! WeekContainerReference = yes' );
  (TRegistryStorable<IDataSet>.Create(Self, PATH) as IStorable).Load;
end;

procedure TDataSetEnum.Save;
begin
  raise Exception.Create('���������� �� �������������� !!!WeekContainerReference = yes');
  (TRegistryStorable<IDataSet>.Create(Self, PATH) as IStorable).Save;
end;

{[function TDataSetEnum.TryFind(const FileName: string; out ds: IDataSet): Boolean;
 var
  ii: IInterface;
  //i: IDataSet;
begin
//  Result := False;
  //  �������������� WeekContainerReference = True;  �� ������������ ����������
//  for i in Enum(True) do if SameText(i.GetFileName, FileName) then
//   begin
//    ds := i;
//    Exit(True);
//  end;
  Result := GContainer.TryGetInstKnownServ(IDataSet, FileName, ii) and (ii.QueryInterface(IDataSet, ds) = S_OK);
end;}


{$REGION 'TIDataSet'}
{ TIDataSet }

constructor TIDataSet.Create;
 var
  i: Integer;
begin
  inherited Create(nil);
  i:= 1;
  while GContainer.Contains(RootName + i.ToString()) do Inc(i);
  Name := RootName + i.ToString;
  FWeekContainerReference := True;
end;

destructor TIDataSet.Destroy;
begin
 // TDebug.Log('TIDataSet.Destroy %s', [name]);
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
  if Result = 0 then
   begin
    Destroy
   end
  else if Result = 1 then
   begin
//    if WeekContainerReference then GContainer.NillInstance(Model, Name);
    if WeekContainerReference then GContainer.RemoveInstance(Model, Name);
   end;
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

//function TIDataSet.GetFileName: string;
//begin
//  Result := '';
//end;

function TIDataSet.GetItemName: String;
begin
  Result := Name;
end;

function TIDataSet.GetTempDir: string;
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

{$ENDREGION 'TIDataSet'}

{ TRecBuffer }

//procedure TRecBuffer.SetBookmark(const Value: TBookmark);
//begin
//  ID := PInteger(@Value[0])^
//end;
//
//function TRecBuffer.GetBookmark: TBookmark;
//begin
//  SetLength(Result, SizeOf(Integer));
//  PInteger(@Result[0])^ := ID;
//end;
//
{function TRecBuffer.GetPtr: TRecordBuffer;
begin
  Result := @Self;
end;}

{$REGION 'TRLDataSet'}

{ TRLDataSet }

function TRLDataSet.GetRecordSize: Word;
begin
  Result := SizeOf(TRecBuffer);
  if AutoCalcFields then inc(Result, FInternalCalcDataLen);
end;

function TRLDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  GetMem(Result, RecordSize);
  InternalInitRecord(Result);
end;

procedure TRLDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer);
  Buffer := nil;
end;

procedure TRLDataSet.InternalInitFieldDefs;
begin
end;

procedure TRLDataSet.InternalInitRecord(Buffer: TRecordBuffer);
begin
  FillChar(Buffer^, RecordSize, 0);
end;

function TRLDataSet.GetActiveRecBuf(var RecBuf: PRecBuffer): Boolean;
begin
  case State of
    dsBrowse:
      if IsEmpty then
        RecBuf := nil
      else
        RecBuf := PRecBuffer(ActiveBuffer);
    dsEdit, dsInsert:
      RecBuf := PRecBuffer(ActiveBuffer);
    dsCalcFields:
      RecBuf := PRecBuffer(CalcBuffer);
    dsFilter:
      RecBuf := PRecBuffer(TempBuffer);
    else
      RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

procedure TRLDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark);
begin
  PInteger(@Data[0])^ := PRecBuffer(Buffer).ID;
end;

procedure TRLDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark);
begin
  PRecBuffer(Buffer).ID := PInteger(@Data[0])^;
end;

function TRLDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := PRecBuffer(Buffer).BookmarkFlag;
end;

procedure TRLDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  PRecBuffer(Buffer).BookmarkFlag := Value;
end;

procedure TRLDataSet.InternalGotoBookmark(Bookmark: TBookmark);
begin
  FCurrent := PInteger(@Bookmark[0])^-1;
end;

procedure TRLDataSet.InternalHandleException;
begin
  TDebug.DoException(Exception(ExceptObject));
end;

function TRLDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
begin
  Result := grOK; // default
  case GetMode of
    gmNext: // move on
      if FCurrent < RecordCount - 1 then Inc(FCurrent)
      else Result := grEOF; // end of file
    gmPrior: // move back
      if FCurrent > 0 then Dec(FCurrent)
      else Result := grBOF; // begin of file
    gmCurrent: // check if empty
      if FCurrent >= RecordCount then Result := grEOF;
  end;
  if Result = grOK then if IsUniDirectional then with PRecBuffer(Buffers[0])^ do
   begin
    // ���� ��� � ���������
// fnction TDataSet.GetNextRecord: Boolean;
//   ..............
//    Result := (GetRecord(GetBuffer(FRecordCount), GetMode, True) = grOK);
//   ..............
//    else
//      if FRecordCount < FBufferCount then
//        Inc(FRecordCount) else
//        MoveBuffer(0, FRecordCount); <= ���� UniDirectional �� �������� � ��� ������ ������
//    FCurrentRecord := FRecordCount - 1;
//    Result := True;
//  /////////////////////
    InternalInitRecord(Buffer);
    ID := FCurrent+1;
    BookmarkFlag := bfCurrent;
   end else
  // read the data
    with PRecBuffer(Buffer)^ do
    begin
     InternalInitRecord(Buffer);
     ID := FCurrent+1;
     BookmarkFlag := bfCurrent;
    end;
end;

procedure TRLDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  FCurrent := PRecBuffer(Buffer).ID-1;
end;

procedure TRLDataSet.InternalLast;
begin
  FCurrent := RecordCount - 1;
end;

procedure TRLDataSet.InternalFirst;
begin
  FCurrent := -1;
end;

function TRLDataSet.GetRecNo: Integer;
begin
  Result := FCurrent + 1;
end;

procedure TRLDataSet.SetRecNo(Value: Integer);
begin
  if Value <> (FCurrent + 1) then
  begin
    DoBeforeScroll;
    FCurrent := Min(max(1, Value), RecordCount)-1;
    Resync([]);
    DoAfterScroll;
  end;
end;

function TRLDataSet.IsCursorOpen: Boolean;
begin
  Result := FIsTableOpen;
end;

procedure TRLDataSet.InternalClose;
begin
  BindFields(False);
  if DefaultFields then DestroyFields;
  FIsTableOpen := False;
end;

procedure TRLDataSet.InternalOpen;
begin
  BookmarkSize := SizeOf(Integer);
  FieldDefs.Updated := False;
  FieldDefs.Update;
  FieldDefList.Update;
  if DefaultFields then CreateFields;
  BindFields(True);
  InternalFirst;
  FIsTableOpen := True;
end;

{$ENDREGION 'TRLDataSet'}


{ TIDataSetDef }

function TIDataSetDef.GetCaption: string;
begin
  Result := '������'
end;

procedure TIDataSetDef.SetCaption(const Value: string);
begin

end;

initialization
  TRegister.AddType<TDataSetEnum, IDataSetEnum>.LiveTime(ltSingleton);
//TRegister.AddType<TIDataSet, IDataSet>.LiveTime(ltSingletonNamed);child mast register
end.
