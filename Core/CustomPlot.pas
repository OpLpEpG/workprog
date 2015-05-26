unit CustomPlot;

interface

uses RootImpl, RootIntf, tools, debug_except, ExtendIntf, FileCachImpl,
     System.Bindings.Helper, System.IOUtils,
     Vcl.Grids,
     SysUtils, Controls, Messages, Winapi.Windows, Classes, System.Rtti, types,
     Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.Themes, Vcl.GraphUtil;

type
  /// основной класс графиков
  TCustomPlot = class;
  EPlotException = EBaseException;

  /// прямоугольник отрисовки  графиков легенды информации
  TPlotRegion = class;
  /// коллекция хранится в колонке
  TPlotRegions = class;

  /// колонки коллекция
  TPlotColumn = class;
  TPlotColumns = class;
  /// строки коллекция
  TPlotRow = class;
  TPlotRows = class;

  /// содержимое таблиц графиков
  EParamException = class(EPlotException);
  TPlotParam = class;
  TPlotParams = class;
  /// содержимое PARAM
  EParamFilter = class(EParamException);
  TParamFilter = class;
  TParamFilters = class;


  [EnumCaptions('ID, Кадр, Глубина(м.), Время')]
  TAxisY = (axyID, axyKadr, axyDept, axyTime);

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
    function GetItem(Index: Integer): T;
    procedure SetItem(Index: Integer; const Value: T);
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
    procedure DoVisibleChanged; virtual;
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
  TCustomPlotLegend = class(TNoSizeblePlotRow)
  published
    [ShowProp('Показать легенду')] property Visible;
  end;
  TCustomPlotInfo = class(TNoSizeblePlotRow)
    [ShowProp('Показать информацию')] property Visible;
  end;

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
    procedure ColumnCollectionChanged(Collection: TPlotCollection); virtual;
    procedure ColumnCollectionItemChanged(Item: TPlotCollectionItem); virtual;
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
   [ShowProp('Params')] property Params: TPlotParams read FParams;
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

  {$REGION 'коллекции хранящиеся в колонке: параметры, регионы, мeтки глубины'}
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
    procedure ParentFontChanged; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure SetClientRect(const Value: TRect); virtual;
    procedure UpdateSize;
    procedure Paint; virtual;
  public
    // поиск нкжного класса региона по колонке и ряду
    class procedure RegClsRegister(apc: TPlotRegionClass; arc: TPlotRowClass; acc: TPlotColumnClass);
    class function RegClsFind(arc: TPlotRowClass; acc: TPlotColumnClass): TPlotRegionClass;
    function TryHitParametr(pos: TPoint; out Par: TPlotParam): Boolean; virtual;
    function MouseToClient(pos: TPoint): TPoint;
    property Row: TPlotRow read FPlotRow write FPlotRow;
    property ClientRect: TRect read FClientRect write SetClientRect;
  published
    property PropRow: string read GetRow write SetRow;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
  end;
  TPlotRegions = class(TColumnCollection<TPlotRegion>);
  {$ENDREGION}

  {$REGION 'Параметры колонки'}

  {$REGION 'DataLink'}
  IDataLink = interface
  ['{421A0AD1-48C0-4DB0-A08D-281E0121C13D}']
    function TryRead(id: Integer; out Data: TValue): Boolean;
    function Count: Integer; //ID
  end;

  TYpoint = record
   Y: Double;
   id: Integer;
  end;

  IYDataLink = interface
  ['{CB3CD728-5FEA-4F9F-A223-2D1E4B629FB0}']
//    function YtoID(Y: Double): Integer;
//    function IDtoY(id: Integer): Double;
    procedure First;
    procedure Last;
    function Previous: Boolean;
    function Next: Boolean;
    function Data: TYpoint;
  end;

  TCustomDataLink = class;

  TCustomYDataLink = class(TInterfacedPersistent)
  private
    FLink: TCustomDataLink;
    FPlot: TCustomPlot;
  protected
    procedure First; virtual; abstract;
    function Next: Boolean; virtual; abstract;
    procedure Last; virtual; abstract;
    function Previous: Boolean; virtual; abstract;
    function Data: TYpoint; virtual; abstract;
  public
    constructor Create(AOwner: TCustomDataLink); virtual;
    property Plot: TCustomPlot read FPlot;
  end;

  TLogDataLink = class(TCustomYDataLink)
  private
    Findex: Integer;
  protected
    procedure First; override;
    procedure Last; override;
    function Previous: Boolean; override;
    function Next: Boolean; override;
    function Data: TYpoint; override;
  end;

  // привязка к проекту БД, las, lines, или директории с файлами Log Ram Glu
  // или к файлу активного фильтра
  TCustomDataLinkClass = class of TCustomDataLink;
  TCustomDataLink = class(TInterfacedPersistent, IDataLink, IYDataLink)
  private
    FOwner: TPlotParam;
    FYLink: TCustomYDataLink;
    function GetYDataLink: TCustomYDataLink; virtual;
  protected
    function TryRead(id: Integer; out Data: TValue): Boolean; virtual; abstract;
    function Count: Integer; virtual; abstract;
    property YDataLink: TCustomYDataLink read GetYDataLink implements IYDataLink;
  public
    constructor Create(AOwner: TPlotParam); virtual;
    destructor Destroy; override;
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
  // [ShowProp('Y')]  property YParamPath: string read FYParamPath write SetYParamPath;
  end;
  {$ENDREGION}

  TPlotParamClass = class of TPlotParam;
  TPlotParam = class(TColumnCollectionItem, IDataLink)
  private
    FFilters: TParamFilters;
    FLink: TCustomDataLink;
    FOnContextPopup: TContextPopupEvent;
    FTitle: string;
    FVisible: Boolean;
    FColor: TColor;
    FDeltaX: Double;
    FDeltaY: Double;
    FHideInLegend: boolean;
    FFixedParam: boolean;
    FEUnit: string;
    FPresizion: Integer;
    FActiveFilter: Integer;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean);
    procedure SetTitle(const Value: string);
    function GetLinkClass: string;
    procedure SetLinkClass(const Value: string);
    procedure SetLink(const Value: TCustomDataLink);
    procedure SetVisible(const Value: Boolean);
    procedure SetColor(const Value: TColor);
    procedure SetDeltaX(const Value: Double);
    procedure SetDeltaY(const Value: Double);
    procedure SetEUnit(const Value: string);
    procedure SetHideInLegend(const Value: boolean);
    procedure NotifyCollumn;
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property Color: TColor read FColor write SetColor default clBlack;
    property EUnit: string read FEUnit write SetEUnit;
    property Presizion: Integer read FPresizion write FPresizion default 2;
    property FixedParam: boolean read FFixedParam write FFixedParam;
    property HideInLegend: boolean read FHideInLegend write SetHideInLegend;
    [ShowProp('История изменений')] property Filters: TParamFilters read FFilters;
  published
    property LinkClass: string read GetLinkClass write SetLinkClass;
    [ShowProp('Источник', True)] property Link: TCustomDataLink read FLink write SetLink implements IDataLink;
    [ShowProp('Имя')]            property Title: string read FTitle write SetTitle;
    [ShowProp('Показать')]       property Visible: Boolean read FVisible write SetVisible default True;
    [ShowProp('Смещение X')]     property DeltaX: Double read FDeltaX write SetDeltaX;
    [ShowProp('Смещение Y')]     property DeltaY: Double read FDeltaY write SetDeltaY;
//    [ShowProp('Масштаб')]        property Scale        : Double read FScale write SetScale;
    property OnContextPopup: TContextPopupEvent read FOnContextPopup write FOnContextPopup;
  end;

  TPlotParams = class(TColumnCollection<TPlotParam>)
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  end;

  TXScalableParam = class(TPlotParam)
  private
    FScaleX: Double;
    procedure SetScale(const Value: Double);
  public
    constructor Create(Collection: TCollection); override;
  published
    [ShowProp('Масштаб')] property ScaleX: Double read FScaleX write SetScale;
  end;

  [EnumCaptions('сплошная, точка, тире, точка тире, точка точка тире')]
  TLineDashStyle = (ldsSolid, ldsDot, ldsDash, ldsDashDot, ldsDashDotDot);

  TLineParam = class(TXScalableParam)
  private
    FWidth: Integer;
    FDashStyle: TLineDashStyle;
    procedure SetWidth(const Value: Integer);
    procedure SetDashStyle(const Value: TLineDashStyle);
  public
    constructor Create(Collection: TCollection); override;
  published
    [ShowProp('Ширина линии')] property Width: Integer read FWidth write SetWidth default 2;
    [ShowProp('Цвет')] property Color;
    [ShowProp('Стиль штрихов')] property DashStyle: TLineDashStyle read FDashStyle write SetDashStyle default ldsSolid;
    [ShowProp('Заморозить')]                    property FixedParam;
    [ShowProp('Скрыть легенду')]                property HideInLegend;
    [ShowProp('Единицы измерения')]             property EUnit;
    [ShowProp('Точность(цифр после запятой)')]  property Presizion;
  end;

  TGamma = TColor;

  TWaveParam = class(TXScalableParam)
  private
    FGamma: TGamma;
    procedure SetGamma(const Value: TGamma);
  published
    [ShowProp('Гамма')] property Gamma: TGamma read FGamma write SetGamma;
  end;

  TStringParam = class(TPlotParam)
  published
    [ShowProp('Цвет')] property Color;
  end;

    {$REGION 'коллекции хранящиеся в параметрe'}
  /// коллекция Параметра общее
  TParamCollectionItem = class(TColumnCollectionItem)
  private
    FParam: TPlotParam;
  public
    constructor Create(Collection: TCollection); override;
    property Param: TPlotParam read FParam;
  end;
  TParamCollection<T: TParamCollectionItem> = class(TColumnCollection<T>)
  private
    FParam: TPlotParam;
  public
    constructor Create(AOwner: TObject); override;
    property Param: TPlotParam read FParam;
  end;
       {$REGION 'коллекции параметра:  Фильтр'}
  TParamFilter = class(TParamCollectionItem, ICaption, IFileData)
  private
    FSourceFile: string;
    FActiv: Boolean;
    FIData: IFileData;
    procedure SetSourceFile(const Value: string);
    procedure SetActiv(const Value: Boolean);
    function GetIData: IFileData;
  protected
    function GetCaption: string; virtual; abstract;
    procedure SetCaption(const Value: string);
    property  FileData: IFileData read GetIData implements IFileData;
  published
    [ShowProp('Активный')] property Activ: Boolean read FActiv write SetActiv default False;
    [ShowProp('Название файла', True)] property SourceFile: string read FSourceFile write SetSourceFile;
  end;

  TParamFilters = class(TParamCollection<TParamFilter>, ICaption)
  protected
    function GetCaption: string;
    procedure SetCaption(const Value: string);
  end;

  TWaveletFilter = class(TParamFilter)
  private
    FDisplayName: string;
  protected
    function GetCaption: string; override;
  published
   [ShowProp('Настройка')] property DisplayName: string read FDisplayName write FDisplayName;
  end;
      {$ENDREGION}
    {$ENDREGION}
  {$ENDREGION}
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

  {$REGION 'классы выполняюшие ScrollBar'}
  TYScrollBarClass = class of TYScrollBar;
  TYScrollBar = class
    Plot: TCustomPlot;
    FRow: TCustomPlotData;
    Fpp2mm: Double;
    function GetRealScrollPosition: Integer;
    function GetRow: TCustomPlotData;
    constructor Create(Owner: TCustomPlot);
    procedure Update;
    procedure Scroll(var Message: TWMVScroll);
    procedure Wheel(var Message: TCMMouseWheel);
    function Range: Integer;
    function Page: Integer;
    function Line: Integer;
    procedure UpdatePosition;
    procedure SetPosition(Y: Integer);
    property Row: TCustomPlotData read GetRow;
    function GetPosition: Integer; virtual;
    procedure SetPlotPosition(Y: Integer); virtual;
    procedure SetPlotYScreen; virtual;
    property Position: Integer read GetPosition write SetPosition;
  end;
  TMirrorYScrollBar = class(TYScrollBar)
    function GetPosition: Integer; override;
    procedure SetPlotYScreen; override;
    procedure SetPlotPosition(Y: Integer); override;
  end;
  {$ENDREGION}

  ///  клласс основной
  TCustomPlot = class(TICustomControl{, IYDataLink})
  public
   const
    SCALE_PRESET: array[0..17] of Double =(0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5,
                                       1, 2, 5, 10, 20, 50);
   type
    [EnumCaptions('Указать начало, Сначала, Последние, Все')]
    TYFrom = (yfmUser, yfmFirst, yfmLast, yfmALL);
  private
    FHitTest: TPoint;
    FState: PlotState;
    FEditPlot: TCustomEditDlot;
    FColumns: TPlotColumns;
    FRows: TPlotRows;
    FHitRegion: TPlotRegion;
    FYPosition: Double;
    FYScale: Double;
    FMirror: Boolean;
    FYRange: Double;
    FYFrom: Double;
    FYFromType: TYFrom;
    FYFirstAvail: Double;
    FYLastAvail: Double;
    FOnDataAdded: TNotifyEvent;
    FYScrollBar: TYScrollBar;
    FPropertyChanged: string;
    FYTopScreen: Double;
    FYButtomScreen: Double;
 //   FYDataLink: TCustomYDataLink;

    procedure UpdateColRowRegionSizes;
    procedure UpdateRegionSizes;
    function IsMouseSizeMove(Pos: TPoint; var ps: PlotState; out Item: TColRowCollectionItem): Boolean; overload;
    function IsMouseSizeMove(Pos: TPoint; var ps: PlotState): Boolean; overload;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure CMParentFontChanged(var Message: TCMParentFontChanged); message CM_PARENTFONTCHANGED;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure SetMirror(const Value: Boolean);
    procedure SetYFrom(const Value: Double);
    procedure SetYPosition(const Value: Double);
    procedure SetYScale(const Value: Double);
    procedure SetYRange(const Value: Double);
    procedure SetYFromType(const Value: TYFrom);
    function GetYRangeAvail: Double; inline;
    function GetYLast: Double; inline;
    procedure SetYLast(const Value: Double);
    procedure ChekYPosition;
    procedure SetPropertyChanged(const Value: string);
    procedure UpdateYScreen(t, d: Double);
  protected
    /// Иызывается источником данных при поступлении данных
    procedure DataAdded; virtual;
    function GetDefaultYAxis: TAxisY; virtual;
    procedure Loaded; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DrowRegionsBounds;
    procedure Paint; override;

    function HitRow(pos: TPoint): TPlotRow;
    function HitColumn(pos: TPoint): TPlotColumn;
    function HitRegion(pos: TPoint): TPlotRegion; overload;
    function HitRegion(c: TPlotColumn; r: TPlotRow): TPlotRegion; overload;

  //  property YDataLink: TCustomYDataLink read FYDataLink implements IYDataLink;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    /// пересчет границ Y, scrollbar
    /// перерисовка обновленных колонок
    /// для события OnDataAdded
    procedure UpdateData;

    property Canvas;
    property Font;

    property YFirstAvail: Double read FYFirstAvail;
    property YLastAvail: Double read FYLastAvail;
    property YRangeAvail: Double read GetYRangeAvail;
    property YLast: Double read GetYLast write SetYLast;

    [ShowProp('TOP Y', true)] property YTopScreen: Double read FYTopScreen;
    [ShowProp('BOT Y', true)] property YButtomScreen: Double read FYButtomScreen;


    [ShowProp('Columns')] property Columns: TPlotColumns read FColumns;
    [ShowProp('Rows')]    property Rows: TPlotRows read FRows;
    /// ID , кадр, глубина
    [ShowProp('Ось Y по умолчанию'), True] property DefaultYAxis: TAxisY read GetDefaultYAxis;

    property S_PropertyChanged: string read FPropertyChanged write SetPropertyChanged;
  published
    [ShowProp('Инвертировать Y')] property YMirror: Boolean read FMirror write SetMirror;
    [ShowProp('Диапазон по Y')]   property YFromType: TYFrom read FYFromType write SetYFromType;
    [ShowProp('Начать Y с')]      property YFromData: Double read FYFrom write SetYFrom;
    [ShowProp('Диапазон Y')]      property YRangeData: Double read FYRange write SetYRange;
    [ShowProp('Позиция Y')]       property YPosition: Double read FYPosition write SetYPosition;
    [ShowProp('Масштаб по Y')]    property YScale: Double read FYScale write SetYScale;

    property OnDataAdded: TNotifyEvent read FOnDataAdded write FOnDataAdded;
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

   {$REGION 'PlotCollection'}

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
{$ENDREGION}

   {$REGION ' ColRowCollection строки колонки общее'}

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

procedure TColRowCollectionItem.DoVisibleChanged;
begin
  TCollectionColRows<TColRowCollectionItem>(Collection).UpdateSizes;
  Plot.FYScrollBar.Update;
  Plot.FYScrollBar.SetPlotYScreen;
  Plot.UpdateRegionSizes;
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
    DoVisibleChanged;
    Plot.Repaint;
   end;
end;

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
  Plot.FYScrollBar.SetPlotYScreen;
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
  {$ENDREGION}

   {$REGION 'Column, Row'}

{ TPlotRows }

function TPlotRows.FindRows(rc: TPlotRowClass): TArray<TPlotRow>;
 var
  r: TPlotRow;
begin
  for r in Self do if r is rc then CArray.Add<TPlotRow>(Result, r);
end;

function TPlotRows.GetAllLen: Integer;
begin
  Result := FPlot.ClientHeight;
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

{ TCustomPlotData }

constructor TCustomPlotData.Create(Collection: TCollection);
begin
  inherited;
  FCursor := crCross;
end;

{ TPlotColumns }

function TPlotColumns.GetAllLen: Integer;
begin
  Result := FPlot.ClientWidth;
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

procedure TPlotColumn.ColumnCollectionChanged(Collection: TPlotCollection);
begin
end;

procedure TPlotColumn.ColumnCollectionItemChanged(Item: TPlotCollectionItem);
begin
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
 {$ENDREGION}

   {$REGION 'структура колонки: Regions, Parameters'}

  /// коллекция колонки общее

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

    {$REGION 'PlotRegion'}
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

procedure TPlotRegion.ParentFontChanged;
begin
end;
procedure TPlotRegion.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
end;
procedure TPlotRegion.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
end;
function TPlotRegion.MouseToClient(pos: TPoint): TPoint;
begin
  Result := pos - clientRect.TopLeft;
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
  r := TRect.Create(Column.Left+1, Row.Top+1, Column.Right, Row.Bottom);
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
   {$ENDREGION}

{ TCustomDataLink }

constructor TCustomDataLink.Create(AOwner: TPlotParam);
begin
  FOwner := AOwner;
end;

destructor TCustomDataLink.Destroy;
begin
  if Assigned(FYLink) then FYLink.Free;
  inherited;
end;

function TCustomDataLink.GetYDataLink: TCustomYDataLink;
begin
  if Assigned(FYLink) then Result := FYLink
  else
   begin

   end;
//  Result := FOwner.Plot.YDataLink;
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

   {$REGION 'PlotParam'}

{ TPlotParam }

constructor TPlotParam.Create(Collection: TCollection);
begin
  FVisible := True;
  FPresizion := 2;
  FPlot := TPlotParams(Collection).Plot;
  FColumn := TPlotParams(Collection).Column;
  FFilters := TParamFilters.Create(Self);
  inherited Create(Collection);
end;

procedure TPlotParam.DefineProperties(Filer: TFiler);
begin
  inherited;
  FFilters.RegisterProperty(Filer, 'Filters');
end;

destructor TPlotParam.Destroy;
begin
  if Assigned(FLink) then FreeAndNil(Flink);
  FFilters.Free;
  inherited;
end;

procedure TPlotParam.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
begin
  if Assigned(FOnContextPopup) then FOnContextPopup(Self, MousePos, Handled);
end;

function TPlotParam.GetLinkClass: string;
begin
  if Assigned(FLink) then Result := FLink.ClassName
  else Result :=  '';
end;

procedure TPlotParam.NotifyCollumn;
begin
  Column.ColumnCollectionItemChanged(Self);
end;

procedure TPlotParam.SetColor(const Value: TColor);
begin
  FColor := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetDeltaX(const Value: Double);
begin
  FDeltaX := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetDeltaY(const Value: Double);
begin
  FDeltaY := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetEUnit(const Value: string);
begin
  FEUnit := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetHideInLegend(const Value: boolean);
begin
  FHideInLegend := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetLink(const Value: TCustomDataLink);
begin
  if Assigned(FLink) then FLink.Free;
  FLink := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetLinkClass(const Value: string);
begin
  if Assigned(FLink) then FreeAndNil(Flink);
  if Value <> '' then FLink := TCustomDataLinkClass(FindClass(Value)).Create(Self);
end;

procedure TPlotParam.SetTitle(const Value: string);
begin
  FTitle := Value;
  NotifyCollumn;
end;

procedure TPlotParam.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
  NotifyCollumn;
end;

{ TPlotParams }

procedure TPlotParams.Notify(Item: TCollectionItem; Action: TCollectionNotification);
begin
  inherited;
  FColumn.ColumnCollectionChanged(Self);
end;

{ TXScalableParam }

constructor TXScalableParam.Create(Collection: TCollection);
begin
  FScaleX := 1;
  inherited;
end;

procedure TXScalableParam.SetScale(const Value: Double);
begin
  if Value = 0 then Exit;   
  FScaleX := Value;
  NotifyCollumn;
end;

{ TLineParam }

constructor TLineParam.Create(Collection: TCollection);
begin
  FWidth := 2;
  inherited;
end;

procedure TLineParam.SetDashStyle(const Value: TLineDashStyle);
begin
  FDashStyle := Value;
  NotifyCollumn;
end;

procedure TLineParam.SetWidth(const Value: Integer);
begin
  if FWidth = 0 then Exit;
  FWidth := Value;
  NotifyCollumn;
end;

{ TWaveParam }

procedure TWaveParam.SetGamma(const Value: TGamma);
begin
  FGamma := Value;
  NotifyCollumn;
end;

    {$ENDREGION}
  {$ENDREGION 'структура колонки Region, Parameters'}

   {$REGION 'структура параметра: История изменений'}
/// коллекция Параметра общее

{ TParamCollectionItem }

constructor TParamCollectionItem.Create(Collection: TCollection);
begin
  FParam := TParamCollection<TParamCollectionItem>(Collection).FParam;
  inherited Create(Collection);
end;

{ TParamCollection<T> }

constructor TParamCollection<T>.Create(AOwner: TObject);
begin
  FParam := TPlotParam(AOwner);
  inherited Create(TPlotParam(AOwner).Plot);
end;
     {$REGION 'История изменений (Фильтров) параметра'}

{ TParamFilter }

function TParamFilter.GetIData: IFileData;
begin
  if not Assigned(FIData) and TFile.Exists(FSourceFile) then FIData := GFileDataFactory.Factory(TFileData, FSourceFile);
  Result := FIData;
end;

procedure TParamFilter.SetActiv(const Value: Boolean);
 var
  f: TParamFilter;
begin
  if Value = True then
   begin
    for f in Param.Filters do f.Activ := False;
    FActiv := True;

   end
  else FIData := nil;
end;

procedure TParamFilter.SetCaption(const Value: string);
begin
end;
procedure TParamFilter.SetSourceFile(const Value: string);
begin
  if FSourceFile <> '' then raise EParamFilter.CreateFmt('файл %s нельзя заменить на %s',[FSourceFile, Value]);
  if not TFile.Exists(Value) then raise EParamFilter.CreateFmt('файл %s не найден',[Value]);
  FSourceFile := Value;
end;

{ TParamFilters }

function TParamFilters.GetCaption: string;
begin
  Result := 'Фильтр'
end;
procedure TParamFilters.SetCaption(const Value: string);
begin
end;

{ TWaveletFilter }

function TWaveletFilter.GetCaption: string;
begin
  Result := 'Вейвлет'
end;
     {$ENDREGION}
   {$ENDREGION}
{$ENDREGION Collection}

{$REGION ' классы выполняюшие PlotState '}

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
    else
     begin
      FOwner.Rows.UpdateSizes();
      FOwner.FYScrollBar.SetPlotYScreen;
     end;
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
    else
     begin
      FOwner.Rows.UpdateSizes();
      FOwner.FYScrollBar.Update;
      FOwner.FYScrollBar.SetPlotYScreen;

     end;
    FOwner.UpdateRegionSizes;
    FOwner.Repaint;
   end
  else Drow;
  inherited;
end;
{$ENDREGION}

{$REGION 'классы выполняюшие ScrollBar'}
{ TYScrollBar }

constructor TYScrollBar.Create(Owner: TCustomPlot);
begin
  Plot := Owner;
  Fpp2mm := Screen.PixelsPerInch/2.54*2;
  Update
end;

function TYScrollBar.GetRealScrollPosition: Integer;
 var
  si: TScrollInfo;
begin
  si.cbSize := SizeOf(TScrollInfo);
  si.fMask := SIF_TRACKPOS;
  FlatSB_GetScrollInfo(Plot.Handle, SB_VERT, si);
  Result := si.nTrackPos;
end;

function TYScrollBar.GetRow: TCustomPlotData;
 var
  r: TPlotRow;
begin
  if Assigned(FRow) then Exit(FRow);
  for r in Plot.Rows do if r is TCustomPlotData then
   begin
    FRow := TCustomPlotData(r);
    Exit(Frow);
   end;
  Result := nil;
end;

function TYScrollBar.Line: Integer;
begin
  Result := Round(1000/3/Plot.YScale);
end;

function TYScrollBar.Page: Integer;
begin
  Result := 1;
  if Assigned(Row) then Result := Round(FRow.Height/Fpp2mm/Plot.YScale*1000);
  if Result = 0 then Result := 1;
end;

function TMirrorYScrollBar.GetPosition: Integer;
begin
  Result := Round((plot.YRangeData - (plot.YPosition - Plot.YFromData))*1000);
end;

function TYScrollBar.GetPosition: Integer;
begin
  Result := Round((plot.YPosition - Plot.YFromData) * 1000);
end;

function TYScrollBar.Range: Integer;
begin
  Result := Round(Plot.YRangeData*1000);
end;

procedure TYScrollBar.SetPosition(Y: Integer);
 var
  DeltaY: Integer;
begin
  if Y < 0 then Y := 0
  else if Y > Range then y := Range;
  DeltaY := GetPosition - Y;
  if DeltaY <> 0 then
   begin
    if FlatSB_GetScrollPos(Plot.Handle, SB_VERT) <> Y then FlatSB_SetScrollPos(Plot.Handle, SB_VERT, Y, True);
    SetPlotPosition(Y);
   end;
end;
procedure TYScrollBar.Scroll(var Message: TWMVScroll);
begin
  case Message.ScrollCode of
    SB_BOTTOM:      SetPosition(Range);
    SB_ENDSCROLL:   Update;
    SB_LINEUP:      SetPosition(GetPosition - Line);
    SB_LINEDOWN:    SetPosition(GetPosition + Line);
    SB_PAGEUP:      SetPosition(GetPosition - Page);
    SB_PAGEDOWN:    SetPosition(GetPosition + Page);
    SB_THUMBPOSITION,
    SB_THUMBTRACK:  SetPosition(GetRealScrollPosition);
    SB_TOP:         SetPosition(0);
  end;
  Message.Result := 0;
end;

procedure TMirrorYScrollBar.SetPlotPosition(Y: Integer);
begin
  Plot.FYPosition := Plot.YRangeData - Y/1000 + Plot.YFromData;
  SetPlotYScreen;
end;

procedure TYScrollBar.SetPlotPosition(Y: Integer);
begin
  Plot.FYPosition := Plot.YFromData + Y/1000;
  SetPlotYScreen;
end;

procedure TMirrorYScrollBar.SetPlotYScreen;
 var
  t, d, dl: Double;
begin
  if not Assigned(Row) then Exit;
  dl := FRow.Height/Fpp2mm/Plot.YScale;
  t := Plot.YPosition;
  d := t - dl;
  if dl > Plot.YRangeData then
   begin
    t := Plot.YLast;
    d := t - dl;
   end else if d < Plot.YFromData then
    begin
     d := Plot.YFromData;
     t := d + dl;
    end;
  if (t <> Plot.YTopScreen) or (d <> Plot.YButtomScreen) then Plot.UpdateYScreen(t, d);
end;

procedure TYScrollBar.SetPlotYScreen;
 var
  t, d, dl: Double;
begin
  if not Assigned(Row) then Exit;
  dl := FRow.Height/Fpp2mm /Plot.YScale;
  t := Plot.YPosition;
  d := t + dl;
  if dl > Plot.YRangeData then
   begin
    t := Plot.YFromData;
    d := t + dl;
   end
  else if d > Plot.YLast then
   begin
    d := Plot.YLast;
    t := d - dl;
   end;
  if (t <> Plot.YTopScreen) or (d <> Plot.YButtomScreen) then Plot.UpdateYScreen(t, d);
end;

procedure TYScrollBar.UpdatePosition;
 var
  y: Integer;
begin
  y := Position;
  if not Plot.HandleAllocated or (csLoading in Plot.ComponentState) then Exit;
  if FlatSB_GetScrollPos(Plot.Handle, SB_VERT) <> y then FlatSB_SetScrollPos(Plot.Handle, SB_VERT, y, True);
end;

procedure TYScrollBar.Update;
 var
  ScrollInfo: TScrollInfo;
  ofY: Integer;
begin
  if not Plot.HandleAllocated or (csLoading in Plot.ComponentState)  then Exit;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  ScrollInfo.nMin := 0;
  ScrollInfo.nMax := Range;
  ScrollInfo.nPage := Page;
  ofY := GetPosition;
  ScrollInfo.nPos := OfY;
  ScrollInfo.nTrackPos := OfY;
  FlatSB_SetScrollInfo(Plot.Handle, SB_VERT, ScrollInfo, True);
end;

procedure TYScrollBar.Wheel(var Message: TCMMouseWheel);
 var
  ScrollAmount: Integer;
  WheelFactor: Double;
begin
  inherited;
  with Message do
  begin
   if Page < Range then
    begin
     WheelFactor := WheelDelta / WHEEL_DELTA;
     if ssCtrl in ShiftState then ScrollAmount := Trunc(WheelFactor * Page)
     else ScrollAmount := Trunc(WheelFactor * line);
     SetPosition(GetPosition - ScrollAmount);
    end
  end;
end;
{$ENDREGION}

{$REGION 'TCustomPlot ----- Create Destroy'}

{ TCustomPlot }

constructor TCustomPlot.Create(AOwner: TComponent);
begin
  inherited;
  FYFirstAvail := 10.676;
  FYLastAvail := 10000.3445;
  FYScale := 1;
  FRows := TPlotRows.Create(Self);
  FColumns := TPlotColumns.Create(Self);
  FYScrollBar := TYScrollBar.Create(Self);
end;

destructor TCustomPlot.Destroy;
begin
  FYScrollBar.Free;
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

procedure TCustomPlot.DataAdded;
begin
  if Assigned(FOnDataAdded) then FOnDataAdded(self);
end;

procedure TCustomPlot.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  FRows.RegisterProperty(Filer, 'PlotRows');
  FColumns.RegisterProperty(Filer, 'PlotColumns');
end;
{$ENDREGION}

{$REGION 'TCustomPlot ----- SCROLL DATA'}
procedure TCustomPlot.WMVScroll(var Message: TWMVScroll);
begin
  FYScrollBar.Scroll(Message);
end;

procedure TCustomPlot.CMMouseWheel(var Message: TCMMouseWheel);
 var
  dlt: Double;
  i, idx: Integer;
begin
  if Message.Result <> 0  then Exit;
  with Message do
  begin
   Result := 1;
   if ssShift in ShiftState then
    begin
     dlt := 1000000;
     idx := -1;
     for i:= 0 to High(SCALE_PRESET) do if Abs(SCALE_PRESET[i]-YScale) < dlt then
      begin
       idx := i;
       dlt := Abs(SCALE_PRESET[i]-YScale);
      end;
     if idx = -1 then
       if WheelDelta > 0 then YScale := YScale * 2
       else YScale := YScale / 2
     else
      begin
       idx := idx + Sign(WheelDelta);
       if (idx >= 0) and (idx < Length(SCALE_PRESET)) then YScale := SCALE_PRESET[idx];
      end;
    end
   else FYScrollBar.Wheel(Message);
  end
end;

procedure TCustomPlot.CMParentFontChanged(var Message: TCMParentFontChanged);
 var
  c: TPlotColumn;
  r: TPlotRegion;
begin
  inherited;
  if not HandleAllocated then Exit;
  for c in Columns do for r in c.Regions do r.ParentFontChanged;
end;

{$ENDREGION 'TCustomPlot ----- SCROLL BAR'}

{$REGION 'TCustomPlot ----- MOVE, RESIZE HIT'}

procedure TCustomPlot.UpdateData;
begin

end;

procedure TCustomPlot.UpdateColRowRegionSizes;
begin
  if not HandleAllocated then Exit;
  Rows.UpdateSizes;
  FYScrollBar.SetPlotYScreen;
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

procedure TCustomPlot.UpdateYScreen(t, d: Double);
begin
  FYTopScreen := SimpleRoundTo(t);
  FYButtomScreen := SimpleRoundTo(d);
  S_PropertyChanged := 'Screen';
end;

function TCustomPlot.HitColumn(pos: TPoint): TPlotColumn;
 var
  r: TPlotColumn;
begin
  for r in Columns do
    if (pos.X >= r.Left) and (pos.X <= r.Right) then Exit(r);
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

procedure TCustomPlot.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
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
    FYScrollBar.Update;
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

procedure TCustomPlot.DrowRegionsBounds;
 var
  c: TPlotColumn;
  r: TPlotRow;
begin
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
  Canvas.moveTo(ClientWidth, 0);
  Canvas.LineTo(0, 0);
  Canvas.LineTo(0, ClientHeight);
  for c in Columns do if c.Visible then
   begin
    Canvas.moveTo(c.Right, 0);
    Canvas.LineTo(c.Right, ClientHeight);
   end;
  for r in Rows do if r.Visible then
   begin
    Canvas.moveTo(0, r.Bottom);
    Canvas.LineTo(ClientWidth, r.Bottom);
   end;
end;

procedure TCustomPlot.Paint;
 var
  c: TPlotColumn;
  p: TPlotRegion;
begin
  TDebug.Log('TCustomPlot ----- P A I N T');
  DrowRegionsBounds;
  for c in Columns do
   for p in c.Regions do
    p.Paint;
end;
{$ENDREGION}

{$REGION 'TCustomPlot ----- Y'}
procedure TCustomPlot.SetMirror(const Value: Boolean);
 const
  CSB: array [Boolean] of TYScrollBarClass =(TYScrollBar, TMirrorYScrollBar);
begin
  if FMirror <> Value then
   begin
    FMirror := Value;
    FYScrollBar.Free;
    FYScrollBar := CSB[FMirror].Create(Self);
    FYScrollBar.Position := FYScrollBar.Position - FYScrollBar.Page;
    FYScrollBar.SetPlotYScreen;
    S_PropertyChanged := 'YMirror';
   end;
end;

procedure TCustomPlot.SetPropertyChanged(const Value: string);
begin
  FPropertyChanged := Value;
  TBindings.Notify(Self, 'S_PropertyChanged');
end;

procedure TCustomPlot.ChekYPosition;
begin
  if FYPosition < FYFrom then FYPosition := FYFrom
  else if FYPosition > YLast then FYPosition := YLast;
end;

procedure TCustomPlot.SetYFrom(const Value: Double);
begin
  if FYFromType <> yfmUser then Exit;
  if (FYFrom <> Value) or (FYFrom < FYFirstAvail) or (FYFrom > FYLastAvail) then
   begin
    FYFrom := Value;
    if FYFrom < FYFirstAvail then FYFrom := FYFirstAvail
    else if FYFrom > FYLastAvail then FYFrom := FYLastAvail;
    if YLast > YLastAvail then YLast := YLastAvail;
    ChekYPosition;
    FYScrollBar.Update;
    FYScrollBar.SetPlotYScreen;
    S_PropertyChanged := 'YFrom';
   end;
end;

procedure TCustomPlot.SetYFromType(const Value: TYFrom);
begin
 if FYFromType <> Value then
  begin
   FYFromType := Value;
   case Value of
     yfmUser:
      begin
       if FYFrom < FYFirstAvail then FYFrom := FYFirstAvail;
       if YLast > YLastAvail then YLast := YLastAvail;
      end;
     yfmFirst:
      begin
       FYFrom := FYFirstAvail;
       if FYRange > YRangeAvail then FYRange := YRangeAvail;
      end;
     yfmLast:
      begin
       if FYRange > YRangeAvail then FYRange := YRangeAvail;
       FYFrom := FYLastAvail - FYRange;
      end;
     yfmALL:
      begin
       FYFrom := FYFirstAvail;
       FYRange := YRangeAvail;
      end;
   end;
   ChekYPosition;
   FYScrollBar.Update;
   FYScrollBar.SetPlotYScreen;
   S_PropertyChanged := 'YFromType';
  end;
end;

procedure TCustomPlot.SetYLast(const Value: Double);
begin
  if (YLast <> Value) or (YLast > YLastAvail) then
   begin
    FYRange := Value - FYFrom;
    if YLast > YLastAvail then FYRange := YLastAvail - FYFrom;
    if FYRange < 0 then FYRange := 0;
    FYScrollBar.Update;
    FYScrollBar.SetPlotYScreen;
    S_PropertyChanged := 'YLast';
   end;
end;

procedure TCustomPlot.SetYPosition(const Value: Double);
begin
  if (FYPosition <> Value) or (FYPosition < FYFrom) or (FYPosition > YLast) then
   begin
    FYPosition := Value;
    ChekYPosition;
    FYScrollBar.UpdatePosition;
    FYScrollBar.SetPlotYScreen;
    S_PropertyChanged := 'YPosition';
   end;
end;

procedure TCustomPlot.SetYScale(const Value: Double);
begin
  if (FYScale <> Value) and (FYScale > 0) then
   begin
    FYScale := Value;
    ChekYPosition;
    FYScrollBar.Update;
    FYScrollBar.SetPlotYScreen;
    S_PropertyChanged := 'YScale';
   end;
end;

procedure TCustomPlot.SetYRange(const Value: Double);
begin
  if Value <= 0 then Exit;
  case FYFromType of
    yfmUser, yfmFirst: if (FYRange <> Value) or (YLast > YLastAvail) then
     begin
      FYRange := Value;
      if YLast > YLastAvail then YLast := YLastAvail;
      ChekYPosition;
      FYScrollBar.Update;
      FYScrollBar.SetPlotYScreen;
      S_PropertyChanged := 'YRange';
     end;
    yfmLast: if (FYRange <> Value) or (YLast > YLastAvail) then
     begin
      FYRange := Value;
      FYFrom := YLastAvail - FYRange;
      if FYFrom < FYFirstAvail then
       begin
        FYFrom := FYFirstAvail;
        FYRange := YRangeAvail;
       end;
       ChekYPosition;
       FYScrollBar.Update;
       FYScrollBar.SetPlotYScreen;
       S_PropertyChanged := 'YRange';
     end;
    yfmALL: if (FYRange <> YRangeAvail) or (FYFrom <> FYFirstAvail) then
     begin
      FYFrom := FYFirstAvail;
      FYRange := YRangeAvail;
      ChekYPosition;
      FYScrollBar.Update;
      FYScrollBar.SetPlotYScreen;
      S_PropertyChanged := 'YRange';
     end;
  end;

end;

function TCustomPlot.GetYLast: Double;
begin
  Result := FYFrom + FYRange;
end;

function TCustomPlot.GetYRangeAvail: Double;
begin
  Result := YLastAvail - YFirstAvail;
end;

function TCustomPlot.GetDefaultYAxis: TAxisY;
begin
  Result := axyID;
end;

{$ENDREGION}

{ TLogDataLink }

function TLogDataLink.Data: TYpoint;
begin
  Result.id := Findex;
  Result.Y := Findex+1;
end;

procedure TLogDataLink.First;
begin
  Findex := 0;
end;

procedure TLogDataLink.Last;
begin
  Findex := FLink.Count-1;
end;

function TLogDataLink.Next: Boolean;
begin
  Inc(Findex);
  Result := Findex > Plot.YLast;
end;

function TLogDataLink.Previous: Boolean;
begin
  Dec(Findex);
  Result := Findex >= 0;
end;

{ TCustomYDataLink }

constructor TCustomYDataLink.Create(AOwner: TCustomDataLink);
begin
  FLink := AOwner;
  FPlot := FLink.FOwner.Plot;
end;

initialization
  RegisterClasses([TCustomPlotLegend, TCustomPlotData, TCustomPlotInfo]);
  RegisterClasses([TPlot, TPlotRegion, TPlotColumn, TPlotRow]);
  RegisterClasses([TPlotParam, TLineParam, TWaveParam, TFileDataLink, TWaveletFilter]);
end.
