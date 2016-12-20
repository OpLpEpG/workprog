unit VCL.Decoder.Frame1;

interface

uses  DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
     VCL.ControlRootForm, Math.Telesistem.Custom,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeEngine,
  VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrameDecoderStamdart = class(TDecoderFrame)
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
    SeriesCode: TBarSeries;
    SeriesPorog: TFastLineSeries;
    srSignal: TFastLineSeries;
    srNoise: TFastLineSeries;
    srData: TFastLineSeries;
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
    MenuItem3: TMenuItem;
    N4: TMenuItem;
    N11: TMenuItem;
    N21: TMenuItem;
    N31: TMenuItem;
    N41: TMenuItem;
    N51: TMenuItem;
    N61: TMenuItem;
    N71: TMenuItem;
    N81: TMenuItem;
    N91: TMenuItem;
    N101: TMenuItem;
    N111: TMenuItem;
    N121: TMenuItem;
    N131: TMenuItem;
    N141: TMenuItem;
    N151: TMenuItem;
    N161: TMenuItem;
    procedure N1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
  private
  protected
    procedure SetDecoder(const Value: TCustomDecoder); override;
    class function DecoderClassName: string; override;
  public
    procedure DoData(Data: TCustomDecoder); override;
  end;

implementation

{$R *.dfm}

{ TFrame2 }

class function TFrameDecoderStamdart.DecoderClassName: string;
begin
  Result := 'TCustomDecoder';
end;

procedure TFrameDecoderStamdart.DoData(Data: TCustomDecoder);
  procedure AddVertLine(const p: TBufPoint; color: TColor);
  begin
    SeriesSP.AddNullXY(p.idx, 0);
    SeriesSP.AddXY(p.idx, 0);
    SeriesSP.AddXY(p.idx, p.dat, '', color);
  end;
begin
  if NPause.Checked then Exit;
  case Data.State of
    // поиск СП
    csFindSP:
     begin
      PanelFindSP.BringToFront;
      SeriesCorr.BeginUpdate;
      SeriesSP.BeginUpdate;
      try
       SeriesCorr.Clear;
       SeriesCorr.AddArray(Data.FindSp.Corr.Data);
      with Data.FindSP do
       begin
        SeriesSP.Clear;
        AddVertLine(Max1, clred);
        AddVertLine(Max2, clMaroon);
        AddVertLine(Min1, clBlue);
        AddVertLine(Min2, clNavy);
       end;
      finally
       SeriesCorr.EndUpdate;
       SeriesSP.EndUpdate;
      end;
     end;
    // поиск СП окончен найдено СП
    csSP: with Data.SPData do
     begin
      PanelCOD.BringToFront;
      Memo.Clear;
      Memo.Lines.Add(Format('SP Faza: %5d Idx: %5d', [FazaFind, Corr.FirstIdx]));
      Memo.Lines.Add(Format('SP  Amp: %5.1f Qua: %5.0f', [sp.dat, Quality]));
      BarSeriesSP.Clear;
      BarSeriesSP.AddArray(Corr.Data);
     end;
    csCode:
     begin

     end;
    csCheckSP:
     begin

     end;
    csBadCodes:
     begin

     end;
    csUserToFindSP:
     begin

     end;
    csUserToSP:
    begin

    end;
  end;
end;

procedure TFrameDecoderStamdart.MenuItem1Click(Sender: TObject);
begin
  Decoder.State := csUserToFindSP;
end;

procedure TFrameDecoderStamdart.N1Click(Sender: TObject);
begin
  Decoder.State := csUserToSP;
end;

procedure TFrameDecoderStamdart.SetDecoder(const Value: TCustomDecoder);
begin
  inherited;
  if Value.KadrLen <> ChartSP.BottomAxis.Maximum then ChartSP.BottomAxis.Maximum := Value.KadrLen;
end;

initialization
  RegisterClass(TFrameDecoderStamdart);
  TFrameDecoderStamdart.RegisterSelfClass;
end.
