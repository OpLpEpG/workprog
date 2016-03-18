unit Plot.GR32;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, ExtendIntf, Vcl.Forms, Plot.DataLink,
  Vcl.Graphics, Vcl.Themes, Winapi.Windows, Winapi.Messages, System.Math,
  GR32_Math, GR32, GR32_Image, GR32_RangeBars, GR32_Blend, GR32_Polygons, GR32_Resamplers,
  GR32_VectorUtils, GR32_Geometry, RootImpl, RootIntf, tools, JDtools,
  debug_except, CustomPlot;

type
//  IGR32LineCash = interface(ICashedData)
//  ['{BDB9C4F0-5B3E-43A2-8B53-C2323DC139ED}']
//  end;
//
//  TGR32LineCash = class(TAggObject, IGR32LineCash)
//    procedure SetCashSize(const Value: Integer); virtual; abstract;
//    function GetCashSize: Integer; virtual; abstract;
//    function GetMaxCashSize: Int64; virtual; abstract;
//  end;

//  TGR32FileDataLink = class(TFileDataLink)
//  property Cash: ICashedData read FCash implements ICashedData
//  end;

  TGR32GraphicCollumn = class(TGraphColmn)
  protected
    procedure DoVisibleChanged; override;
    procedure ColumnCollectionChanged(ColumnCollection: TGraphCollection); override;
    procedure ColumnCollectionItemChanged(const Item: TColumnCollectionItem); override;
  end;

  TGR32LegendRow = class(TCustomGraphLegendRow)
  protected
    procedure DoVisibleChanged; override;
  end;

  TGR32Region = class(TGraphRegion)
  protected
    procedure SetVisible(Visible: Boolean); virtual;
    procedure ParamCollectionChanged; virtual; abstract;
    procedure ParamPropChanged; virtual; abstract;
  end;

{$REGION 'Отрисовка легенды'}

  TGR32GraphicLegend = class(TGR32Region)
  private
    FCanvasShowRect: TRect;
    FbitmapShowRect: TRect;
    FRangeBar: TCustomRangeBar;
    FRange: Integer;
    FBitmap: TBitmap32;
    procedure UpdateShowRect;
    procedure UpdateRange;
    procedure UpdateBitmapBaund;
    procedure OnScroll(Sender: TObject);
    procedure Render;
    function GetPatamHeight(p: TGraphPar): Integer;
    procedure RenderLinePatam(Y: Integer; p: TLineParam);
    procedure RenderWavePatam(Y: Integer; p: TWaveParam);
    procedure RenderStringPatam(Y: Integer; p: TStringParam);
    function GetCheckBoxRect(Par: TLineParam; nX: Integer = 0): TRect;
  protected
    procedure SetVisible(Visible: Boolean); override;
    procedure ParamCollectionChanged; override;
    procedure ParamPropChanged; override;
    procedure ParentFontChanged; override;
    procedure Paint; override;
    procedure SetClientRect(const Value: TRect); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(Collection: TCollection); override;
//    property pp2mm: Double read Fpp2mm;
    destructor Destroy; override;
    function TryHitParametr(pos: TPoint; out Par: TGraphPar): Boolean; override;
  end;
{$ENDREGION 'Отрисовка легенды'}

{$REGION 'Отрисовка данных'}

  TWaveParamBuffer = class(TIObject)
    Bitmap: TBitmap32;
    constructor Create;
    destructor Destroy; override;
  end;

{$REGION 'lines'}

  TLineParamBuffer = class(TIObject)
    Points: TArrayOfFloatPoint;
  end;

  ILineParamMouseEdit = interface
    procedure DoMouseMove(X, Y: Integer);
    procedure DoMouseUp(X, Y: Integer);
  end;

  TGR32GraphicData = class;

  /// скроллинг мышкой
  TScrollMouseData = class(TIObject, ILineParamMouseEdit)
    Owner: TGR32GraphicData;
    YBegin: Integer;
    const
      MRTOINT: array[Boolean] of Integer = (-1, 1);
    constructor Create(AOwner: TGR32GraphicData; Y: Integer);
    procedure DoMouseMove(X, Y: Integer);
    procedure DoMouseUp(X, Y: Integer);
  end;
  /// корневой класс для ркдактирования линий
  TLineParamMouseEdit = class(TIObject, ILineParamMouseEdit)
    Owner: TGR32GraphicData;
    Param: TLineParam;
    XBegin: Integer;
    Points: TArrayOfFloatPoint;
    const
      PPMMDELTA = 1 / 4;
    constructor Create(AOwner: TGR32GraphicData; Par: TGraphPar; X: Integer); virtual;
    procedure DoMouseMove(X, Y: Integer); virtual; abstract;
    procedure DoMouseUp(X, Y: Integer); virtual; abstract;
  end;
  /// сдвигание линии
  TLineParamMouseMove = class(TLineParamMouseEdit)
    KSumm: Integer;
    procedure DoMouseMove(X, Y: Integer); override;
    procedure DoMouseUp(X, Y: Integer); override;
  end;
  /// масштабирование линии по Х
  TLineParamMouseScale = class(TLineParamMouseEdit)
    XMiddle: Double;
    KDeltaOLD: Integer;
    KScale: Double;
    Delta: Single;
    Origin: TArray<Single>;
    const
      PPMMSCALE = 1 / 10;
    constructor Create(AOwner: TGR32GraphicData; Par: TGraphPar; X: Integer); override;
    procedure DoMouseMove(X, Y: Integer); override;
    procedure DoMouseUp(X, Y: Integer); override;
  end;

{$ENDREGION lines}

  TGR32GraphicData = class(TGR32Region)
    const
      ACL_AXIS = $F0A8A8A8;
      ACL_AXIS_LABEL = clBlack32;
  private
    FLineParamMouseEdit: ILineParamMouseEdit;
    FShowRect: TRect;
    FBitmap: TBitmap32;
    FPropertyChanged: string;
    FRenderNeeded: Boolean;
    FShowYlegend: boolean;
    procedure SetPropertyChanged(const Value: string);
    procedure Render(UpdateBuffers: Boolean = True);
    procedure SetShowYlegend(const Value: boolean);
  protected
    function GetCursor: Integer; override;
    procedure DrowAxis();
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetClientRect(const Value: TRect); override;
    procedure ParamCollectionChanged; override;
    procedure ParamPropChanged; override;
    procedure ParentFontChanged; override;
    procedure Paint; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function TryHitParametr(pos: TPoint; out Par: TGraphPar): Boolean; override;
    property C_PropertyChanged: string read FPropertyChanged write SetPropertyChanged;
  published
    [ShowProp('Метки оси Y')] property ShowYlegend: boolean read FShowYlegend write SetShowYlegend default True;
  end;
{$ENDREGION 'Отрисовка данных'}

function RandomColor: TColor;

implementation

{$REGION 't o o l s'}

function RandomColor: TColor;
begin
//  Result := TColor(HSVtoRGB(Random(360), 1, 0.5));
   Result := TColor(Color32(Random(256),Random(256),Random(256),$E0));
end;

function ScaleFloatPoint(L: TFloat; R: TFloatPoint): TFloatPoint;
begin
  Result.X := R.X * L;
  Result.Y := R.Y * L;
end;

/// <summary>
/// расстояние от точки p до отрезка vw
/// </summary>
/// <remarks>
/// взял с интернета
/// </remarks>
/// <example>
/// <code>
/// float minimum_distance(vec2 v, vec2 w, vec2 p)
/// {
///  // Return minimum distance between line segment vw and point p
///  const float l2 = length_squared(v, w);  // i.e. |w-v|^2 -  avoid a sqrt
///   if (l2 == 0.0) return distance(p, v);   // v == w case
///   // Consider the line extending the segment, parameterized as v + t (w - v).
///   // We find projection of point p onto the line.
///   // It falls where t = [(p-v) . (w-v)] / |w-v|^2
///   // We clamp t from [0,1] to handle points outside the segment vw.
///   const float t = max(0, min(1, dot(p - v, w - v) / l2));
///   const vec2 projection = v + t * (w - v);  // Projection falls on the segment
///   return distance(p, projection);
/// }
/// </code>
/// </example>
function DistanceFromPointToSegment(v, w, p: TFloatPoint): TFloat;
var
  t, l2: Single;
begin
  /// i.e. |w-v|^2 -  avoid a sqrt
  l2 := SqrDistance(v, w);
  /// v == w case
  if (l2 = 0.0) then
    Exit(Distance(p, v));
  /// Consider the line extending the segment, parameterized as v + t (w - v).
  /// We find projection of point p onto the line.
  /// It falls where t = [(p-v) . (w-v)] / |w-v|^2
  /// We clamp t from [0,1] to handle points outside the segment vw.
  t := max(0, min(1, dot(p - v, w - v) / l2));
//  const vec2 projection = v + t * (w - v);  // Projection falls on the segment
  Result := Distance(p, v + ScaleFloatPoint(t, w - v));
end;

/// <summary>
/// расстояние от точки p до кривой
/// </summary>
function DistanceFromPointToCurve(p: TFloatPoint; const Curve: TArrayOfFloatPoint): TFloat;
var
  n, L, i: Integer;
begin
  Result := Single.MaxValue;
  L := Length(Curve);
  if L = 1 then
    Exit(Distance(p, Curve[0]));
  n := 0;
  // Так как  планируется что Y Всегда монотонно растет находим Curve[n-1].Y < p.Y <= Curve[n].Y
  while (n < L) and (p.Y > Curve[n].Y) do
    Inc(n);
  //  в районе n находим расстояние до кривой
  for I := Max(0, n - 3) to Min(L - 2, n + 3) do
    Result := Min(Result, DistanceFromPointToSegment(Curve[i], Curve[i + 1], p));
end;

const
  CHECKBOX_SIZE = 10;

procedure DrawCheckBox(Bitmap: TBitmap32; Y: Integer; const Checked: Boolean; nX: Integer = 0);
const
  DA: array[Boolean] of TThemedButton = (tbCheckBoxUncheckedNormal, tbCheckBoxCheckedNormal);
var
  B: Vcl.Graphics.TBitmap;
  NonThemedCheckBoxState: Cardinal;
  R: TRect;
begin
  B := Vcl.Graphics.TBitmap.Create;
  try
    B.SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE);
    R := Rect(0, 0, CHECKBOX_SIZE, CHECKBOX_SIZE);
    if StyleServices.Enabled then
      StyleServices.DrawElement(B.Canvas.Handle, StyleServices.GetElementDetails(DA[Checked]), R)
    else
    begin
      B.Canvas.FillRect(R);
      NonThemedCheckBoxState := DFCS_BUTTONCHECK;
      if Checked then
        NonThemedCheckBoxState := NonThemedCheckBoxState or DFCS_CHECKED;
      DrawFrameControl(B.Canvas.Handle, R, DFC_BUTTON, NonThemedCheckBoxState);
    end;
    Bitmap.Draw(TRect.Create(TPoint.Create(nX * (CHECKBOX_SIZE + 1) + CHECKBOX_SIZE div 2, y - CHECKBOX_SIZE div 2), CHECKBOX_SIZE, CHECKBOX_SIZE), R, b.Canvas.Handle);
  finally
    B.Free;
  end;
end;

procedure DrawLineParametr(Bitmap: TBitmap32; P: TLineParam; points: TArrayOfFloatPoint);

  function GetDashes: TArrayOfFloat;
  var
    i: Integer;
  begin
    case p.DashStyle of
      ldsDot:
        Result := [1, 2];
      ldsDash:
        Result := [8, 2];
      ldsDashDot:
        Result := [8, 2, 1, 2];
      ldsDashDotDot:
        Result := [8, 2, 1, 2, 1, 2];
    end;
    for i := 0 to High(Result) do
      Result[i] := Result[i] {* FixedOne}  * p.Width;
  end;

begin
  if p.DashStyle = ldsSolid then
    PolylineFS(Bitmap, points, p.Color, False, p.Width{ * FixedOne})
  else
    DashLineFS(Bitmap, points, GetDashes, p.Color, False, p.Width{ * FixedOne});
end;

{$ENDREGION}

procedure TGR32LegendRow.DoVisibleChanged;
var
  i: Integer;
begin
  inherited DoVisibleChanged;
  for i := 0 to RegionsCount - 1 do
    if Regions[i] is TGR32Region then
      TGR32Region(Regions[i]).SetVisible(Visible);
end;

{ TGR32Region }

procedure TGR32Region.SetVisible(Visible: Boolean);
begin
end;

{ TGR32GraphicCollumn }

procedure TGR32GraphicCollumn.ColumnCollectionChanged(ColumnCollection: TGraphCollection);
var
  r: TGraphRegion;
begin
  if ColumnCollection is TGraphParams then
    for r in Regions do
      if r is TGR32Region then
        TGR32Region(r).ParamCollectionChanged;
end;

procedure TGR32GraphicCollumn.ColumnCollectionItemChanged(const Item: TColumnCollectionItem);
var
  r: TGraphRegion;
begin
  if Item is TGraphPar then
    for r in Regions do
      if r is TGR32Region then
        TGR32Region(r).ParamPropChanged;
end;

procedure TGR32GraphicCollumn.DoVisibleChanged;
var
  i: Integer;
begin
  inherited DoVisibleChanged;
  for i := 0 to RegionsCount - 1 do
    if Regions[i] is TGR32Region then
      TGR32Region(Regions[i]).SetVisible(Visible);
end;

{$REGION 'TGR32GraphicLegend'}

{ TGR32GraphicLegend }

constructor TGR32GraphicLegend.Create(Collection: TCollection);
begin
  inherited;
  FRangeBar := TCustomRangeBar.Create(nil);
  FRangeBar.Kind := sbVertical;
  FRangeBar.Width := 4;
  FRangeBar.BorderStyle := bsNone;
  FRangeBar.ShowArrows := False;
  FRangeBar.OnChange := OnScroll;
  FBitmap := TBitmap32.Create;
end;

destructor TGR32GraphicLegend.Destroy;
begin
  FBitmap.Free;
  FRangeBar.Free;
  inherited;
end;

function TGR32GraphicLegend.GetCheckBoxRect(Par: TLineParam; nX: Integer = 0): TRect;
var
  y: Integer;
  p: TGraphPar;
begin
  y := -Round(FRangeBar.Position);
  for p in Column.Params do
    if p = Par then
      Exit(TRect.Create(TPoint.Create(nX * (CHECKBOX_SIZE + 1) + CHECKBOX_SIZE div 2, y + FBitmap.TextHeight(']') + 1 + par.Width div 2 - CHECKBOX_SIZE div 2), CHECKBOX_SIZE, CHECKBOX_SIZE))
    else
      Inc(Y, GetPatamHeight(p));
end;

function TGR32GraphicLegend.GetPatamHeight(p: TGraphPar): Integer;
begin
  Result := FBitmap.TextHeight('[') * 2;
  if p is TLineParam then
    Inc(Result, TLineParam(p).Width)
  else
    Inc(Result, 1);
end;

procedure TGR32GraphicLegend.OnScroll(Sender: TObject);
begin
  UpdateShowRect;
  Paint;
end;

procedure TGR32GraphicLegend.Paint;
begin
  if not Graph.Frosted and Graph.HandleAllocated and Column.Visible and Row.Visible then
    FBitmap.DrawTo(Graph.Canvas.Handle, FCanvasShowRect, FBitmapShowRect);
end;

procedure TGR32GraphicLegend.ParamCollectionChanged;
begin
  UpdateRange;
  FRangeBar.SetParams(FRange, ClientRect.Height);
  FRangeBar.Visible := Column.Visible and Row.Visible and (FRange > ClientRect.Height);
  UpdateShowRect;
  UpdateBitmapBaund;
  Render;
  Paint;
end;

procedure TGR32GraphicLegend.ParamPropChanged;
begin
  ParamCollectionChanged;
end;

procedure TGR32GraphicLegend.ParentFontChanged;
begin
  FBitmap.Font := Graph.Font;
  UpdateRange;
  Render;
  //Paint//?
end;

procedure TGR32GraphicLegend.Render;
var
  p: TGraphPar;
  Y: Integer;
begin
  FBitmap.FillRect(0, 0, FBitmap.Width, FBitmap.Height, clWhite32);
  Y := 0;
  for p in Column.Params do
    if not p.HideInLegend then
    begin
      if p is TStringParam then
        RenderStringPatam(Y, TStringParam(p))
      else if p is TLineParam then
        RenderLinePatam(Y, TLineParam(p))
      else if p is TWaveParam then
        RenderWavePatam(Y, TWaveParam(p));
      inc(Y, GetPatamHeight(p));
    end;
end;

procedure TGR32GraphicLegend.RenderLinePatam(Y: Integer; p: TLineParam);
var
  CaptionX, LineY, ym: Integer;
  s: Tsize;
  AxisLabel: Double;
  posX: Double;
  Fpp2mm: Double;
begin
  Fpp2mm := Screen.PixelsPerInch / 2.54 * 2;
  s := FBitmap.TextExtent(p.Title);
  CaptionX := (FBitmap.Width - s.cx) div 2;
  if CaptionX < 0 then
    CaptionX := 0;
  // заголовок
  if p.EUnit <> '' then
    FBitmap.RenderText(CaptionX, y, p.Title + '[' + p.EUnit + ']', 1, clBlack32)// p.Color)
  else
    FBitmap.RenderText(CaptionX, y, p.Title, 1, clBlack32);//p.Color);
  // линия
  LineY := y + s.cy + 1 + p.Width div 2;
  DrawLineParametr(FBitmap, p, [TFloatPoint.Create(0, LineY), TFloatPoint.Create(FBitmap.Width, LineY)]);
  // риски и шкала
  posX := 0;
  AxisLabel := p.DeltaX;
  FBitmap.PenColor := p.Color;
  ym := LineY + p.Width div 2;
  while posX < FBitmap.Width do
  begin
    FBitmap.VertLineTS(Round(posX), ym, ym + 8, p.Color);
    FBitmap.RenderText(Round(posX), ym, Format('%-10.5g', [AxisLabel]), 1, clBlack32);//p.Color);
    posX := posX + Fpp2mm;
    AxisLabel := AxisLabel + 1.0 / p.ScaleX;
    if Abs(AxisLabel) < 0.0000001 then
      AxisLabel := 0;
  end;
  // CheckBox
  DrawCheckBox(FBitmap, LineY, p.Visible);
  DrawCheckBox(FBitmap, LineY, p.Selected, 1);
//  yl := y+GetPatamHeight(p);
//  FBitmap.HorzLineTS(0, yl, FBitmap.Width, clBlack32);
end;

procedure TGR32GraphicLegend.RenderStringPatam(Y: Integer; p: TStringParam);
begin
  FBitmap.PenColor := p.Color;
  FBitmap.Textout(0, Y, p.Title);
end;

procedure TGR32GraphicLegend.RenderWavePatam(Y: Integer; p: TWaveParam);
begin
//  FBitmap.PenColor :=  p.Gamma;
  FBitmap.Textout(0, Y, p.Title);
end;

procedure TGR32GraphicLegend.SetClientRect(const Value: TRect);
begin
  inherited;
  FRangeBar.SetBounds(Value.Right - FRangeBar.Width, Value.Top, FRangeBar.Width, Value.Height);
  if FRange = 0 then
    UpdateRange;
  FRangeBar.SetParams(FRange, Value.Height);
  FRangeBar.Visible := FRange > Value.Height;
  UpdateShowRect;
  UpdateBitmapBaund;
  Render;
  if not Assigned(FRangeBar.Parent) then
    FRangeBar.Parent := Graph;
end;

procedure TGR32GraphicLegend.SetVisible(Visible: Boolean);
begin
  FRangeBar.Visible := Column.Visible and Row.Visible  and (FRange > FBitmapShowRect.Height);
end;

procedure TGR32GraphicLegend.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TGraphPar;
  clPoint, point: TPoint;
begin
  point := Tpoint.Create(X, Y);
  clPoint := MouseToClient(point);
  if TryHitParametr(point, p) and (p is TLineParam) then
  begin
    if GetCheckBoxRect(TLineParam(p)).contains(clPoint) then
      p.Visible := not p.Visible;
    if GetCheckBoxRect(TLineParam(p), 1).contains(clPoint) then
      p.Selected := not p.Selected;
  end;
end;

function TGR32GraphicLegend.TryHitParametr(pos: TPoint; out Par: TGraphPar): Boolean;
var
  p: TGraphPar;
  top, ht: Integer;
  clPoint: TPoint;
begin
  top := -Round(FRangeBar.Position);
  clPoint := MouseToClient(pos);
  for p in Column.Params do
  begin
    ht := GetPatamHeight(p);
    if (clPoint.Y > top) and (clPoint.Y < top + ht) then
    begin
      Par := p;
      Exit(True);
    end;
    Inc(top, ht);
  end;
  Result := False;
end;

procedure TGR32GraphicLegend.UpdateBitmapBaund;
begin
  if FRange > FBitmapShowRect.Height then
    FBitmap.SetSize(FBitmapShowRect.Width, FRange)
  else
    FBitmap.SetSize(FBitmapShowRect.Width, FBitmapShowRect.Height)
end;

procedure TGR32GraphicLegend.UpdateRange;
var
  p: TGraphPar;
begin
  FRange := 0;
  for p in Column.Params do
    if not p.HideInLegend then
      Inc(FRange, GetPatamHeight(p));
end;

procedure TGR32GraphicLegend.UpdateShowRect;
var
  origin: TPoint;
begin
  FCanvasShowRect := ClientRect;
  if FRangeBar.Visible then
    FCanvasShowRect.Width := FCanvasShowRect.Width - FRangeBar.Width;
  FBitmapShowRect := FCanvasShowRect;
  origin.X := 0;
  origin.Y := 0;
  if FRangeBar.Position <= FRange - FBitmapShowRect.Height then
    origin.Y := Round(FRangeBar.Position)
  else if FRange - FBitmapShowRect.Height >= 0 then
    origin.Y := FRange - FBitmapShowRect.Height;
  FBitmapShowRect := TRect.Create(origin, FCanvasShowRect.Width, FCanvasShowRect.Height);
end;
{$ENDREGION}

{$REGION 'TGR32GraphicData'}

{ TLineParamMouseEdit TLineParamMouseMove, TLineParamMouseScale TScrollMouseData }

constructor TScrollMouseData.Create(AOwner: TGR32GraphicData; Y: Integer);
begin
  Owner := AOwner;
  YBegin := Y;
  SetCursor(Screen.Cursors[crHandPoint])
end;

procedure TScrollMouseData.DoMouseMove(X, Y: Integer);
var
  k: Double;
begin
  if Y <> YBegin then with Owner.Graph do
    begin
     k := YScale * (Screen.PixelsPerInch / 2.54 * 2)*MRTOINT[YMirror];
     YPosition := YPosition + (Y - YBegin) / k;
     YBegin := Y;
    end;
end;

procedure TScrollMouseData.DoMouseUp(X, Y: Integer);
begin
end;

constructor TLineParamMouseEdit.Create(AOwner: TGR32GraphicData; Par: TGraphPar; X: Integer);
begin
  Owner := AOwner;
  Param := TLineParam(Par);
  XBegin := X;
  Points := TLineParamBuffer((Param as ILineDataLink).DrowMemoryBuffer).Points;
end;

constructor TLineParamMouseScale.Create(AOwner: TGR32GraphicData; Par: TGraphPar; X: Integer);
var
  I: Integer;
begin
  inherited;
  XMiddle := 0;
  SetLength(Origin, Length(Points));
  for i := 0 to High(Points) do
  begin
    XMiddle := XMiddle + Points[i].X;
    Origin[i] := Points[i].X;
  end;
  XMiddle := XMiddle / Length(Points);
  KScale := 1;
end;

procedure TLineParamMouseMove.DoMouseMove(X, Y: Integer);
var
  Delta: Single;
  k, i: Integer;
  ppmm: Double;
begin
  ppmm := Screen.PixelsPerInch / 2.54 * 2 * PPMMDELTA;
  k := Trunc((X - XBegin) / ppmm);
  if Abs(K) > 0 then
  begin
    Delta := k * ppmm;
    for i := 0 to Length(Points) - 1 do
      Points[i].X := Points[i].X + Delta;
    XBegin := X;
    inc(KSumm, k);
    Owner.Render(False);
    Owner.Paint;
  end;
end;

procedure TLineParamMouseScale.DoMouseMove(X, Y: Integer);
var
  k, i: Integer;
  ppmm: Double;
begin
  ppmm := Screen.PixelsPerInch / 2.54 * 2 * PPMMDELTA;
  k := Min(Max(Low(SCALE_PRESET_MOUSE), Trunc((X - XBegin) / ppmm)), High(SCALE_PRESET_MOUSE));
  if Abs(KDeltaOLD - K) > 0 then
  begin
    KDeltaOLD := K;
    KScale := SCALE_PRESET_MOUSE[k];
   /// Формулы в блонноте (Экран проект 3)
    Delta := XMiddle / KScale - XMiddle;
    for i := 0 to Length(Points) - 1 do
      Points[i].X := (Origin[i] + Delta) * KScale;
    Owner.Render(False);
    Owner.Paint;
  end;
end;

procedure TLineParamMouseScale.DoMouseUp(X, Y: Integer);
var
  pp2mm: Double;
//  I: Integer;
begin
  pp2mm := Screen.PixelsPerInch / 2.54 * 2;
  Owner.Graph.Frost;
  try
   /// Формулы в блонноте (Экран проект 3)
    Param.DeltaX := Param.DeltaX - Delta / Param.ScaleX / pp2mm;
    Param.ScaleX := FindBestScale(Param.ScaleX * KScale);
    Param.DeltaX := Round(Param.DeltaX * Param.ScaleX) / Param.ScaleX;
  finally
    Owner.Graph.DeFrost;
  end;
end;

procedure TLineParamMouseMove.DoMouseUp(X, Y: Integer);
begin
  Param.DeltaX := Param.DeltaX - KSumm * PPMMDELTA / Param.ScaleX;
end;

{ TGR32GraphicData }

constructor TGR32GraphicData.Create(Collection: TCollection);
begin
  inherited;
  FShowYlegend := True;
  FBitmap := TBitmap32.Create;
  TBindHelper.Bind(Self, 'C_PropertyChanged', Graph as IInterface, ['S_PropertyChanged']);
end;

destructor TGR32GraphicData.Destroy;
begin
  TBindHelper.RemoveExpressions(Self);
  FBitmap.Free;
  inherited;
end;

procedure TGR32GraphicData.DrowAxis();
var
  pp2mm: Double;
  x, y, ylb: Double;
  m: Integer;

  function nextAxis(var a: Double): Integer;
  begin
    a := a + pp2mm;
    Result := Round(a);
  end;

  function YtoBitmap(Ypos: Double): Integer;
  var
    pos: Double;
  begin
    Pos := Ypos - Graph.YTopScreen;
    Pos := Pos * pp2mm * Graph.YScale;
    Result := Round(pos);
  end;

begin
  pp2mm := Screen.PixelsPerInch / 2.54 * 2;
  if Graph.YMirror then
    m := -1
  else
    m := 1;
  x := 0;
  while x < FBitmap.Width do
    FBitmap.VertLineTS(nextAxis(x), 0, FBitmap.Height, ACL_AXIS);
  ylb := Trunc(Graph.YTopScreen * Graph.YScale) / Graph.YScale; // ceil mirror ????
  y := m * YtoBitmap(ylb); { TODO : write function }
  while y < FBitmap.Height do
  begin
    FBitmap.HorzLineTS(0, Round(y), FBitmap.Width, ACL_AXIS);
    if FShowYlegend then
      FBitmap.RenderText(0, Round(y), FloatToStr(SimpleRoundTo(Ylb, -4)), 1, ACL_AXIS_LABEL);
    ylb := ylb + m / Graph.YScale;
    Y := Y + pp2mm;
  end;
end;

function TGR32GraphicData.GetCursor: Integer;
begin
  Result := crCross;
end;

procedure TGR32GraphicData.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TGraphPar;
begin
  if TryHitParametr(TPoint.Create(X, Y), p) then
    if ssShift in Shift then
      FLineParamMouseEdit := TLineParamMouseScale.Create(Self, p, X)
    else
      FLineParamMouseEdit := TLineParamMouseMove.Create(Self, p, X)
  else
    FLineParamMouseEdit := TScrollMouseData.Create(Self, Y)
end;

procedure TGR32GraphicData.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FLineParamMouseEdit) then
    FLineParamMouseEdit.DoMouseMove(X, Y);
end;

procedure TGR32GraphicData.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FLineParamMouseEdit) then
    FLineParamMouseEdit.DoMouseUp(X, Y);
  FLineParamMouseEdit := nil;
end;

procedure TGR32GraphicData.Paint;
begin
  if Graph.Frosted then
    Exit;
  if FRenderNeeded then
    Render();
  if Column.Visible and Row.Visible then
    FBitmap.DrawTo(Graph.Canvas.Handle, ClientRect, FShowRect);
end;

procedure TGR32GraphicData.ParamCollectionChanged;
begin
  Render;
  Paint;
end;

procedure TGR32GraphicData.ParamPropChanged;
begin
  Render;
  Paint;
end;

procedure TGR32GraphicData.ParentFontChanged;
begin
end;

procedure TGR32GraphicData.Render(UpdateBuffers: Boolean = True);
 var
  pp2mm: Single;
  procedure RenderWaveparams;
   var
    p: TGraphPar;
    pss: IWaveDataLink;
    SrcRect: TRect;
    Src: TBitmap32;
    dx, dy, ky, kx: Single;
    X0,X1,Y0,Y1, indx: Integer;
  begin
    for p in Column.Params do if p.Visible and (p is TWaveParam) and Supports(p, IWaveDataLink, pss) then
     begin
      if not Assigned(pss.DrowMemoryBuffer) then
       begin
        pss.DrowMemoryBuffer := TWaveParamBuffer.Create;
        TWaveParamBuffer(pss.DrowMemoryBuffer).Bitmap.SetSize(pss.ArrayCount, pss.RecordCount);
       end;
      ky := p.Graph.YScale * pp2mm;
      kx := TLineParam(p).ScaleX * pp2mm;
      X0 := Round(p.DeltaX * kx);
      X1 := Round((p.DeltaX + pss.ArrayCount) * kx);
      dy := (-p.Graph.YTopScreen + p.DeltaY) * ky;
      Y0 := Round(pss.IndexOfY(p.Graph.YTopScreen * ky - dy, fitPrior));
      Y1 := Round(pss.IndexOfY(p.Graph.YButtomScreen * ky - dy, fitNext));

      Src := TWaveParamBuffer(pss.DrowMemoryBuffer).Bitmap;

      SrcRect := TRect.Create(X0,Y0, X1, Y1);
      if UpdateBuffers  then
       begin
        indx := 0;
        pss.Read(0, 1, procedure(Y: Single; const X: TArray<Byte>)
         var
          i: Integer;
        begin
          for i := 0 to Length(X)-1 do Src.Pixel[i, indx] := TWaveParam(p).Gamma[X[i]];
          inc(indx);
        end);
       end;
      StretchTransfer(FBitmap, FBitmap.BoundsRect, FBitmap.ClipRect, src, SrcRect, src.Resampler, src.DrawMode, src.OnPixelCombine);
     end;
  end;
  procedure RenderLineparams;
   var
    p: TGraphPar;
    pss: ILineDataLink;
    dx, dy, ky, kx: Single;
    i, cnt: Integer;
    fp: TFloatPoint;
  begin
    for p in Column.Params do if p.Visible and (p is TLineParam) and Supports(p, ILineDataLink, pss) then
      begin
     // создание буфера
        if not Assigned(pss.DrowMemoryBuffer) then pss.DrowMemoryBuffer := TLineParamBuffer.Create;
        with TLineParamBuffer(pss.DrowMemoryBuffer) do
         begin
          if UpdateBuffers then
           begin
          // подготовка буфера чтение из БД буфера фильтра
            SetLength(points, 0);
            ky := p.Graph.YScale * pp2mm;
            kx := TLineParam(p).ScaleX * pp2mm;
            // чтение из БД
            pss.Read(Min(p.Graph.YTopScreen, p.Graph.YButtomScreen), Max(p.Graph.YTopScreen, p.Graph.YButtomScreen),
            procedure(Y: Single;const X: Single)
            begin
              points := points + [TFloatPoint.Create(X*kx, Y*ky)];
            end);
           // удаление лишних точек
            if Length(points) > 100 then points := VertexReduction(points);
            dx := p.DeltaX * kx;
            dy := (-p.Graph.YTopScreen + p.DeltaY) * ky;
            cnt := Length(points);
            if p.Graph.YMirror then
             begin
              if odd(cnt) then
               begin
                points[cnt div 2].X := points[cnt div 2].X - dx;
                points[cnt div 2].Y := -(points[cnt div 2].Y + dy);
               end;
              for i := 0 to cnt div 2-1 do
               begin
                fp := points[i];
                points[i].X := points[cnt-1-i].X - dx;
                points[i].Y := -(points[cnt-1-i].Y + dy);
                points[cnt-1-i].X := fp.X - dx;
                points[cnt-1-i].Y := -(fp.Y + dy);
               end
             end
            else for i := 0 to cnt-1 do
             begin
              points[i].X := points[i].X - dx;
              points[i].Y := points[i].Y + dy;
             end;
           end;
       // рендеринг
          if Length(points) > 1 then DrawLineParametr(FBitmap, TLineParam(p), points);
         end;
      end;
  end;
begin
  if Graph.Frosted then
  begin
    FRenderNeeded := True;
    Exit;
  end;
  FRenderNeeded := False;
  pp2mm := Screen.PixelsPerInch / 2.54 * 2;
  FBitmap.FillRect(0, 0, FBitmap.Width, FBitmap.Height, clWhite32);
  RenderWaveparams;
  RenderLineparams;
  DrowAxis;
end;

procedure TGR32GraphicData.SetClientRect(const Value: TRect);
begin
  inherited;
  FBitmap.SetSize(Value.Width, value.Height);
  FShowRect := FBitmap.BoundsRect;
  Render;
  Paint;
end;

procedure TGR32GraphicData.SetPropertyChanged(const Value: string);
begin
  FPropertyChanged := Value;
  if Value = 'Screen' then
  begin
    Render;
    Paint;
  end;
end;

procedure TGR32GraphicData.SetShowYlegend(const Value: boolean);
begin
  FShowYlegend := Value;
  Render(False);
  Paint;
end;

function TGR32GraphicData.TryHitParametr(pos: TPoint; out Par: TGraphPar): Boolean;
var
  p: TGraphPar;
  clPoint: TFloatPoint;
  Dist, delta: TFloat;
begin
  clPoint := TFloatPoint.Create(MouseToClient(pos));
  Result := False;
  for p in Column.Params do
    if p.Visible then
    begin
      if p is TLineParam then
        with TLineParamBuffer((p as ILineDataLink).DrowMemoryBuffer) do
        begin
          delta := TLineParam(p).Width + 2;
          Dist := DistanceFromPointToCurve(clPoint, Points);
          if Dist < delta then
          begin
            Par := p;
            Exit(True);
          end;
        end;
    end;
end;

{$ENDREGION}

{ TWaveParamBuffer }

constructor TWaveParamBuffer.Create;
begin
  Bitmap := TBitmap32.Create;
end;

destructor TWaveParamBuffer.Destroy;
begin
  Bitmap.Free;
  inherited;
end;

initialization
  TGR32GraphicCollumn.ColClsRegister(TGR32GraphicCollumn, 'Графическая колонка');
  TGraphRegion.RegClsRegister(TGR32GraphicLegend, TGR32LegendRow, TGR32GraphicCollumn);
  TGraphRegion.RegClsRegister(TGR32GraphicData, TCustomGraphDataRow, TGR32GraphicCollumn);
  RegisterClasses([TGR32GraphicCollumn, TGR32GraphicLegend, TGR32GraphicData, TGR32LegendRow]);

end.

