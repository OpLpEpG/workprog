unit VCL.Telesis.Decoder;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
     VCL.ControlRootForm,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TDecoderECHOForm = class(TControlRootForm<TTelesistemDecoder, ITelesistem>)
  private
    FFrameSP, FFrameCod: TControlRootFrame<TTelesistemDecoder>;
  protected
    procedure DoData; override;
    procedure Loaded; override;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses VCL.Telesis.Decoder.FindSP, VCL.Telesis.Decoder.RunCode;

{ TFormDecoder }

procedure TDecoderECHOForm.Loaded;
begin
  inherited;
  FFrameSP := TFrameFindSP.Create(Self);
  FFrameCod := TFormRunCodes.Create(Self);
//  FFrameCod.Parent := nil;
//  FFrameCod.Show;
  FFrameSP.Show;
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
