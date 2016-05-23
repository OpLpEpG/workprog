unit DockIForm;

interface

uses System.SysUtils, Vcl.Controls, debug_except, Winapi.Windows, Vcl.Graphics, Container, Actns, System.TypInfo,
     DeviceIntf, ExtendIntf, RootImpl, JvDockControlForm, JvDockVSNetStyle, Vcl.ActnPopup, Vcl.Menus, System.Classes, Vcl.Dialogs,
     Vcl.ComCtrls;

type
  ShowNCMenu = set of (sncClose, sncTab, sncDock);

  IDockClient = interface
  ['{978365AC-9C3B-461A-8668-E668D2CCFE96}']
    function GetDockClient: TJvDockClient;
    property DockClient: TJvDockClient read GetDockClient;
    procedure SetNCMenusVisible(const snc: ShowNCMenu);
  end;

  TDockIFormClass = class of TDockIForm;

  TDockIForm = class(TIForm, IDockClient, INotifyBeforeRemove, INotifyBeforeClean)
  private
//    FShowAction: IAction;
    FDockClient: TJvDockClient;
    FDockVSNetStyle: TJvDockVSNetStyle;
    FCaption: string;
    procedure Tab_ItemClick(Sender: TObject);
    procedure Dock_ItemClick(Sender: TObject);
    function IsAutoHidden: Boolean;
    function IsTabbedDocument: Boolean;
    procedure OnFormShowHide(Sender: TObject);
//    procedure CreateShowAction;
    procedure SetCaption(const Value: string);
  protected
   const
    AUTO_CHECK: array[Boolean]of Integer = (0,1);
   var
    NCanClose: Boolean;
    NClose, NTab, NDock: TMenuItem;
    procedure BeforeRemove(); virtual;
   procedure BeforeClean(var CanClean: Boolean); virtual;
    procedure InitializeNewForm; override;
    procedure IShow; override;
//    procedure LoadBeroreAdd(); virtual;
//    procedure BeforeAdd(); virtual;
//    procedure AfteActionManagerLoad(); virtual;
    class function ClassIcon: Integer; virtual;
    procedure Close_ItemClick(Sender: TObject); virtual;
    procedure NCPopup(Sender: TObject); virtual;
//    procedure AddToNCMenu(const ACaption: string; AClick: TNotifyEvent; out Item: TMenuItem; Index: Integer = -1; Autocheck: Integer = -1; Root: TMenuItem = nil); overload;
    function AddToNCMenu(const ACaption: string; AClick: TNotifyEvent = nil; Index: Integer = -1; Autocheck: Integer = -1; Root: TMenuItem = nil): TMenuItem;
    class function GetUniqueForm(const FormName: string): IForm;
  public
    class procedure DoCreateForm(Sender: IAction); virtual;
    destructor Destroy; override;
    procedure SetNCMenusVisible(const snc: ShowNCMenu);
    function GetDockClient: TJvDockClient;
    procedure OnShowAction(Sender: IAction);
  published
    property Caption: string read FCaption write SetCaption;
  end;

//  TDialogIFormClass = class of TDialogIForm;

  TDialogIForm = class(TDockIForm)
  protected
    function GetInfo: PTypeInfo; virtual; abstract;
    procedure Close_ItemClick(Sender: TObject); override;
    function Priority: Integer; override;
  public
    constructor Create; override;
  end;

  TCustomFontIForm = class(TDockIForm)
  private
    procedure NFontClick(Sender: TObject);
  protected
    NFont: TMenuItem;
    procedure DoSetFont(const AFont: TFont); virtual;
    procedure InitializeNewForm; override;
  end;

implementation

{$REGION ' TDockIForm '}

{ TDockIForm }

function TDockIForm.GetDockClient: TJvDockClient;
begin
  Result := FDockClient;
end;

function TDockIForm.IsAutoHidden: Boolean;
var
  ds: TWinControl;
begin
  ds := HostDockSite;
  while (ds <> nil) and (ds.Parent <> nil) and (ds.Parent.HostDockSite <> nil) do ds := ds.Parent.HostDockSite;
  Result := ds is TJvDockVSPopupPanel;
end;

procedure TDockIForm.IShow;
begin
  ShowDockForm(Self);
end;

function TDockIForm.IsTabbedDocument: Boolean;
 var
  t: ITabFormProvider;
begin
  Result := False;
  if Supports(GlobalCore, ITabFormProvider, t) then Result := t.IsTab(Self as IForm);
end;

procedure TDockIForm.InitializeNewForm;
// var
//  n: TMenuItem;
//  pp: TPopupActionBar;
begin
  inherited;
  FDockClient := CreateUnLoad<TJvDockClient>;
  FDockClient.OnFormShow := OnFormShowHide;
  FDockClient.OnFormHide := OnFormShowHide;
  FDockVSNetStyle := CreateUnLoad<TJvDockVSNetStyle>;
  FDockClient.DockStyle := FDockVSNetStyle;
  FDockClient.NCPopupMenu := CreateUnLoad<TPopupActionBar>;
  FDockClient.NCPopupMenu.OnPopup := NCPopup;
  NClose := AddToNCMenu('Закрыть Окно', Close_ItemClick);
  AddToNCMenu('-');
  NTab := AddToNCMenu('Вкладка', Tab_ItemClick);
  NDock := AddToNCMenu('Закрепляемое', Dock_ItemClick);
  AddToNCMenu('-');
  Icon := ClassIcon;
  NCanClose := True;
end;


procedure TDockIForm.NCPopup(Sender: TObject);
begin
  with FDockClient.NCPopupMenu do if (PopupComponent = Self) or (PopupComponent is TPageControl) then
   begin
    Nclose.Enabled := NCanClose;
    Ntab.Enabled := not IsAutoHidden;
    NDock.Enabled := not (IsAutoHidden or IsTabbedDocument);
    Ntab.Checked := IsTabbedDocument;
    NDock.Checked := FDockClient.EnableDock;
   end
  else
   begin
    Nclose.Enabled := False;
    Ntab.Enabled := False;
    NDock.Enabled := False;
   end;
end;

procedure TDockIForm.OnFormShowHide(Sender: TObject);
 var
  da: TIDynamicAction;
  s: string;
begin
  s:= Format('%s_%s',[Name, 'OnShowAction']);
  GContainer.RemoveInstance(TypeInfo(TIDynamicAction), s);
  if Visible then Exit;
  da := TIDynamicAction.CreateUser(Caption, 'Окна', Icon);
  da.Name := s;
  da.InstanceName := Name;
  da.ActionComponentClass := ClassName;
  da.ActionMethodName := 'OnShowAction';
//  da.AddToActionManager('Окна', Caption, ClassIcon, 0);
  TRegister.AddType<TIDynamicAction>.AddInstance(s, da as IInterface);
  (GlobalCore as IActionProvider).RegisterAction(da);
  (GlobalCore as IActionProvider).ShowInBar(0, 'Окна', da as IAction);
//  AfteActionManagerLoad;
end;

procedure TDockIForm.OnShowAction(Sender: IAction);
begin
  ShowDockForm(Self);
end;

procedure TDockIForm.SetCaption(const Value: string);
begin
  FCaption := Value;
  inherited Caption := FCaption;
//  if Assigned(FShowAction) then FShowAction.Caption := FCaption;
end;

procedure TDockIForm.SetNCMenusVisible(const snc: ShowNCMenu);
begin
  NClose.Visible := sncClose in snc;
  NTab.Visible := sncTab in snc;
  NDock.Visible := sncDock in snc;
end;

{procedure TDockIForm.AddToNCMenu(const ACaption: string; AClick: TNotifyEvent; out Item : TMenuItem; Index, Autocheck: Integer; Root: TMenuItem);
begin
  Item := TMenuItem.Create(FDockClient.NCPopupMenu);
  Item.Caption := ACaption;
  Item.OnClick := AClick;
  if Assigned(Root) then Root.Add(Item)
  else FDockClient.NCPopupMenu.Items.Add(Item);
  if Index <> -1 then Item.MenuIndex := Index;
  if Autocheck <> -1 then
   begin
    Item.AutoCheck := True;
    Item.Checked := Autocheck = 1;
   end;
end;}

{procedure TDockIForm.AfteActionManagerLoad;
 var
  ap: IActionProvider;
begin
  CreateShowAction;
  if Supports(GlobalCore, IActionProvider, ap) and Assigned(FShowAction) then
   if not Visible then
      ap.ShowInBar(0,'Окна', FShowAction)
   else
      ap.HideInBar(0, FShowAction);
end;

procedure TDockIForm.BeforeAdd;
begin
  CreateShowAction
end;

procedure TDockIForm.LoadBeroreAdd;
begin
  CreateShowAction
end;}

function TDockIForm.AddToNCMenu(const ACaption: string; AClick: TNotifyEvent; Index, Autocheck: Integer; Root: TMenuItem): TMenuItem;
begin
  Result := TMenuItem.Create(FDockClient.NCPopupMenu);
  Result.Caption := ACaption;
  Result.OnClick := AClick;
  if Assigned(Root) then Root.Add(Result)
  else FDockClient.NCPopupMenu.Items.Add(Result);
  if Index <> -1 then Result.MenuIndex := Index;
  if Autocheck <> -1 then
   begin
    Result.AutoCheck := True;
    Result.Checked := Autocheck = 1;
   end;
end;

procedure TDockIForm.BeforeClean(var CanClean: Boolean);
begin
  HideDockForm(Self); // не удалять !!!
end;

procedure TDockIForm.BeforeRemove;
begin
  HideDockForm(Self); // не удалять !!!
end;

class function TDockIForm.ClassIcon: Integer;
begin
  Result := 305;
end;

procedure TDockIForm.Close_ItemClick(Sender: TObject);
 var
  fe: IFormEnum;
begin
  FDockClient.OnFormShow := nil;
  FDockClient.OnFormHide := nil;
  //HideDockForm(Self); // не удалять !!!
  if Supports(GlobalCore, IFormEnum, fe) then fe.Remove(Self as IForm);
end;

//procedure TDockIForm.CreateShowAction;
// var
//  ap: IActionProvider;
//begin
//  if Assigned(FShowAction) then Exit;
//  if Supports(GlobalCore, IActionProvider, ap) then FShowAction := ap.Create('Окна', Caption, Name +  '_ShowAction', OnShowAction, Icon);
//end;

//destructor TDockIForm.Destroy;
//begin
//  TDebug.Log('TDockIForm.Destroy    '+ Name+ '    ' + caption+ '    ' );
//  FShowAction := nil;
//  inherited;
//end;

destructor TDockIForm.Destroy;
begin
  GContainer.RemoveInstance(TypeInfo(TIDynamicAction), Format('%s_%s',[Name, 'OnShowAction']));
  inherited;
end;

procedure TDockIForm.Dock_ItemClick(Sender: TObject);
begin
  if not IsAutoHidden then FDockClient.EnableDock := not FDockClient.EnableDock
end;

class function TDockIForm.GetUniqueForm(const FormName: string): IForm;
 var
  fe: IFormEnum;
begin
  if Supports(GlobalCore, IFormEnum, fe) then Result := fe.Get(FormName)
  else Result := nil;
  if Assigned(Result) then
   begin
    ShowDockForm(TDockIForm(Result));
    (GlobalCore as ITabFormProvider).SetActiveTab(Result);
   end
  else
   begin
    Result := CreateUser(FormName) as IForm;
    if Assigned(fe) then fe.Add(Result);
    Result.Show;
   end;
end;

class procedure TDockIForm.DoCreateForm(Sender: IAction);
 var
  f: IForm;
  fe: IFormEnum;
begin
  f := CreateUser() as IForm;
  if Supports(GlobalCore, IFormEnum, fe) then fe.Add(f);
  f.Show;
end;

procedure TDockIForm.Tab_ItemClick(Sender: TObject);
 var
  t: ITabFormProvider;
begin
  if Supports(GlobalCore, ITabFormProvider, t) then
   begin
    if t.IsTab(Self as IForm) then t.UnTab(Self as IForm)
    else t.Tab(Self as IForm)
   end;
end;
{$ENDREGION}

{ TDialogIForm }

procedure TDialogIForm.Close_ItemClick(Sender: TObject);
begin
  inherited;
  RegisterDialog.UnInitialize(GetInfo);
end;

constructor TDialogIForm.Create;
begin
  CreateUser('Dialog_' + ClassName);
  FDockClient.EnableDock := False;
end;

function TDialogIForm.Priority: Integer;
begin
  Result := PRIORITY_NoStore;
end;

{ TCustomFontIForm }

procedure TCustomFontIForm.InitializeNewForm;
begin
  inherited;
  NFont := AddToNCMenu('Выбрать шрифт', NFontClick);
end;

procedure TCustomFontIForm.DoSetFont(const AFont: TFont);
begin
  Font := AFont;
end;

procedure TCustomFontIForm.NFontClick(Sender: TObject);
 var
  fd: TFontDialog;
begin
  fd := TFontDialog.Create(nil);
  try
   fd.Font := Font;
   if fd.Execute(Handle) then DoSetFont(fd.Font);
  finally
   fd.Free;
  end;
end;

end.
