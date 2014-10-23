unit VCL.Telesis.Decoder;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem,
     VCL.ControlRootForm,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCL.Telesis.Decoder.FindSP;

type
  TDecoderECHOForm = class(TControlRootForm<TDecoder, ITelesistem>)
  private
    FFrame: TControlRootFrame<PTelesistemDecoderData>;
    FState: TCorrelatorState;
    procedure InitFrame;
  protected
    procedure DoData; override;
    procedure Loaded; override;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

{ TFormDecoder }

procedure TDecoderECHOForm.InitFrame;
begin
  if Assigned(FFrame) then FFrame.Free;
  if not Assigned(C_Data) then FFrame := TFrameFindSP.Create(Self)
  else case C_Data.Data.State of
    csFindSP: FFrame := TFrameFindSP.Create(Self);
    csSP: ;
    csCode: ;
    csCheckSP: ;
    csBadCodes: ;
    csUserToFindSP: ;
  end;
end;

procedure TDecoderECHOForm.Loaded;
begin
  inherited;
  InitFrame;
end;

procedure TDecoderECHOForm.DoData;
begin
  if (FState <> C_Data.Data.State) or not Assigned(FFrame) then InitFrame
  else FFrame.DoData(C_Data.Data);
end;

initialization
  RegisterClass(TDecoderECHOForm);
  TRegister.AddType<TDecoderECHOForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TDecoderECHOForm>;
end.
