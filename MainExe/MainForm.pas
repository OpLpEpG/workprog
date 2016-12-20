unit MainForm;

interface

uses DeviceIntf, ExtendIntf, RootIntf, IndexBuffer,
  Winapi.Messages, System.Variants, Vcl.HtmlHelpViewer,  XMLScript.Math, XMLScript.IKN, XMLScript.Report,
  System.SysUtils, PluginAPI, Vcl.Dialogs, Vcl.ImgList, Vcl.Controls, Vcl.StdActns, Vcl.BandActn, System.Classes, Vcl.ActnList, Vcl.ActnMan,
  Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.ComCtrls, Vcl.Forms, Vcl.Graphics, Winapi.Windows, JvAppStorage, JvAppRegistryStorage, JvDockControlForm,
  Vcl.AppEvnts, Vcl.ExtCtrls, JvFormPlacement, JvDockVIDStyle, JvComponentBase, System.Actions,
  System.Generics.Collections,
  System.Generics.Defaults,  JvDockSupportControl,
  JvDockVSNetStyle, JvDockTree, Vcl.ToolWin, Vcl.PlatformDefaultStyleActnCtrls, System.ImageList, JvAppXMLStorage;

const
  DEF_SCREEN = 'ScreenDefault';
  REG_PATH = 'Software\AMKGorizont\WorkProg';


type
  TFormMain = class(TForm, IImagProvider, IActionProvider, IRegistry, ITabFormProvider, IMainScreen, IProject)
    ActionManager: TActionManager;
    CustomizeActionBars: TCustomizeActionBars;
    ActionUpdate: TAction;
    ActionExit: TAction;
    ActionSaveDesktop: TAction;
    ActionLoadDesktop: TAction;
    ActionPluginSetup: TAction;
    ImageList: TImageList;
    rini: TJvAppRegistryStorage;
    ControlBar: TControlBar;
    MainMenu: TActionMainMenuBar;
    ToolBar1: TActionToolBar;
    ToolBar2: TActionToolBar;
    sb: TStatusBar;
    ActionExceptForm: TAction;
    FormStorage: TJvFormStorage;
    ApplicationEvents: TApplicationEvents;
    pc: TPageControl;
    JvDockServer: TJvDockServer;
    JvDockVSNetStyle: TJvDockVSNetStyle;
    xini: TJvAppXMLFileStorage;
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
//    procedure TimerTimer(Sender: TObject);
    procedure ActionExceptFormExecute(Sender: TObject);
    procedure pc1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure CustomizeActionBarsCustomizeDlgClose(Sender: TObject);
//    procedure PrjNewAccept(Sender: TObject);
//    procedure PrjOpenAccept(Sender: TObject);
//    procedure PrjCloseExecute(Sender: TObject);
//    procedure SetupProjectExecute(Sender: TObject);
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
    procedure ResetActions();
    // IRegistry
    procedure SaveString(const Name, Value: String; Registry: Boolean = False);
    function LoadString(const Name, DefValue: String; Registry: Boolean = False): String;
    procedure SaveArrayString(const Root: String; const Value: TArray<string>; Registry: Boolean = False);
    procedure LoadArrayString(const Root: String; var Value: TArray<string>; Registry: Boolean = False);
    //  ITabFormProvider (зависит от версии компилятора т.к. использ TDockIForm, TJvDockClient
    function IsTab(const Form: IForm): Boolean;
    procedure Tab(const Form: IForm);
    procedure UnTab(const Form: IForm);
    procedure SetActiveTab(const Form: IForm);
    procedure Dock(const Form: IForm; Corner: Integer);
    //IMainScreen
    procedure IMainScreen.Changed = MainScreenChanged;
    procedure MainScreenChanged;

    function GetStatusBar(index: Integer): string;
    procedure SetStatusBar(index: Integer; const Value: string);

    procedure Lock;
    procedure UnLock;

    //IProject = interface
    function IProject.New = IProjectNew;
    function IProjectNew(out ProjectName: string): Boolean;
    function IProject.Load = IProjectLoad;
    function IProjectLoad(out ProjectName: string): Boolean;
    function IProject.Setup =IProjectSetup;
    function IProjectSetup: Boolean;
    procedure IProject.Close = IProjectClose;
    procedure IProjectClose;
    procedure IProjectInnerLoad(const PrjName: string; isNew: Boolean);
    function GetDecimalSeparator: Char;

  private
    FDecimalSeparator: Char;
    FMainScreenChange: Boolean;
    procedure SaveScreeDialog;
    function ChildFormsBusy: boolean;
    function DeviceBusy: boolean;
//    procedure AfterLoadScreen;
//    procedure SetProjectFile(const Value: WideString);
//    procedure SowPrg(sho: Boolean);
//    procedure WMSync(var Message: TMessage); message WM_SYNC;
  public
    FCurrentScreen: string;
    procedure RegisterProviders;
    procedure LoadNotify;
    procedure LoadScreen(LoadProject: Boolean = False);
    procedure LoadActionManager;
    procedure SaveTabForms();
    procedure LoadTabForms();
    property StatusBar[index: Integer]: string read GetStatusBar write SetStatusBar;
  end;


var
  FormMain: TFormMain;

implementation

{$R *.dfm}


uses GR32, WinAPI.GDIPObj, WinAPI.GDIPApi, RootImpl, VCLTee.TeEngine, DataImportImpl,
    PluginManager, PluginSetupForm, ExceptionForm, tools, DockIForm, debug_except, ActionBarHelper, FirstForm, Container;//, Hock_Exept;

{$REGION  '*********** Create Destroy ****************'}
procedure TFormMain.FormCreate(Sender: TObject);
begin
  TThread.NameThreadForDebugging('__M_A_I_N__');
  Application.HelpFile := ExtractFilePath(ParamStr(0)) + 'help.chm';
//  GDIPlus.Start;

  FDecimalSeparator := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';

  SetErrorMode(SetErrorMode(0) or SEM_NOOPENFILEERRORBOX or SEM_FAILCRITICALERRORS);
  Plugins.SetVersion(VERS1000);

  StatusBar[1] := ExtractFilePath(ParamStr(0)) + 'Default.xml';

  TFormExceptions.This.Icon := 257;
  //  *******************************************8
  //     Регистрация провайдеров сервисов ядра
  //  *******************************************8
  TRegister.AddType<TFormMain, IImagProvider, IActionProvider, IRegistry, ITabFormProvider, IMainScreen, IProject>.LiveTime(ltSingleton).AddInstance(Self as IInterface);
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
//   PrjNew.Dialog.InitialDir := ExtractFilePath(ParamStr(0)) + 'Projects';
    //  *******************************************
    // загрузка плагинов с событием LoadNotify после загрузки осгновной формы !!!
    //  *******************************************
    { TODO : создание разных рабочих столов }
   rini.Root := REG_PATH;
   FCurrentScreen := rini.ReadString('screen', DEF_SCREEN);
   rini.Root := REG_PATH + '\' + FCurrentScreen;
   TFormPluginSetup.LoadPlugins(rini.Root, nil, True);

    // LoadNotify функция вызывается после загрузки плугинов и перед событием LoadNotify
    // регистрируем провайдеры которым нужны для регистрации плугины но желательно до
    // события LoadNotify (LoadNotify провайдеров происходит после пругинов)
  finally
  // if Assigned(FormSplash) then FreeAndNil(FormSplash);
   TFormExceptions.This.NShowDebug.Checked := FormStorage.StoredValue['ErrorInfo'];
   TFormExceptions.This.NDialog.Checked := FormStorage.StoredValue['ErrorDialog'];
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
  else
   begin
    LoadScreen(True);
//    TActionBarHelper.ShowHidenActions(ActionManager);
//    UpdateWidthBars;
   end;
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
//  GDIPlus.Stop;
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
    (GlobalCore as IFormEnum).Clear;
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
   xini.WriteStringList('Tabs', ss);
   xini.WriteInteger('Tabs\ActiveTab', pc.ActivePageIndex);
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
    xini.ReadStringList('Tabs', ss);
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
   i := xini.ReadInteger('Tabs\ActiveTab', 0);
   if (i >= 0) and (i < pc.PageCount) then  pc.ActivePageIndex := i;
  end;
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
   //(GContainer as IProjectOptions).Option['ActionManager'] := ss.DataString;
   xini.WriteString('ActionManager\ObjectText', ss.DataString);
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
  FormStorage.StoredValue['ErrorInfo'] := TFormExceptions.This.NShowDebug.Checked;
  FormStorage.StoredValue['ErrorDialog'] := TFormExceptions.This.NDialog.Checked;
  if Supports(Plugins, IManager, m) then m.SaveScreen();                // формы  обьекты
  try
   SaveDockTreeToAppStorage(xini, 'DockTree'); // Dock manager (зависит от версии компилятора т.к. использ TForm, TJvDockClient)
  except
   on E: Exception do TDebug.DoException(E, False);
  end;
  SaveTabForms();                         // Tab forms (зависит от версии компилятора т.к. использ TForm, TJvDockClient)
  SaveActionManager;                 // Action manager основной формы
  FormStorage.SaveFormPlacement;      // сохранение cool bar основной формы
  //FormPlacement.SaveFormPlacement;      // сохранение cool bar основной формы
  //xini.Flush; // !!!
  (GContainer as IProjectOptions).Option['CurrentScreen'] := xini.AsString;
  rini.Flush;
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
  if  xini.ValueStored('ActionManager\ObjectText') then
//  if  not VarIsNull((GContainer as IProjectOptions).Option['ActionManager']) then
   begin
    ss := TStringStream.Create;
    ms := TMemoryStream.Create;
    try
     ss.WriteString(xini.ReadString('ActionManager\ObjectText', ''));
     //ss.WriteString((GContainer as IProjectOptions).Option['ActionManager']);
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

procedure TFormMain.ResetActions();
 var
  a: IAction;
  ar: TArray<IAction>;
begin
  ar := GContainer.InstancesAsArray<IAction>(True);
  Tarray.Sort<IAction>(ar, TComparer<IAction>.Construct(function(const Left, Right: IAction): Integer
  begin
    Result := string.Compare(Left.GetPath, Right.GetPath);
  end));
  LoadActionManager; // скрывает часть { TODO : проблемма с - и логикой действий}
  for a in ar do
   begin
    if not a.OwnerExists then
     begin
      GContainer.RemoveInstance(a.Model, a.IName);
     end
    else if not Assigned(ActionManager.FindItemByAction(TCustomAction(a.GetComponent))) then
     begin
      a.DefaultShow;
     end;
   end;
  if HideUnusedMenus then
   begin
    UpdateWidthBars;
    SaveActionManager;
   end;
end;

procedure TFormMain.LoadScreen(LoadProject: Boolean = False);
// var
//  m: IManager;
begin
  StatusBar[1] := rini.ReadString('CurrentProject');
  IProjectInnerLoad(StatusBar[1], False);
 { BeginDockLoading;
  try
    //xini.Reload; // !!!
    StatusBar[1] := rini.ReadString('CurrentProject');
    if Supports(Plugins, IManager, m) then
     begin
      if LoadProject and (StatusBar[1] <> '') then m.LoadProject(StatusBar[1]);
      (GContainer as IProjectOptions).AddOrIgnore('CurrentScreen', 'Screen');

      if not VarIsNull((GContainer as IProjectOptions).Option['CurrentScreen']) then
         xini.AsString := (GContainer as IProjectOptions).Option['CurrentScreen'];

      m.LoadScreen();                 //  загрузка текстов обьектов - форм actions
     end;

    // create actions
    ResetActions;     // показывает все

    // create forms
    GContainer.InstancesAsArray<IForm>(True);


    LoadDockTreeFromAppStorage(xini, 'DockTree');
    LoadTabForms();

    FormStorage.RestoreFormPlacement;
//    AfterLoadScreen;
  finally
    EndDockLoading;
  end; }
end;

{procedure TFormMain.PrjCloseExecute(Sender: TObject);
 var
  m: IManager;
begin
  LockWindowUpdate(Handle);
  try
   if not Supports(Plugins, IManager, m) then Exit;
   StatusBar[1] := '';
   m.LoadProject(StatusBar[1]);
   ini.WriteString('CurrentProject', StatusBar[1]);
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
   StatusBar[1] := PrjNew.Dialog.FileName;
   m.NewProject(StatusBar[1]);
   ini.WriteString('CurrentProject', StatusBar[1]);
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
   StatusBar[1] := PrjOpen.Dialog.FileName;
   m.LoadProject(StatusBar[1]);
   ini.WriteString('CurrentProject', StatusBar[1]);
   ResetActions;
  finally
   LockWindowUpdate(0);
  end;
end;    }
{$ENDREGION  *********** SAVE LOAD ****************}


{$REGION  '*********** Providers ****************'}
// IRegistry
procedure TFormMain.SaveArrayString(const Root: String; const Value: TArray<string>; Registry: Boolean = False);
 var
  i: Integer;
  s: TJvCustomAppStorage;
begin
  if Registry then s := rini else s := xini;
  s.DeleteSubTree(Root);
  s.WriteInteger(Root+ '\ItemCount', Length(Value));
  for i := 0 to Length(Value)-1 do s.WriteString(Root+ '\Item'+i.ToString, Value[i]);
end;

procedure TFormMain.LoadArrayString(const Root: String; var Value: TArray<string>; Registry: Boolean = False);
 var
  i: Integer;
  s: TJvCustomAppStorage;
begin
  if Registry then s := rini else s := xini;
  SetLength(Value, s.ReadInteger(Root+ '\ItemCount',0));
  for i := 0 to Length(Value)-1 do Value[i] := s.ReadString(Root+ '\Item'+i.ToString, '');
end;

function TFormMain.LoadString(const Name, DefValue: String; Registry: Boolean = False): String;
 var
  s: TJvCustomAppStorage;
begin
  if Registry then s := rini else s := xini;
  Result := s.ReadString(Name, DefValue);
end;

procedure TFormMain.SaveString(const Name, Value: String; Registry: Boolean = False);
 var
  s: TJvCustomAppStorage;
begin
  if Registry then s := rini else s := xini;
  s.WriteString(Name, Value);
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
function TFormMain.GetDecimalSeparator: Char;
begin
  Result := FDecimalSeparator;
end;

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
 // IScreen
procedure TFormMain.MainScreenChanged;
begin
  FMainScreenChange := True;
end;
procedure TFormMain.Lock;
begin
  LockWindowUpdate(Handle);
end;
procedure TFormMain.UnLock;
begin
  LockWindowUpdate(0);
end;
function TFormMain.GetStatusBar(index: Integer): string;
begin
 Result := sb.Panels[index].Text;
end;
procedure TFormMain.SetStatusBar(index: Integer; const Value: string);
begin
  sb.Panels[index].Text := Value;
end;

 /// IProject
procedure TFormMain.IProjectInnerLoad(const PrjName: string; isNew: Boolean);
 var
  m: IManager;
  AfterCreateProject: Tproc;
begin
  AfterCreateProject := procedure
   var
    sa: TArray<IStorable>;
    s: IStorable;
  begin
    (GlobalCore as IFormEnum).Clear;

    (GContainer as IProjectOptions).AddOrIgnore('CurrentScreen', 'Screen');

    if not VarIsNull((GContainer as IProjectOptions).Option['CurrentScreen']) then
       xini.AsString := (GContainer as IProjectOptions).Option['CurrentScreen'];

    // m.LoadScreen();                 //  загрузка текстов!!! обьектов - форм actions
    sa := GContainer.InstancesAsArray<IStorable>(true);
    TArray.Sort<IStorable>(sa, TManagItemComparer<IStorable>.Create);
    for s in sa do s.Load;
  end;

    //xini.Reload; // !!!
    try
      if Supports(Plugins, IManager, m) then
       if isNew then m.NewProject(PrjName, AfterCreateProject)
       else m.LoadProject(PrjName, AfterCreateProject);
    finally
      BeginDockLoading;
      try
        // create actions
        ResetActions;     // показывает все { TODO : проблемма с - и логикой действий}

        // create forms
        GContainer.InstancesAsArray<IForm>(True);

        LoadDockTreeFromAppStorage(xini, 'DockTree');
        LoadTabForms();

        FormStorage.RestoreFormPlacement;

        //FormPlacement.RestoreFormPlacement;
      finally
        EndDockLoading;
      end;
    end;
end;

function TFormMain.IProjectNew(out ProjectName: string): Boolean;
 var
  me: IManagerEx;
  m: IManager;
  s: string;
begin
  Result := True;
  with TOpenDialog.Create(nil) do
  try
   if Supports(GContainer, IManagerEx, me) then
    begin
     DefaultExt := me.GetProjectDefaultExt;
     Filter :=  me.GetProjectFilter;
     InitialDir := me.GetProjectDirectory;
    end
   else
    begin
     DefaultExt := 'db';
     Filter := 'Файл проекта (*.db)|*.db';
     InitialDir := ExtractFilePath(ParamStr(0))+ '\Projects';
    end;
   Options := [ofOverwritePrompt,ofHideReadOnly,ofEnableSizing];
   if not Execute() then Exit(False);
   IProjectInnerLoad(FileName, True);
   if Supports(GContainer, IManager, m) then
    begin
     s := m.ProjectName;
     rini.WriteString('CurrentProject', s);
     ProjectName := s;
     StatusBar[1] := s;
    end;
  finally
   Free;
  end;
end;

procedure TFormMain.IProjectClose;
 var
  m: IManager;
  CanClose: Boolean;
begin
  SaveScreeDialog;
  CanClose := not (ChildFormsBusy or DeviceBusy);
  if not CanClose then Exit;
  BeginDockLoading;
  try
    (GlobalCore as IFormEnum).Clear;
    //xini.Reload; // !!!
    if Supports(Plugins, IManager, m) then m.LoadProject('');

    // create actions
    ResetActions;     // показывает все { TODO : проблемма с - и логикой действий}
    rini.WriteString('CurrentProject', '');
    StatusBar[1] := '';
  finally
    EndDockLoading;
  end;
end;

function TFormMain.IProjectLoad(out ProjectName: string): Boolean;
 var
  me: IManagerEx;
  s: string;
  CanClose: Boolean;
begin
  SaveScreeDialog;
  CanClose := not (ChildFormsBusy or DeviceBusy);
  if not CanClose then Exit;
  Result := True;
  with TOpenDialog.Create(nil) do
  try
   if Supports(GContainer, IManagerEx, me) then
    begin
     DefaultExt := me.GetProjectDefaultExt;
     Filter :=  me.GetProjectFilter;
     InitialDir := me.GetProjectDirectory;
    end
   else
    begin
     DefaultExt := 'db';
     Filter := 'Файл проекта (*.db)|*.db';
     InitialDir := ExtractFilePath(ParamStr(0))+ '\Projects';
    end;
   Options := [ofReadOnly,ofHideReadOnly,ofPathMustExist,ofFileMustExist,ofEnableSizing];
   if not Execute() then Exit(False);
   IProjectInnerLoad(FileName, False);
   s := (GContainer as IManager).ProjectName;
   rini.WriteString('CurrentProject', s);
   ProjectName := s;
   StatusBar[1] := s;
  finally
   Free;
  end;
end;

function TFormMain.IProjectSetup: Boolean;
 var
  d: Idialog;
  dp: IDialog<Pointer>;
begin
  Result := (StatusBar[1] <> '') and RegisterDialog.TryGet<Dialog_SetupProject>(d) and Supports(d, IDialog<Pointer>, dp);
  if Result then dp.Execute(nil);
end;


{$ENDREGION  '*********** Providers ****************'}


{$REGION 'trach'}
//procedure TFormMain.SetProjectFile(const Value: WideString);
//begin
//  StatusBar[1] := Value;
//  sb.Panels[1].Text := FProjectFile;
//end;

{procedure TFormMain.SetupProjectExecute(Sender: TObject);
 var
  d: Idialog;
  dp: IDialog<Pointer>;
begin
  if StatusBar[1] = '' then Exit;
  if RegisterDialog.TryGet<Dialog_SetupProject>(d) then
   if Supports(d, IDialog<Pointer>, dp ) then dp.Execute(nil);
end;}

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

procedure TFormMain.Dock(const Form: IForm; Corner: Integer);
 var
  Source: TJvDockDragDockObject;
  f: TForm;
begin
  f := TForm(Form.GetComponent);
  JvDockServer.LeftDockPanel.Width := f.Width;
  F.ManualDock(JvDockServer.LeftDockPanel , nil, JvDockServer.LeftDockPanel.Align);
  JvDockServer.LeftDockPanel.ShowDockPanel(True, F);
end;

//procedure TFormMain.SowPrg(sho: Boolean);
//begin
//  ActionManager.FindItemByCaption('Проект').Visible := Sho;
//  ActionManager.FindItemByCaption('Новый проект...').Visible := Sho;
//  ActionManager.FindItemByCaption('Открыть проект...').Visible := Sho;
//  ActionManager.FindItemByCaption('Закрыть проект').Visible := Sho;
//  ActionManager.FindItemByCaption('Свойства проекта').Visible := Sho;
//  if not sho and (ProjectFile <> '') then PrjCloseExecute(nil);
//end;

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

procedure TFormMain.CustomizeActionBarsCustomizeDlgClose(Sender: TObject);
begin
  UpdateWidthBars;
end;

//procedure TFormMain.ToolBarCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
//begin
 // if NewHeight > 24 then NewHeight := 24;
//end;

//procedure TFormMain.TimerTimer(Sender: TObject);
// var
//  tn: TTime;
//  Fts: Variant;
//  Ftd: Variant;
//  Ftw: Variant;
//  s: string;
//  ds: DelayStatus;
//  dm: IDelayManager;
//begin
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
//end;

{$ENDREGION}

// *****************************************************************************
// **************         Тестовые функции          ****************************
// *****************************************************************************


//initialization
// ReportMemoryLeaksOnShutdown := True;
end.
