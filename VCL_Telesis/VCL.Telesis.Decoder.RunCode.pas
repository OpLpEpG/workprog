unit VCL.Telesis.Decoder.RunCode;

interface

uses VCL.ControlRootForm, Math.Telesistem,
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
    procedure ChartAfterDraw(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
    Fdata: TTelesistemDecoder;
    statCnt, statBad: Integer;
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
      SeriesCode.Clear;
      SeriesCode.AddArray(CodData[CodeCnt-1].Corr);
      if Data is TFibonachiDecoder then
       begin
        SeriesPorog.Clear;
        SeriesPorog.AddXY(0, TFibonachiDecoder(Data).PorogAmpCod);
        SeriesPorog.AddXY(ChartCode.BottomAxis.Maximum, TFibonachiDecoder(Data).PorogAmpCod);
       end
     else if Data is TFSKDecoder then
       begin
        SeriesPorog.Clear;
        SeriesPorog.AddXY(0, TFSKDecoder(Data).PorogAmpCod);
        SeriesPorog.AddXY(ChartCode.BottomAxis.Maximum, TFSKDecoder(Data).PorogAmpCod);
       end;
      Memo.Lines.Add(Format('%5d %5d %5d %15.0f',[CodeCnt, BadCodes, CodData[CodeCnt-1].Code, CodData[CodeCnt-1].Porog]));
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

procedure TFormRunCodes.N1Click(Sender: TObject);
begin
  if Assigned(FData) then FData.State := csUserToFindSP;
end;

procedure TFormRunCodes.N2Click(Sender: TObject);
begin
  statCnt := 0;
  statBad := 0;
end;

end.
