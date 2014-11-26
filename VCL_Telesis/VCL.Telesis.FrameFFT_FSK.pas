unit VCL.Telesis.FrameFFT_FSK;

interface

uses  Math.Telesistem, DeviceIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCLTee.Series, VCLTee.TeEngine, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.Menus;

type
  TFrameFFT_FSK = class(TFrame)
    Splitter: TSplitter;
    Chart: TChart;
    scFFT: TAreaSeries;
    scFlt: TAreaSeries;
    ChartT: TChart;
    csInData: TFastLineSeries;
    scOut: TFastLineSeries;
    csBit: TFastLineSeries;
    csOI: TFastLineSeries;
    PopupMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
  private
  public
    Fdata: TFSKDecoderFFT;
    procedure ShowData;
  end;

implementation

{$R *.dfm}

uses VCL.Telesis.DecoderFFT_FSK;

procedure TFrameFFT_FSK.N1Click(Sender: TObject);
begin
  if Assigned(FData) then FData.State := csUserToFindSP;
end;

procedure TFrameFFT_FSK.N2Click(Sender: TObject);
begin
//
end;

procedure TFrameFFT_FSK.N3Click(Sender: TObject);
 var
  s: string;
  i: Integer;
begin
  s := Height.ToString();
  if Vcl.Dialogs.InputQuery('input height', 'input new', s) then
   begin
    Height := s.ToInteger();
    for i := 0 to Length(TFormDEcoderFFT_FSK(Owner).Frms)-1 do TFormDEcoderFFT_FSK(Owner).Frms[i].Height := Height;
   end;
end;

procedure TFrameFFT_FSK.ShowData;
  var
   d: TFFTData;
begin
  scFFT.Clear;
  scFlt.Clear;
  d := FData.Data;
  Inc(d.FF);
  Inc(d.FFFiltered);
  Dec(d.FFTSize);
//  All := 0;
//  Signal := 0;
  while d.FFTSize > 0 do
   begin
    scFFT.Add(d.FF^);
    scFlt.Add(d.FFFiltered^);
//    all := All + d.FF^;
//    Signal := Signal + d.FFFiltered^;
    Inc(d.FF);
    Inc(d.FFFiltered);
    Dec(d.FFTSize);
   end;
  csInData.Clear;
  scOut.Clear;
  while d.SampleSize > 0 do
   begin
    csInData.Add(d.InData^);
    scOut.Add(d.OutData^);
    Inc(d.InData);
    Inc(d.OutData);
    Dec(d.SampleSize);
   end;
end;

end.
