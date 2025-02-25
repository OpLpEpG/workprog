// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
{$IFDEF RELEASE}
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
{$ELSE}
// JCL_DEBUG_EXPERT_INSERTJDBG ON
{$ENDIF}
library VCLTelesis;

uses
  System.SysUtils,
  System.TypInfo,
  PluginAPI,
  AbstractPlugin,
  Container,
  System.Classes,
  VCL.ControlRootForm in 'VCL.ControlRootForm.pas',
  VCL.Telesis.Otk in 'VCL.Telesis.Otk.pas' {OtkForm},
  VCL.TelesisRetr.FFT in 'VCL.TelesisRetr.FFT.pas' {fftRETRForm},
  VCL.Telesis.Decoder in 'VCL.Telesis.Decoder.pas' {DecoderECHOForm},
  VCL.Telesis.Decoder.RunCode in 'VCL.Telesis.Decoder.RunCode.pas' {FormRunCodes: TFrame},
  VCL.Telesis.Decoder.FindSP in 'VCL.Telesis.Decoder.FindSP.pas' {FrameFindSP},
  VCL.Telesis.DecoderFFT_FSK in 'VCL.Telesis.DecoderFFT_FSK.pas' {FormDEcoderFFT_FSK},
  VCL.Telesis.FrameFFT_FSK in 'VCL.Telesis.FrameFFT_FSK.pas' {FrameFFT_FSK: TFrame},
  VCL.Telesis.uso in 'VCL.Telesis.uso.pas' {UsoOscForm},
  VCL.Telesis.Osc in 'VCL.Telesis.Osc.pas' {OscForm},
  VCL.Telesis.FFT in 'VCL.Telesis.FFT.pas' {FFTForm},
  VCL.TelesisRetr.Decoder in 'VCL.TelesisRetr.Decoder.pas' {DecoderRETRForm},
  VCL.Decoder.Frame in 'VCL.Decoder.Frame.pas' {FrameDecoderStandart: TFrame},
  VCL.TelesisRetr.Player in 'VCL.TelesisRetr.Player.pas' {PLeerRETRForm};

{$R *.res}

type
 TvclTelesis = class(TAbstractPlugin)
 protected
   class function GetHInstance: THandle; override;
 public
   class function PluginName: string; override;
 end;

function Init(): PTypeInfo;
begin
  TRegister.AddType<TvclTelesis, IPlugin>.LiveTime(ltSingleton);
  Result := TypeInfo(TvclTelesis);
end;

procedure Done;
begin
  GContainer.RemoveModel<TvclTelesis>;
end;

exports
  Init name SPluginInitFuncName,
  Done name SPluginDoneFuncName;

class function TvclTelesis.PluginName: string;
begin
  Result := '����� ��� �����������';
end;

class function TvclTelesis.GetHInstance: THandle;
begin
  Result := HInstance;
end;

begin
end.
