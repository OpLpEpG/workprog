unit Easy64Incl;

interface

uses  DeviceIntf, ExtendIntf, RootIntf, PluginAPI, Container, dockIform,

  System.TypInfo, System.IOUtils, Vcl.Menus, Actns, JvDockControlForm,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, System.ImageList, Vcl.ImgList, Vcl.ActnCtrls, Vcl.ToolWin, Vcl.ActnMan,
  Vcl.ActnMenus, Vcl.ExtCtrls, Vcl.BandActn, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.AppEvnts,
  Vcl.StdCtrls, JvFormPlacement, JvComponentBase, JvAppStorage, JvAppXMLStorage;

type
  TMenuAction = class(TICustomAction)
  private
    Fmenu: TMenuItem;
    class var Index: Integer;
  public
    function Execute: Boolean; override;
    function Update: Boolean; override;
    constructor CreateUser(Amenu: TMenuItem; const Categoty: string; ImagIndex: integer); overload;
    destructor Destroy; override;
  end;

  TFormEasyIntf = class(TForm, IActionProvider, IRegistry)
    ActionManager: TActionManager;
    ActionExit: TAction;
    ActionExceptForm: TAction;
    ControlBar: TControlBar;
    MainMenu: TActionMainMenuBar;
    ToolBar1: TActionToolBar;
    ToolBar2: TActionToolBar;
    ImageList: TImageList;
    sb: TStatusBar;
    ActionNop: TAction;
    PanelW: TPanel;
    Splitter1: TSplitter;
    PanelT: TPanel;
    ApplicationEvents: TApplicationEvents;
    ActionComPort: TAction;
    ActionSelectPort: TAction;
    xini: TJvAppXMLFileStorage;
    FormStorage: TJvFormStorage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ActionExceptFormExecute(Sender: TObject);
    procedure ActionExitExecute(Sender: TObject);
    procedure ActionNopExecute(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure ActionComPortUpdate(Sender: TObject);
  private
    FDev: IDevice;
    FWorkForm, FtrrForm: IForm;
//  IActionProvider = interface
//    function Create(const Category, Caption, Name: WideString; Event: TIActionEvent; ImagIndex: Integer = -1; GroupIndex: Integer = -1): IAction;
    procedure ActionComExecute(Sender: TObject);
    procedure ShowInBar(BarID: Integer; const path: string; Action: IAction; Index: Integer = -1); overload;
    procedure ShowInBar(BarID: Integer; const path: TArray<TMenuPath>; Action: IAction; ActionIndex: Integer = -1); overload;
    procedure SetIndexInBar(BarID: Integer; const ACaption: string; Index: Integer);
    procedure HideInBar(BarID: Integer; Action: IAction);
    //new intf
    procedure RegisterAction(Action: IAction);
    function HideUnusedMenus: boolean;
    procedure UpdateWidthBars;
    procedure SaveActionManager;
    procedure ResetActions;
//  IRegistry = interface
//  ['{BAABFFB6-4B3F-4788-BE0E-29FB35A787EC}']
    procedure SaveString(const Name, Value: String; Registry: Boolean = False);
    function LoadString(const Name, DefValue: String; Registry: Boolean = False): String;
    procedure SaveArrayString(const Root: String; const Value: TArray<string>; Registry: Boolean = False);
    procedure LoadArrayString(const Root: String; var Value: TArray<string>; Registry: Boolean = False);
  public
    { Public declarations }
  end;

var
  FormEasyIntf: TFormEasyIntf;

implementation

uses PluginManager, GR32, WinAPI.GDIPObj, WinAPI.GDIPApi, RootImpl, ActionBarHelper, ExceptionForm, debug_except;

{$R *.dfm}

procedure TFormEasyIntf.ActionNopExecute(Sender: TObject);
begin
//
end;

procedure TFormEasyIntf.ActionComExecute(Sender: TObject);
begin
  FDev.IConnect.ConnectInfo := (Sender as TAction).Caption;
  FormStorage.StoredValue['COM'] := FDev.IConnect.ConnectInfo;
  sb.Panels[0].Text := FDev.IConnect.ConnectInfo;
//  (Sender as TAction).Checked := True;
end;

procedure TFormEasyIntf.ActionComPortUpdate(Sender: TObject);
 var
  cm, a: TActionClientItem;
  ac: TAction;
  s: string;
begin
  cm := MainMenu.ActionClient.Items[3].Items[0];
  cm.Items.Clear;
  for s in (GContainer as IGetConnectIO).GetConnectInfo(1) do
   begin
    a := cm.Items.Add;
    ac := TAction.Create(Self);
    ac.Caption := s;
    ac.AutoCheck := True;
    ac.OnExecute := ActionComExecute;
    a.Action := ac;
   end;
end;

procedure TFormEasyIntf.ActionExceptFormExecute(Sender: TObject);
begin
  TFormExceptions.This.Show;
end;

procedure TFormEasyIntf.ActionExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormEasyIntf.ApplicationEventsException(Sender: TObject; E: Exception);
const
  {$J+}
    IsShow: Boolean = False;
  {$J-}
begin
  if not TDebug.DoException(E) then
    if not IsShow then
   begin
    IsShow := True;
    Application.ShowException(e);
    IsShow := False;
   end;
end;

procedure TFormEasyIntf.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LockWindowUpdate(Handle);
  try
    FormStorage.SaveFormPlacement;      // сохранение cool bar основной формы
    TDockIForm(FWorkForm).Visible := False;
    TDockIForm(FtrrForm).Visible := False;
    ((GContainer as IFormEnum) as IStorable).Save;
    FDev := nil;
    FWorkForm := nil;
    FtrrForm := nil;
    Plugins.UnloadAll;
  finally
   LockWindowUpdate(0);
  end;
end;


procedure TFormEasyIntf.FormCreate(Sender: TObject);
 var
 i: IInterface;
  FConnection: IConnectIO;
begin
  FormatSettings.DecimalSeparator := '.';
  TRegister.AddType<TFormEasyIntf, IActionProvider, IRegistry>.LiveTime(ltSingleton).AddInstance(Self as IInterface);
end;

procedure TFormEasyIntf.FormShow(Sender: TObject);
 var
  FConnection: IConnectIO;
  i: Integer;
  m, fm,rm, wm: TMenuItem;
  s: string;
  ii: IInterface;
begin
  LockWindowUpdate(Handle);
  try
    FormStorage.RestoreFormPlacement;
    Plugins.LoadPlugin(TPath.GetDirectoryName(ParamStr(0))+'\ComDev.dlp');
    Plugins.LoadPlugin(TPath.GetDirectoryName(ParamStr(0))+'\VCLData.dlp');
    Plugins.LoadPlugin(TPath.GetDirectoryName(ParamStr(0))+'\metrol.dlp');
  //  Plugins.LoadPlugin(TPath.GetDirectoryName(ParamStr(0))+'\VCLControl.dlp');
    FDev := (GContainer as IGetDevice).Device([104], 'ПСК4');
    (GContainer as IDeviceEnum).Add(Fdev);
    FConnection := (GContainer as IGetConnectIO).ConnectIO(1);
    FConnection.ConnectInfo := FormStorage.StoredValue['COM'];
    sb.Panels[0].Text := FormStorage.StoredValue['COM'];

    (GContainer as IConnectIOEnum).Add(FConnection);
    FDev.IConnect := FConnection;

    ((GContainer as IFormEnum) as IStorable).load;

    if not GContainer.TryGetInstance('FormWrok1', ii) then
     begin
      FWorkForm := GContainer.CreateValuedInstance<string>('TFormWrok', 'CreateUser', 'FormWrok1') as IForm;
      (GContainer as IFormEnum).Add(FWorkForm);
     end
    else FWorkForm := ii as IForm;

    if not GContainer.TryGetInstance('TrrForm1', ii) then
     begin
      FtrrForm := GContainer.CreateValuedInstance<string>('TFormInclinTrrAndP2', 'CreateUser', 'TrrForm1') as IForm;
      (GContainer as IFormEnum).Add(FtrrForm);
     end
    else FtrrForm := ii as IForm;

    TDockIForm(FWorkForm).GetDockClient.EnableDock := False;
    TDockIForm(FtrrForm).GetDockClient.EnableDock := False;
    TDockIForm(FtrrForm).SetNCMenusVisible([]);
    TFormExceptions.This.GetDockClient.NCPopupMenu.Items[3].Click;
    TFormExceptions.This.NShowDebug.Checked := False;
    TFormExceptions.This.SetNCMenusVisible([]);

    Tform(FWorkForm).BorderStyle := bsNone;
    Tform(FWorkForm).Parent := PanelW;
    Tform(FWorkForm).Align := alClient;
    (FWorkForm as ISetDevice).SetDataDevice(FDev.IName);

    Tform(FWorkForm).Show;

    Tform(FtrrForm).BorderStyle := bsNone;
    Tform(FtrrForm).Parent := PanelT;
    Tform(FtrrForm).Align := alClient;
    (FtrrForm as ISetDevice).SetDataDevice(FDev.IName);

    Tform(FtrrForm).Show;

    fm := TDockIForm(FtrrForm).GetDockClient.NCPopupMenu.Items.Find('Файл');
    rm := TDockIForm(FtrrForm).GetDockClient.NCPopupMenu.Items;
    wm := TDockIForm(FWorkForm).GetDockClient.NCPopupMenu.Items;

    //Caption := rm.Count.ToString;

    ShowInBar(0, 'Файл', TMenuAction.CreateUser(fm[0],'Файл', 18), 0);
    ShowInBar(0, 'Файл', TMenuAction.CreateUser(fm[1],'Файл', 17), 1);
    ShowInBar(0, 'Файл', TMenuAction.CreateUser(fm[2],'Файл', 19), 2);

    rm[9].Click;
    rm[3].Click;

   // ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[9],'Метрология', 28), 0);
    wm[5].Caption := 'Щрифт окна данных...';
    ShowInBar(0, 'Окна', TMenuAction.CreateUser(wm[5],'Окна', -1), 0);
    rm[5].Caption := 'Щрифт окна метрологии...';
    ShowInBar(0, 'Окна', TMenuAction.CreateUser(rm[5],'Окна', -1), 0);

    ShowInBar(0, 'Метрология.Метод', TMenuAction.CreateUser(rm[10],'Метрология', -1), 1);
    ShowInBar(0, 'Метрология.Метод', TMenuAction.CreateUser(rm[11],'Метрология', -1), 2);
    ShowInBar(0, 'Метрология.Метод', TMenuAction.CreateUser(rm[21],'Метрология', 68), 3);
    ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[13],'Метрология', 48), 3);
    ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[12],'', -1), 4);
    ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[14],'Метрология', 40), 5);
  //  ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[15],'Метрология', 18), 6);
  //  ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[16],'Метрология', 18), 7);
  //  ShowInBar(0, 'Метрология.Метод', TMenuAction.CreateUser(rm[17],'Метрология', -1), 3);

    ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[20],'Метрология', 118), 9);
    ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[19],'Метрология', 59), 10);
    ShowInBar(0, 'Метрология', TMenuAction.CreateUser(rm[22],'Метрология', 59), 11);
  finally
   LockWindowUpdate(0);
  end;
end;

{$REGION 'intf'}
procedure TFormEasyIntf.LoadArrayString(const Root: String; var Value: TArray<string>; Registry: Boolean);
 var
  i: Integer;
begin
  SetLength(Value, xini.ReadInteger(Root+ '\ItemCount',0));
  for i := 0 to Length(Value)-1 do Value[i] := xini.ReadString(Root+ '\Item'+i.ToString, '');
end;

function TFormEasyIntf.LoadString(const Name, DefValue: String; Registry: Boolean): String;
begin
  Result := xini.ReadString(Name, DefValue);
end;

procedure TFormEasyIntf.SaveArrayString(const Root: String; const Value: TArray<string>; Registry: Boolean);
 var
  i: Integer;
begin
  xini.DeleteSubTree(Root);
  xini.WriteInteger(Root+ '\ItemCount', Length(Value));
  for i := 0 to Length(Value)-1 do xini.WriteString(Root+ '\Item'+i.ToString, Value[i]);
end;

procedure TFormEasyIntf.SaveString(const Name, Value: String; Registry: Boolean);
begin
  xini.WriteString(Name, Value);
end;

procedure TFormEasyIntf.SetIndexInBar(BarID: Integer; const ACaption: string; Index: Integer);
begin
  TActionBarHelper.Index(ActionManager.ActionBars[BarID], ACaption, Index);
end;
procedure TFormEasyIntf.ShowInBar(BarID: Integer; const path: TArray<TMenuPath>; Action: IAction; ActionIndex: Integer);
begin
  TActionBarHelper.ShowArr(ActionManager.ActionBars[BarID], path, Action, ActionIndex);
end;

procedure TFormEasyIntf.UpdateWidthBars;
begin

end;

procedure TFormEasyIntf.SaveActionManager;
begin

end;

procedure TFormEasyIntf.ResetActions;
begin

end;

procedure TFormEasyIntf.ShowInBar(BarID: Integer; const path: string; Action: IAction; Index: Integer = -1);
begin
  TActionBarHelper.Show(ActionManager.ActionBars[BarID], path, Action, Index);
  ActionManager.ActionBars[BarID].ActionBar.RecreateControls;
end;
procedure TFormEasyIntf.HideInBar(BarID: Integer; Action: IAction);
begin
 // TActionBarHelper.hide(ActionManager.ActionBars[BarID], Action);
end;
function TFormEasyIntf.HideUnusedMenus: boolean;
begin
  Result := False;
 // while TActionBarHelper.HideUnusedMenus(ActionManager) do Result := True;
end;
procedure TFormEasyIntf.RegisterAction(Action: IAction);
begin
  TCustomAction(Action.GetComponent).ActionList := ActionManager;
end;
{$ENDREGION}

type
  TDeviceEnum = class(TRootServiceManager<IDevice>, IDeviceEnum);
  TConnectEnum = class(TRootServiceManager<IConnectIO>, IConnectIOEnum);

{ TMenuAction }

constructor TMenuAction.CreateUser(Amenu: TMenuItem; const Categoty: string; ImagIndex: integer);
begin
  Fmenu := Amenu;
//  Self.Assign(Fmenu);
  CreateUser(Fmenu.Caption, Category, ImagIndex);
  inc(Index);
  (Self as IManagItem).IName := 'MenuAction' + Index.ToString;
  Enabled := Fmenu.Enabled;
  AutoCheck := Fmenu.AutoCheck;
  Checked := Fmenu.Checked;
  (GlobalCore as IActionEnum).Add(Self as IManagItem);
  (GlobalCore as IActionProvider).RegisterAction(self as IAction);
end;

destructor TMenuAction.Destroy;
begin

  inherited;
end;

function TMenuAction.Execute: Boolean;
begin
  Result := True;
  Fmenu.Click;
end;

function TMenuAction.Update: Boolean;
begin
  Result := True;
  Checked := Fmenu.Checked;
  Enabled := Fmenu.Enabled;
  Caption := Fmenu.Caption;
end;

initialization
  TRegister.AddType<TDeviceEnum, IDeviceEnum, IStorable>.LiveTime(ltSingleton);
  TRegister.AddType<TConnectEnum, IConnectIOEnum, IStorable>.LiveTime(ltSingleton);
end.
