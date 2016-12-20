unit VCL.Telesis.DecoderFFT_FSK;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
     VCL.ControlRootForm, VCL.Telesis.FrameFFT_FSK,

     Winapi.Windows, Winapi.Messages,
     System.SysUtils, System.Variants, System.Classes,
     Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFormDEcoderFFT_FSK = class(TControlRootForm<TTelesistemDecoder, ITelesistem>)
  private
    FFrameSP: TControlRootFrame<TTelesistemDecoder>;
  protected
    procedure DoData; override;
    procedure Loaded; override;
  public
    Frms: Tarray<TFrameFFT_FSK>;
  end;

implementation

{$R *.dfm}

uses VCL.Telesis.Decoder.FindSP;

{ TFormDEcoderFFT_FSK }

procedure TFormDEcoderFFT_FSK.DoData;
 var
  i: Integer;
begin
  if Length(Frms) = 0 then
   begin
    SetLength(Frms, C_Data.DataCnt);
    for i := 0 to C_Data.DataCnt-1 do
     begin
      Frms[i] := TFrameFFT_FSK.Create(Self);
      Frms[i].Parent := Self;
      Frms[i].Name := 'Frm' + i.ToString();
      Frms[i].Fdata := TFSKDecoderFFT(C_Data);
     end;
   end;

  case C_Data.State of
   csFindSP:
    begin
     for i := 0 to C_Data.DataCnt-1 do Frms[i].Visible := False;
     FFrameSP.Show;
     FFrameSP.DoData(C_Data);
    end;
   csSP,csCode, csCheckSP:
    begin
     for i := 0 to C_Data.DataCnt-1 do Frms[i].Visible := True;
     Frms[C_Data.Codes.CodeCnt].ShowData;
     FFrameSP.Hide;
     TFrameFindSP(FFrameSP).SeriesCorr.Clear;
    end;
    csUserToFindSP:
  end;
end;

procedure TFormDEcoderFFT_FSK.Loaded;
begin
  inherited;
  FFrameSP := TFrameFindSP.Create(Self);
  FFrameSP.Show;
end;

initialization
  RegisterClass(TFormDEcoderFFT_FSK);
  TRegister.AddType<TFormDEcoderFFT_FSK, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormDEcoderFFT_FSK>;
end.
