unit VCL.TelesisRetr.Player;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns, JDtools, IndexBuffer,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, VCL.ControlRootForm,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons, Vcl.ComCtrls;

type
  TPLeerRETRForm = class(TControlRootForm<TIndexBuf, ITelesistem_retr>)
    Timer1: TTimer;
    sbStep: TSpeedButton;
    sbPlay: TSpeedButton;
    sbStop: TSpeedButton;
    ProgressBar1: TProgressBar;
    procedure Timer1Timer(Sender: TObject);
    procedure ProgressBar1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure sbPlayClick(Sender: TObject);
    procedure sbStopClick(Sender: TObject);
    procedure sbStepClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function Pleer: IPleer;
  public
  end;

implementation

{$R *.dfm}

procedure TPLeerRETRForm.FormShow(Sender: TObject);
begin
  Timer1.Enabled := False;
  ProgressBar1.Position := 0
end;

function TPLeerRETRForm.Pleer: IPleer;
begin
  if not Assigned(FC_Data) or not Supports(FC_Data.Owner,IPleer, Result) then Result := nil;
end;

procedure TPLeerRETRForm.ProgressBar1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Timer1.Enabled := False;
  ProgressBar1.Position := x*100 div ProgressBar1.ClientWidth;
  Pleer.Position := Round(ProgressBar1.Position/100 * Pleer.Maximum);
  Pleer.Step(64*16);
end;

procedure TPLeerRETRForm.sbPlayClick(Sender: TObject);
begin
  Timer1.Interval := 50;
  Timer1.Enabled := True;
end;

procedure TPLeerRETRForm.sbStepClick(Sender: TObject);
 var
  p: IPleer;
  sp: Int64;
  i : Integer;
begin
  Timer1.Enabled := False;
  p := Pleer;
  if Assigned(p) then
   begin
    p.Step(64*16);
    ProgressBar1.Position := p.Position*100 div p.Maximum;
   end;
end;

procedure TPLeerRETRForm.sbStopClick(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

procedure TPLeerRETRForm.Timer1Timer(Sender: TObject);
 var
  p: IPleer;
  sp: Int64;
  i : Integer;
begin
  Timer1.Interval := 50;
  p := Pleer;
  if Assigned(p) then
   begin
    p.Step(64);
    ProgressBar1.Position := p.Position*100 div p.Maximum;
   end;
end;

initialization
  RegisterClasses([TPLeerRETRForm]);
  TRegister.AddType<TPLeerRETRForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TPLeerRETRForm>;
end.
