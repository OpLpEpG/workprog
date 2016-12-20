unit VCL.TelesisRetr.Decoder;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, Math.Telesistem.Custom,
     VCL.ControlRootForm, fifo.Decoder,
     System.Bindings.Helper,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls;

type
  IFifoDec = ISubDevice<TCFifoDecoder>;
  TDecoderRETRForm = class(TControlRootForm<TCFifoDecoder, ITelesistem_retr>)
    pc: TCPageControl;
  private
    FC_Decoder: TCustomDecoderWrap;
    FDecoderFrames: Tarray<TDecoderFrame>;
    procedure SetC_Decoder(const Value: TCustomDecoderWrap);
  protected
    procedure SetSubControlName(const AValue: String); override;
    procedure UpdateFrames(s: IFifoDec);
    procedure Loaded; override;
  public
    property C_Decoder: TCustomDecoderWrap read FC_Decoder write SetC_Decoder;
  end;

implementation

{$R *.dfm}

{ TDecoderRETRForm }

procedure TDecoderRETRForm.Loaded;
 var
  d: IRootDevice;
  s: ISubDevice;
  ii: IInterface;
// label
//  FindComp;
begin
  inherited Loaded;
  if GContainer.TryGetInstKnownServ(TypeInfo(IDevice), ControlName, ii) and Supports(ii, IRootDevice, d)
  and ExistsSubDev(d, SubControlName, s) then
   begin
    UpdateFrames(s as IFifoDec);
    Bind('C_Decoder', s, ['S_Decoder']);
   end;
end;

procedure TDecoderRETRForm.SetSubControlName(const AValue: String);
 var
  i: IInterface;
begin
  inherited;
  if GContainer.TryGetInstKnownServ(TypeInfo(ITelesistem_retr), SubControlName, i) and not(csLoading in ComponentState) then
   begin
    UpdateFrames(i as IFifoDec);
    TBindHelper.RemoveControlExpressions(Self, ['C_Decoder']);
    Bind('C_Decoder', i, ['S_Decoder']);
   end
end;

procedure TDecoderRETRForm.UpdateFrames(s: IFifoDec);
 var
  i: Integer;
  frm: TDecoderFrame;
  procedure Recreate;
   var
    i: Integer;
  begin
    SetLength(FDecoderFrames, 0);
    for i := pc.PageCount-1 downto 0 do pc.Pages[i].Free;
    for i := 0 to s.Data.Decoders.Count-1 do
     FDecoderFrames := FDecoderFrames + [TDecoderFrame.New(pc, TCustomDecoder(s.Data.Decoders.Items[i]))];
    MainScreenChanged;
  end;
begin
  if s.Data.Decoders.Count = pc.PageCount then
   begin
    for i := 0 to pc.PageCount-1 do
     begin
      frm := TDecoderFrame(pc.Pages[i].FindChildControl('DecoderFrame'+ i.ToString));
      if Assigned(frm) and frm.CheckDecoder(TCustomDecoder(s.Data.Decoders.Items[i])) then
       begin
        FDecoderFrames := FDecoderFrames + [frm];
        Continue;
       end;
      Recreate;
      Exit;
     end;
   end
  else Recreate;
end;

procedure TDecoderRETRForm.SetC_Decoder(const Value: TCustomDecoderWrap);
 var
  f: TDecoderFrame;
begin
  FC_Decoder := Value;
  for f in FDecoderFrames do
   begin
   if f.Decoder  = Value.obj then
   begin
    f.DoData(Value.obj as TCustomDecoder);
    Break;
   end;
   end;
end;

initialization
  RegisterClasses([TDecoderRETRForm, TCtabsheet]);
  TRegister.AddType<TDecoderRETRForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TDecoderRETRForm>;
end.
