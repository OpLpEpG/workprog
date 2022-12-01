unit FormDelay2;

interface

//{$D1}

uses DeviceIntf, DockIForm, debug_except, ExtendIntf, RootImpl, PluginAPI, RootIntf,  Actns, FrameDelayDev,
     System.Variants, Container, System.TypInfo, System.SysUtils, System.Classes, System.DateUtils,
     Winapi.Windows, Winapi.Messages, Vcl.Graphics, Vcl.Menus, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
     Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Mask;
type
  EDialogDelayException = class(EBaseException);

  TDialogDelay = class(TDialogIForm, IDialog, IDialog<IDelayDevice>)
    pnEdit: TPanel;
    pnShow: TPanel;
    lbSetDelay: TLabel;
    lbWork: TLabel;
    medDelay: TMaskEdit;
    medWork: TMaskEdit;
    btApply: TButton;
    btClose: TButton;
    Memo: TMemo;
    btDelay: TButton;
    Timer: TTimer;
    pnCtatus: TPanel;
    TimerErr: TTimer;
    procedure btCloseClick(Sender: TObject);
    procedure EditsChange(Sender: TObject);
    procedure btApplyClick(Sender: TObject);
    procedure btDelayClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TimerErrTimer(Sender: TObject);
  private
    // ���������� ����� ������ ��
    FDBTimeStart: TDateTime;
    FDBIntervalWork: TTime;

    // Applied
    FApplStartTime: TDateTime;
    FApplIntervalDelay: TTime;
    FApplWork: TTime;

    FSettingDelay: Boolean;
    DelayDevice: IDelayDevice;
    IsDelayIntervalMenu: TMenuItem;
    ResetDelayMenu: TMenuItem;

    FBindWorkRes: TWorkEventRes;
    FMetaDataInfo: TInfoEventRes;

    FFrameDelayInfos: Tarray<TFrameDelayInfo>;
    procedure CheckStartTime(TimeStart: TDateTime);
    procedure WriteToBD(TimeStart: TDateTime; IntervalWork: TTime);
    procedure OnSetDelay(Res: TSetDelayRes);
    procedure IsDelayIntervalMenuClick(Sender: TObject);
    procedure ResetDelayMenuClick(Sender: TObject);
    function Delayed: Boolean; inline;
    procedure AnyUserAction(Apply, Delay: Boolean);
    procedure UpdateDelayed;
    procedure UpdateDelayControls(ToDelay: Boolean);
    procedure SetBindWorkRes(const Value: TWorkEventRes);
  protected
    procedure InitDevInfo;
    procedure Loaded; override;
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: IDelayDevice): Boolean;
    class function ClassIcon: Integer; override;
  public
    property C_BindWorkRes: TWorkEventRes read FBindWorkRes write SetBindWorkRes;
  end;


implementation

{$R *.dfm}

uses tools;

const
 TLBL_SETDELAY: array[Boolean] of string = ('����� ���������', '�������� ��������');
 TMSK_SETDELAY: array[Boolean] of string = ('90/00/0000 00:00:00', '9 00:00:00');
 T_CAPTION: array[Boolean] of string = ('���������� �� ��������', 'C������������ ��������');
 T_BUTTON: array[Boolean] of string = ('��������� �� ��������', 'C��������������� ��������');

{ TDialogDelay }

function TDialogDelay.Delayed: Boolean;
begin
  Result := FDBTimeStart > 0;
end;

procedure TDialogDelay.btCloseClick(Sender: TObject);
begin
  var DoStd := (GContainer as IActionEnum).Get((DelayDevice as IDevice).IName + '_DoStd');
  var DoData := (GContainer as IActionEnum).Get((DelayDevice as IDevice).IName + '_DoData');
  if DoData.Checked then (DoData.GetComponent as TICustRTTIAction).Execute;
  if DoStd.Checked then (DoStd.GetComponent as TICustRTTIAction).Execute;

  RegisterDialog.UnInitialize<Dialog_SetDeviceDelay>;
end;

function TDialogDelay.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_SetDeviceDelay);
end;

function TDialogDelay.Execute(InputData: IDelayDevice): Boolean;
begin
  Result := True;
  DelayDevice := InputData;
  UpdateDelayed;
  IsDelayIntervalMenuClick(nil);
  btDelay.Enabled := Delayed;
  if Delayed then TimerTimer(nil);
  IShow;
  InitDevInfo;

  var DoStd := (GContainer as IActionEnum).Get((DelayDevice as IDevice).IName + '_DoStd');
  var DoData := (GContainer as IActionEnum).Get((DelayDevice as IDevice).IName + '_DoData');
  if not DoStd.Checked then (DoStd.GetComponent as TICustRTTIAction).Execute;
  if not DoData.Checked then (DoData.GetComponent as TICustRTTIAction).Execute;

  Bind('C_BindWorkRes',InputData, ['S_WorkEventInfo']);
end;

procedure TDialogDelay.Loaded;
 var
  opt: IProjectOptions;
begin
  inherited;
  if Supports(GContainer, IProjectOptions, opt) then
   begin
    FDBTimeStart := opt.DelayStart;
    FDBIntervalWork := opt.IntervalWork;
   end;
  IsDelayIntervalMenu := AddToNCMenu('�������� ��������', IsDelayIntervalMenuClick);
  IsDelayIntervalMenu.AutoCheck := True;
  AddToNCMenu('-');
  ResetDelayMenu := AddToNCMenu('�������� ��������(����� ���������, �������� ������)...', ResetDelayMenuClick);
end;

procedure TDialogDelay.UpdateDelayed;
begin
  Caption := Format('[%s] %s',[(DelayDevice as ICaption).Text, T_CAPTION[Delayed]]);
  btDelay.Caption := T_BUTTON[Delayed];
  pnEdit.Visible := not Delayed;
  IsDelayIntervalMenu.Visible := not Delayed;
  ResetDelayMenu.Visible := Delayed;
end;

procedure TDialogDelay.WriteToBD(TimeStart: TDateTime; IntervalWork: TTime);
 var
  opt: IProjectOptions;
begin
  FDBTimeStart := TimeStart;
  FDBIntervalWork := IntervalWork;
  if Supports(GContainer, IProjectOptions, opt) then
   begin
    opt.Option['TIME_START'] := DateTimeToStr(FDBTimeStart);
    opt.Option['WORK_INTERVAL'] := TimeToStr(FDBIntervalWork);
   end;
end;

procedure TDialogDelay.CheckStartTime(TimeStart: TDateTime);
begin
  if TimeStart < Now then
    raise EDialogDelayException.CreateFmt('����� ���������� �� ��������, ��������� �������, ������:%s ������:%s',
          [DateTimeToStr(TimeStart), DateTimeToStr(Now)]);
  if TimeStart - Now > 20 then
    raise EDialogDelayException.CreateFmt('����� ��������� ������� %1.1f �����', [TimeStart - Now]);
end;

class function TDialogDelay.ClassIcon: Integer;
begin
  Result := 142;
end;

procedure TDialogDelay.TimerErrTimer(Sender: TObject);
begin
 for var f  in FFrameDelayInfos do if secondsbetween(now, f.LastUpdate) > 3 then f.UpdateTimout;
end;

procedure TDialogDelay.TimerTimer(Sender: TObject);
 var
  toff, tStart: TDateTime;
  iDelay: TTime;
  procedure DelayPlus;
  begin
    Memo.Lines.Add(Format('��������� ��:      %s', [DateTimeToStr(tStart)]));
    Memo.Lines.Add(Format('�������� ��������: %s', [Ctime.AsString(iDelay)]));
    Memo.Lines.Add(Format('����: %d', [Ctime.RoundToKadr(iDelay)]));
  end;
  procedure DelayMinus;
  begin
    Memo.Lines.Add(Format('�� ��������� �:    %s', [DateTimeToStr(FDBTimeStart)]));
    Memo.Lines.Add(Format('��������:          %s', [Ctime.AsString(-iDelay)]));
    Memo.Lines.Add(Format('����: %d', [Ctime.RoundToKadr(-iDelay)]));
  end;
  procedure WorkDelayPlus(w: TTime);
  begin
    if w <> 0 then
     begin
      Memo.Lines.Add('');
      Memo.Lines.Add(Format('���������� ��:     %s', [DateTimeToStr(Ctime.Round(tStart + w))]));
      Memo.Lines.Add(Format('�� ����������:     %s', [Ctime.AsString(Ctime.Round(iDelay + w))]));
     end;
  end;
  procedure WorkOff;
  begin
    Memo.Lines.Add(Format('��������� �:       %s', [DateTimeToStr(FDBTimeStart)]));
    Memo.Lines.Add(Format('���������:         %s', [Ctime.AsString(FDBIntervalWork)]));
    Memo.Lines.Add('');
    Memo.Lines.Add(Format('�� ����������:     %s', [DateTimeToStr(toff)]));
    Memo.Lines.Add(Format('��������:          %s', [Ctime.AsString(Ctime.Round(Now-toff))]));
  end;
begin
  Timer.Enabled := False;
  Memo.Lines.BeginUpdate;
  Memo.Clear;
  try
    if not Delayed then
     begin
      if IsDelayIntervalMenu.Checked then
       begin
        tStart := Ctime.Round(Now + FApplIntervalDelay);
        iDelay := FApplIntervalDelay;
       end
      else
       begin
        tStart := FApplStartTime;
        iDelay := Ctime.Round(FApplStartTime - Now);
       end;
      try
       CheckStartTime(tStart);
      except
       btDelay.Enabled := False;
       raise;
      end;
      DelayPlus;
      WorkDelayPlus(FApplWork);
     end
    else
     begin
      tStart := FDBTimeStart;
      iDelay := Ctime.Round(FDBTimeStart - Now);
      if iDelay > 0 then
       begin
        DelayPlus;
        WorkDelayPlus(FDBIntervalWork);
       end
      else
       begin
        btDelay.Enabled := False;
        if (FDBIntervalWork > 0) then
         begin
          toff := FDBTimeStart + FDBIntervalWork;
          if Now > toff then WorkOff
          else
           begin
            DelayMinus;
            WorkDelayPlus(FDBIntervalWork);
           end;
         end
        else DelayMinus;
       end
     end;
  finally
   Memo.Lines.EndUpdate;
  end;
  Timer.Enabled := True;
end;

procedure TDialogDelay.AnyUserAction(Apply, Delay: Boolean);
begin
  Timer.Enabled := False;
  Memo.Clear;
  btDelay.Enabled := Delay;
  btApply.Enabled := Apply;
end;

procedure TDialogDelay.ResetDelayMenuClick(Sender: TObject);
begin
  if MessageDlg('�������� ����� ���������, �������� ������ ��� �������?', TMsgDlgType.mtError,[mbOK, mbCancel],1) = mrOk then
   begin
    WriteToBD(0, 0);
    UpdateDelayed;
    AnyUserAction(False, False);
   end;
end;

procedure TDialogDelay.SetBindWorkRes(const Value: TWorkEventRes);
begin
  FBindWorkRes := Value;
  for var d in FFrameDelayInfos do  if FBindWorkRes.DevAdr = d.Adr then
   begin
     d.UpdateData;
     Break;
   end;
end;

procedure TDialogDelay.InitDevInfo;
begin
  FMetaDataInfo := (DelayDevice as IDataDevice).GetMetaData();
  var dvs := FindDevs(FMetaDataInfo.Info);
  for var d in dvs do FFrameDelayInfos := FFrameDelayInfos +[TFrameDelayInfo.GetNew(d.Attributes[AT_ADDR], d, pnCtatus)];
  for var d in FMetaDataInfo.ErrAdr do FFrameDelayInfos := FFrameDelayInfos +[TFrameDelayInfo.GetNew(d, nil, pnCtatus)];
  pnCtatus.ClientHeight := Length(FFrameDelayInfos)*FFrameDelayInfos[0].Height;
end;

procedure TDialogDelay.IsDelayIntervalMenuClick(Sender: TObject);
begin
  medDelay.EditMask :=  TMSK_SETDELAY[IsDelayIntervalMenu.Checked];
  lbSetDelay.Caption := TLBL_SETDELAY[IsDelayIntervalMenu.Checked];
  if IsDelayIntervalMenu.Checked then medDelay.Text := '0 00:03:00'
  else medDelay.Text := DateToStr(Trunc(Now * HoursPerDay)/ HoursPerDay);
  AnyUserAction(False, False);
end;

procedure TDialogDelay.EditsChange(Sender: TObject);
begin
  AnyUserAction(True, False);
end;

procedure TDialogDelay.btApplyClick(Sender: TObject);
begin
  FApplWork := Ctime.FromString(medWork.Text);
  if IsDelayIntervalMenu.Checked then FApplIntervalDelay := Ctime.FromString(medDelay.Text)
  else
   begin
    FApplStartTime := StrToDateTime(medDelay.Text);
    CheckStartTime(FApplStartTime);
   end;
  TimerTimer(Sender);
  btApply.Enabled := False;
  btDelay.Enabled := True;
  btDelay.Click;
end;

procedure TDialogDelay.UpdateDelayControls(ToDelay: Boolean);
begin
  FSettingDelay := ToDelay;
  NCanClose := not ToDelay;
  btClose.Enabled := not ToDelay;
  medDelay.Enabled := not ToDelay;
  medWork.Enabled := not ToDelay;
  btDelay.Enabled := not ToDelay;
  IsDelayIntervalMenu.Enabled := not ToDelay;
  ResetDelayMenu.Enabled := not ToDelay;
end;

procedure TDialogDelay.btDelayClick(Sender: TObject);
begin
  if IsDelayIntervalMenu.Checked then FApplStartTime := Round((Now + FApplIntervalDelay)*SecsPerDay)/ SecsPerDay;
  UpdateDelayControls(True);
  if Delayed then DelayDevice.SetDelay(FDBTimeStart, FDBIntervalWork, OnSetDelay)
  else DelayDevice.SetDelay(FApplStartTime, FApplWork, OnSetDelay);
end;

procedure TDialogDelay.OnSetDelay(Res: TSetDelayRes);
 const
  ST = '���������:  %s'+#$D#$A+
       '��������:                        %s'+#$D#$A+
       '���������:  %s'+#$D#$A+
       #$D#$A+
       '����������: %s'+#$D#$A+
       '���.������: %s';
 var
  tst, td, ton, tw, toff: string;
begin
  UpdateDelayControls(False);
  if Res.Res then
   begin
    if not Delayed then
     begin
      WriteToBD(FApplStartTime, FApplWork);
      UpdateDelayed;
     end;
/// �������������� ��� ������ 3
 {   ConnectionsPool.Query.Acquire;
    try
     ConnectionsPool.Query.ExecSQL('UPDATE Device SET TimeSetupDelay = :P1 WHERE (IName = :P2)', [Res.SetTime, (DelayDevice as IManagItem).IName], [ftDateTime, ftString]);
    finally
     ConnectionsPool.Query.Release;
    end;}
    DateTimeToString(tst, 'dd.mm.yyyy hh:nn:ss:zzz', Res.SetTime);
    DateTimeToString(td,  'hh:nn:ss:zzz', Res.Delay);
    DateTimeToString(ton, 'dd.mm.yyyy hh:nn:ss:zzz', Res.SetTime + Res.Delay);
    if Res.WorkTime = 0 then
     begin
      toff := '---';
      tw := '---';
     end
    else
     begin
      DateTimeToString(tw, 'hh:nn:ss:zzz', Res.WorkTime);
      DateTimeToString(toff, 'dd.mm.yyyy hh:nn:ss:zzz', Res.SetTime + Res.Delay + Res.WorkTime);
     end;
    MessageDlg(Format(ST, [tst,td,ton,toff,tw]), mtConfirmation, [mbOk], 0);
   end;
end;

initialization
  RegisterDialog.Add<TDialogDelay, Dialog_SetDeviceDelay>;
finalization
  RegisterDialog.Remove<TDialogDelay>;
end.
