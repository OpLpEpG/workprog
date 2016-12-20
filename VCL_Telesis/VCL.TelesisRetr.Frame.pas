unit VCL.TelesisRetr.Frame;

interface

uses  DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
     VCL.ControlRootForm, Math.Telesistem.Custom,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, VCLTee.Series, Vcl.StdCtrls, VCLTee.TeEngine, VCLTee.TeeProcs,
  VCLTee.Chart, Vcl.ExtCtrls;

type
  TFrame2 = class(TDecoderFrame)
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
    PanelFindSP: TPanel;
    ChartSP: TChart;
    SeriesSP: TLineSeries;
    SeriesCorr: TFastLineSeries;
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
    PopupMenuSP: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    NPause: TMenuItem;
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

class function TFrame2.DecoderClassName: string;
begin

end;

procedure TFrame2.DoData(Data: TCustomDecoder);
begin
  inherited;

end;

procedure TFrame2.MenuItem1Click(Sender: TObject);
begin
//
end;

procedure TFrame2.N1Click(Sender: TObject);
begin
//
end;

procedure TFrame2.SetDecoder(const Value: TCustomDecoder);
begin
  inherited;

end;

end.
