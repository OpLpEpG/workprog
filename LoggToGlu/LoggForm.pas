unit LoggForm;

interface

uses  LAS, LasImpl,  System.DateUtils,  tools,
  RootImpl, ExtendIntf, DockIForm, debug_except, RootIntf, Container, Actns,  System.TypInfo,  DataSetIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Rtti,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PluginAPI, DeviceIntf, Vcl.StdCtrls, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup, Vcl.ActnList, Vcl.StdActns, System.Actions, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TFormLogg = class(TDialogIForm, IDialog, IDialog<Integer>)
    sb: TStatusBar;
    btExit: TButton;
    btStart: TButton;
    Progress: TProgressBar;
    od: TJvFilenameEdit;
    sd: TJvFilenameEdit;
    lbDelaycap: TLabel;
    lbDelay: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    lbGluStart: TLabel;
    btTerminate: TButton;
    Label4: TLabel;
    lbDradr: TLabel;
    procedure btExitClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure odAfterDialog(Sender: TObject; var AName: string; var AAction: Boolean);
    procedure sdAfterDialog(Sender: TObject; var AName: string; var AAction: Boolean);
    procedure btTerminateClick(Sender: TObject);
  private
    FDelayStart: TDateTime;
    FGluStart: TDateTime;
    FlasInp, FlasOut: ILasDoc;
    FreadyInput, FReadyOutput, FRun: Boolean;
    procedure UpdateControls;
  protected
    class function ClassIcon: Integer; override;
    function Execute(dummy: Integer): Boolean;
    function GetInfo: PTypeInfo; override;
  public
    //Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
    [StaticAction('Конвертор LOGG в GLU', 'Отладочные', 260, '0:Показать.Отладочные:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
  published
  end;

implementation


uses Convertor;


{$R *.dfm}

{ TFormIO }

procedure TFormLogg.UpdateControls;
begin
  btStart.Enabled :=  FreadyInput and FReadyOutput and not FRun;
  btExit.Enabled := not FRun;
  od.Enabled := not FRun;
  sd.Enabled := not FRun;
  btTerminate.Enabled := FRun;
end;

procedure TFormLogg.odAfterDialog(Sender: TObject; var AName: string; var AAction: Boolean);
 var
  unixTime: Variant;
  deptStart: Variant;
begin
  FlasInp := NewLasDoc;
  FlasInp.LoadFromFile(AName);
  unixTime := FlasInp[ETIM,0];
  deptStart := FlasInp[DEPT,0];
  if unixTime = varNull then
   raise ENeedDialogException.Create('Во входном файле нет кривой ETIM');
  if deptStart = varNull then
   raise ENeedDialogException.Create('Во входном файле нет кривой DEPT');
  FGluStart := UnixToDateTime(unixTime);
  lbGluStart.Caption := DateTimeToStr(FGluStart);
  lbDradr.Caption := CTime.RoundToKadr(FDelayStart-FGluStart).ToString;
  FreadyInput := True;
  UpdateControls;
end;

procedure TFormLogg.sdAfterDialog(Sender: TObject; var AName: string; var AAction: Boolean);
begin
  FReadyOutput := True;
  UpdateControls;
end;

procedure TFormLogg.btTerminateClick(Sender: TObject);
begin
  convert_terminate;
  Sleep(100);
  FRun := False;
  UpdateControls;
  sb.Panels[4].Text := 'прервано';
end;

procedure TFormLogg.btStartClick(Sender: TObject);
begin
  sb.Panels[4].Text := 'старт';
  FRun := True;
  UpdateControls;
  FlasOut := NewLasDoc(True);
  // FlasOut ID KADR DEPT TIME
//  FlasOut.Curve.Add(TlasFormat.Create('ID','',''));
//  FlasOut.Curve.DisplayFormat['ID'] := '';
  FlasOut.Curve.Add(TlasFormat.Create(KADR,'N','номер кадра'));
  FlasOut.Curve.DisplayFormat[KADR] := '';
  FlasOut.Curve.Add(TlasFormat.Create(DEPT,'m','глубина'));
  FlasOut.Curve.DisplayFormat[DEPT] := ' %10.6f';
  FlasOut.Curve.Add(TlasFormat.Create(TIME, 'tDateTime','время кадра'));
  FlasOut.Curve.DisplayFormat[TIME] := ' %g';
  convert(FlasInp, FlasOut, FDelayStart, procedure (st: IStatistic)
  begin
    if Assigned(st) then
     begin
      TStatisticCreate.UpdateStandardStatusBar(sb, st.Statistic);
      Progress.Position := Round(st.Statistic.ProcRun);
     end
    else
     begin
      FRun := False;
      UpdateControls;
      try
       sb.Panels[4].Text := 'конец';
       FlasOut.SaveToFile(sd.FileName);
      except
       on E: Exception do TDebug.DoException(E);
      end;
     end;
  end);
end;

function TFormLogg.Execute(dummy: Integer): Boolean;
 var
  opt: IProjectOptions;
begin
  if Supports(GContainer, IProjectOptions, opt) then
   begin
    FDelayStart := opt.DelayStart;
    lbDelay.Caption := DateTimeToStr(opt.DelayStart);
   end;
  Result := True;
  IShow;
  UpdateControls;
end;

procedure TFormLogg.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize(EXPORT_DIALOG_CATEGORY, 'LOGG_TO_GLU');
end;

function TFormLogg.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_Export);
end;

class function TFormLogg.ClassIcon: Integer;
begin
  Result := 260;
end;


class procedure TFormLogg.DoCreateForm(Sender: IAction);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet(EXPORT_DIALOG_CATEGORY, 'LOGG_TO_GLU', d) then (d as IDialog<Integer>).Execute(0);
end;

initialization
  RegisterDialog.Add<TFormLogg, Dialog_Export>(EXPORT_DIALOG_CATEGORY, 'LOGG_TO_GLU');
finalization
  RegisterDialog.Remove<TFormLogg>;
end.





