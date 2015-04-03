unit VCL.Telesis.Decoder.RunCode;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
  VCL.ControlRootForm,  VCL.Telesis.Decoder,  MathIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls, Vcl.Menus;

type
  TFormRunCodes = class(TControlRootFrame<TTelesistemDecoder>)
    Chart: TChart;
    ChartCode: TChart;
    Panel: TPanel;
    Splitter1: TSplitter;
    Memo: TMemo;
    Splitter2: TSplitter;
    SeriesCode: TBarSeries;
    SeriesSP: TBarSeries;
    SeriesPorog: TFastLineSeries;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    srSignal: TFastLineSeries;
    srNoise: TFastLineSeries;
    srData: TFastLineSeries;
    srMul: TFastLineSeries;
    srBit: TFastLineSeries;
    srZerro: TFastLineSeries;
    N3: TMenuItem;
    NPause: TMenuItem;
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
    procedure ChartAfterDraw(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure NPauseClick(Sender: TObject);
    procedure NDataClick(Sender: TObject);
  private
    Fdata: TTelesistemDecoder;
    statCnt, statBad: Integer;
    function Root: TDecoderECHOForm; inline;
    procedure ShowData(idx, CurCode: Integer);
  public
    procedure DoData(Data: TTelesistemDecoder); override;
  end;

implementation

{$R *.dfm}


{ TFrame1 }

procedure TFormRunCodes.ChartAfterDraw(Sender: TObject);
 const
  FMTT = '%4d:%7.0f';
 var
  s: string;
begin
  if not Assigned(FData) or (statCnt = 0) then Exit;
  ChartCode.Canvas.Font.Name := 'Courier';
  s := Format(FMTT, [statCnt, statBad/statCnt*100]);
  ChartCode.Canvas.TextOut(ChartCode.ClientWidth - ChartCode.Canvas.TextWidth(s), 0, s);
//    s := Format(FMTT, [Max2Index, Max2]);
//    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.Canvas.TextHeight(s), s);
//
//    s := Format(FMTT, [Min2Index, Min2]);
//    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.BottomAxis.PosAxis - Chart.Canvas.TextHeight(s)*2, s);
//    s := Format(FMTT, [Min1Index, Min1]);
//    Chart.Canvas.TextOut(Chart.ClientWidth - Chart.Canvas.TextWidth(s), Chart.BottomAxis.PosAxis - Chart.Canvas.TextHeight(s), s);
end;


procedure TFormRunCodes.DoData(Data: TTelesistemDecoder);
 const
  STRSTATE: array[TCorrelatorState] of string =('csFindSP', 'csSP', 'csCode', 'csCheckSP', 'csBadCodes', 'csUserToFindSP', 'csUserToSP');
  procedure ShowSrs(const y: PdoubleArray; s: TFastLineSeries);
   var
    i: Integer;
  begin
    for i := 0 to data.DataLen - 1 do s.Add(y[i])
  end;
 var
  i: Integer;
begin
  FData :=  Data;
  Memo.Lines.Add(STRSTATE[Data.State]);

  case Data.State of
    csFindSP: ;
    csSP: with Data.SPData, Data.SPIndex do
     begin
      Memo.Clear;
      Memo.Lines.Add(Format('%5d %5d %15.1f %15.0f',[Faza, Idx, Amp, Porog]));
      SeriesSP.Clear;
      SeriesSP.AddArray(Corr);
     end;
    csCode: with Data.Codes do
     begin
      if CodeCnt <> 1 then if {CodeCnt-1} 2090 <> CodData[CodeCnt-1].Code then inc(statBad);
      Inc(statCnt);

      for i := 0 to ChartCode.SeriesCount-1 do  ChartCode.Series[i].Clear;

      for i := 0 to Length(CodData[CodeCnt-1].CodBuf[bftcorr])-1 do SeriesCode.AddXY(i* Data.Bits, CodData[CodeCnt-1].CodBuf[bftcorr][i]);
    // SeriesCode.AddArray(CodData[CodeCnt-1].Corr);

      if Root.UsoReady then ShowSrs(data.IndexBuffer(Root.C_Uso.Fifo), srSignal);
      if Root.NoiseReady then ShowSrs(data.IndexBuffer(Root.C_Noise.FifoFShum), srNoise);
      if Root.fftReady then ShowSrs(data.IndexBuffer(Root.C_fft.FifoData), srData);

      srMul.AddArray(CodData[CodeCnt-1].CodBuf[bftMul]);
      srBit.AddArray(CodData[CodeCnt-1].CodBuf[bftBit]);
      srZerro.AddArray(CodData[CodeCnt-1].CodBuf[bftZerro]);


      if Data is TFibonachiDecoder then
       begin
        SeriesPorog.AddXY(0, TFibonachiDecoder(Data).PorogAmpCod);
        SeriesPorog.AddXY(ChartCode.BottomAxis.Maximum, TFibonachiDecoder(Data).PorogAmpCod);
       end
      else if Data is TFSKDecoder then
       begin
        SeriesPorog.AddXY(0, TFSKDecoder(Data).PorogAmpCod);
        SeriesPorog.AddXY(ChartCode.BottomAxis.Maximum, TFSKDecoder(Data).PorogAmpCod);
       end;
      if CodeCnt in [1,6,11] then Memo.Lines.Add(Format('%5d %5d %5d %15.0f',[CodeCnt, BadCodes, CodData[CodeCnt-1].Code, CodData[CodeCnt-1].Porog]))
      else Memo.Lines.Add(Format('%5d %5d %5d %15.0f',[CodeCnt, BadCodes, CodData[CodeCnt-1].Code-1292, CodData[CodeCnt-1].Porog]))
     end;
    csCheckSP: with Data.SPData, Data.CheckSPIndex do
     begin
      Memo.Clear;
      SeriesSP.Clear;
      SeriesSP.AddArray(Corr);
      Memo.Lines.Add(Format('%5d %5d %15.1f %15.0f',[Fazanew, Dkadr, Amp, Porog]));
     end;
    csBadCodes: ;
    csUserToFindSP: ;
    csUserToSP: ;
  end;

//  if Data.KadrLen <> Chart.BottomAxis.Maximum then  Chart.BottomAxis.Maximum := Data.KadrLen;
//  if SeriesCorr.Count >= Data.KadrLen then SeriesCorr.Clear;
//  for d in Data.FindSpData.Corr do SeriesCorr.Add(d);
//  SeriesSP.Clear;
//  with Fdata.FindSPData do
//   begin
//    SeriesSP.AddNullXY(Max1Index, 0);
//    SeriesSP.AddXY(Max1Index, 0);
//    SeriesSP.AddXY(Max1Index, Max1, '', clRed);
//    SeriesSP.AddNullXY(Max2Index, 0);
//    SeriesSP.AddXY(Max2Index, 0);
//    SeriesSP.AddXY(Max2Index, Max2, '', clMaroon);
//    SeriesSP.AddNullXY(Min1Index, 0);
//    SeriesSP.AddXY(Min1Index, 0);
//    SeriesSP.AddXY(Min1Index, Min1, '', clBlue);
//    SeriesSP.AddNullXY(Min2Index, 0);
//    SeriesSP.AddXY(Min2Index, 0);
//    SeriesSP.AddXY(Min2Index, Min2, '', clNavy);
//   end;
end;

procedure TFormRunCodes.NDataClick(Sender: TObject);
begin
  if Assigned(FData) and (TMenuItem(Sender).Tag <= FData.Codes.CodeCnt) then ShowData(TMenuItem(Sender).Tag-1, FData.Codes.CodeCnt-1);
end;

procedure TFormRunCodes.N1Click(Sender: TObject);
begin
  if Assigned(FData) then FData.State := csUserToFindSP;
end;

procedure TFormRunCodes.N2Click(Sender: TObject);
begin
  statCnt := 0;
  statBad := 0;
end;

procedure TFormRunCodes.NPauseClick(Sender: TObject);
begin
  Root.S_Pause := NPause.Checked;
end;

function TFormRunCodes.Root: TDecoderECHOForm;
begin
  Result := TDecoderECHOForm(Owner);
end;

procedure TFormRunCodes.ShowData(idx, CurCode: Integer);
  procedure ShowSrs(y: PdoubleArray; s: TFastLineSeries);
   var
    i, d: Integer;
  begin
    Dec(Pdouble(y), (CurCode - idx +1) * Fdata.DataLen);
    for i := 0 to Fdata.DataLen - 1 do s.Add(y[i])
  end;
 var
  i: Integer;
begin
  with FData.Codes do
     begin
      for i := 0 to ChartCode.SeriesCount-1 do  ChartCode.Series[i].Clear;

      for i := 0 to Length(CodData[idx].CodBuf[bftcorr])-1 do SeriesCode.AddXY(i* FData.Bits, CodData[idx].CodBuf[bftcorr][i]);
    // SeriesCode.AddArray(CodData[CodeCnt-1].Corr);

      if Root.UsoReady then ShowSrs(Fdata.IndexBuffer(Root.C_Uso.Fifo), srSignal);
      if Root.NoiseReady then ShowSrs(Fdata.IndexBuffer(Root.C_Noise.FifoFShum), srNoise);
      if Root.fftReady then ShowSrs(Fdata.IndexBuffer(Root.C_fft.FifoData), srData);

      srMul.AddArray(CodData[idx].CodBuf[bftMul]);
      srBit.AddArray(CodData[idx].CodBuf[bftBit]);
      srZerro.AddArray(CodData[idx].CodBuf[bftZerro]);
     end;
end;

end.
