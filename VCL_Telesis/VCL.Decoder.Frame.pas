unit VCL.Decoder.Frame;

interface

uses
  DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, IndexBuffer,
  Math.Telesistem, VCL.ControlRootForm, Math.Telesistem.Custom, Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrameDecoderStandart = class(TDecoderFrame)
    PanelFindSP: TPanel;
    ChartSP: TChart;
    SeriesSP: TLineSeries;
    SeriesCorr: TFastLineSeries;
    PanelCOD: TPanel;
    Splitter2: TSplitter;
    Panel: TPanel;
    Splitter1: TSplitter;
    Chart: TChart;
    BarSeriesSP: TBarSeries;
    ChartCode: TChart;
    srCorr: TBarSeries;
    srPorog: TFastLineSeries;
    srData: TFastLineSeries;
    srNoise: TFastLineSeries;
    srSignalShum: TFastLineSeries;
    srMul: TFastLineSeries;
    srBit: TFastLineSeries;
    srZerro: TFastLineSeries;
    Memo: TMemo;
    PopupMenuSP: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    NPause: TMenuItem;
    PopupMenu: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    N3: TMenuItem;
    NPauseCode: TMenuItem;
    NShowCode: TMenuItem;
    NLegend: TMenuItem;
    N6: TMenuItem;
    procedure N1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure NLegendClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure ChartSPAfterDraw(Sender: TObject);
  private
    FStdSeries: array [TBufferType] of TChartSeries;
    FUpdateCodeSeries: Boolean;
    function GetMemoWidth: Integer;
    procedure SetMemoWidth(const Value: Integer);
    function GetChartW: Integer;
    procedure SetChartW(const Value: Integer);
    function GetShowLegend: Boolean;
    procedure SetShowLegend(const Value: Boolean);
    procedure UpdateCodeSeries(const c: TCodeData);
    procedure ShowCode(const c: TCodeData);
    procedure ShowCodeClick(Sender: TObject);
  protected
    procedure AddVertLine(const p: TBufPoint; color: TColor); overload;
    procedure AddVertLine(x: Integer; color: TColor); overload;
    procedure AddGorizLine(x1,x2, y: Integer; color: TColor);
    procedure SetDecoder(const Value: TCustomDecoder); override;
    class function DecoderClassName: string; override;
    procedure DoPaintCorr(Data: TCustomDecoder); virtual;
    procedure Loaded; override;
  public
    procedure DoData(Data: TCustomDecoder); override;
  published
    property MemoWidth: Integer read GetMemoWidth write SetMemoWidth;
    property ChartWidth: Integer read GetChartW write SetChartW;
    property ShowLegend: Boolean read GetShowLegend write SetShowLegend;
  end;

  TFrameDecoderWindow = class(TFrameDecoderStandart)
  protected
    procedure DoPaintCorr(Data: TCustomDecoder); override;
    class function DecoderClassName: string; override;
  end;

implementation

{$R *.dfm}

{ TFrame2 }

procedure TFrameDecoderStandart.ChartSPAfterDraw(Sender: TObject);
 const
  FMTT = '%4d:%7.1f';
 var
  s: string;
begin
  if not Assigned(Decoder) and NPause.Checked then Exit;
  ChartSP.Canvas.Font.Name := 'Courier';

  with Decoder.FindSP, ChartSP, ChartSP.Canvas do
   begin
    s := Format(FMTT, [Max1.idx, Max1.dat]);
    TextOut(ClientWidth - TextWidth(s), 0, s);
    s := Format(FMTT, [Max2.idx, Max2.dat]);
    TextOut(ClientWidth - TextWidth(s), TextHeight(s), s);

    s := Format(FMTT, [Min2.idx, Min2.dat]);
    Canvas.TextOut(ClientWidth - TextWidth(s), BottomAxis.PosAxis - TextHeight(s)*2, s);
    s := Format(FMTT, [Min1.idx, Min1.dat]);
    Canvas.TextOut(ClientWidth - TextWidth(s), BottomAxis.PosAxis - TextHeight(s), s);
   end;
end;

class function TFrameDecoderStandart.DecoderClassName: string;
begin
  Result := 'TCustomDecoder';
end;

procedure TFrameDecoderStandart.AddGorizLine(x1, x2, y: Integer; color: TColor);
begin
  SeriesSP.AddNullXY(x1, y);
  SeriesSP.AddXY(x1, y);
  SeriesSP.AddXY(x2, y, '', color);
  SeriesSP.AddNullXY(x2, y);
end;

procedure TFrameDecoderStandart.AddVertLine(x: Integer; color: TColor);
begin
  SeriesSP.AddNullXY(x, ChartSP.LeftAxis.Minimum);
  SeriesSP.AddXY(x, ChartSP.LeftAxis.Minimum);
  SeriesSP.AddXY(x, ChartSP.LeftAxis.Maximum, '', color);
end;

procedure TFrameDecoderStandart.AddVertLine(const p: TBufPoint; color: TColor);
begin
  SeriesSP.AddNullXY(p.idx, 0);
  SeriesSP.AddXY(p.idx, 0);
  SeriesSP.AddXY(p.idx, p.dat, '', color);
end;

procedure TFrameDecoderStandart.DoData(Data: TCustomDecoder);
 const
  BL: array[Boolean] of string = (' ', 'B');
begin
  if NPause.Checked then
    Exit;
  case Data.State of
    // поиск СП
    csFindSP:
      begin
        if not NPauseCode.Checked then PanelFindSP.BringToFront;
        SeriesCorr.BeginUpdate;
        SeriesSP.BeginUpdate;
        try
          SeriesCorr.Clear;
          SeriesSP.Clear;
          DoPaintCorr(Data);
        finally
          SeriesCorr.EndUpdate;
          SeriesSP.EndUpdate;
        end;
      end;
    // поиск СП окончен найдено СП
    csSP,
    // проверка сп
    csCheckSP:
      with Data.SPData do
      begin
        if not NPause.Checked then PanelCOD.BringToFront;
        //Memo.Clear;
        Memo.Lines.Add(Format('SP  FzFn: %5d Idx: %5d', [FazaFind, Corr.FirstIdx]));
        if FazaCheck <> 0 then
        Memo.Lines.Add(Format('CSP FzCh: %5d  dT: %5d', [FazaCheck, Dtakt]));
        Memo.Lines.Add(Format('SP   Amp: %5.1f Qua: %5.0f', [sp.dat, Quality]));
        BarSeriesSP.Clear;
        BarSeriesSP.AddArray(Corr.Data);
      end;
    csCode:
      begin
        if not NPause.Checked then PanelCOD.BringToFront;
        if Data.Codes.Count > 0 then
          with Data.Codes do
          begin
           Memo.Lines.Add(Format('CD %5d %s =%5x Q=%5.0f', [Count, BL[curr.IsBad], curr.Code, Curr.Quality]));
           UpdateCodeSeries(Curr);
           if not NPauseCode.Checked then ShowCode(Curr);
          end;
      end;
    csBadCodes:
      begin
        Memo.Lines.Add(Format('BADCODES =%d', [Data.Codes.BadCodes]));
      end;
    csUserToFindSP:
      begin
        Memo.Lines.Add('Принкдительно  сброс СП');
      end;
    csUserToSP:
      begin
        Memo.Lines.Add('Принкдительно СП');
      end;
  end;
end;

procedure TFrameDecoderStandart.DoPaintCorr(Data: TCustomDecoder);
begin
  SeriesCorr.AddArray(Data.FindSp.Corr.Data);
  with Data.FindSP do
  begin
    AddVertLine(Max1, clred);
    AddVertLine(Max2, clMaroon);
    AddVertLine(Min1, clBlue);
    AddVertLine(Min2, clNavy);
  end;
end;

function TFrameDecoderStandart.GetChartW: Integer;
begin
  Result := Chart.Height;
end;

function TFrameDecoderStandart.GetMemoWidth: Integer;
begin
  Result := Memo.Width;
end;

function TFrameDecoderStandart.GetShowLegend: Boolean;
begin
  Result := ChartCode.Legend.Visible;
end;

procedure TFrameDecoderStandart.Loaded;
begin
  inherited;
  FStdSeries[bftData] := srData;
  FStdSeries[bftBit] := srBit;
  FStdSeries[bftCorr] := srCorr;
  FStdSeries[bftMul] := srMul;
  FStdSeries[bftZerro] := srZerro;
  FStdSeries[bftSigShum] := srSignalShum;
  FStdSeries[bftNoise] := srNoise;
  FStdSeries[bftPorog] := srPorog;
end;

procedure TFrameDecoderStandart.SetMemoWidth(const Value: Integer);
begin
  Memo.Width := Value;
end;

procedure TFrameDecoderStandart.SetShowLegend(const Value: Boolean);
begin
  ChartCode.Legend.Visible := Value;
  NLegend.Checked := Value;
end;

procedure TFrameDecoderStandart.ShowCode(const c: TCodeData);
 var
  bt: TBufferType;
  i: Integer;
begin
  for i := 0 to ChartCode.SeriesCount-1 do ChartCode.Series[i].BeginUpdate;
  for i := 0 to ChartCode.SeriesCount-1 do ChartCode.Series[i].Clear;
  try
   for bt in c.BufferType do FStdSeries[bt].AddArray(c.Buf[bt].Data);
  finally
   for i := 0 to ChartCode.SeriesCount-1 do  ChartCode.Series[i].EndUpdate;
  end;
end;

procedure TFrameDecoderStandart.ShowCodeClick(Sender: TObject);
begin
  if Assigned(Decoder) and (TMenuItem(Sender).Tag < Decoder.Codes.Count) then
  begin
   NPauseCode.Checked := True;
   ShowCode(Decoder.Codes.CodData[TMenuItem(Sender).Tag]);
  end;
end;

procedure TFrameDecoderStandart.UpdateCodeSeries(const c: TCodeData);
 var
  bt: TBufferType;
  i: Integer;
begin
  if not FUpdateCodeSeries then Exit;
  ///update series
  for bt in c.BufferType do
   begin
    FStdSeries[bt].ShowInLegend := True;
    FStdSeries[bt].Visible := True;
   end;
  FUpdateCodeSeries := False;
end;

procedure TFrameDecoderStandart.MenuItem1Click(Sender: TObject);
begin
  PanelFindSP.BringToFront;
  Decoder.State := csUserToFindSP;
end;

procedure TFrameDecoderStandart.N1Click(Sender: TObject);
begin
  PanelCOD.BringToFront;
  Decoder.State := csUserToSP;
end;

procedure TFrameDecoderStandart.NLegendClick(Sender: TObject);
begin
  ChartCode.Legend.Visible := NLegend.Checked;
end;

procedure TFrameDecoderStandart.N6Click(Sender: TObject);
begin
  Memo.Clear;
end;

procedure TFrameDecoderStandart.SetChartW(const Value: Integer);
begin
  Chart.Height := Value;
end;

procedure TFrameDecoderStandart.SetDecoder(const Value: TCustomDecoder);
 var
  i: Integer;
  m: TMenuItem;
begin
  inherited;
  PanelFindSP.BringToFront;
  if Value.KadrLen <> ChartSP.BottomAxis.Maximum then ChartSP.BottomAxis.Maximum := Value.KadrLen;
  ///update series
  FUpdateCodeSeries := True;
  for i := 0 to ChartCode.SeriesCount-1 do
   begin
    ChartCode.Series[i].Visible := False;
    ChartCode.Series[i].ShowInLegend := False;
   end;
  ///update code menu
  NShowCode.Clear;
  for I := 0 to Value.DataCnt-1 do
   begin
    m := TMenuItem.Create(NShowCode);
    m.Name := 'ShowCode' + i.ToString();
    m.Tag := i;
    m.Caption := 'Показать ' + (i+1).ToString();
    m.OnClick := ShowCodeClick;
    NShowCode.Add(m);
   end;
end;

{ TFrameDecoderWindow }

class function TFrameDecoderWindow.DecoderClassName: string;
begin
  Result := 'TWindowDecoder';
end;

procedure TFrameDecoderWindow.DoPaintCorr(Data: TCustomDecoder);
 var
  l: LocIdx;
  p:TBufPoint;
begin
  inherited;
  with TWindowDecoder(Data) do
   begin
    l := FindSP.Corr.Local(SPWindow);
    if (l >= 0) and  (l < KadrLen) then
     begin
      ChartSP.LeftAxis.AdjustMaxMin;
      AddVertLine((KadrLen+l-SPDeltaBit*BitLen)mod KadrLen, clYellow);
      AddVertLine((KadrLen+l+SPDeltaBit*BitLen)mod KadrLen, clYellow);
     // AddGorizLine(l-SPDeltaBit*BitLen, l+SPDeltaBit*BitLen,0, clYellow);
     end;
   end;
end;

initialization
  RegisterClasses([TFrameDecoderStandart, TFrameDecoderWindow]);
  TFrameDecoderStandart.RegisterSelfClass;
  TFrameDecoderWindow.RegisterSelfClass;
end.


