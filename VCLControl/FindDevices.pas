unit FindDevices;

interface

uses  RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, RootIntf, Container, Actns,  tools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  FrameFindDevs2;

type
  TFormFindDev = class(TDockIForm, INotifyBeforeSave)
    Panel1: TPanel;
    Panel2: TPanel;
    btStart: TButton;
    btCansel: TButton;
    btExit: TButton;
    Memo: TMemo;
    Splitter1: TSplitter;
    procedure btStartClick(Sender: TObject);
    procedure btCanselClick(Sender: TObject);
    procedure btExitClick(Sender: TObject);
  private
    frames: TArray<TFrameFindDev>;
    procedure UpdateControls(enable: Boolean);
    procedure ClearDevs();
  protected
   const
    NICON = 279;
   var
    class function ClassIcon: Integer; override;
    procedure BeforeSave();
  public
//Capt, Categ: string; AImageIndex: Integer; APaths: string; AHint: string; AAutoCheck AChecked AGroupIndex AEnabled
    [StaticAction('����� ��������', '��������', NICON, '0:��������:1;1:')]
    class procedure DoCreateForm(Sender: IAction); override;
    { Public declarations }
  end;


implementation

{$R *.dfm}

{ TFormFindDev }

procedure TFormFindDev.BeforeSave;
begin
  ClearDevs;
  Memo.Clear;
end;

procedure TFormFindDev.btCanselClick(Sender: TObject);
begin
  Memo.Lines.Add('----��������---');
  for var f in frames do  f.Fterminate := True;
  UpdateControls(True);
end;

procedure TFormFindDev.btExitClick(Sender: TObject);
begin
  Close_ItemClick(Self);
end;

procedure TFormFindDev.btStartClick(Sender: TObject);
 var
  gc: IGetConnectIO;
  d: IDevice;
  de: IDeviceEnum;
  ports: TArray<string>;
begin
  ClearDevs;
  Memo.Lines.Clear;
  Memo.Lines.Add('---������ ������ ----');
  Memo.Lines.Add('1. �������� ������� ��������');
  if Supports(GlobalCore, IDeviceEnum, de) then
   for d in de do if Supports(d, IDataDevice) then
    if not (d.Status in [dsNoInit, dsPartReady, dsReady]) and not d.CanClose then
   begin
     Memo.Lines.Add(Format(' ERR:  ������ [%s] � ������',[(d as ICaption).Text]));
    MessageDlg(Format('������ [%s] � ������. ���������� ��������� �������� ������ �������', [(d as ICaption).Text]),
               mtWarning, [mbOk], 0);
    Exit();
   end;
  Memo.Lines.Add('1. �������� ������� �������� OK');

  Memo.Lines.Add('2. ����� ����������');
  if Supports(GlobalCore, IGetConnectIO, gc) then
   begin
    ports := gc.GetConnectInfo(1);
   end;
  if Length(ports) = 0 then
   begin
    Memo.Lines.Add('ERR ��� ����������(COM ������)');
    Exit;
   end;
  Memo.Lines.Add('2. ����� ���������� OK');

  Memo.Lines.Add('3. ����� �������');
  UpdateControls(False);
  for var portName in  ports do
   begin
    var f := TFrameFindDev.Create(self);
    f.Name := f.Name + Length(frames).ToString;
    f.Parent := Panel2;
    f.lbCon.Caption := portName;
    frames := frames +[f];
   end;
  for var f in frames do  f.Execute(f.lbCon.Caption, Memo, procedure(e: TFrameFindDev)
    begin
     for var ff in frames do if not ff.FExecuted then exit;
     UpdateControls(True);
   end);
end;

class function TFormFindDev.ClassIcon: Integer;
begin
  Result := NICON;
end;

procedure TFormFindDev.ClearDevs;
begin
  for var f in frames do f.Free;
  SetLength(frames, 0);
end;

class procedure TFormFindDev.DoCreateForm(Sender: IAction);
begin
  var f := GetUniqueForm('GlobalFormFindDev');
//  (GContainer as ITabFormProvider).Tab(f);
//  (GContainer as ITabFormProvider).SetActiveTab(f);
end;

procedure TFormFindDev.UpdateControls(enable: Boolean);
begin
  btStart.Enabled := enable;
  btExit.Enabled := enable;
  btCansel.Enabled := not enable;
end;

initialization
  RegisterClass(TFormFindDev);
  RegisterClass(TFrameFindDev);
  TRegister.AddType<TFormFindDev, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormFindDev>;
end.
