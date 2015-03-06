unit CustomPlot;

interface

uses RootImpl, tools,
     Vcl.Grids,
     SysUtils, Controls, Messages, Winapi.Windows, Classes, System.Rtti, types,
     Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.Themes, Vcl.GraphUtil;

type
  // основной класс графиков
  TCustomPlot = class;

  // всякие коллекции сохраняемые
  TPlotCollectionItem = class(TICollectionItem)
  private
    FPlot: TCustomPlot;
  public
    constructor Create(Collection: TCollection); override;
    property Plot: TCustomPlot read FPlot;
  end;

  TPlotCollection = class(TICollection)
  private
    FPlot: TCustomPlot;
  protected
  public
    function Add(const ItemClassName: string): TPlotCollectionItem; reintroduce; overload;
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
    constructor Create(AOwner: TObject);
    property Items[Index: Integer]: T read GetItem write SetItem; default;
  end;

  /// прямоугольник отрисовки
  TPlotRegion = class;

//  PlotRegionType = (praService, praData);
  /// строки колонки общее
  TRegionCollectionItem = class(TPlotCollectionItem)
  private
    FRegionsCount: Integer;
    FAutoSize: Boolean;
    function GetItem(Index: Integer): TPlotRegion;
  protected
    FFrom: Integer;
    FLen: Integer;
    function GetTo: Integer; inline;
    procedure SetLen(const Value: Integer); inline;
  public
    constructor Create(Collection: TCollection); override;
    property AutoSize: Boolean read FAutoSize;
    property Regions[Index: Integer]: TPlotRegion read GetItem; default;
    property RegionsCount: Integer read FRegionsCount;
  end;

  TPlotRegions<T: TRegionCollectionItem> = class(TPlotCollection<T>)
  protected
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
    function LastToResize(FromLast: integer): TRegionCollectionItem;
    function GetAllLen: Integer; virtual; abstract;
  public
    procedure UpdateSizes;
  end;

  /// колонки коллекция
  TPlotColumn = class;
  TPlotColumns = class;
  /// строки коллекция
  TPlotRow = class;
  TPlotRows = class;


  TPlotRow = class(TRegionCollectionItem)
  private
//    FPlotRowType: PlotRowType;
    FVisible: Boolean;
    FCursor: Integer;
  public
    property Top: Integer read FFrom;
    property Down: Integer read GetTo;
//    property PlotRowType: PlotRowType read FPlotRowType;
    property Cursor: Integer read FCursor;
  published
    property Height: Integer read FLen write SetLen;
    property Visible: Boolean read FVisible write FVisible;
  end;

  // типы строки;
  TCustomPlotLegend = class(TPlotRow);
  TCustomPlotData = class(TPlotRow)
  public
    constructor Create(Collection: TCollection); override;
  end;
  TCustomPlotInfo = class(TPlotRow);


  TPlotRows = class(TPlotRegions<TPlotRow>)
  protected
    function GetAllLen: Integer; override;
  end;

  TPlotRegion = class
    PlotRow: TPlotRow;
    PlotColumn: TPlotColumn;
  end;

  TPlotColumn = class(TRegionCollectionItem)
  private
    FResizeble: Boolean;
  protected
  public
    property Left: Integer read FFrom;
    property Right: Integer read GetTo;
    property Resizeble: Boolean read FResizeble;
  published
    property Width: Integer read FLen write SetLen;
  end;
  TPlotColumnClass = class of TPlotColumn;

  TPlotColumns = class(TPlotRegions<TPlotColumn>)
  protected
    function GetAllLen: Integer; override;
  end;
  TPlotColumnsClass = class of TPlotColumns;





  PlotState = (pcsNormal, pcsColSizing, pcsColMoving, pcsRowSizing, pcsRowMoving);

  TCustomPlot = class(TICustomControl)
  private
   type
    TUpdate = (uColunsWidth, uLegendHeight, uScrollRect, uBitmapLegend, uBitmapData, uScrollBar,
               uPrepareLegend, uPaintLegend, uPaintData,
               uAsyncPrepareData, uAsyncPaintData, uSyncPrepareData, uSyncPaintData);
    TUpdates = set of TUpdate;
//    TCheckMouse = (cmColSize, cmColMove, cmColData, cmColLegend);
//    TCheckMouses = set of TCheckMouse;
    TCheckMouseFunc = reference to function (cm: PlotState; Col: TPlotColumn; X, Y: integer): boolean;
    TMovSiz = class
      FItem, FSwap: TRegionCollectionItem;
      Fpos: TPoint;
      FState: PlotState;
      procedure Drow;
      procedure Move(Pos: TPoint);
      constructor Create(Pos: TPoint; ps: PlotState; item: TRegionCollectionItem);
    end;

   var
    FColumns: TPlotColumns;
    FRows: TPlotRows;

    FSelectedColumn: TPlotColumn;
    FSelectedPow: TPlotRow;
    FSelectedRegion: TPlotRegion;

    FHitTest: TPoint;

    FState: PlotState;


    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure DrawSizingLine();
    procedure DrawMovingLine();
//    procedure DrawCrossLine(X, Y: Integer);
  protected
    function IsMouseSizeMove(Pos: TPoint; var ps: PlotState; out Item: TRegionCollectionItem): Boolean; overload;
    function IsMouseSizeMove(Pos: TPoint; var ps: PlotState): Boolean; overload;
    procedure DefineProperties(Filer: TFiler); override;
//    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
//    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
//    DataBitmap: TBitmap;
//    ScaleFactor: Double;
//    Mirror: Integer; { TODO : protected property DB plot check SQL for DESC to set mirror -1 }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
{    function MouseYtoParamY(Y: Integer): Double;
    function ParamYToY(Y: Double): Double;
    procedure UpdateMinMaxY(ForceScale: boolean = False); virtual;
    procedure Update0Position;
    procedure UpdateAllAndRepaint;
    procedure UpdateDataAndRepaint;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure AsyncRun(Async, AfrerSync: TRenderProc);
    procedure GoToBookmark();
    function IsLegend(Y: Integer): Boolean; inline;
    procedure SetBookmark(Y: Integer); inline;
    property OnScaleChanged: TNotifyEvent read FOnScaleChanged write FOnScaleChanged;}
    function GetRow(pos: TPoint): TPlotRow;
    property Columns: TPlotColumns read FColumns;
    property Rows: TPlotRows read FRows;
//    property SelectedColumn: TPlotColumn read FSelectedColumn write FSelectedColumn;
{    property TitleY: string read FTitle write FTitle;
    property EUnitY: string read FEUnit write FEUnit;
    property PresizionY: Integer read FPresizionY write FPresizionY default 2;
    property DpmmX: Double read Xdpmm;
    property DpmmY: Double read Ydpmm;
    property OnParamXAxisChanged: TParamXAxisChangedEvent read FOnParamXAxisChanged write FOnParamXAxisChanged;
    property Popupmenu;}
  published
//    property ScaleY: Double read FScaleY write SetScaleY;
//    property PresetScaleY: integer read FPresetScaleY write SetPresetScaleY default SCALE_ONE;
//    property YOffset: Integer read OffsetY write SetYOffset; // должно быть после ScaleY PresetScaleY
//    property CursorY: Double read FCursorY write SetCursorY;
  end;

  TPlot3 = class(TCustomPlot)
  published
    property Align;
    property ParentFont;
    property Font;
//    property OnScaleChanged;
    property ParentColor;
    property Color;
    property OnContextPopup;
//    property OnParamXAxisChanged;
  end;

var
 testcnt: Integer;


//function SetPresetScale(s: double): Double;
//procedure TstDebug(const msg: string);


implementation

uses System.Math, debug_except, Winapi.CommCtrl;


{ TPlotCollectionItem }

constructor TPlotCollectionItem.Create(Collection: TCollection);
begin
  FPlot := TPlotCollection(Collection).Plot;
  inherited Create(Collection);
end;

{ TPlotCollection }

function TPlotCollection.Add(const ItemClassName: string): TPlotCollectionItem;
begin
  Result := TPlotCollectionItem(TICollectionItemClass(FindClass(ItemClassName)).Create(Self));
end;

function TPlotCollection<T>.Add<C>: C;
begin
  Result := TRttiContext.Create.GetType(TClass(C)).GetMethod('Create').Invoke(TClass(C), [Self]).AsType<C>; //через жопу работает
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

constructor TRegionCollectionItem.Create(Collection: TCollection);
begin
  FLen := 20;
  FAutoSize := True;
  inherited;
end;

function TRegionCollectionItem.GetItem(Index: Integer): TPlotRegion;
begin

end;

function TRegionCollectionItem.GetTo: Integer;
begin
  Result := FFrom + FLen;
end;

procedure TRegionCollectionItem.SetLen(const Value: Integer);
begin
  if Value > 20 then
    FLen := Value
  else
    FLen := 20;
end;

{ TCustomPlotData }

constructor TCustomPlotData.Create(Collection: TCollection);
begin
  inherited;
  FCursor := crCross;
//  FPlotRowType := praData;
end;

{ TPlotRegions<T> }

function TPlotRegions<T>.LastToResize(FromLast: integer): TRegionCollectionItem;
 var
  i: Integer;
//  r: TRegionCollectionItem;
begin
  Result := Items[FromLast];
  for i := FromLast downto 0 do if Items[i].AutoSize then Exit(Items[i]);
//  for r in self do TDebug.Log('resize  from %d   len %d   ',[r.FFrom, r.FLen]);
//  TDebug.Log('Result  from %d   len %d   ',[Result.FFrom, Result.FLen]);
end;

procedure TPlotRegions<T>.Notify(Item: TCollectionItem; Action: TCollectionNotification);
 var
  r: TRegionCollectionItem;
  len: Integer;
begin
  inherited;
  if csDestroying in FPlot.ComponentState then Exit;
  if (Action = cnAdded) then
   if (Count >= 2) then
    begin
     r := LastToResize(Count - 2);
     r.SetLen(r.FLen div 2);
     TRegionCollectionItem(Item).FLen := r.FLen;
//     TDebug.Log(' r from %d   r len %d   ',[r.FFrom, r.FLen]);
    end
   else TRegionCollectionItem(Item).FLen := GetAllLen;
//  for r in self do TDebug.Log('  from %d   len %d   ',[r.FFrom, r.FLen]);

  UpdateSizes;
  FPlot.Repaint;
end;

procedure TPlotRegions<T>.UpdateSizes;
 var
  lf, i, j, wf: Integer;
  r, rs: TRegionCollectionItem;
begin
  if Count = 0 then Exit;
  rs := LastToResize(Count - 1);
  lf := 0;
  for i := 0 to Count-1 do
   begin
    r := Items[i];
    r.FFrom := lf;
    if rs  = r then
     begin
      wf := 0;
      for j := i + 1 to Count - 1 do wf := wf + Items[j].Flen;
      r.SetLen(GetAllLen - lf- wf);
     end;
    Inc(lf, r.FLen);
   end;
  for r in self do TDebug.Log('update  from %d   len %d   ',[r.FFrom, r.FLen]);
end;



{ TCustomPlot }

constructor TCustomPlot.Create(AOwner: TComponent);
begin
  inherited;
  FColumns := TPlotColumns.Create(Self);
  FRows := TPlotRows.Create(Self);
end;

destructor TCustomPlot.Destroy;
begin
  FColumns.Free;
  FRows.Free;
  inherited;
end;


{$REGION 'Сериализация коллекции с у которой элементы разные классы'}
procedure TCustomPlot.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  FColumns.RegisterProperty(Filer, 'PlotColumns');
  FRows.RegisterProperty(Filer, 'PlotRows');
end;
{$ENDREGION}

{$REGION 'Сериализация коллекции с у которой элементы разные классы'}
{procedure TCustomPlot.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
 var
  c: TPlotColumn;
begin
  inherited;
  if Handled then Exit;
  for c in Columns do if (c.Left < MousePos.X) and (c.Right > MousePos.X) then
   begin
    c.DoContextPopup(MousePos, Handled);
    Break;
   end;
end;

function TCustomPlot.UpdateALL(const tsk: TUpdates): TUpdates;
begin
  Result := [];
  if (csLoading in ComponentState) then Exit;
  if uColunsWidth in tsk then UpdateColumns;
  if uLegendHeight in tsk then Result := Result + UpdateLegendHeight;
  if uScrollRect in tsk then UpdateScrollRect;
  if uBitmapLegend in tsk then Result := Result + UpdateSizeBitmapLegend;
  if uBitmapData in tsk then Result := Result + UpdateSizeBitmapData;
  if uScrollBar in tsk then UpdateVerticalScrollBar;
  if uPrepareLegend in tsk then DoPrepareLegend;
  if ShowLegend and (uPaintLegend in tsk) then DoPaintLegend;
  if uPaintData in tsk then DoPaintData;
  if uAsyncPrepareData in tsk then
    if uAsyncPaintData in tsk then AsyncRun(DoPrepareData, DoPaintData)
    else AsyncRun(DoPrepareData, nil);
  if uSyncPrepareData in tsk then
    if uSyncPaintData in tsk then
     begin
      DoPrepareData;
      DoPaintData;
     end
    else DoPrepareData;
end;

procedure TCustomPlot.UpdateAllAndRepaint;
begin
  UpdateALL([uColunsWidth, uScrollRect, uLegendHeight, uBitmapLegend, uBitmapData, uScrollBar, uPrepareLegend,
             uPaintLegend, uAsyncPrepareData, uAsyncPaintData]);
end;

function TCustomPlot.UpdateSizeBitmapData: TUpdates;
begin
  DataBitmap.Canvas.Lock;
  try
   if (DataBitmap.Width < ClientWidth) or (DataBitmap.Height < ScrollRect.Height) then
    begin
     DataBitmap.SetSize(ClientWidth, ScrollRect.Height);
     Result := [uBitmapData]
    end
   else Result := []
  finally
   DataBitmap.Canvas.Unlock;
  end;
end;

function TCustomPlot.UpdateSizeBitmapLegend: TUpdates;
begin
  if (LegendBitmap.Width < ClientWidth) or (LegendBitmap.Height < LegendHeight) then
   begin
    LegendBitmap.SetSize(ClientWidth, LegendHeight);
    Result := [uBitmapLegend]
   end
  else Result := []
end;

procedure TCustomPlot.UpdateColumns;
 var
  lf, i: Integer;
begin
  if Columns.Count = 0 then Exit;
  lf := 0;
  for i := 0 to Columns.Count-2 do
   begin
    Columns.Items[i].FLeft := lf;
    Inc(lf, Columns.Items[i].Width);
   end;
  Columns.Items[Columns.Count-1].FLeft := lf;
  Columns.Items[Columns.Count-1].Width := ClientWidth - lf;   // последняя колонка переменной ширины
end;

procedure TCustomPlot.UpdateDataAndRepaint;
begin
  AsyncRun(DoPrepareData, DoPaintData);
end;

function TCustomPlot.UpdateLegendHeight: TUpdates;
 var
  G: TGPGraphics;
  c: TPlotColumn;
  lh: Integer;
begin
  if not HandleAllocated then Exit;
  GDIPlus.Lock;
  G := TGPGraphics.Create(LegendBitmap.Canvas.Handle);
  try
   lh := 64;
   for c in Columns do c.CalcLegendHeight(G, lh);
  finally
   G.Free;
   GDIPlus.UnLock;
  end;
  if LegendHeight <> lh then Result := [uLegendHeight] else Result := [];
  LegendHeight := lh;
end;

procedure TCustomPlot.UpdateScrollRect;
  var
  last_mirror: Boolean;
begin
  if not HandleAllocated then Exit;
  last_mirror := (OffsetY = (ScrollRect.Height - Range)) and (Mirror = -1);
  ScrollRect := ClientRect;
  if FShowLegend then
   begin
    if LegendHeight > ScrollRect.Height then ScrollRect.Height := 1
    else ScrollRect.Height := ScrollRect.Height - LegendHeight;
    if last_mirror then
     begin
      if not (csLoading in ComponentState) and (Range > 1)  then OffsetY := ScrollRect.Height - Range;
      Exit;
     end;
   end;
  if not (csLoading in ComponentState) and (Range > 1) and (OffsetY < (ScrollRect.Height - Range)) then
   begin
    OffsetY := ScrollRect.Height - Range;
    if OffsetY > 0 then OffsetY := 0;
   end;
end;

procedure TCustomPlot.UpdateVerticalScrollBar();
 var
  ScrollInfo: TScrollInfo;
  ofY: Integer;
begin
  if  not HandleAllocated or (csLoading in ComponentState)  then Exit;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  ScrollInfo.nMin := 0;
  if Range > ScrollRect.Height then ScrollInfo.nMax := Range else  ScrollInfo.nMax := 0;
  ScrollInfo.nPage := Max(1, ScrollRect.Height);
  if Mirror = 1 then ofY :=  -OffsetY
  else ofY := Range + OffsetY - ScrollRect.Height;
  ScrollInfo.nPos := OfY;
  ScrollInfo.nTrackPos := OfY;
  FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
end;    }


{ TODO : написать  ADDData RecalcScale только для последних данных}
//procedure TCustomPlot.UpdateMinMaxY(ForceScale: boolean);
// var
//  c: TPlotColumn;
//  mx, mi: Double;
//  OldFirstY, OldLastY: Integer;
//begin
//  mi := 1000000;
//  mx := -1;
//  OldFirstY := FirstY;
//  OldLastY := LastY;
//  { TODO : перерисать оптимально т.к . RecalcScale длительная операция }
//  for c in Columns do
//   begin
//    c.UpdateMinMaxY(mi, mx);
//    if mi < mx then
//     begin
//      FirstY := Trunc(mi);
//      FirstY := FirstY div 10 * 10;
//      LastY :=  Trunc(mx)+1;
//     end;
//   end;
//  if (OldFirstY = FirstY) and (OldLastY = LastY) and not ForceScale then Exit;
//  for c in Columns do if c is TGraphColumn then TGraphColumn(c).RecalcScale;
//end;

{procedure TCustomPlot.Update0Position;
begin
  if HandleAllocated then
   begin
    if Mirror = -1 then SetOffsetY(-10000000, True)
    else SetOffsetY(0, True);
    Exclude(FStates, psScrolling);
    UpdateVerticalScrollBar;
   end;
end;

function TCustomPlot.LegendRect: TRect;
begin
  Result := ClientRect;
  Result.Height := LegendHeight;
end;

function TCustomPlot.CreateGPFont: TGPFont;
 var
  f: TFontStyles;
begin
   f := Font.Style;
  Result := TGPFont.Create(Font.Name, Font.Size, PInteger(@F)^);
end;

function TCustomPlot.IsLegend(Y: Integer): Boolean;
begin
  Result := ShowLegend and (Y < LegendHeight);
end;

procedure TCustomPlot.KeyPress(var Key: Char);
begin
  if CharInSet(AnsiString(Key)[1], ['L','l','Д','д']) then ShowLegend := not ShowLegend
  else if CharInSet(AnsiString(Key)[1],['C','c','С','с']) then GoToBookmark;
  inherited;
end;     }

{$ENDREGION}

{$REGION 'SCROLL DATA'}
{function TCustomPlot.Range: Integer;
begin
  Result := Trunc(RangeY * ScaleY*Ydpmm)+1;
end;

function TCustomPlot.RangeY: Integer;
begin
  Result := LastY - FirstY;
end;

procedure TCustomPlot.SetScaleY(const Value: Double);
 var
  p: TCollectionItem;
begin
  if FScaleY <> Value then
   begin
    if Mirror = 1 then OffsetY := Round(OffsetY *Value/FScaleY)
    else OffsetY := Round((OffsetY- ScrollRect.Height)*Value/FScaleY+ ScrollRect.Height);
    FScaleY := Value;
    for p in FColumns do if p is TGraphColumn then TGraphColumn(p).RecalcScale();
    if HandleAllocated then
     begin
      UpdateVerticalScrollBar;
      SetOffsetY(OffsetY, True);
      Exclude(FStates, psScrolling);
      if Assigned(FOnScaleChanged) then FOnScaleChanged(Self);
     end;
   end;
end;

procedure TCustomPlot.SetShowLegend(const Value: Boolean);
begin
  if (FShowLegend <> Value) then
   begin
    FShowLegend := Value;
    if not (csLoading in ComponentState) then
      UpdateALL([uScrollRect, uBitmapLegend, uBitmapData, uScrollBar, uPrepareLegend, uPaintLegend, uAsyncPrepareData, uAsyncPaintData]);
   end;
end;

procedure TCustomPlot.SetYOffset(const Value: Integer);
begin
  OffsetY := Value;
end;

procedure TCustomPlot.SetBookmark(Y: Integer);
begin
  CursorY := MouseYtoParamY(Y);
end;

procedure TCustomPlot.SetCursorY(const Value: Double);
begin
  FCursorY := Value;
end;

function TCustomPlot.SetOffsetY(Y: Integer; NeedRepaint: Boolean = False): Boolean;
 var
  DeltaY, ofY: Integer;
begin
  if Y < (ScrollRect.Height - Range) then Y := ScrollRect.Height - Range;
  if Y > 0 then Y := 0;
  DeltaY := Y - OffsetY;
  Result := (DeltaY <> 0);
  if Result or NeedRepaint then
   begin
    OffsetY := Y;
    Include(FStates, psScrolling);
    //Рисуем скроллбар
    if Mirror = 1 then ofY :=  -OffsetY
    else ofY := Range + OffsetY - ScrollRect.Height;
    if FlatSB_GetScrollPos(Handle, SB_VERT) <> -OffsetY then FlatSB_SetScrollPos(Handle, SB_VERT, OfY, True);

    if ScrollRect.Height > 0 then AsyncRun(DoPrepareData, DoPaintData);
   end;
end;

procedure TCustomPlot.SetPresetScaleY(const Value: integer);
begin
  if FPresetScaleY <> Value then
   begin
    if Value < 0 then FPresetScaleY := 0
    else if Value > High(SCALE_PRESET) then FPresetScaleY := High(SCALE_PRESET)
    else FPresetScaleY := Value;
    if HandleAllocated then ScaleY := SCALE_PRESET[FPresetScaleY]* ScaleFactor;
   end;
end;

procedure TCustomPlot.WMSize(var Message: TWMSize);
begin
  inherited;
  if HandleAllocated and (([psSizing, psUpdating] * FStates) = []) and (ClientHeight > 0) and not (csLoading in ComponentState) then
   try
    Include(FStates, psSizing);
    TDebug.Log(' *** TCustomPlot.WMSize  ****    ');                                                                             //??????
    UpdateALL([uColunsWidth, uLegendHeight, uScrollRect, uBitmapLegend, uBitmapData, uScrollBar, uPrepareLegend, uPaintLegend, uSyncPrepareData]);
   finally
    Exclude(FStates, psSizing);
   end;
end;

procedure TCustomPlot.CMHintShow(var Message: TCMHintShow);
begin
  with Message.HintInfo^ do  HintPos := FHintData.DataPoint;
end;                                                          }

//procedure TCustomPlot.CMMouseWheel(var Message: TCMMouseWheel);
// var
//  ScrollAmount: Integer;
//  ScrollLines: DWORD;
//  WheelFactor: Double;
//begin
//  inherited;
//  if Message.Result = 0  then
//  begin
//    with Message do
//    begin
//     Result := 1;
//     if ([psPainting, {psScrolling,} psUpdating] * FStates) <> [] then Exit;
//     if ssShift in ShiftState then
//      begin
//       if WheelDelta > 0 then PresetScaleY := PresetScaleY+1 else PresetScaleY := PresetScaleY-1
//      end
//     else if Range > ScrollRect.Height then
//      begin
//       WheelFactor := WheelDelta / WHEEL_DELTA;
//       if ssCtrl in ShiftState then ScrollAmount := Trunc(WheelFactor * ScrollRect.Height)
//       else
//        begin
//         SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @ScrollLines, 0);
//         if ScrollLines = WHEEL_PAGESCROLL then ScrollAmount := Trunc(WheelFactor * ScrollRect.Height)
//         else ScrollAmount := Trunc(WheelFactor * ScrollLines * Ydpmm);
//        end;
//       SetOffsetY(OffsetY + Mirror*ScrollAmount);
//       Exclude(FStates, psScrolling);
//      end
//    end;
//  end;
//end;

//procedure TCustomPlot.WMVScroll(var Message: TWMVScroll);
//  function GetRealScrollPosition: Integer;
//   var
//    SI: TScrollInfo;
//    Code: Integer;
//  begin
//    SI.cbSize := SizeOf(TScrollInfo);
//    SI.fMask := SIF_TRACKPOS;
//    Code := SB_VERT;
//    FlatSB_GetScrollInfo(Handle, Code, SI);
//    if Mirror = 1 then Result := SI.nTrackPos
//    else Result := Range - SI.nTrackPos - ScrollRect.Height
//  end;
//begin
//  case Message.ScrollCode of
//    SB_BOTTOM:      SetOffsetY(-Range);
//    SB_ENDSCROLL:
//     begin
//      UpdateVerticalScrollBar();
//      Exclude(FStates, psScrolling);
//     end;
//    SB_LINEUP:      SetOffsetY(OffsetY + Mirror*FIncrementY);
//    SB_LINEDOWN:    SetOffsetY(OffsetY - Mirror*FIncrementY);
//    SB_PAGEUP:      SetOffsetY(OffsetY + Mirror*ScrollRect.Height);
//    SB_PAGEDOWN:    SetOffsetY(OffsetY - Mirror*ScrollRect.Height);
//    SB_THUMBPOSITION,
//    SB_THUMBTRACK:  SetOffsetY(-GetRealScrollPosition);
//    SB_TOP:         SetOffsetY(0);
//  end;
//  Message.Result := 0;
//end;       }
{$ENDREGION 'SCROLL BAR'}

{$REGION 'MOVE, RESIZE COLUMN HIT'}

//procedure TCustomPlot.DrawCrossLine(X, Y: Integer);
// procedure DrowCr;
// begin
//   if ShowLegend then Canvas.MoveTo(FChangeLeft, LegendHeight)
//   else Canvas.MoveTo(FChangeLeft, 0);
//   Canvas.LineTo(FChangeLeft, ClientHeight);
//   Canvas.MoveTo(0, FChangePos);
//   Canvas.LineTo(Clientwidth, FChangePos);
// end;
//begin
//  Canvas.Pen.Color := clBlack;
//  Canvas.Pen.Style := psDot;
//  Canvas.Pen.Mode := pmXor;
//  Canvas.Pen.Width := 1;
//  if FHorizontShowed then DrowCr;
//  FChangeLeft := X;
//  FChangePos := Y;
//  DrowCr;
//  FHorizontShowed := True;
//end;

procedure TCustomPlot.DrawMovingLine;
begin
  Canvas.Pen.Color := clWhite;
  Canvas.Pen.Style := psDot;
  Canvas.Pen.Mode := pmXor;
  Canvas.Pen.Width := 5;
//  Canvas.MoveTo(FChangeLeft, 0);
//  Canvas.LineTo(FChangeLeft, ClientHeight);
end;

procedure TCustomPlot.DrawSizingLine;
begin
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Style := psDot;
  Canvas.Pen.Mode := pmXor;
  Canvas.Pen.Width := 1;
//  Canvas.MoveTo(FChangePos, 0);
//  Canvas.LineTo(FChangePos, ClientHeight);
end;

function TCustomPlot.GetRow(pos: TPoint): TPlotRow;
 var
  r: TPlotRow;
begin
 // Result := Rows[Rows.Count-1];
  for r in Rows do if (pos.Y >= r.Top) and (pos.Y <= r.Down) then Exit(r);
  raise EBaseException.Create('Нет рада в данном месте');
end;

procedure TCustomPlot.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  DefaultHandler(Msg);
  FHitTest := ScreenToClient(SmallPointToPoint(Msg.Pos));
end;

{function TCustomPlot.CheckMousePosition(cms: PlotState; X, Y: Integer; func: TCheckMouseFunc): Boolean;
 var
  c: TPlotColumn;
  Yd: integer;
begin
  Result := False;
  if cmColSize in cms then for c in Columns do
    if (Abs(c.Right - X) < 7) then Exit(func(cmColSize, c, X, Y));

  if (cmColMove in cms) and (Y < 32) then for c in Columns do
    if (X > c.Left + CHECKBOX_SIZE + CHECKBOX_SIZE div 2) and (X < c.Right) then Exit(func(cmColMove, c, X, Y));

  if ShowLegend and (cmColLegend in cms) and (Y < LegendHeight) then
    for c in Columns do
     if (X > c.Left) and (X < c.Right) then Exit(func(cmColLegend, c, X, Y));

  if FShowLegend then Yd := Y - LegendHeight
  else Yd := Y;
  if (cmColData in cms) and (ClientHeight-Yd > 10) and (Yd > 10) then
    for c in Columns do
     if (X > c.Left+5) and (X < c.Right-5) then Exit(func(cmColData, c, X, Y));
end; }

function TCustomPlot.IsMouseSizeMove(Pos: TPoint; var ps: PlotState; out Item: TRegionCollectionItem): Boolean;
 const
  MM = 4;
 var
  c: TPlotColumn;
  r: TPlotRow;
  function Setps(s: PlotState; ri: TRegionCollectionItem): Boolean;
  begin
    Item := ri;
    ps := s;
    Result := True;
  end;
begin
  if (Pos.Y < MM*2) then for r in Rows do if (r.Top < Pos.Y) and (Pos.Y < r.Down) then Exit(Setps(pcsRowMoving, r))
  else if (Pos.X < MM*2) then for c in Columns do if (c.Left < Pos.X) < (Pos.X < c.Right) then Exit(Setps(pcsColMoving, c));
  for c in Columns do if Abs(c.Right - Pos.X) < MM then Exit(Setps(pcsColSizing, c));
  for r in Rows do if Abs(r.Down - Pos.Y) < MM then Exit(Setps(pcsRowSizing, r));
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
  if (Pos.Y < MM*2) then Exit(Setps(pcsRowMoving))
  else if (Pos.X < MM*2) then Exit(Setps(pcsColMoving));
  for c in Columns do if Abs(c.Right - Pos.X) < MM then Exit(Setps(pcsColSizing));
  for r in Rows do if Abs(r.Down - Pos.Y) < MM then Exit(Setps(pcsRowSizing));
  Result := False;
  ps := pcsNormal;
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
    else if not IsMouseSizeMove(FHitTest, State) then Cur := Screen.Cursors[GetRow(FHitTest).Cursor];
    /// setup cursors
    if (State = pcsColSizing) then Cur := Screen.Cursors[crHSplit]
    else if (State = pcsRowSizing) then Cur := Screen.Cursors[crVSplit]
    else if State in [pcsColMoving, pcsRowMoving] then Cur := Screen.Cursors[crDrag]
   end;
  if Cur <> 0 then SetCursor(Cur) else inherited;
end;

procedure TCustomPlot.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 var
  s: PlotState;
  r: TRegionCollectionItem;
begin
  try
   if not (csDesigning in ComponentState) and (CanFocus or (GetParentForm(Self) = nil)) then
    begin
     SetFocus;
    end;
   if (Button = mbLeft) and (ssDouble in Shift) then  DblClick
   else if Button = mbLeft then
    if IsMouseSizeMove(Tpoint.Create(X,Y), s, r) then
     begin
      FState := s;
     case s of
       pcsColSizing, pcsRowSizing: ;
       pcsColMoving, pcsRowMoving : ;
     end
     end
    else { TODO : Region Mouse down }

    function (cm: TCheckMouse; Col: TPlotColumn; X, Y: integer): boolean
    begin
      Result := True;
      case cm of
       cmColSize:
        begin
         FColState := pcsSizing;
         FChangeColumn := Col;
         FChangePos := Col.Right;
         FChangeLeft := Col.Left;
         DrawSizingLine;
        end;
       cmColMove:
        begin
         FColState := pcsMoving;
         FChangeColumn := Col;
         FSwapColumn := Col;
         FChangeLeft := Col.Left;
         DrawMovingLine;
         SetCursor(Screen.Cursors[crDrag]);
        end;
       cmColData:
        begin
         FSelectedColumn := Col;
         if Col.CheckMouseDownInData(X, Y, Shift) then
          begin
           FColState := pcsColumnData;
           FChangeColumn := Col;
           FChangeLeft := Col.Left;
          end;
        end;
       cmColLegend: Col.DoMouseDownInLegend(X, Y);
      end;
    end)
  finally
   inherited;
  end;
end;

procedure TCustomPlot.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
//  TDebug.Log(FloatToStr(ParamYToY(MouseYtoParamY(Y))));

 { case FColState of
   pcsSizing:
    begin
     DrawSizingLine();
     FChangePos := X;
     DrawSizingLine();
    end;
   pcsMoving: for c in Columns do if (X < c.Right) and (X > c.Left) and (FSwapColumn <> c) then
    begin
     DrawMovingLine;
     FSwapColumn := c;
     FChangeLeft := c.Left;
     DrawMovingLine;
     Break;
    end;
   pcsColumnData:
    begin
     if FShowLegend then Y := Y - LegendHeight;
     FChangeColumn.DoMouseMoveInData(X, Y);
    end;
   pcsNormal: if not IsLegend(Y) then DrawCrossLine(X, Y);
  end;
  inherited; }
end;

//procedure TCustomPlot.AsyncRepaint;
//begin
//  if ([psPainting, psScrolling, psUpdating] * FStates) <> [] then Exit;
//  DoPrepareLegend;
//  if ShowLegend then DoPaintLegend;
//  AsyncRun(DoPrepareData, DoPaintData);
//end;

procedure TCustomPlot.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//  procedure rep;
//  begin
//    UpdateColumns;
//    AsyncRepaint;
//  end;
begin
{  try
   case FColState of
    pcsSizing:
     begin
      DrawSizingLine();
      FChangePos := X;
      FChangeColumn.Width := FChangePos - FChangeLeft;
      rep;
     end;
    pcsMoving:
     begin
      DrawMovingLine();
      FChangeColumn.Index := FSwapColumn.Index;
      rep;
     end;
    pcsColumnData:
     begin
      if FShowLegend then Y := Y - LegendHeight;
      FChangeColumn.DoMouseUpInData(X, Y);
     end;
  end;
  finally
   FColState := pcsNormal;
  end;
  inherited;}
end;

procedure TCustomPlot.Paint;
 var
  i: Integer;
 var
  c: TPlotColumn;
  r: TPlotRow;
begin
  Canvas.FillRect(ClientRect);
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Mode := pmCopy;
//  Canvas.Rectangle(ClientRect);
  for c in Columns do
   begin
    Canvas.moveTo(c.Right, 0);
    Canvas.LineTo(c.Right, Height);
   end;
  for r in Rows do
   begin
    Canvas.moveTo(0, r.Down);
    Canvas.LineTo(width, r.Down);
   end;
end;

{$ENDREGION}

{function TCustomPlot.MouseYtoParamY(Y: Integer): Double;
begin
  if ShowLegend then Y := Y-LegendHeight;
 //scaledY
  if Mirror = 1 then Result := -OffsetY+Y else Result := OffsetY - ScrollRect.Height + Y;
 //RealY
  Result := Result/(Mirror*Ydpmm*ScaleY) + FirstY;
end;

function TCustomPlot.ParamYToY(Y: Double): Double;
begin
 //scaledY
  Y := (Y-FirstY)*Mirror*Ydpmm*ScaleY;
 //screenY
  if Mirror = 1 then Result := OffsetY+Y else Result := -OffsetY + ScrollRect.Height + Y;
end;

procedure TCustomPlot.GoToBookmark;
 var
  y: Double;
  off: double;
begin
  if FCursorY = NULL_VALL then Exit;
  Y := ParamYToY(FCursorY);
  off := ScrollRect.Height/2;
  if ShowLegend then off := off - LegendHeight/2;
  SetOffsetY(Round(OffsetY +Mirror*(off - Y)));
  Exclude(FStates, psScrolling);
end;   }


{$REGION 'P A I N T'}
{procedure TCustomPlot.ShowYWalls(G: TGPGraphics; top, Height: integer);
 var
  pn: TGPPen;
  i: Integer;
begin
  pn := TGPPen.Create(aclBlack, 1);
  try
  for i := 1 to Columns.Count-1 do G.DrawLine(pn, TPlotColumn(Columns.Items[i]).Left, top, TPlotColumn(Columns.Items[i]).Left, Height);
  finally
   pn.Free;
  end;
end;

procedure TCustomPlot.ShowCursorY(G: TGPGraphics);
  var
   Y: Double;
  pn: TGPPen;
begin
  if FCursorY <> NULL_VALL then
   begin
    Y := ParamYToY(FCursorY);
    if (Y >= 0) and (Y <= ScrollRect.Height) then
     begin
      pn := TGPPen.Create(ACL_CURSOR, 8);
      try
       G.DrawLine(pn, 0, Y, ClientWidth, Y);
      finally
       pn.Free;
      end;
     end;
   end;
end;

procedure TCustomPlot.ShowXAxis(G: TGPGraphics);
  var
   pn: TGPPen;
   Y: Double;
begin
  pn := TGPPen.Create(ACL_AXIS, 1);
  try
    if Mirror = 1 then g.TranslateTransform(0, OffsetY)
    else g.TranslateTransform(0, -OffsetY+ScrollRect.Height);

    Y := 2*Ydpmm*Trunc(-OffsetY/Ydpmm/2);
    while Y < (-OffsetY + ScrollRect.Height) do
     begin
      G.DrawLine(pn, 0, Y*Mirror, ClientWidth, Y*Mirror);
      Y := Y + Ydpmm*2;
     end;
  finally
   pn.Free;
  end;
end;

procedure TCustomPlot.DoPrepareData();
 var
  c: TPlotColumn;
  g: TGPGraphics;
  sb: TGPSolidBrush;
begin
  if psUpdating in FStates then Exit;
  Include(FStates, psUpdating);
//  TDebug.Log('  PrepareData() START---------');
  DataBitmap.Canvas.Lock;
//  TDebug.Log('  PrepareData() START++++++++++');
  try
   GDIPlus.Lock;
//   TDebug.Log('  PrepareData() START===== ');
   g := TGPGraphics.Create(DataBitmap.Canvas.Handle);
   sb := TGPSolidBrush.Create(ColorRefToARGB(color));
   try
    G.FillRectangle(sb, MakeRect(ScrollRect));
    ShowCursorY(G);
    ShowXAxis(G);
    G.ResetTransform;
    for c in Columns do
     begin
      c.ShowData(G);
      G.TranslateTransform(TPlotColumn(c).Width, 0);
     end;
    G.ResetTransform;
    ShowYWalls(G, 0, ScrollRect.Height);
   finally
    sb.Free;
    g.Free;
    GDIPlus.UnLock;
   end;
  finally
   DataBitmap.Canvas.Unlock;
//   TDebug.Log('  PrepareData() E N D ');
   Exclude(FStates, psUpdating);
  end;
end;

procedure TCustomPlot.DoPrepareLegend();
 var
  c: TPlotColumn;
  g: TGPGraphics;
  sb: TGPSolidBrush;
  p : TGPPen;
begin
  GDIPlus.Lock;
  G := TGPGraphics.Create(LegendBitmap.Canvas.Handle);
  sb := TGPSolidBrush.Create(ColorRefToARGB(color));
  p := TGPPen.Create(aclBlack, 1);
  try
   G.FillRectangle(sb, MakeRect(LegendRect));
   for c in Columns do
    begin
     c.ShowLegend(G, LegendHeight);
     G.TranslateTransform(TPlotColumn(c).Width, 0);
    end;
   G.ResetTransform;
   ShowYWalls(G, 0, LegendHeight-1);
   G.DrawLine(p, 0, LegendHeight-1, ClientWidth, LegendHeight-1);
  finally
   p.Free;
   sb.Free;
   g.free;
   GDIPlus.UnLock;
  end;
end;

procedure TCustomPlot.DoPaintData();
begin
//  TDebug.Log('  DoPaintData() START ');
  DataBitmap.Canvas.Lock;
  try
   if ShowLegend then BitBlt(Canvas.Handle, 0, LegendHeight, ClientWidth, ScrollRect.Height, DataBitmap.Canvas.Handle, 0, 0, SRCCOPY)
   else BitBlt(Canvas.Handle, 0, 0, ClientWidth, ScrollRect.Height, DataBitmap.Canvas.Handle, 0, 0, SRCCOPY);
   FHorizontShowed := False;
  finally
   DataBitmap.Canvas.Unlock;
  end;
//  TDebug.Log('  DoPaintData() E N D ');
end;

procedure TCustomPlot.DoPaintLegend();
begin
  BitBlt(Canvas.Handle, 0,0, ClientWidth, LegendHeight, LegendBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TCustomPlot.DoParamXAxisChanged(Column: TGraphColumn; Param: TGraphParam; ChangeState: TChangeStateParam);
begin
  if Assigned(FOnParamXAxisChanged) then FOnParamXAxisChanged(Column, Param, ChangeState);
end;

procedure TCustomPlot.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TCustomPlot.WMPaint(var Message: TWMPaint);
 var
  PS: TPaintStruct;
begin
//  TDebug.Log('  P A I N T   ');                                                      ;
  if (([psPainting, psScrolling, psUpdating] * FStates) <> []) or (Columns.Count <= 0) then Exit;
  Include(FStates, psPainting);
  BeginPaint(Handle, PS);
  try
   if ShowLegend then DoPaintLegend();
   DoPaintData();
  finally
   EndPaint(Handle, PS);
   Exclude(FStates, psPainting);
  end;
end;   }

{$ENDREGION}

{ TPlotColumns }

function TPlotColumns.GetAllLen: Integer;
begin
  Result := FPlot.Width;
end;

{ TPlotRows }

function TPlotRows.GetAllLen: Integer;
begin
  Result := FPlot.Height;
end;

initialization
//  RegisterClasses([TPlotCollection, TPlotColumns, TPlotColumn, TYColumn, TGraphColumn, TPlot, TGraphParams, TGraphParam]);
end.
