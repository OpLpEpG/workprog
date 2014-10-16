unit MainForm;

interface

uses DeviceIntf, ExtendIntf, RootIntf,  Winapi.Messages, System.Variants,  IGDIPlus, Vcl.HtmlHelpViewer,  XMLScript.Math,
  System.SysUtils, PluginAPI, Vcl.Dialogs, Vcl.ImgList, Vcl.Controls, Vcl.StdActns, Vcl.BandActn, System.Classes, Vcl.ActnList, Vcl.ActnMan,
  Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.ComCtrls, Vcl.Forms, Vcl.Graphics, Winapi.Windows, JvAppStorage, JvAppRegistryStorage, JvDockControlForm,
  Vcl.AppEvnts, Vcl.ExtCtrls, JvFormPlacement, JvDockVIDStyle, JvComponentBase, System.Actions,
  JvDockVSNetStyle, JvDockTree, Vcl.ToolWin, Vcl.PlatformDefaultStyleActnCtrls;

const
  DEF_SCREEN = 'ScreenDefault';
  REG_PATH = 'Software\AMKGorizont\WorkProg';


type
  TFormMain = class(TForm, IImagProvider, IActionProvider, IRegistry, ITabFormProvider, IMainScreen)
    ActionManager: TActionManager;
    CustomizeActionBars: TCustomizeActionBars;
    ActionUpdate: TAction;
    ActionExit: TAction;
    ActionSaveDesktop: TAction;
    ActionLoadDesktop: TAction;
    ActionPluginSetup: TAction;
    ImageList: TImageList;
    ini: TJvAppRegistryStorage;
    ControlBar: TControlBar;
    MainMenu: TActionMainMenuBar;
    ToolBar1: TActionToolBar;
    ToolBar2: TActionToolBar;
    sb: TStatusBar;
    Timer: TTimer;
    ActionExceptForm: TAction;
    FormStorage: TJvFormStorage;
    ApplicationEvents: TApplicationEvents;
    pc: TPageControl;
    PrjOpen: TFileOpen;
    PrjNew: TFileOpen;
    PrjClose: TAction;
    SetupProject: TAction;
    JvDockServer: TJvDockServer;
    JvDockVSNetStyle: TJvDockVSNetStyle;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionExitExecute(Sender: TObject);
    procedure ActionPluginSetupExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure SaveScreenClick(Sender: TObject);
    procedure Debug_ReloadClick(Sender: TObject);
    procedure ActionUpdateExecute(Sender: TObject);
    procedure ControlBarBandPaint(Sender: TObject; Control: TControl; Canvas: TCanvas; var ARect: TRect; var Options: TBandPaintOptions);
    procedure TimerTimer(Sender: TObject);
    procedure ActionExceptFormExecute(Sender: TObject);
    procedure pc1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure PrjNewAccept(Sender: TObject);
    procedure PrjOpenAccept(Sender: TObject);
    procedure PrjCloseExecute(Sender: TObject);
    procedure SetupProjectExecute(Sender: TObject);
  protected
    // IImagProvider
    procedure GetIcon(Index: integer; Image: TIcon);
    function GetImagList: TImageList;
    // IActionProvider
//    function IActionProvider.Create = CreateAction;
//    function CreateAction(const ACategory, ACaption, AName: WideString; Event: TIActionEvent; ImagIndex: Integer = -1; GroupIndex: Integer = -1): IAction;
    procedure ShowInBar(BarID: Integer; const path: string; Action: IAction; Index: Integer = -1); overload;
    procedure ShowInBar(BarID: Integer; const path: TArray<TMenuPath>; Action: IAction; ActionIndex: Integer = -1); overload;

//    procedure ShowInBar(BarID: Integer; const path: WideString; Action: IAction; Index: Integer = -1);
    procedure HideInBar(BarID: Integer; Action: IAction);
    procedure SetIndexInBar(BarID: Integer; const ACaption: string; Index: Integer);
    procedure RegisterAction(Action: IAction);
    procedure UpdateWidthBars;
    function HideUnusedMenus: boolean;
    procedure SaveActionManager();
    // IRegistry
    procedure SaveString(const Name, Value: WideString);
    function LoadString(const Name, DefValue: WideString): WideString;
    procedure SaveArrayString(const Root: WideString; const Value: TWideStrings);
    procedure LoadArrayString(const Root: WideString; var Value: TWideStrings);
    //  ITabFormProvider (зависит от версии компилятора т.к. использ TDockIForm, TJvDockClient
    function IsTab(const Form: IForm): Boolean;
    procedure Tab(const Form: IForm);
    procedure UnTab(const Form: IForm);
    procedure SetActiveTab(const Form: IForm);
    //IMainScreen
    procedure IMainScreen.Changed = MainScreenChanged;
    procedure MainScreenChanged;
  private
    FMainScreenChange: Boolean;
    FProjectFile: WideString;
    procedure SaveScreeDialog;
    function ChildFormsBusy: boolean;
    function DeviceBusy: boolean;
//    procedure AfterLoadScreen;
    procedure SetProjectFile(const Value: WideString);
    procedure SowPrg(sho: Boolean);
    procedure ResetActions;
//    procedure SetShowDebugErrorData(const Value: boolean);
//    procedure SetShowErrorDialog(const Value: boolean);
//    function GetShowDebugErrorData: boolean;
//    function GetShowErrorDialog: boolean;
//    procedure WMSync(var Message: TMessage); message WM_SYNC;
  public
    FCurrentScreen: string;
    procedure RegisterProviders;
    procedure LoadNotify;
    procedure LoadScreen(LoadProject: Boolean = False);
    procedure LoadActionManager;
    procedure SaveTabForms();
    procedure LoadTabForms();
    property ProjectFile: WideString read FProjectFile write SetProjectFile;
//  published
//    property ShowErrorDialog: boolean read GetShowErrorDialog write SetShowErrorDialog;
//    property ShowDebugErrorData: boolean read GetShowDebugErrorData write SetShowDebugErrorData;
  end;


var
  FormMain: TFormMain;

implementation

{$R *.dfm}


uses RootImpl,
    PluginManager, PluginSetupForm, ExceptionForm, tools, DockIForm, debug_except, ActionBarHelper, FirstForm, Container;//, Hock_Exept;

{$REGION  '*********** Create Destroy ****************'}
procedure TFormMain.FormCreate(Sender: TObject);
begin
  TThread.NameThreadForDebugging('__M_A_I_N__');
  Application.HelpFile := ExtractFilePath(ParamStr(0)) + 'help.chm';
  GDIPlus.Start;

  FormatSettings.DecimalSeparator := '.';

  SetErrorMode(SetErrorMode(0) or SEM_NOOPENFILEERRORBOX or SEM_FAILCRITICALERRORS);
  Plugins.SetVersion(VERS1000);

  FProjectFile := ExtractFilePath(ParamStr(0)) + 'Default.xml';

  TFormExceptions.This.Icon := 257;

  //  *******************************************8
  //     Регистрация провайдеров сервисов ядра
  //  *******************************************8
  TRegister.AddType<TFormMain, IImagProvider, IActionProvider, IRegistry, ITabFormProvider, IMainScreen>.LiveTime(ltSingleton).AddInstance(Self as IInterface);
end;

procedure TFormMain.RegisterProviders;
begin
  TRegister.AddType<TFormMain>.AddInstance(Self as IInterface);
end;

procedure TFormMain.FormShow(Sender: TObject);
// var
//  a: TICustRTTIAction;
begin
  try
   PrjNew.Dialog.InitialDir := ExtractFilePath(ParamStr(0)) + 'Projects';
    //  *******************************************
    // загрузка плагинов с событием LoadNotify после загрузки осгновной формы !!!
    //  *******************************************
    { TODO : создание разных рабочих столов }
   ini.Root := REG_PATH;
   FCurrentScreen := ini.ReadString('screen', DEF_SCREEN);
   ini.Root := REG_PATH + '\' + FCurrentScreen;
   TFormPluginSetup.LoadPlugins(ini.Root, nil, True);
    // LoadNotify функция вызывается после загрузки плугинов и перед событием LoadNotify
    // регистрируем провайдеры которым нужны для регистрации плугины но желательно до
    // события LoadNotify (LoadNotify провайдеров происходит после пругинов)
  finally
   if Assigned(FormSplash) then FreeAndNil(FormSplash);
  end;

  OutputDebugString(PChar('==================  НАЧАЛО РАБОТЫ ПРОГРАММЫ  ================================='));

//  GContainer.Enum<IPlugin>(True);

//  a := TICustRTTIAction.Create;
   // FormGraphLog13109997256: TFormGraphLog
//  a.ActionComponentClass := 'TFormGraphLog';
//  a.ActionMethodName := 'DoCreateForm';
//  a.AddToActionManager('Окна','TEST',123,0);
//  a.Execute;
end;
procedure TFormMain.LoadNotify; // call LoadPlugins
begin
  if (ParamCount >= 1) and (Trim(ParamStr(1)) = '-nl') then ResetActions
  else LoadScreen(True);
end;


procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  procedure ClrItems; // m должен быть локальн.
   var
    m: IManager;
  begin
    if Supports(Plugins, IManager, m) then m.ClearItems;
  end;
begin
  SaveScreeDialog;
  CanClose := not (ChildFormsBusy or DeviceBusy);
  if not CanClose then Exit;
  OutputDebugString(PChar('==================  ЗАКРЫТИЕ ПРОГРАММЫ  ================================='));
  LockWindowUpdate(Handle);
  try
   ClrItems;
   Plugins.UnloadAll;
   TFormExceptions.DeInit();
  finally
   LockWindowUpdate(0);
  end;
//  ini.Root := REG_PATH;
//  ini.WriteString('screen', FCurrentScreen);
end;
procedure TFormMain.FormDestroy(Sender: TObject);
begin
  OutputDebugString(PChar('***************   ВСЕ ИНТЕРФЕЙСЫ И МОДУЛИ ДОЛЖНЫ УЖЕ БЫТЬ ЗАКРЫТЫ  ******************* '));
  GDIPlus.Stop;
end;
{$ENDREGION  '*********** Create Dectroy ****************'}


{$REGION  '*********** SAVE LOAD ****************'}
procedure TFormMain.Debug_ReloadClick(Sender: TObject);
 var
  m: IManager;
begin
  SaveScreeDialog;
  if Supports(Plugins, IManager, m) and not ChildFormsBusy and not DeviceBusy then
   begin
    m.ClearItems([ecForm]);
    LoadScreen();
   end;
end;

procedure TFormMain.SaveTabForms();
 var
  ss: TStrings;
  i : Integer;
begin
  ss := TStringList.Create;
  try
   for i:=0 to pc.PageCount-1 do ss.Add(TForm(pc.Pages[i].Tag).Name);
   ini.WriteStringList('Tabs', ss);
   ini.WriteInteger('Tabs\ActiveTab', pc.ActivePageIndex);
  finally
   ss.Free;
  end;
end;

procedure TFormMain.LoadTabForms();
 var
  d: IFormEnum;
  f: IForm;
  ss: TStrings;
  i: Integer;
begin
 if Supports(Plugins, IFormEnum, d) then
  begin
   ss := TStringList.Create;
   try
    ini.ReadStringList('Tabs', ss);
    for i := 0 to SS.Count-1 do
     for f in d do
      if SameText((f as IManagItem).IName, ss[i]) then
     begin
      Tab(f);
      Break;
     end;
   finally
    ss.Free;
   end;
   i := ini.ReadInteger('Tabs\ActiveTab', 0);
   if (i >= 0) and (i < pc.PageCount) then  pc.ActivePageIndex := i;
  end;
end;

procedure TFormMain.MainScreenChanged;
begin
  FMainScreenChange := True;
end;

procedure TFormMain.SaveActionManager;
// var
//  S: TMemoryStream;
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ActionManager.SaveToStream(ms);
   ms.Position := 0;
   ObjectBinaryToText(ms, ss);
   ini.WriteString('ActionManager\ObjectText', ss.DataString);
  finally
   ss.Free;
   ms.Free;
  end;
//  s := TMemoryStream.Create;
//  try
//   ActionManager.SaveToStream(S);
//   ini.WriteBinary('ActionManager\data', S.Memory, S.Size);
//   ini.WriteInteger('ActionManager\size', S.Size);
//  finally
//   S.Free;
//  end;
end;

procedure TFormMain.SaveScreenClick(Sender: TObject);
 var
  m: IManager;
begin
  FMainScreenChange := False;
  if Supports(Plugins, IManager, m) then m.SaveScreen();                // формы  обьекты
  SaveDockTreeToAppStorage(ini, 'DockTree'); // Dock manager (зависит от версии компилятора т.к. использ TForm, TJvDockClient)
  SaveTabForms();                         // Tab forms (зависит от версии компилятора т.к. использ TForm, TJvDockClient)
  SaveActionManager;                 // Action manager основной формы
  FormStorage.SaveFormPlacement;      // сохранение cool bar основной формы
  ini.Flush; // !!!
end;

//procedure TFormMain.AfterLoadScreen;
// var
//  aaml: INo tifyAf teActionManagerLoad;
//  m: IManager;
//  FlagSave: Boolean;
//  p: IPlugin;
//begin
{  for p in GContainer.Enum<IPlugin> do// .CreateAndExecService<IPluginNotify>(procedure(p: IPluginNotify)
//  GContainer.ExecExistsService<IPlugin>(procedure(p: IPlugin)
  begin
   if Supports(p, INoti fyAfteA ctionManagerLoad, aaml) then aaml.AfteActionManagerLoad();
  end;}
//  if Supports(GlobalCore, IManager, m) then m.NotifyAfteActionManagerLoad;
//  SowPrg((Plugins.IndexOf(FORM_Control) >= 0) and (Plugins.IndexOf(PLUGIN_ComDev) >= 0));{ TODO : восстановить }
//end;

procedure Test(c: TComponent);
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  ss := TStringStream.Create;
  ms := TMemoryStream.Create;
  try
   ms.WriteComponent(c);
   ms.Position := 0;
   ObjectBinaryToText(ms, ss);
   ss.SaveToFile('C:\XE\Projects\Device2\_exe\'+c.Name+'.txt');
  finally
   ss.Free;
   ms.Free;
  end;
end;

procedure TFormMain.LoadActionManager;
 var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  if  ini.ValueStored('ActionManager\ObjectText') then
   begin
    ss := TStringStream.Create;
    ms := TMemoryStream.Create;
    try
     ss.WriteString(ini.ReadString('ActionManager\ObjectText', ''));
     ss.Position := 0;
     ObjectTextToBinary(ss, ms);
     ms.Position := 0;
     ActionManager.LoadFromStream(ms);
    finally
     ss.Free;
     ms.Free;
    end;
   end;
end;

procedure TFormMain.ResetActions;
 var
  a: IAction;
begin
  for a in GContainer.Enum<IAction>(True) do
   begin
    if not a.OwnerExists then GContainer.RemoveInstance(a.Model, a.IName);
    if not Assigned(ActionManager.FindItemByAction(TCustomAction(a.GetComponent))) then a.DefaultShow;
   end;
  if HideUnusedMenus then
   begin
    UpdateWidthBars;
    SaveActionManager;
   end;
end;

procedure TFormMain.LoadScreen(LoadProject: Boolean = False);
 var
  m: IManager;
begin
  BeginDockLoading;
  try
    ini.Reload; // !!!
    ProjectFile := ini.ReadString('CurrentProject');
    if Supports(Plugins, IManager, m) then
     begin
      m.LoadScreen();                 //  загрузка текстов обьектов - форм actions
      if LoadProject and (FProjectFile <> '') then m.LoadProject(FProjectFile);
     end;
    // create actions
    ResetActions;

    // create forms
    GContainer.InstancesAsArray<IForm>(True);

    LoadActionManager;

    LoadDockTreeFromAppStorage(ini, 'DockTree');
    LoadTabForms();

    FormStorage.RestoreFormPlacement;
//    AfterLoadScreen;
  finally
    EndDockLoading;
  end;
end;

procedure TFormMain.PrjCloseExecute(Sender: TObject);
 var
  m: IManager;
begin
  LockWindowUpdate(Handle);
  try
   if not Supports(Plugins, IManager, m) then Exit;
   ProjectFile := '';
   m.LoadProject(ProjectFile);
   ini.WriteString('CurrentProject', ProjectFile);
   ResetActions;
  finally
   LockWindowUpdate(0);
  end;
end;

procedure TFormMain.PrjNewAccept(Sender: TObject);
 var
  m: IManager;
begin
  LockWindowUpdate(Handle);
  try
   if not Supports(Plugins, IManager, m) then Exit;
   ProjectFile := PrjNew.Dialog.FileName;
   m.NewProject(ProjectFile);
   ini.WriteString('CurrentProject', ProjectFile);
   ResetActions;
  finally
   LockWindowUpdate(0);
  end;
end;

procedure TFormMain.PrjOpenAccept(Sender: TObject);
 var
  m: IManager;
begin
  LockWindowUpdate(Handle);
  try
   if not Supports(Plugins, IManager, m) then Exit;
   ProjectFile := PrjOpen.Dialog.FileName;
   m.LoadProject(ProjectFile);
   ini.WriteString('CurrentProject', ProjectFile);
   ResetActions;
  finally
   LockWindowUpdate(0);
  end;
end;
{$ENDREGION  *********** SAVE LOAD ****************}


{$REGION  '*********** Providers ****************'}
// IRegistry
procedure TFormMain.SaveArrayString(const Root: WideString; const Value: TWideStrings);
 var
  i: Integer;
begin
  ini.DeleteSubTree(Root);
  ini.WriteInteger(Root+ '\ItemCount', Length(Value));
  for i := 0 to Length(Value)-1 do ini.WriteString(Root+ '\Item'+i.ToString, Value[i]);
end;

procedure TFormMain.LoadArrayString(const Root: WideString; var Value: TWideStrings);
 var
  i: Integer;
begin
  SetLength(Value, ini.ReadInteger(Root+ '\ItemCount',0));
  for i := 0 to Length(Value)-1 do Value[i] := ini.ReadString(Root+ '\Item'+i.ToString, '');
end;

function TFormMain.LoadString(const Name, DefValue: WideString): WideString;
begin
  Result := ini.ReadString(Name, DefValue);
end;

procedure TFormMain.SaveString(const Name, Value: WideString);
begin
  ini.WriteString(Name, Value);
end;

//ITabFormProvider
procedure TFormMain.pc1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
 var
  i: integer;
begin
  with Sender as TPageControl do
   begin
    if [htOnItem] * GetHitTestInfoAt(MousePos.X, MousePos.Y) <> [] then
     begin
      i := IndexOfTabAt(MousePos.X, MousePos.Y);
      if i >= 0 then ActivePage := Pages[i];
      PopupMenu :=  TDockIForm(ActivePage.tag).GetDockClient.NCPopupMenu;
     end
    else PopupMenu := nil;
   end;
end;

function TFormMain.IsTab(const Form: IForm): Boolean;
 var
  i: Integer;
begin
  Result := False;
  for i := 0 to pc.PageCount-1 do if (TDockIForm(pc.Pages[i].tag) as IForm) = Form then Exit(True)
end;

procedure TFormMain.UnTab(const Form: IForm);
 var
  i: Integer;
  f: TDockIForm;
begin
  BeginDockLoading;
  try
  for i := 0 to pc.PageCount-1 do if (TDockIForm(pc.Pages[i].tag) as IForm) = Form then
   begin
    f := TDockIForm(pc.Pages[i].tag);
    DoFloat(pc, f);
    f.GetDockClient.EnableDock := Boolean(f.Tag);
    Exit;
   end;
  finally
   EndDockLoading;
  end;
end;

procedure TFormMain.UpdateWidthBars;
  procedure SetBar(b: TCustomActionDockBar);
   var
    i: Integer;
  begin
    for I := 0 to b.ActionClient.Items.Count-1 do b.ActionClient.Items[i].Visible := True;
    b.ClientWidth := b.CalcDockedWidth;
  end;
begin
  HideUnusedMenus;
//  Application.HandleMessage;
//  SetBar(MainMenu);
//  SetBar(ToolBar1);
//  SetBar(ToolBar2);
//  Application.HandleMessage;
  SetBar(MainMenu);
  SetBar(ToolBar1);
  SetBar(ToolBar2);
end;

//procedure TFormMain.WMSync(var Message: TMessage);
// var
//  i: Integer;
//begin
//  for i := 0 to  Plugins.Count-1 do Plugins[i].CheckSynchronize;
//  CheckSynchronize;
//end;

procedure TFormMain.Tab(const Form: IForm);
 var
  i: Integer;
  f: TDockIForm;
begin
  BeginDockLoading;
  try
   for i := 0 to pc.PageCount-1 do if (TDockIForm(pc.Pages[i].tag) as IForm) = Form then Exit;
   f := TDockIForm((Form as IInterfaceComponentReference).GetComponent);
   if F.ManualDock(pc) then
    begin
     f.Parent.Tag := Integer(f);
     TTabSheet(f.Parent).ImageIndex := f.Icon;
     f.Tag := Integer(f.GetDockClient.EnableDock);
     f.GetDockClient.EnableDock := False;
     f.Show;
    end;
  finally
   EndDockLoading;
  end;
end;

procedure TFormMain.SetActiveTab(const Form: IForm);
 var
  i: Integer;
begin
  for i := 0 to pc.PageCount-1 do if (TDockIForm(pc.Pages[i].tag) as IForm) = Form then
   begin
    pc.ActivePage := pc.Pages[i];
    Exit;
   end;
end;

// IImagProvider
procedure TFormMain.GetIcon(Index: integer; Image: TIcon);
begin
  ImageList.GetIcon(Index, Image);
end;

function TFormMain.GetImagList: TImageList;
begin
  Result := ImageList;
end;

// IActionProvider
//function TFormMain.CreateAction(const ACategory, ACaption, AName: WideString; Event: TIActionEvent; ImagIndex: Integer = -1; GroupIndex: Integer = -1): IAction;
//begin
//  Result := TIAction.CreateAction(ActionManager, ACategory, ACaption, AName, Event, ImagIndex, GroupIndex);
//end;
procedure TFormMain.SetIndexInBar(BarID: Integer; const ACaption: string; Index: Integer);
begin
  TActionBarHelper.Index(ActionManager.ActionBars[BarID], ACaption, Index);
end;
procedure TFormMain.ShowInBar(BarID: Integer; const path: TArray<TMenuPath>; Action: IAction; ActionIndex: Integer);
begin
  TActionBarHelper.ShowArr(ActionManager.ActionBars[BarID], path, Action, ActionIndex);
end;
procedure TFormMain.ShowInBar(BarID: Integer; const path: string; Action: IAction; Index: Integer = -1);
begin
  TActionBarHelper.Show(ActionManager.ActionBars[BarID], path, Action, Index);
end;
procedure TFormMain.HideInBar(BarID: Integer; Action: IAction);
begin
  TActionBarHelper.hide(ActionManager.ActionBars[BarID], Action);
end;
function TFormMain.HideUnusedMenus: boolean;
begin
  Result := False;
  while TActionBarHelper.HideUnusedMenus(ActionManager) do Result := True;
end;
procedure TFormMain.RegisterAction(Action: IAction);
begin
  TCustomAction(Action.GetComponent).ActionList := ActionManager;
end;



{$ENDREGION  '*********** Providers ****************'}


{$REGION 'trach'}
procedure TFormMain.SetProjectFile(const Value: WideString);
begin
  FProjectFile := Value;
  sb.Panels[1].Text := FProjectFile;
end;

{procedure TFormMain.SetShowDebugErrorData(const Value: boolean);
begin
  TFormExceptions.This.NDialog.Checked := Value;
end;

procedure TFormMain.SetShowErrorDialog(const Value: boolean);
begin
  TFormExceptions.This.NShowDebug.Checked := Value;
end;

function TFormMain.GetShowDebugErrorData: boolean;
begin
  Result := TFormExceptions.This.NShowDebug.Checked;
end;

function TFormMain.GetShowErrorDialog: boolean;
begin
  Result := TFormExceptions.This.NDialog.Checked;
end;}


procedure TFormMain.SetupProjectExecute(Sender: TObject);
 var
  d: Idialog;
  dp: IDialog<Pointer>;
begin
  if ProjectFile = '' then Exit;
  if RegisterDialog.TryGet<Dialog_SetupProject>(d) then
   if Supports(d, IDialog<Pointer>, dp ) then dp.Execute(nil);
end;

function TFormMain.ChildFormsBusy: boolean;
 var
  f: IForm;
  fe: IFormEnum;
  cc: INotifyCanClose;
  cclz: Boolean;
begin
  Result := False;
  if Supports(Plugins, IFormEnum, fe) then
   for f in fe do
    if Supports(f, INotifyCanClose, cc) then
     begin
      cclz := True;
      cc.CanClose(cclz);
      if not cclz then Exit(True);
     end;
end;

procedure TFormMain.SaveScreeDialog;
begin
  if FMainScreenChange and (MessageDlg('Сохранить экран ?', mtWarning, [mbYes, mbNo], 0) = mrYes) then SaveScreenClick(nil);
end;

function TFormMain.DeviceBusy: boolean;
 var
  d: IDevice;
  de: IDeviceEnum;
begin
  Result := False;
  if Supports(Plugins, IDeviceEnum, de) then
   for d in de do
    if not (d.Status in [dsNoInit, dsPartReady, dsReady]) and not d.CanClose then
   begin
    MessageDlg(Format('Прибор [%s] в работе. Необходимо завершить операцию обмена данными', [(d as ICaption).Text]),
               mtWarning, [mbOk], 0);
    Exit(True);
   end;
end;

procedure TFormMain.SowPrg(sho: Boolean);
begin
  ActionManager.FindItemByCaption('Проект').Visible := Sho;
  ActionManager.FindItemByCaption('Новый проект...').Visible := Sho;
  ActionManager.FindItemByCaption('Открыть проект...').Visible := Sho;
  ActionManager.FindItemByCaption('Закрыть проект').Visible := Sho;
  ActionManager.FindItemByCaption('Свойства проекта').Visible := Sho;
  if not sho and (ProjectFile <> '') then PrjCloseExecute(nil);
end;

procedure TFormMain.ActionExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.ActionPluginSetupExecute(Sender: TObject);
begin
  TFormPluginSetup.Execute(REG_PATH + '\'+ FCurrentScreen);
end;

procedure TFormMain.ActionExceptFormExecute(Sender: TObject);
begin
  ShowDockForm(TFormExceptions.This);
  SetActiveTab(TFormExceptions.This as IForm);
end;

procedure TFormMain.ActionUpdateExecute(Sender: TObject);
begin
  TActionBarHelper.ShowHidenActions(ActionManager);
  UpdateWidthBars;
end;

procedure TFormMain.ApplicationEventsException(Sender: TObject; E: Exception);
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

procedure TFormMain.ControlBarBandPaint(Sender: TObject; Control: TControl; Canvas: TCanvas; var ARect: TRect; var Options: TBandPaintOptions);
begin
  if ARect.Contains(MainMenu.BoundsRect) then Options := []
  else Options := [bpoGrabber];
end;

//procedure TFormMain.ToolBarCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
//begin
 // if NewHeight > 24 then NewHeight := 24;
//end;

procedure TFormMain.TimerTimer(Sender: TObject);
 var
  tn: TTime;
  Fts: Variant;
  Ftd: Variant;
  Ftw: Variant;
  s: string;
//  ds: DelayStatus;
//  dm: IDelayManager;
begin
{  if Supports(Plugins, IDelayManager, dm) then with dm do
   begin
    GetDelay(Fts,Ftd,Ftw, ds);
    case ds of
     dsNone: if FProjectFile = '' then
                  sb.Panels[0].Text := 'Нет открытого проекта'
             else sb.Panels[0].Text := 'Не поставлен на задержку';
     dsSetDelay:
      begin
        tn := Double(Ftd) - (Now - Double(Fts));
        if tn < 0 then
         begin
          s := 'время работы прибора ';
          tn := -tn;
          if not VarisNull(Ftw) and (tn > Double(Ftw)) then s := 'время после окончания работы прибора ';
         end
        else s := 'осталось времени до включения прибора ';
        sb.Panels[0].Text := s + MyTimeToStr(tn);
      end;
     dsEndDelay: sb.Panels[0].Text := 'Задержка остановлена';
    end;
   end;}
end;

{$ENDREGION}

// *****************************************************************************
// **************         Тестовые функции          ****************************
// *****************************************************************************


//initialization
// ReportMemoryLeaksOnShutdown := True;
end.
