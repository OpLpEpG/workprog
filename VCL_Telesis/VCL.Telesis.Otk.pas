unit VCL.Telesis.Otk;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns,
  Winapi.Windows, Winapi.Messages, Math.Telesistem, Vcl.Menus,
  System.SysUtils, System.Variants, System.Classes,  AVRtypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VCL.ControlRootForm,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, OtklonitelPaintClass, GR32_Image;

type
  TOtkForm = class(TControlRootForm<TPriborData, ITelesistem>)
    Otk: TOtklonitelPaint;
  protected
    procedure NSetupClick(Sender: TObject);
    procedure DoData; override;
    procedure InitializeNewForm; override;
    procedure Loaded; override;
    procedure DoSetFont(const AFont: TFont); override;
  public
   constructor CreateUser(const aName: string =''); override;
  end;


implementation

{$R *.dfm}

constructor TOtkForm.CreateUser(const aName: string);
begin
  inherited;

end;

procedure TOtkForm.DoData;
begin
   Otk.C_Data := C_Data;
end;

procedure TOtkForm.DoSetFont(const AFont: TFont);
begin
  inherited;
  Otk.Buffer.Font := AFont;
end;

procedure TOtkForm.InitializeNewForm;
 var
  ce: IConnectIOEnum;
  m: IManager;
  Item : TMenuItem;
begin
  inherited;
  AddToNCMenu('-', nil, Item);
  AddToNCMenu('Установки Отклонителя...', NSetupClick, Item);
end;

procedure TOtkForm.Loaded;
begin
  inherited;
  Otk.Buffer.Font := Font;
end;

procedure TOtkForm.NSetupClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TOtklonitelPaint>).Execute(Otk);
end;

{ TBitOscForm }

initialization
  RegisterClasses([TOtkForm]);
  TRegister.AddType<TOtkForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TOtkForm>;
end.
