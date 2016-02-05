unit IDataSets;

interface

uses
     sysutils, Classes, Controls, Data.DB, debug_except, Container, RootImpl, RootIntf, ExtendIntf, DataSetIntf,
     System.Bindings.Helper;

type
  TIDataSet = class(TDataSet, IInterface{!!!!!! иначе _AddRef _Release будут иногда старые}, IManagItem, IBind, IDataSet)
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
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
    class function NewInstance: TObject; override;
    procedure AfterConstruction; override;
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HResult; override;
/// <summary>
///   После добавления экземпляра в общее хранилище ltSingletonNamed
///  если WeekContainerReference = ДА, то если осталась тольо ссылка в контейнере то удаляем из контейнера
/// </summary>
/// <remarks>
///  Включать WeekContainerReference только после добавления В глобальный контейнер
/// </remarks>
    property WeekContainerReference: Boolean read FWeekContainerReference write FWeekContainerReference;
  published
    property FieldDefs;
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
   ID: Integer;
   BookmarkFlag: TBookmarkFlag;
//   property Ptr: TRecordBuffer read GetPtr;
//   property Bookmark: TBookmark read GetBookmark write SetBookmark;
  end;

  TRLDataSet = class(TIDataSet)
  protected
    // record data and status
    FIsTableOpen: Boolean;
  //  FRecordSize: Integer; // actual data + housekeeping
    FCurrent: Integer;
    // буферизация
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    function GetRecordSize: Word; override;
    //закладки
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: TBookmark); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
    // маршрутизация
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

    // другое
    procedure InternalHandleException; override;
    /////
    function GetActiveRecBuf(var RecBuf: PRecBuffer): Boolean; virtual;
  end;

   TDataSetEnum = class(TRootServiceManager<IDataSet>, IDataSetEnum)
   protected
     const PATH = 'IDataSetObjs';
     procedure Save(); override;
     procedure Load(); override;
   end;

implementation

{$REGION 'TIDataSet'}
{ TIDataSet }

constructor TIDataSet.Create;
 var
  i: Integer;
begin
  inherited Create(nil);
  ObjectView := True;
  i:= 1;
  while GContainer.Contains(RootName + i.ToString()) do Inc(i);
  Name := RootName + i.ToString;
end;

destructor TIDataSet.Destroy;
begin
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

function TIDataSet.GetItemName: String;
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

{ TDataSetEnum }

procedure TDataSetEnum.Load;
begin
  (TRegistryStorable<IDataSet>.Create(Self, PATH) as IStorable).Load;
end;

procedure TDataSetEnum.Save;
begin
  (TRegistryStorable<IDataSet>.Create(Self, PATH) as IStorable).Save;
end;

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
  FCurrent := PInteger(@Bookmark[0])^;
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
      if fCurrent < RecordCount - 1 then Inc(fCurrent)
      else Result := grEOF; // end of file
    gmPrior: // move back
      if fCurrent > 0 then Dec(fCurrent)
      else Result := grBOF; // begin of file
    gmCurrent: // check if empty
      if fCurrent >= RecordCount then Result := grEOF;
  end;

  if Result = grOK then // read the data
    with PRecBuffer(Buffer)^ do
    begin
      ID := fCurrent;
      BookmarkFlag := bfCurrent;
    end;
end;

procedure TRLDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  FCurrent := PRecBuffer(Buffer).ID;
end;

procedure TRLDataSet.InternalLast;
begin
  FCurrent := RecordCount - 1;
end;

procedure TRLDataSet.InternalFirst;
begin
  FCurrent := 0;
end;

function TRLDataSet.GetRecNo: Integer;
begin
  Result := FCurrent + 1;
end;

procedure TRLDataSet.SetRecNo(Value: Integer);
begin
  if (Value > 0) and (Value <= RecordCount) then
  begin
    DoBeforeScroll;
    FCurrent := Value - 1;
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


initialization
  TRegister.AddType<TDataSetEnum, IDataSetEnum>.LiveTime(ltSingleton);
//TRegister.AddType<TIDataSet, IDataSet>.LiveTime(ltSingletonNamed);child mast register
end.
