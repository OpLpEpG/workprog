unit VCL.Telesis.Decoder;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
     VCL.ControlRootForm,
     System.Bindings.Helper,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TDecoderECHOForm = class(TControlRootForm<TTelesistemDecoder, ITelesistem>)
  private
    FFrameSP, FFrameCod: TControlRootFrame<TTelesistemDecoder>;
    FC_Noise: TFFTData;
    FC_fft: TFFTData;
    FC_Uso: TUsoData;
    FS_Pause: Boolean;
    procedure SetC_fft(const Value: TFFTData);
    procedure SetC_Noise(const Value: TFFTData);
    procedure SetC_Uso(const Value: TUsoData);
    procedure SetS_Pause(const Value: Boolean);
  protected
    procedure DoData; override;
    procedure Loaded; override;
  public
    NoiseReady: Boolean;
    fftReady: Boolean;
    UsoReady: Boolean;
    property C_Uso: TUsoData read FC_Uso write SetC_Uso;
    property C_Noise: TFFTData read FC_Noise write SetC_Noise;
    property C_fft: TFFTData read FC_fft write SetC_fft;
    property S_Pause: Boolean read FS_Pause write SetS_Pause;
  end;

implementation

{$R *.dfm}

uses VCL.Telesis.Decoder.FindSP, VCL.Telesis.Decoder.RunCode;

{ TFormDecoder }

procedure TDecoderECHOForm.Loaded;
 var
  d: IRootDevice;
  s: ISubDevice;
  i: IInterface;
begin
  inherited;
  if GContainer.TryGetInstKnownServ(TypeInfo(IDevice), ControlName, i) and Supports(i, IRootDevice, d) then
   begin
    if ExistsSubDev(d, 'Усо', '', s) then Bind('C_Uso', s, ['S_Data']);
    if ExistsSubDev(d, 'Усо', 'Усо файловое', s) then Bind(s, 'C_Pause', ['S_Pause']);
    if ExistsSubDev(d, 'Фильтры', 'генератор шума',  s) then Bind('C_Noise', s, ['S_Data']);
    if ExistsSubDev(d, 'Фильтры', 'Фильтр FFT',  s) then Bind('C_fft', s, ['S_Data']);
   end;
  FFrameSP := TFrameFindSP.Create(Self);
  FFrameCod := TFormRunCodes.Create(Self);
//  FFrameCod.Parent := nil;
//  FFrameCod.Show;
  FFrameSP.Show;
end;

procedure TDecoderECHOForm.SetC_fft(const Value: TFFTData);
begin
  FC_fft := Value;
  fftReady := True;
end;

procedure TDecoderECHOForm.SetC_Noise(const Value: TFFTData);
begin
  FC_Noise := Value;
  NoiseReady := True;
end;

procedure TDecoderECHOForm.SetC_Uso(const Value: TUsoData);
begin
  FC_Uso := Value;
  UsoReady := True;
end;

procedure TDecoderECHOForm.SetS_Pause(const Value: Boolean);
begin
  FS_Pause := Value;
  TBindings.Notify(Self, 'S_Pause');
end;

procedure TDecoderECHOForm.DoData;
begin
  case C_Data.State of
   csFindSP:
    begin
     FFrameSP.Show;
     FFrameCod.Hide;
     FFrameSP.DoData(C_Data);
    end;
   csSP,csCode, csCheckSP:
    begin
     FFrameSP.Hide;
     TFrameFindSP(FFrameSP).SeriesCorr.Clear;
     FFrameCod.Show;
     FFrameCod.DoData(C_Data);
    end;
    csUserToFindSP:
  end;
end;

initialization
  RegisterClass(TDecoderECHOForm);
  TRegister.AddType<TDecoderECHOForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TDecoderECHOForm>;
end.
