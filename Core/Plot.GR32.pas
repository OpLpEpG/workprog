unit Plot.GR32;

interface

uses System.SysUtils, System.Classes, System.Types,
     Vcl.Forms,
     GR32, GR32_Image, GR32_RangeBars, GR32_Blend,
     RootImpl, RootIntf, tools, debug_except, CustomPlot;

type
  TGR32GraphicCollumn = class(TPlotColumn)
  protected
    procedure ColumnCollectionChanged(ColumnCollection: TPlotCollection); override;
    procedure ColumnCollectionItemChanged(Item: TPlotCollectionItem); override;
  end;

  TGR32Legend = class(TCustomPlotLegend)
  protected
    procedure DoVisibleChanged; override;
  end;

  TGR32Region = class(TPlotRegion)
  protected
    procedure SetVisible(Visible: Boolean); virtual;
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
    function GetPatamHeight(p: TPlotParam): Integer;
    procedure RenderLinePatam(Y: Integer; p: TLineParam);
    procedure RenderWavePatam(Y: Integer; p: TWaveParam);
    procedure RenderStringPatam(Y: Integer; p: TStringParam);
  protected
    procedure SetVisible(Visible: Boolean); override;
    procedure ParamChanged;
    procedure ParamPropChanged;
    procedure ParentFontChanged; override;
    procedure Paint; override;
    procedure SetClientRect(const Value: TRect); override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  end;

implementation

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

function TGR32GraphicLegend.GetPatamHeight(p: TPlotParam): Integer;
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
  if Column.Visible and Row.Visible then FBitmap.DrawTo(Plot.CanvasHandle, FCanvasShowRect, FBitmapShowRect);
end;

procedure TGR32GraphicLegend.ParamChanged;
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
  ParamChanged;
end;

procedure TGR32GraphicLegend.ParentFontChanged;
begin
  FBitmap.Font := Plot.Font;
  UpdateRange;
  Render;
  //Paint//?
end;

procedure TGR32GraphicLegend.Render;
 var
  p: TPlotParam;
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
  i: Integer;
  x: Integer;
  s: Tsize;
begin
//  FBitmap.Font.Color := p.Color;
  s := FBitmap.TextExtent(p.Title);
  x := (FBitmap.Width - s.cx) div 2;
  if x < 0 then x := 0;
  FBitmap.RenderText(x, y, p.Title, 1, p.Color);
  for i := 0 to p.Width do FBitmap.HorzLineTS(0, y+s.cy+i+1, FBitmap.Width, p.Color);
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
  if not Assigned(FRangeBar.Parent) then FRangeBar.Parent := Plot;
end;

procedure TGR32GraphicLegend.SetVisible(Visible: Boolean);
begin
  FRangeBar.Visible := Visible and (FRange > FBitmapShowRect.Height);
end;

procedure TGR32GraphicLegend.UpdateBitmapBaund;
begin
  if FRange > FBitmapShowRect.Height then FBitmap.SetSize(FBitmapShowRect.Width, FRange)
  else FBitmap.SetSize(FBitmapShowRect.Width, FBitmapShowRect.Height)
end;

procedure TGR32GraphicLegend.UpdateRange;
 var
  p: TPlotParam;
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

{ TGR32Legend }

procedure TGR32Legend.DoVisibleChanged;
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

procedure TGR32GraphicCollumn.ColumnCollectionChanged(ColumnCollection: TPlotCollection);
 var
  r: TPlotRegion;
begin
  if ColumnCollection is TPlotParams then for r in Regions do if r is TGR32GraphicLegend then TGR32GraphicLegend(r).ParamChanged;
end;

procedure TGR32GraphicCollumn.ColumnCollectionItemChanged(Item: TPlotCollectionItem);
 var
  r: TPlotRegion;
begin
  for r in Regions do if r is TGR32GraphicLegend then TGR32GraphicLegend(r).ParamPropChanged;
end;

initialization
  TPlotRegion.RegClsRegister(TGR32GraphicLegend, TGR32Legend, TGR32GraphicCollumn);
  RegisterClasses([TGR32GraphicCollumn, TGR32GraphicLegend, TGR32Legend]);
end.
