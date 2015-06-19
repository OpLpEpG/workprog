unit Plot.GR32;

interface

uses System.SysUtils, System.Classes, System.Types, System.UITypes, ExtendIntf,
     Vcl.Forms, Vcl.Graphics, Vcl.Themes, Winapi.Windows, Winapi.Messages, System.Math,
     GR32, GR32_Image, GR32_RangeBars, GR32_Blend, GR32_Polygons, GR32_VectorUtils,
     RootImpl, RootIntf, tools, debug_except, CustomPlot;

type
  IGR32LineCash = interface(ICashedData)
  ['{BDB9C4F0-5B3E-43A2-8B53-C2323DC139ED}']
  end;

  TGR32LineCash = class(TAggObject, IGR32LineCash)
    procedure SetCashSize(const Value: Integer); virtual; abstract;
    function GetCashSize: Integer; virtual; abstract;
    function GetMaxCashSize: Int64; virtual; abstract;
  end;

  TGR32FileDataLink = class(TFileDataLink)
  //property Cash: ICashedData read FCash implements ICashedData
  end;

  TGR32GraphicCollumn = class(TGraphColmn)
  protected
    procedure ColumnCollectionChanged(ColumnCollection: TGraphCollection); override;
    procedure ColumnCollectionItemChanged(Item: TGraphCollectionItem); override;
  end;

  TGR32LegendRow = class(TCustomGraphLegend)
  protected
    procedure DoVisibleChanged; override;
  end;

  TGR32Region = class(TGraphRegion)
  protected
    procedure SetVisible(Visible: Boolean); virtual;
    procedure ParamCollectionChanged; virtual; abstract;
    procedure ParamPropChanged; virtual; abstract;
  end;

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
    function GetCheckBoxRect(Par: TLineParam): TRect;
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
    function TryHitParametr(pos: TPoint; out Par: TGraphPar): Boolean; override;
    destructor Destroy; override;
  end;

  TGraphicDataState = (gdsNornal, gdsMoving, gdsSceling);

  TGR32GraphicData = class(TGR32Region)
   const
    ACL_AXIS   = $F0A8A8A8;
    ACL_AXIS_LABEL   = clBlack32;
  private
    FBitmapShowRect: TRect;
    FBitmap: TBitmap32;
    FPropertyChanged: string;
    procedure SetPropertyChanged(const Value: string);
    procedure Render;
  protected
    procedure DrowAxis(ShowYlegend: boolean = True);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetVisible(Visible: Boolean); override;
    procedure SetClientRect(const Value: TRect); override;
    procedure ParamCollectionChanged; override;
    procedure ParamPropChanged; override;
    procedure ParentFontChanged; override;
    procedure Paint; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    property C_PropertyChanged: string read FPropertyChanged write SetPropertyChanged;
  end;


implementation

{$REGION 't o o l s'}
const
  CHECKBOX_SIZE = 10;

procedure DrawCheckBox(Bitmap: TBitmap32; Y: Integer; const Checked: Boolean);
 const
  DA: array[Boolean]of TThemedButton = (tbCheckBoxUncheckedNormal, tbCheckBoxCheckedNormal);
 var
  B: Vcl.Graphics.TBitmap;
  NonThemedCheckBoxState: Cardinal;
  R: TRect;
begin
  B := Vcl.Graphics.TBitmap.Create;
  try
    B.SetSize(CHECKBOX_SIZE, CHECKBOX_SIZE);
    R := Rect(0,0,CHECKBOX_SIZE,CHECKBOX_SIZE);
    if StyleServices.Enabled then
      StyleServices.DrawElement(B.Canvas.Handle, StyleServices.GetElementDetails(DA[Checked]), R)
    else
     begin
      B.Canvas.FillRect(R);
      NonThemedCheckBoxState := DFCS_BUTTONCHECK;
      if Checked then  NonThemedCheckBoxState := NonThemedCheckBoxState or DFCS_CHECKED;
      DrawFrameControl(B.Canvas.Handle, R, DFC_BUTTON, NonThemedCheckBoxState);
     end;
   Bitmap.Draw(TRect.Create(TPoint.Create(CHECKBOX_SIZE div 2, y-CHECKBOX_SIZE div 2), CHECKBOX_SIZE, CHECKBOX_SIZE), R, b.Canvas.Handle);
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
     ldsDot: Result := [1, 2];
     ldsDash: Result := [8, 2];
     ldsDashDot: Result := [8, 2, 1, 2];
     ldsDashDotDot: Result := [8, 2, 1, 2, 1, 2];
    end;
    for i := 0 to High(Result) do Result[i] := Result[i] {* FixedOne} * p.Width;
  end;
begin
  if p.DashStyle = ldsSolid then PolylineFS(Bitmap, points, p.Color, False, p.Width{ * FixedOne})
  else DashLineFS(Bitmap, points, GetDashes, p.Color, False, p.Width{ * FixedOne});
end;

{ TGR32Legend }

procedure TGR32LegendRow.DoVisibleChanged;
 var
  i: Integer;
begin
  inherited DoVisibleChanged;
  for i:= 0 to RegionsCount-1 do if Regions[i] is TGR32Region then TGR32Region(Regions[i]).SetVisible(Visible);
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
  if ColumnCollection is TGraphParams then for r in Regions do if r is TGR32Region then TGR32Region(r).ParamCollectionChanged;
end;

procedure TGR32GraphicCollumn.ColumnCollectionItemChanged(Item: TGraphCollectionItem);
 var
  r: TGraphRegion;
begin
 if Item is TGraphPar then for r in Regions do if r is TGR32Region then TGR32Region(r).ParamPropChanged;
end;
{$ENDREGION}

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

function TGR32GraphicLegend.GetCheckBoxRect(Par: TLineParam): TRect;
 var
  y: Integer;
  p: TGraphPar;
begin
  y := -Round(FRangeBar.Position);
  for p in Column.Params do if p = Par then Exit(TRect.Create(TPoint.Create(CHECKBOX_SIZE div 2, y + FBitmap.TextHeight(']') + 1 + par.Width div 2-CHECKBOX_SIZE div 2), CHECKBOX_SIZE, CHECKBOX_SIZE))
  else Inc(Y, GetPatamHeight(p));
end;

function TGR32GraphicLegend.GetPatamHeight(p: TGraphPar): Integer;
begin
  Result := FBitmap.TextHeight('[')*2;
  if p is TLineParam then Inc(Result, TLineParam(p).Width)
  else Inc(Result, 1);
end;

procedure TGR32GraphicLegend.OnScroll(Sender: TObject);
begin
  UpdateShowRect;
  Paint;
end;

procedure TGR32GraphicLegend.Paint;
begin
  if  Column.Visible and Row.Visible then FBitmap.DrawTo(Graph.Canvas.Handle, FCanvasShowRect, FBitmapShowRect);
end;

procedure TGR32GraphicLegend.ParamCollectionChanged;
begin
  UpdateRange;
  FRangeBar.SetParams(FRange, ClientRect.Height);
  FRangeBar.Visible := FRange > ClientRect.Height;
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
  for p in Column.Params do if not p.HideInLegend then
   begin
    if p is TStringParam then RenderStringPatam(Y, TStringParam(p))
    else if p is TLineParam then RenderLinePatam(Y, TLineParam(p))
    else if p is TWaveParam then RenderWavePatam(Y, TWaveParam(p));
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
  Fpp2mm := Screen.PixelsPerInch/2.54*2;
  s := FBitmap.TextExtent(p.Title);
  CaptionX := (FBitmap.Width - s.cx) div 2;
  if CaptionX < 0 then CaptionX := 0;
  // заголовок
  if p.EUnit <> '' then FBitmap.RenderText(CaptionX, y, p.Title + '['+ p.EUnit +']', 1, p.Color)
   else FBitmap.RenderText(CaptionX, y, p.Title, 1, p.Color);
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
    FBitmap.VertLineTS(Round(posX), ym, ym+8, p.Color);
    FBitmap.RenderText(Round(posX), ym, Format('%-10.5g', [AxisLabel]), 1, p.Color);
    posX := posX + Fpp2mm;
    AxisLabel := AxisLabel + 2.0/p.ScaleX;
    if Abs(AxisLabel) < 0.0000001 then AxisLabel := 0;
   end;
  // CheckBox
  DrawCheckBox(FBitmap, LineY, p.Visible);
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
  FBitmap.PenColor := p.Gamma;
  FBitmap.Textout(0, Y, p.Title);
end;

procedure TGR32GraphicLegend.SetClientRect(const Value: TRect);
begin
  inherited;
  FRangeBar.SetBounds(Value.Right - FRangeBar.Width, Value.Top, FRangeBar.Width, Value.Height);
  if FRange = 0 then UpdateRange;
  FRangeBar.SetParams(FRange, Value.Height);
  FRangeBar.Visible := FRange > Value.Height;
  UpdateShowRect;
  UpdateBitmapBaund;
  Render;
  if not Assigned(FRangeBar.Parent) then FRangeBar.Parent := Graph;
end;

procedure TGR32GraphicLegend.SetVisible(Visible: Boolean);
begin
  FRangeBar.Visible := Visible and (FRange > FBitmapShowRect.Height);
end;

procedure TGR32GraphicLegend.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
 var
  p: TGraphPar;
  clPoint, point: TPoint;
begin
  point := Tpoint.Create(X,Y);
  clPoint := MouseToClient(point);
  if TryHitParametr(point, p) and (p is TLineParam) and GetCheckBoxRect(TLineParam(p)).Contains(clPoint) then p.Visible := not p.Visible
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
    if (clPoint.Y > top) and (clPoint.Y < top+ht) then
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
  if FRange > FBitmapShowRect.Height then FBitmap.SetSize(FBitmapShowRect.Width, FRange)
  else FBitmap.SetSize(FBitmapShowRect.Width, FBitmapShowRect.Height)
end;

procedure TGR32GraphicLegend.UpdateRange;
 var
  p: TGraphPar;
begin
  FRange := 0;
  for p in Column.Params do if not p.HideInLegend then Inc(FRange, GetPatamHeight(p));
end;

procedure TGR32GraphicLegend.UpdateShowRect;
 var
  origin: TPoint;
begin
  FCanvasShowRect := ClientRect;
  if FRangeBar.Visible then FCanvasShowRect.Width := FCanvasShowRect.Width - FRangeBar.Width;
  FBitmapShowRect := FCanvasShowRect;
  origin.X := 0;
  origin.Y := 0;
  if FRangeBar.Position <= FRange - FBitmapShowRect.Height then origin.Y := Round(FRangeBar.Position)
  else if FRange - FBitmapShowRect.Height >= 0 then origin.Y := FRange - FBitmapShowRect.Height;
  FBitmapShowRect := TRect.Create(origin, FCanvasShowRect.Width, FCanvasShowRect.Height);
end;
{$ENDREGION}

{$REGION 'TGR32GraphicData'}

{ TGR32GraphicData }

constructor TGR32GraphicData.Create(Collection: TCollection);
begin
  inherited;
  FBitmap := TBitmap32.Create;
  TBindHelper.Bind(Self, 'C_PropertyChanged', Graph as IInterface, ['S_PropertyChanged']);
end;

destructor TGR32GraphicData.Destroy;
begin
  TBindHelper.RemoveExpressions(Self);
  FBitmap.Free;
  inherited;
end;

procedure TGR32GraphicData.DrowAxis(ShowYlegend: boolean);
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
  pp2mm := Screen.PixelsPerInch/2.54*2;
  if Graph.YMirror then m := -1 else m := 1;
  x := 0;
  while x < FBitmap.Width do FBitmap.VertLineTS(nextAxis(x), 0, FBitmap.Height, ACL_AXIS);
  ylb := Trunc(Graph.YTopScreen*Graph.YScale)/Graph.YScale;// ceil mirror ????
  y := m*YtoBitmap(ylb); { TODO : write function }
  while y < FBitmap.Height do
   begin
    FBitmap.HorzLineTS(0, Round(y), FBitmap.Width, ACL_AXIS);
    FBitmap.RenderText(0, Round(y), FloatToStr(SimpleRoundTo(Ylb, -4)), 1, ACL_AXIS_LABEL);
    ylb := ylb + m/Graph.YScale;
    Y := Y + pp2mm;
   end;
end;

procedure TGR32GraphicData.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TGR32GraphicData.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TGR32GraphicData.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

procedure TGR32GraphicData.Paint;
begin
  if Column.Visible and Row.Visible then FBitmap.DrawTo(Graph.Canvas.Handle, ClientRect, FBitmapShowRect);
end;

procedure TGR32GraphicData.ParamCollectionChanged;
begin

end;

procedure TGR32GraphicData.ParamPropChanged;
begin

end;

procedure TGR32GraphicData.ParentFontChanged;
begin
  inherited;

end;

procedure TGR32GraphicData.Render;
 var
  p: TGraphPar;
  Y: Integer;
begin
  FBitmap.FillRect(0, 0, FBitmap.Width, FBitmap.Height, clWhite32);
{  for p in Column.Params do if p.Visible then
   if p is TLineParam then
    begin
      p as IDataLink
    end;}
  DrowAxis;
end;

procedure TGR32GraphicData.SetClientRect(const Value: TRect);
begin
  inherited;
  FBitmap.SetSize(Value.Width, value.Height);
  FBitmapShowRect := FBitmap.BoundsRect;
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

procedure TGR32GraphicData.SetVisible(Visible: Boolean);
begin
  inherited;

end;

{$ENDREGION}

initialization
  TGraphRegion.RegClsRegister(TGR32GraphicLegend, TGR32LegendRow, TGR32GraphicCollumn);
  TGraphRegion.RegClsRegister(TGR32GraphicData, TCustomGraphData, TGR32GraphicCollumn);
  RegisterClasses([TGR32GraphicCollumn, TGR32GraphicLegend, TGR32GraphicData, TGR32LegendRow]);
end.
