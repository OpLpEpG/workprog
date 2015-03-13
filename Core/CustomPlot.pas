unit CustomPlot;

interface

uses RootImpl, tools, debug_except,
     Vcl.Grids,
     SysUtils, Controls, Messages, Winapi.Windows, Classes, System.Rtti, types,
     Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.Themes, Vcl.GraphUtil;

type
  /// основной класс графиков
  TCustomPlot = class;

  /// прямоугольник отрисовки  графиков легенды информации
  TPlotRegion = class;
  /// коллекция хранится в колонке
  TPlotRegions = class;

  /// содержимое таблиц графиков
  TPlotParam = class;
  TPlotParams = class;

  /// колонки коллекция
  TPlotColumn = class;
  TPlotColumns = class;
  /// строки коллекция
  TPlotRow = class;
  TPlotRows = class;

  {$REGION 'всякие коллекции сохраняемые'}
  TPlotCollection = class;
  TPlotCollectionItem = class(TICollectionItem)
  private
    FPlot: TCustomPlot;
  public
    // конструктор вызывается загрузчиком и в CreateNew
    constructor Create(Collection: TCollection); override;
    // конструктор вызывается пользователем при созданн елемента коллекции
    constructor CreateNew(Collection: TPlotCollection); virtual;
    property Plot: TCustomPlot read FPlot;
  end;
  TPlotCollectionItemClass = class of TPlotCollectionItem;

  TPlotCollection = class abstract(TICollection)
  private
    FPlot: TCustomPlot;
  protected
  public
    function Add(const ItemClassName: string): TPlotCollectionItem; reintroduce; overload;
    function Add(ItemClass: TPlotCollectionItemClass): TPlotCollectionItem; reintroduce; overload;
    property Plot: TCustomPlot read FPlot;
  end;

  TPlotCollection<T: TPlotCollectionItem> = class(TPlotCollection)
  private
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
  type
   TEnumerator = record
   private
     i: Integer;
     FCollection: TPlotCollection<T>;
     function DoGetCurrent: T; inline;
   public
    property Current: T read DoGetCurrent;
    function MoveNext: Boolean; inline;
  end;
  protected
  public
    function Add<C: T>: C; reintroduce; overload;
    function GetEnumerator: TEnumerator; reintroduce;
    constructor Create(AOwner: TObject); virtual;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
  end;
{$ENDREGION}

  {$REGION ' строки колонки '}
  /// строки колонки общее
  TColRowCollectionItem = class(TPlotCollectionItem)
  private
    FVisible: Boolean;
    procedure SetVisible(const Value: Boolean);
  protected
    FFrom: Integer;
    FLen: Integer;
    function GetItem(Index: Integer): TPlotRegion; virtual; abstract;
    function GetRegionsCount: Integer; virtual; abstract;
    function GetTo: Integer; inline;
    procedure SetLen(const Value: Integer); inline;
    function AutoSize: Boolean; virtual;
  public
    constructor Create(Collection: TCollection); override;
    property Regions[Index: Integer]: TPlotRegion read GetItem; default;
    property RegionsCount: Integer read GetRegionsCount;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TCollectionColRows<T: TColRowCollectionItem> = class(TPlotCollection<T>)
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    function LastToResize(FromLast: integer; ToFirst: Integer = 0): TColRowCollectionItem;
    function GetAllLen: Integer; virtual; abstract;
  public
    procedure UpdateSizes;
  end;

  // строки;
  TPlotRow = class(TColRowCollectionItem)
  private
    FCursor: Integer;
  public
    property Top: Integer read FFrom;
    property Bottom: Integer read GetTo;
    property Cursor: Integer read FCursor;
  protected
    function GetItem(Index: Integer): TPlotRegion; override;
    function GetRegionsCount: Integer; override;
  published
    property Height: Integer read FLen write SetLen;
    property Visible;
  end;
  TPlotRowClass = class of TPlotRow;
  TPlotRows = class(TCollectionColRows<TPlotRow>)
  protected
    function GetAllLen: Integer; override;
  public
    function FindRows(rc: TPlotRowClass):TArray<TPlotRow>;
  end;
  // типы строки;
  TNoSizeblePlotRow = class(TPlotRow)
  protected
    function AutoSize: Boolean; override;
  end;
  TCustomPlotLegend = class(TNoSizeblePlotRow);
  TCustomPlotInfo = class(TNoSizeblePlotRow);
  TCustomPlotData = class(TPlotRow)
  public
    constructor Create(Collection: TCollection); override;
  end;

  /// колонки
  TPlotColumnClass = class of TPlotColumn;
  TPlotColumn = class(TColRowCollectionItem)
  public
   type
    TColClassData = record
     ColCls: TPlotColumnClass;
     DisplayName: string;
    end;
  private
    FRegions: TPlotRegions;
    FParams: TPlotParams;
    FOnContextPopup: TContextPopupEvent;
    procedure CreateRegions();
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function GetItem(Index: Integer): TPlotRegion; override;
    function GetRegionsCount: Integer; override;
    // Хранилище типов колонок
    class procedure ColClsRegister(acc: TPlotColumnClass; const DisplayName: string);
  public
    class var ColClassItems: TArray<TColClassData>;
    constructor Create(Collection: TCollection); override;
    constructor CreateNew(Collection: TPlotCollection); override;
//    constructor Create(Collection: TCollection); override; final;
    destructor Destroy; override;
    property Left: Integer read FFrom;
    property Right: Integer read GetTo;
    property Regions: TPlotRegions read FRegions;
    property Params: TPlotParams read FParams;
  published
    property Width: Integer read FLen write SetLen;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
  end;
  TPlotColumns = class(TCollectionColRows<TPlotColumn>)
  protected
    function GetAllLen: Integer; override;
  end;
  TPlotColumnsClass = class of TPlotColumns;
{$ENDREGION}

   {$REGION 'коллекции хранящиеся в колонке параметры: регионы, мeтки глубины'}
  /// коллекция колонки общее
  TColumnCollectionItem = class(TPlotCollectionItem)
  private
    FColumn: TPlotColumn;
  public
    constructor Create(Collection: TCollection); override;
    property Column: TPlotColumn read FColumn;
  end;
  TColumnCollection<T: TColumnCollectionItem> = class(TPlotCollection<T>)
  private
    FColumn: TPlotColumn;
  public
    constructor Create(AOwner: TObject); override;
    property Column: TPlotColumn read FColumn;
  end;

  {$REGION 'TPlotRegion'}
  /// основной класс отрисовки
  TPlotRegionClass = class of TPlotRegion;
  TPlotRegion = class(TColumnCollectionItem)
  private
    FClientRect: TRect;
    FPlotRow: TPlotRow;
    FOnContextPopup: TContextPopupEvent;
    function GetRow: string;
    procedure SetRow(const Value: string);
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean);
   type
    TRegClsData = record
     pc: TPlotRegionClass;
     rc: TPlotRowClass;
     cc: TPlotColumnClass;
    end;
    class var GRegClsItems: TArray<TRegClsData>;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure SetClientRect(const Value: TRect);
    procedure UpdateSize;
    procedure Paint; virtual;
  public
    // поиск нкжного класса региона по колонке и ряду
    class procedure RegClsRegister(apc: TPlotRegionClass; arc: TPlotRowClass; acc: TPlotColumnClass);
    class function RegClsFind(arc: TPlotRowClass; acc: TPlotColumnClass): TPlotRegionClass;
    function TryHitParametr(pos: TPoint; out Par: TPlotParam): Boolean; virtual;
    property Row: TPlotRow read FPlotRow write FPlotRow;
    property ClientRect: TRect read FClientRect write SetClientRect;
  published
    property PropRow: string read GetRow write SetRow;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
  end;
  TPlotRegions = class(TColumnCollection<TPlotRegion>);
  {$ENDREGION}

  IDataLink = interface
  ['{421A0AD1-48C0-4DB0-A08D-281E0121C13D}']

  end;

  TCustomDataLinkClass = class of TCustomDataLink;
  TCustomDataLink = class(TInterfacedPersistent , IDataLink)
  private
    FOwner: TPlotParam;
  public
    constructor Create(AOwner: TPlotParam); virtual;
  end;

  TFileDataLink = class(TCustomDataLink)
  private
    FFileName: string;
    FXParamPath: string;
    FYParamPath: string;
    procedure SetXParamPath(const Value: string);
    procedure SetYParamPath(const Value: string);
  public
    constructor Create(AOwner: TPlotParam); override;
  published
   [ShowProp('Файл', True)]  property FileName: string read FFileName write FFileName;
   [ShowProp('X')]  property XParamPath: string read FXParamPath write SetXParamPath;
   [ShowProp('Y')]  property YParamPath: string read FYParamPath write SetYParamPath;
  end;

  TPlotParamClass = class of TPlotParam;
  TPlotParam = class(TColumnCollectionItem, IDataLink)
  private
    FLink: TCustomDataLink;
    FOnContextPopup: TContextPopupEvent;
    FTitle: string;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean);
    procedure SetTitle(const Value: string);
    function GetLinkClass: string;
    procedure SetLinkClass(const Value: string);
    procedure SetLink(const Value: TCustomDataLink);
  public
    destructor Destroy; override;
  published
    property LinkClass: string read GetLinkClass write SetLinkClass;
    [ShowProp('Имя')] property Title: string read FTitle write SetTitle;
    [ShowProp('Источник', True)] property Link: TCustomDataLink read FLink write SetLink implements IDataLink;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
  end;
  TPlotParams = class(TColumnCollection<TPlotParam>);
{$ENDREGION}

  /// перемещение или изменение размера рядов или колонок мышкой
  ///  сосотяние
  PlotState = (pcsNormal, pcsColSizing, pcsColMoving, pcsRowSizing, pcsRowMoving);
  {$REGION 'классы выполняюшие PlotState'}
  TCustomEditDlot = class
    FOwner:  TCustomPlot;
    FItem, FSwap: TColRowCollectionItem;
    Fpos: Integer;
    FState: PlotState;
    function SetPos(Pos: TPoint):integer;
    procedure Drow; virtual;
    procedure Move(Pos: TPoint); virtual;
    constructor Create(Owner:  TCustomPlot; Pos: TPoint; ps: PlotState; Item: TColRowCollectionItem);
    destructor Destroy; override;
  end;
  TCustomEditDlotClass = class of TCustomEditDlot;

  TColSizing = class(TCustomEditDlot)
    destructor Destroy; override;
  end;

  TRowSizing = class(TColSizing);

  TColMoving = class(TCustomEditDlot)
    procedure Move(Pos: TPoint); override;
    destructor Destroy; override;
  end;

  TRowMoving = class(TColMoving);
{$ENDREGION}

  ///  клласс основной
  EPlotException = EBaseException;
  TCustomPlot = class(TICustomControl)
  private
    FHitTest: TPoint;
    FState: PlotState;
    FEditPlot: TCustomEditDlot;
    FColumns: TPlotColumns;
    FRows: TPlotRows;
    FHitRegion: TPlotRegion;
    FYAxis: TPlotParam;

    procedure UpdateColRowRegionSizes;
    procedure UpdateRegionSizes;
    function IsMouseSizeMove(Pos: TPoint; var ps: PlotState; out Item: TColRowCollectionItem): Boolean; overload;
    function IsMouseSizeMove(Pos: TPoint; var ps: PlotState): Boolean; overload;

    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure SetYAxis(const Value: TPlotParam);
  protected
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
//    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function HitRow(pos: TPoint): TPlotRow;
    function HitColumn(pos: TPoint): TPlotColumn;
    function HitRegion(pos: TPoint): TPlotRegion; overload;
    function HitRegion(c: TPlotColumn; r: TPlotRow): TPlotRegion; overload;
    property Columns: TPlotColumns read FColumns;
    property Rows: TPlotRows read FRows;
  published
    property YAxis: TPlotParam read FYAxis write SetYAxis;
  end;

  TPlot = class(TCustomPlot)
  published
    property Align;
    property ParentFont;
    property Parent;
    property Font;
    property ParentColor;
    property Color;
    property OnContextPopup;
  end;

implementation

uses System.Math, Winapi.CommCtrl;

{$REGION 'Collection'}

{ TPlotCollectionItem }

constructor TPlotCollectionItem.Create(Collection: TCollection);
begin
  FPlot := TPlotCollection(Collection).Plot;
  inherited Create(Collection);
end;

constructor TPlotCollectionItem.CreateNew(Collection: TPlotCollection);
begin
  Create(Collection);
end;

{ TPlotCollection }

function TPlotCollection.Add(const ItemClassName: string): TPlotCollectionItem;
begin
  Result := TPlotCollectionItem(TPlotCollectionItemClass(FindClass(ItemClassName)).CreateNew(Self));
end;

function TPlotCollection<T>.Add<C>: C;
begin
  Result := TRttiContext.Create.GetType(TClass(C)).GetMethod('CreateNew').Invoke(TClass(C), [Self]).AsType<C>; //через жопу работает
end;

constructor TPlotCollection<T>.Create(AOwner: TObject);
begin
  FPlot := TCustomPlot(AOwner);
  inherited Create(T);
end;

function TPlotCollection<T>.GetEnumerator: TEnumerator;
begin
  Result.i := -1;
  Result.FCollection := Self;
end;

function TPlotCollection<T>.GetItem(Index: Integer): T;
begin
  Result := T(inherited GetItem(Index));
end;

procedure TPlotCollection<T>.SetItem(Index: Integer; const Value: T);
begin
  inherited SetItem(Index, Value);
end;

function TPlotCollection.Add(ItemClass: TPlotCollectionItemClass): TPlotCollectionItem;
begin
  Result := ItemClass.CreateNew(Self);
end;

{ TPlotCollection<T>.TEnumerator }

function TPlotCollection<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := FCollection.Items[i];
end;

function TPlotCollection<T>.TEnumerator.MoveNext: Boolean;
begin
  Inc(i);
  Result := i < FCollection.Count;
end;


{ TRegionCollectionItem }

function TColRowCollectionItem.AutoSize: Boolean;
begin
  Result := True;
end;

constructor TColRowCollectionItem.Create(Collection: TCollection);
begin
  FLen := 20;
  FVisible := True;
  inherited;
end;

function TColRowCollectionItem.GetTo: Integer;
begin
  Result := FFrom + FLen;
end;

procedure TColRowCollectionItem.SetLen(const Value: Integer);
begin
  if Value > 20 then FLen := Value
  else FLen := 20;
end;

procedure TColRowCollectionItem.SetVisible(const Value: Boolean);
begin
  if  FVisible <> Value then
   begin
    FVisible := Value;
    if csLoading in Plot.ComponentState then Exit;
    TCollectionColRows<TColRowCollectionItem>(Collection).UpdateSizes;
    Plot.UpdateRegionSizes;
   end;
end;

{ TPlotColumns }

function TPlotColumns.GetAllLen: Integer;
begin
  Result := FPlot.Width;
end;

{ TPlotRows }

function TPlotRows.FindRows(rc: TPlotRowClass): TArray<TPlotRow>;
 var
  r: TPlotRow;
begin
  for r in Self do if r is rc then CArray.Add<TPlotRow>(Result, r);
end;

function TPlotRows.GetAllLen: Integer;
begin
  Result := FPlot.Height;
end;

{ TPlotRow }

function TPlotRow.GetItem(Index: Integer): TPlotRegion;
 var
  r: TPlotRegion;
begin
  if (Index < 0) or (Index >= FPlot.Columns.Count) then raise EPlotException.CreateFmt('Неверный индекс Региона I:%d L:%d',[Index, FPlot.Columns.Count]);
  for r in FPlot.Columns[Index].FRegions do if r.Row = Self then Exit(r);
  raise EPlotException.CreateFmt('Регион %s не найлен',[ClassName]);
end;

function TPlotRow.GetRegionsCount: Integer;
begin
  Result := FPlot.Columns.Count;
end;

{ TNoSizeblePlotRow }

function TNoSizeblePlotRow.AutoSize: Boolean;
begin
  Result := False;
end;

{ TPlotColumn }

class procedure TPlotColumn.ColClsRegister(acc: TPlotColumnClass; const DisplayName: string);
 var
  d: TColClassData;
begin
  d.ColCls := acc;
  d.DisplayName := DisplayName;
  CArray.Add<TColClassData>(ColClassItems, d);
end;

constructor TPlotColumn.Create(Collection: TCollection);
begin
  FPlot := TPlotColumns(Collection).Plot;
  FRegions := TPlotRegions.Create(Self);
  FParams := TPlotParams.Create(Self);
  inherited Create(Collection);
end;

constructor TPlotColumn.CreateNew(Collection: TPlotCollection);
begin
  inherited;
  CreateRegions();
end;

procedure TPlotColumn.CreateRegions;
 var
  r: TPlotRow;
  p: TPlotRegion;
begin
  FRegions.Clear;
  for r in Plot.Rows do TPlotRegion(FRegions.Add(TPlotRegion.RegClsFind(TPlotRowClass(r.ClassType), TPlotColumnClass(ClassType)))).FPlotRow := r;
  for p in Regions do p.UpdateSize;
end;

procedure TPlotColumn.DefineProperties(Filer: TFiler);
begin
  inherited;
  FParams.RegisterProperty(Filer, 'Params');
  FRegions.RegisterProperty(Filer, 'Regions');
end;

destructor TPlotColumn.Destroy;
begin
  FRegions.Free;
  FParams.Free;
  inherited;
end;

procedure TPlotColumn.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then FOnContextPopup(Self, MousePos, Handled);
  if not Handled then Plot.HitRegion(Self,  Plot.HitRow(MousePos)).DoContextPopup(MousePos, Handled);
end;

function TPlotColumn.GetItem(Index: Integer): TPlotRegion;
begin
  if (Index < 0) or (Index >= FRegions.Count) then raise EPlotException.CreateFmt('Неверный индекс Региона I:%d L:%d',[Index, FRegions.Count]);
  Result := FRegions[Index];
end;

function TPlotColumn.GetRegionsCount: Integer;
begin
  Result := FRegions.Count;
end;

{ TCustomPlotData }

constructor TCustomPlotData.Create(Collection: TCollection);
begin
  inherited;
  FCursor := crCross;
end;

{ TPlotRegions<T> }

function TCollectionColRows<T>.LastToResize(FromLast: integer; ToFirst: Integer = 0): TColRowCollectionItem;
 var
  i: Integer;
begin
  for i := FromLast downto ToFirst do
   if Items[i].Visible then
    if Items[i].AutoSize then Exit(Items[i])
    else Result := Items[i];
end;

procedure TCollectionColRows<T>.Notify(Item: TCollectionItem; Action: TCollectionNotification);
 var
  r: TColRowCollectionItem;
  len: Integer;
begin
  inherited;
  if FPlot.ComponentState * [csLoading, csDestroying] <> [] then Exit;
  if (Action = cnAdded) then
   if (Count >= 2) then
    begin
     r := LastToResize(Count - 2);
     r.SetLen(r.FLen div 2);
     TColRowCollectionItem(Item).FLen := r.FLen;
    end
   else TColRowCollectionItem(Item).FLen := GetAllLen;
  UpdateSizes;
  Plot.UpdateRegionSizes;
end;

procedure TCollectionColRows<T>.UpdateSizes;
 var
  lf, i, j, wf: Integer;
  r, rs: TColRowCollectionItem;
begin
  if (Count = 0) or (FPlot.ComponentState * [csLoading, csDestroying] <> []) then Exit;
  rs := LastToResize(Count - 1);
  lf := 0;
  for i := 0 to Count-1 do if Items[i].Visible then
   begin
    r := Items[i];
    r.FFrom := lf;
    if rs = r then
     begin
      wf := 0;
      for j := i + 1 to Count - 1 do if Items[j].Visible then wf := wf + Items[j].Flen;
      r.SetLen(GetAllLen - lf- wf);
     end;
    Inc(lf, r.FLen);
   end;
end;

{ TColumnCollection<T> }

constructor TColumnCollection<T>.Create(AOwner: TObject);
begin
  FColumn := TPlotColumn(AOwner);
  inherited Create(TPlotColumn(AOwner).Plot);
end;

{ TColumnCollectionItem }

constructor TColumnCollectionItem.Create(Collection: TCollection);
begin
  FColumn := TColumnCollection<TColumnCollectionItem>(Collection).Column;
  inherited Create(Collection);
end;

{ TPlotRegion }

procedure TPlotRegion.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
 var
  p: TPlotParam;
begin
  if Assigned(FOnContextPopup) then FOnContextPopup(Self, MousePos, Handled);
  if not Handled and TryHitParametr(MousePos, p) then p.DoContextPopup(MousePos, Handled);
end;

function TPlotRegion.GetRow: string;
begin
  Result :=  FPlotRow.ClassName;
end;

procedure TPlotRegion.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;
procedure TPlotRegion.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;
procedure TPlotRegion.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;
procedure TPlotRegion.Paint;
begin
  if Column.Visible and Row.Visible then
   begin
    Plot.Canvas.FillRect(ClientRect);
    Plot.Canvas.TextRect(ClientRect, ClientRect.Left + ClientRect.Width div 2, ClientRect.Top + ClientRect.Height div 2, 'NOP');
   end;
end;
procedure TPlotRegion.UpdateSize;
 var
  r: TRect;
begin
  r := TRect.Create(Column.Left, Row.Top, Column.Right, Row.Bottom);
  if r <> ClientRect then ClientRect := r;
end;

class function TPlotRegion.RegClsFind(arc: TPlotRowClass; acc: TPlotColumnClass): TPlotRegionClass;
 var
  r: TRegClsData;
begin
  for r in GRegClsItems do if (r.cc = acc) and (r.rc = arc) then Exit(r.pc);
  Result := TPlotRegion;
//  raise EPlotException.CreateFmt('Ненайден класс региона %s  %s', [arc.ClassName, acc.ClassName]);
end;

class procedure TPlotRegion.RegClsRegister(apc: TPlotRegionClass; arc: TPlotRowClass; acc: TPlotColumnClass);
 var
  d: TRegClsData;
begin
  d.pc := apc;
  d.rc := arc;
  d.cc := acc;
  CArray.Add<TRegClsData>(GRegClsItems, d);
end;

procedure TPlotRegion.SetClientRect(const Value: TRect);
begin
  FClientRect := Value;
end;

procedure TPlotRegion.SetRow(const Value: string);
 var
  r: TPlotRow;
begin
  for r in Plot.Rows do if SameText(r.ClassName, Value) then
   begin
    FPlotRow := r;
    Exit;
   end;
  raise EPlotException.CreateFmt('Ненайден класс ряда %s', [Value]);
end;

function TPlotRegion.TryHitParametr(pos: TPoint; out Par: TPlotParam): Boolean;
begin
  Result := False;
end;

{ TPlotParam }

destructor TPlotParam.Destroy;
begin
  if Assigned(FLink) then FreeAndNil(Flink);
  inherited;
end;

procedure TPlotParam.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then FOnContextPopup(Self, MousePos, Handled);
end;


{ TCustomDataLink }

constructor TCustomDataLink.Create(AOwner: TPlotParam);
begin
  FOwner := AOwner;
end;

{ TFileDataLink }

constructor TFileDataLink.Create(AOwner: TPlotParam);
begin
  inherited;

end;

procedure TFileDataLink.SetXParamPath(const Value: string);
begin
  FXParamPath := Value;
end;

procedure TFileDataLink.SetYParamPath(const Value: string);
begin
  FYParamPath := Value;
end;

{$ENDREGION Collection}

{$REGION ' классы выполняюшие PlotState '}
function TPlotParam.GetLinkClass: string;
begin
  if Assigned(FLink) then Result := FLink.ClassName
  else Result :=  '';
end;

procedure TPlotParam.SetLink(const Value: TCustomDataLink);
begin
  if Assigned(FLink) then FLink.Free;
  FLink := Value;
end;

procedure TPlotParam.SetLinkClass(const Value: string);
begin
  if Assigned(FLink) then FreeAndNil(Flink);
  if Value <> '' then FLink := TCustomDataLinkClass(FindClass(Value)).Create(Self);
end;

procedure TPlotParam.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

{ TCustomEditDlot }

constructor TCustomEditDlot.Create(Owner:  TCustomPlot; Pos: TPoint; ps: PlotState; Item: TColRowCollectionItem);
begin
  FOwner := Owner;
  FItem := Item;
  FSwap := Item;
  FState := ps;
  if FState in [pcsColMoving, pcsRowMoving] then Fpos := Item.FFrom
  else Fpos := SetPos(Pos);
  Drow;
end;

destructor TCustomEditDlot.Destroy;
begin
  FOwner.FState := pcsNormal;
  inherited;
end;

procedure TCustomEditDlot.Drow;
begin
  with FOwner.Canvas do
   begin
    Pen.Style := psDot;
    Pen.Mode := pmXor;
    if FState in [pcsColSizing, pcsRowSizing] then
     begin
      Pen.Color := clBlack;
      Pen.Width := 1;
     end
    else
     begin
      Pen.Color := clWhite;
      Pen.Width := 5;
     end;
    if FState in [pcsColSizing, pcsColMoving] then
     begin
      MoveTo(Fpos, 0);
      LineTo(Fpos, FOwner.ClientHeight);
     end
    else
     begin
      MoveTo(0, Fpos);
      LineTo(FOwner.ClientWidth, Fpos);
     end;
   end;
end;

procedure TCustomEditDlot.Move(Pos: TPoint);
begin
  Drow;
  Fpos := SetPos(Pos);
  Drow;
end;

function TCustomEditDlot.SetPos(Pos: TPoint): integer;
begin
  if FState in [pcsColMoving, pcsColSizing] then Result := Pos.X
  else Result := Pos.Y;
end;

{ TRowSizing }

destructor TColMoving.Destroy;
begin
  if FItem <> FSwap then
   begin
    FItem.Index := FSwap.Index;
    if FState = pcsColMoving then FOwner.Columns.UpdateSizes()
    else FOwner.Rows.UpdateSizes();
    FOwner.UpdateRegionSizes;
    FOwner.Repaint;
   end
  else Drow;
  inherited;
end;

procedure TColMoving.Move(Pos: TPoint);
 var
  r: TColRowCollectionItem;
  p: Integer;
begin
  p := SetPos(Pos);
  for r in TPlotCollection<TColRowCollectionItem>(FItem.Collection) do if (p < r.GetTo) and (p > r.FFrom) and (FSwap <> r) then
   begin
    Drow;
    FSwap := r;
    Fpos := r.FFrom;
    Drow;
    Break;
   end;
end;

{ TColSizing }

destructor TColSizing.Destroy;
 var
  wold: Integer;
begin
  wold := FItem.FLen;
  if FState = pcsColSizing then FSwap := FOwner.Columns.LastToResize(FOwner.Columns.Count-1, FItem.Index+1)
  else FSwap := FOwner.Rows.LastToResize(FOwner.Rows.Count-1, FItem.Index+1);
  if FItem <> FSwap then
   begin
    FItem.SetLen(Fpos - FItem.FFrom);
    FSwap.SetLen(FSwap.FLen - (FItem.FLen - wold));
    if FState = pcsColSizing then FOwner.Columns.UpdateSizes()
    else FOwner.Rows.UpdateSizes();
    FOwner.UpdateRegionSizes;
    FOwner.Repaint;
   end
  else Drow;
  inherited;
end;
{$ENDREGION}

{$REGION 'TCustomPlot ----- Create Destroy'}

{ TCustomPlot }

constructor TCustomPlot.Create(AOwner: TComponent);
begin
  inherited;
  FRows := TPlotRows.Create(Self);
  FColumns := TPlotColumns.Create(Self);
end;

destructor TCustomPlot.Destroy;
begin
  FColumns.Free;
  FRows.Free;
  inherited;
end;


procedure TCustomPlot.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
//  if Assigned(PopupMenu) then
  if not Handled then  HitColumn(MousePos).DoContextPopup(MousePos, Handled);
end;

procedure TCustomPlot.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  FRows.RegisterProperty(Filer, 'PlotRows');
  FColumns.RegisterProperty(Filer, 'PlotColumns');
end;
{$ENDREGION}

{$REGION 'TCustomPlot ----- SCROLL DATA'}
{$ENDREGION 'TCustomPlot ----- SCROLL BAR'}

{$REGION 'TCustomPlot ----- MOVE, RESIZE HIT'}

procedure TCustomPlot.UpdateColRowRegionSizes;
begin
  Rows.UpdateSizes;
  Columns.UpdateSizes;
  UpdateRegionSizes;
end;

procedure TCustomPlot.UpdateRegionSizes;
 var
  c: TPlotColumn;
  p: TPlotRegion;
begin
  if csLoading in ComponentState then Exit;
  for c in Columns do for p in c.Regions do p.UpdateSize;
end;

function TCustomPlot.HitColumn(pos: TPoint): TPlotColumn;
 var
  r: TPlotColumn;
begin
  for r in Columns do if (pos.Y >= r.Left) and (pos.Y <= r.Right) then Exit(r);
  raise EBaseException.Create('Нет колонки в данном месте');
end;

function TCustomPlot.HitRegion(pos: TPoint): TPlotRegion;
begin
  Result := HitRegion(HitColumn(pos), HitRow(pos));
end;

function TCustomPlot.HitRegion(c: TPlotColumn; r: TPlotRow): TPlotRegion;
 var
  p: TPlotRegion;
begin
  for p in c.Regions do if p.Row = r then Exit(p);
  raise EBaseException.Create('Нет региона в данном месте');
end;

function TCustomPlot.HitRow(pos: TPoint): TPlotRow;
 var
  r: TPlotRow;
begin
  for r in Rows do if (pos.Y >= r.Top) and (pos.Y <= r.Bottom) then Exit(r);
  raise EBaseException.Create('Нет ряда в данном месте');
end;

procedure TCustomPlot.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  DefaultHandler(Msg);
  FHitTest := ScreenToClient(SmallPointToPoint(Msg.Pos));
end;

function TCustomPlot.IsMouseSizeMove(Pos: TPoint; var ps: PlotState; out Item: TColRowCollectionItem): Boolean;
 const
  MM = 4;
 var
  c: TPlotColumn;
  r: TPlotRow;
  function Setps(s: PlotState; ri: TColRowCollectionItem): Boolean;
  begin
    Item := ri;
    ps := s;
    Result := True;
  end;
begin
  if Pos.Y < MM*2 then for c in Columns do if (c.Left < Pos.X) and (Pos.X < c.Right) then  Exit(Setps(pcsColMoving, c));
  if Pos.X < MM*2 then for r in Rows do    if (r.Top < Pos.Y)  and (Pos.Y < r.Bottom)  then  Exit(Setps(pcsRowMoving, r));
  if Pos.X < ClientWidth  - MM*2 then for c in Columns do if Abs(c.Right - Pos.X) < MM then Exit(Setps(pcsColSizing, c));
  if Pos.Y < ClientHeight - MM*2 then for r in Rows do    if Abs(r.Bottom -  Pos.Y) < MM then Exit(Setps(pcsRowSizing, r));
  Result := False;
  ps := pcsNormal;
  Item := nil;
end;

function TCustomPlot.IsMouseSizeMove(Pos: TPoint; var ps: PlotState): Boolean;
 const
  MM = 4;
 var
  c: TPlotColumn;
  r: TPlotRow;
  function Setps(s: PlotState): Boolean;
  begin
    ps := s;
    Result := True;
  end;
begin
  if (Pos.Y < MM*2) then Exit(Setps(pcsColMoving));
  if (Pos.X < MM*2) then Exit(Setps(pcsRowMoving));
  if Pos.X < ClientWidth  - MM*2 then for c in Columns do if Abs(c.Right - Pos.X) < MM then Exit(Setps(pcsColSizing));
  if Pos.Y < ClientHeight - MM*2 then for r in Rows do    if Abs(r.Bottom -  Pos.Y) < MM then Exit(Setps(pcsRowSizing));
  Result := False;
  ps := pcsNormal;
end;

procedure TCustomPlot.Loaded;
begin
  inherited;
  UpdateColRowRegionSizes;
end;

procedure TCustomPlot.WMSetCursor(var Msg: TWMSetCursor);
var
  State: PlotState;
  Cur: HCURSOR;
begin
  Cur := 0;
  State := pcsNormal;
  if Msg.HitTest = HTCLIENT then
   begin
    if FState <> pcsNormal then State := FState
    else if not IsMouseSizeMove(FHitTest, State) then Cur := Screen.Cursors[HitRow(FHitTest).Cursor];
    /// setup cursors
    if (State = pcsColSizing) then Cur := Screen.Cursors[crHSplit]
    else if (State = pcsRowSizing) then Cur := Screen.Cursors[crVSplit]
    else if State in [pcsColMoving, pcsRowMoving] then Cur := Screen.Cursors[crDrag]
   end;
  if Cur <> 0 then SetCursor(Cur) else inherited;
end;

procedure TCustomPlot.WMSize(var Message: TWMSize);
begin
  inherited;
  if HandleAllocated and (FState = pcsNormal) and (ClientHeight > 0) and (ClientWidth > 0) and not (csLoading in ComponentState) then
   try
//    Include(FStates, psSizing);
    UpdateColRowRegionSizes;
   finally
//   Exclude(FStates, psSizing);
   end;
end;

procedure TCustomPlot.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 const
  CCLS: array [PlotState] of TCustomEditDlotClass = (TCustomEditDlot, TColSizing, TColMoving, TRowSizing, TRowMoving);
 var
  r: TColRowCollectionItem;
begin
  try
   if not (csDesigning in ComponentState) and (CanFocus or (GetParentForm(Self) = nil)) then
    begin
     SetFocus;
    end;
   if (Button = mbLeft) and (ssDouble in Shift) then  DblClick
   else if Button = mbLeft then
    if IsMouseSizeMove(Tpoint.Create(X,Y), FState, r) then FEditPlot := CCLS[FState].Create(Self, Tpoint.Create(X,Y), FState, r)
    else
     begin
      FHitRegion := HitRegion(Tpoint.Create(X,Y));
      if Assigned(FHitRegion) then FHitRegion.MouseDown(Button, Shift, X, Y);
     end;
  finally
   inherited;
  end;
end;

procedure TCustomPlot.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FEditPlot) then FEditPlot.Move(TPoint.Create(X,Y))
  else if Assigned(FHitRegion) then FHitRegion.MouseMove(Shift, X, Y);
  inherited;
end;

procedure TCustomPlot.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FEditPlot) then FreeAndNil(FEditPlot)
  else if Assigned(FHitRegion) then
   begin
    FHitRegion.MouseUp(Button, Shift, X, Y);
    FHitRegion := nil;
   end;
  inherited;
end;

{$ENDREGION}

{$REGION 'TCustomPlot ----- P A I N T'}

procedure TCustomPlot.Paint;
 var
  c: TPlotColumn;
  r: TPlotRow;
  p: TPlotRegion;
begin
  TDebug.Log('TCustomPlot ----- P A I N T');
  for c in Columns do
   for p in c.Regions do
    p.Paint;
//  Canvas.FillRect(ClientRect);
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
//  Canvas.Rectangle(ClientRect);
  for c in Columns do if c.Visible then
   begin
    Canvas.moveTo(c.Right, 0);
    Canvas.LineTo(c.Right, Height);
   end;
  for r in Rows do if r.Visible then
   begin
    Canvas.moveTo(0, r.Bottom);
    Canvas.LineTo(width, r.Bottom);
   end;
end;

procedure TCustomPlot.SetYAxis(const Value: TPlotParam);
begin
  FYAxis := Value;
end;
{$ENDREGION}



initialization
  RegisterClasses([TCustomPlotLegend, TCustomPlotData, TCustomPlotInfo]);
  RegisterClasses([TPlot, TPlotRegion, TPlotColumn, TPlotRow]);
  RegisterClasses([TPlotParam, TFileDataLink]);
end.
