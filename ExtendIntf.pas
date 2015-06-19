unit ExtendIntf;

interface

uses DeviceIntf, PluginAPI, RootIntf, System.UITypes, System.TypInfo, Xml.XMLIntf, Rtti,
     Windows, Vcl.Graphics, SysUtils, VCL.Controls, VCL.Menus, System.Bindings.Expression, System.Classes, Data.DB;

type

  IAction = interface;
  TIActionEvent = procedure (Sender: IAction) of object;

  ///	<summary>
  ///	  <c> устарело </c> создает основная программа плугины вызывают
  ///	  IActionProvider.Create: IAction создается пустое действие
  ///	  зарегистрированное в TActionManager основной формы
  ///	</summary>
  ///	<remarks>
  ///	  Ядро
  ///	</remarks>
  IAction = interface(IManagItem)
  ['{D9BF6110-C97F-4CFF-B10B-EA815C615522}']
//   private
    function GetCaption: String;
    function GetCategory: String;
    function GetChecked: Boolean;
    function GetAutoCheck: Boolean;
    function GetEnabled: Boolean;
    function GetHint: String;
    function GetImageIndex: System.UITypes.TImageIndex;
    function GetGroupIndex: Integer;
//    function GetActionName: String;
//    function GetEventHandler: TIActionEvent;

//    procedure SetActionName(const AValue: String);
    procedure SetCaption(const AValue: String);
    procedure SetCategory(const AValue: String);
    procedure SetChecked(AValue: Boolean);
    procedure SetAutoCheck(AValue: Boolean);
    procedure SetEnabled(AValue: Boolean);
    procedure SetHint(const AValue: String);
    procedure SetImageIndex(AValue: System.UITypes.TImageIndex);
    procedure SetGroupIndex(const AValue: Integer);
//    procedure SetEventHandler(const AEventHandler: TIActionEvent);
    procedure DefaultShow;
    function OwnerExists: Boolean;
    function GetPath: String;
    function DividerBefore: Boolean;
//   public
    property Caption: String read GetCaption write SetCaption;
    property Category: String read GetCategory write SetCategory;
    property AutoCheck: Boolean read GetAutoCheck write SetAutoCheck;
    property Checked: Boolean read GetChecked write SetChecked;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Hint: String read GetHint write SetHint;
//    property Name: String read GetActionName write SetActionName;
    property ImageIndex: System.UITypes.TImageIndex read GetImageIndex write SetImageIndex;
    property GroupIndex: Integer read GetGroupIndex write SetGroupIndex;
//    property EventHandler: TIActionEvent read GetEventHandler write SetEventHandler;
  end;

  IForm = interface(IManagItem)
  ['{0AC2EF7D-DACE-49FC-82D1-7607F8EE47AB}']
    procedure Show;
  end;

  IControlForm = interface(IForm)
  ['{1CBBE75B-6C6B-4C62-8458-79E98D99A4E8}']
    function GetControlName: String;
    procedure SetControlName(const AValue: String);
    property ControlName: String read GetControlName write SetControlName;
  end;

  IRootControlForm = interface(IControlForm)
  ['{555135A4-0322-4C6B-815F-D2DB20C36E6A}']
    function GetSubControlName: String;
    procedure SetSubControlName(const AValue: String);
    property SubControlName: String read GetSubControlName write SetSubControlName;
  end;

  IPlotForm = interface(IForm)
  ['{3B525A57-E0D2-41AC-91FA-F7265005EAEB}']
    function Plot: IInterface;
    procedure SetContextPopupParametr(Parametr: TObject);
  end;

  IDialog = interface(IForm)
  ['{CF5F6A82-A4B3-41C9-9540-F3726204A237}']
    function GetInfo: PTypeInfo;
//    procedure Execute(InputData: IInterface);
    property Info: PTypeInfo read GetInfo;
  end;

  IDialog<T> = interface(IDialog)
  ['{A1E28461-45D5-4D36-B6D6-15D39D2E3548}']
    function Execute(InputData: T): boolean;
  end;

  IActionEnum = interface(IServiceManager<IAction>)
  ['{F52CA2BA-4085-45A1-9EF8-122E8B9C221B}']
  end;

  IFormEnum = interface(IServiceManager<IForm>)
  ['{A58E7139-9DB5-4E1F-8E9E-01BA1D139C61}']
  end;

  // Внутренний  интерфейс IDevice
//  IDeviceName = interface
//  ['{7D8D1998-99EE-423B-B2E3-C8B3FAFDB30D}']
//    function GetDName: string;
//    procedure SetDName(const Value: string);
//    property DName: string read GetDName write SetDName;
//  end;

//  IAddMenus = interface
//  ['{F94C3AE3-D496-4897-9973-8CED4384E9B6}']
//    procedure AddMenus(Root: TMenuItem);
//    procedure ShowInMenu();
//    procedure NotifyRemove();
//  end;

  // Внутренний  интерфейс IManager
  IProjectMetaData = interface
  ['{E273ADFF-A2D3-419D-970F-5F9C31D57481}']
    procedure SetMetaData(Dev: IDevice; Adr: Integer; MetaData: IXMLInfo);
  end;


  IProjectData = interface
  ['{E77FDE33-3D81-465E-9E85-B8EFB0CE1FDE}']
    procedure SaveLogData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; StdOnly: Boolean = False);
    procedure SaveRamData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; CurAdr, CurKadr: Integer; CurTime: TDateTime; ModulID: Integer);
  end;
  // Внутренний  интерфейс IManager3
  IProjectDataFile = interface
  ['{BFD4B4E0-2F3D-4D46-91A6-C5EE6AA97703}']
    procedure SaveLogData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; Row: Pointer; RowLen: Integer);
    procedure SaveRamData(Dev: IDevice; Adr: Integer; Data: IXMLInfo; Row: Pointer; RowLen: Integer);
  end;

  IFileData = interface
  ['{4405AC54-233B-4E82-9065-F1852B93337E}']
    function GetPosition: Int64;
    function GetSize: Int64;
    procedure SetPosition(const Value: Int64);
    function GetFileName: string;
    function Read(Count: Integer; out PData: Pointer; From: Int64 = -1): Integer;
    function Write(Count: Integer; PData: Pointer;  From: Int64 = -1): Integer;
    property FileName: string read GetFileName;
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize;
  end;

  ICashedData = interface
  ['{787172A0-1677-4E86-B473-D9864BD0C552}']
    procedure SetCashSize(const Value: Integer);
    function GetCashSize: Integer;
    function GetMaxCashSize: Int64;
    property CashSize: Integer read GetCashSize write SetCashSize;
    property MaxCashSize: Int64 read GetMaxCashSize;
  end;

  IGlobalMemory = interface
  ['{15385324-B18A-4840-B965-D056CC6EBBE9}']
    function GetMemorySize(Need: Int64): Int64;
  end;

  IProjectOptions = interface
  ['{23652567-6435-44AB-8071-32D486C71F35}']
    function GetOption(const Name: string): Variant;
    procedure SetOption(const Name: string; const Value: Variant);

    procedure AddOrIgnore(const Name, Section: string;
                          const Description: string = '';
                          const SectionDescription: string ='';
                          const Units: string = '';
                          Hidden: Boolean = True;
                          ReadOnly: Boolean = False;
                          DataType: Integer = -1);

    property Option[const Name: string]: Variant read GetOption write SetOption;
  end;

  IMetrology = interface
  ['{60B08497-20FD-4740-8B1B-38710546BC3F}']
    procedure Setup(MetrolID: Integer; TrrData: IXMLInfo; const SourceName: string);
  end;

//  DelayStatus = (dsNone, dsSetDelay, dsEndDelay);
//  IDelayManager = interface
//  ['{7EE80247-D601-408B-8A5F-EDD7526882EB}']
//   procedure SetOnTime(Value: TDateTime);
//   function GetOnTime: TDateTime;
//   procedure SetWorkInterval(Value: TTime);
//   function GetWorkInterval: TTime;
//   property OnTime: TDateTime read GetOnTime write SetOnTime;
//   property WorkInterval: TTime read GetWorkInterval write SetWorkInterval;
//  end;


  IALLMetaData = interface
  ['{918B7422-4172-4618-938E-D89A68AC51DA}']
    {TODO -oOwner -cCategory : global meta data }
    ///	<summary>
    ///	  Get From DB (hold in memory) or Memory
    ///	</summary>
    function Get: IXMLDocument;
    ///	<summary>
    ///	  save to DB from Memory
    ///	</summary>
    procedure Save;
  end;

  IALLMetaDataFactory = interface
  ['{5609F9AD-AB7D-4217-8C22-8584D1E137F1}']
    function Get(const Name: string): IALLMetaData; overload;
    function Get: IALLMetaData; overload;
  end;


  // ************  MainForm  ********************** //

  ITabFormProvider = interface
  ['{2A6743BA-EA91-41A0-A32F-3A6FEBDDB2B2}']
    function IsTab(const Form: IForm): Boolean;
    procedure Tab(const Form: IForm);
    procedure UnTab(const Form: IForm);
    procedure SetActiveTab(const Form: IForm);
  end;

  IImagProvider = interface
  ['{C6444DF2-B8CF-4170-AB0D-CD292F649E69}']
    procedure GetIcon(Index: integer; Image: TIcon);
    function GetImagList: TImageList;
  end;

  TMenuPath = record
    Caption: string;
    Index: Integer;
  end;

  IActionProvider = interface
  ['{8D5E309D-62CF-4E81-A2E6-FBE3A1976ABF}']
//    function Create(const Category, Caption, Name: WideString; Event: TIActionEvent; ImagIndex: Integer = -1; GroupIndex: Integer = -1): IAction;
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
  end;

 // TWideStrings = array of WideString;

  ///	<summary>
  ///	  Читает и Пишет в проект или в реестр
  ///	</summary>
  IRegistry = interface
  ['{BAABFFB6-4B3F-4788-BE0E-29FB35A787EC}']
    procedure SaveString(const Name, Value: String; Registry: Boolean = False);
    function LoadString(const Name, DefValue: String; Registry: Boolean = False): String;
    procedure SaveArrayString(const Root: String; const Value: TArray<string>; Registry: Boolean = False);
    procedure LoadArrayString(const Root: String; var Value: TArray<string>; Registry: Boolean = False);
  end;

  IMainScreen = interface
  ['{140FBD42-770F-4448-A09F-963AC6DFFD2C}']
  // private
    function GetStatusBar(index: Integer): string;
    procedure SetStatusBar(index: Integer; const Value: string);

    procedure Changed;
    procedure Lock;
    procedure UnLock;
    property StatusBarText[index: Integer]: string read GetStatusBar write SetStatusBar;
  end;

  ///	<summary>
  ///   Основная форма проекта поддерживает
  ///   создаются диалоги, сообщения
  ///	</summary>
  IProject = interface
  ['{B3F9B7C5-D224-49B0-A7B4-5EB4541BEF5A}']
    function New(out ProjectName: string): Boolean;
    function Load(out ProjectName: string): Boolean;
    function Setup: Boolean;
    procedure Close;
  end;


  // **********  плугин ************************

// проверяем поддержку особых диалогов для InputData пример IConnectIO как USO или NET IConnectIO
// ISupportDialog = interface
// ['{8A9691C6-1C64-45F3-B496-EDCFAFC74581}']
//   function GetIID: TGUID;
//   property IID: TGUID read GetIID;
// end;

 // Inputdata  Dialog  interface вспомогательный

 // обмен данными по мышке
  StatusDataAsk = (sdaGood, sdaUnknownTypeData, sdaCancel, sdaBadData);
  TAnswerFunc<T> = reference to procedure (Rez: StatusDataAsk; Data: T);
//  IDataAsk = interface
//  ['{00597E97-42AC-4EC4-8350-04D4D1C5A384}']
//    procedure Ask<T>(Data: T; Func: TResultDataAskFunc);
//  end;
//   CAskData = class
//     class procedure Ask<TAsk, TAns>(Data: TAsk; Func: TResultDataAskFunc<TAns>);
//   end;

  TAskRamY = type string;
  TAskPlotFormFormMouse = type string;
  TAnswePlotFormFormMouse = record
   X, Y: Integer;
   Active: Boolean;
   Form: IPlotForm;
  end;

  IDataAsk = interface
  ['{5A5A8DD5-BA93-478F-A41F-BDFA83CDC86F}']
    function Check(Ask, Ans: PTypeInfo): Boolean;
  end;

  IDataAsk<TAsk, TAns> = interface(IDataAsk)
  ['{66931295-08FF-4E89-A4E7-175CB1A80254}']
    function GetTAsk: TAsk;
    procedure Answer(Rez: StatusDataAsk; const Ans: TAns);
    property Ask: TAsk read GetTAsk;
  end;

  IDataAnswer = interface
  ['{471DB150-DD27-4245-9C1F-2ABE01C79269}']
    procedure Answer(Rez: StatusDataAsk);
  end;

  // экспортирование данных в Exel OO Calc

  IReport = interface
  ['{538149EA-4710-4F45-8006-E61E64AFE583}']
    function GetService: Variant;
    function GetDocument: Variant;
    function OpenDocument(const FileName: string): Variant;
    procedure SaveAs(const FileName: String);
    procedure CloseDocument;
    property Service: Variant read GetService;
    property Document: Variant read GetDocument;
  end;

  TStatusAutomatMetrology = (samRun, samEnd, samUserStop, samError);
  TStepMetrologyEvent = procedure (Status: TStatusAutomatMetrology; const info: string) of object;
  IAutomatMetrology = interface
  ['{654DBE65-B914-4F35-8712-29AC48D1516A}']
    procedure StartStep(Step: IXMLNode);
    procedure KadrEvent();
    procedure SetDeviceData(WorkInfo: IXMLNode);
    procedure Stop();
    procedure DoEndMetrology();

//    function GetDelayKadr: Integer;
//    procedure SetDelayKadr(Value: Integer);
//    property DelayKadr: Integer read GetDelayKadr write SetDelayKadr;
  end;

  ITelesistem = interface
  ['{BE13ED50-EC96-4BFD-B77D-61A32828143A}']
  end;

  ITelesisCMD = interface
  ['{5CCFAD9E-3063-4350-8908-804D2E45E0B4}']
    procedure SendCmd(Cmd: Byte);
  end;

  ISetBookMark = interface
  ['{134D0265-857C-4F4D-97C3-AFD80CB8CC87}']
    procedure SetBookMark(BookMark: LongWord);
  end;

{$REGION 'внутренние события между динамическими классами плугинов' }

  ///	<summary>
  ///	  <c> устарело </c>
  ///	</summary>
//  INotifyAfteActionManagerLoad = interface
//  ['{FFD2DC09-35AD-49C3-9031-0993334A99F9}']
//   procedure AfteActionManagerLoad();
//  end;
  ///	<summary>
  ///	  вызывается в цикле записи  в XML перед  записью объекта
  ///	</summary>
  ///	<remarks>
  ///	  GlobalManager
  ///	</remarks>
  INotifyBeforeSave = interface
  ['{1A81A2B9-954F-4F5A-B800-740CB3F53274}']
   procedure BeforeSave();
  end;

  INotifyAfteSave = interface
  ['{EF591C15-12FF-41DA-9BB8-71F4E1E01822}']
   procedure AfteSave();
  end;

  ///	<summary>
  ///	  вызывается в цикле загрузки объектов сразу после загрузки и до 
  ///	  добавления объекта в список
  ///	</summary>
  ///	<remarks>
  ///	  GlobalManager
  ///	</remarks>
//  INotifyLoadBeroreAdd = interface
//  ['{E787910A-FAE6-4BFE-B85E-515189C0598E}']
//   procedure LoadBeroreAdd();
//  end;

  ///	<summary>
  ///	  вызывается в цикле загрузки объектов после добавления объекта в список
  ///	</summary>
  ///	<remarks>
  ///	  GlobalManager
  ///	</remarks>
//  INotifyLoadAfteAdd = interface
//  ['{56969DDB-2A07-4E72-9F33-3EA29130174B}']
//   procedure LoadAfteAdd();
//  end;

  ///	<summary>
  ///	  вызывается в FormCloseQuery 
  ///	</summary>
  ///	<remarks>
  ///	  GlobalManager
  ///	</remarks>
  INotifyCanClose = interface
  ['{C0682375-08AB-4DC0-B974-B0DA8EC86967}']
   procedure CanClose(var CanClose: Boolean);
  end;
  ///	<summary>
  ///	  вызывается в цикле удаления всех динамических объектов  перед 
  ///	  удалением объекта
  ///	</summary>
  ///	<remarks>
  ///	  GlobalManager
  ///	</remarks>
  INotifyBeforeClean = interface
  ['{A6F31492-013D-43ED-AAF9-215D56850791}']
   procedure BeforeClean(var CanClean: Boolean);
  end;

  ///	<summary>
  ///	  вызывается во время пользовательского добавления объекта в список до
  ///	  добавления объекта в список
  ///	</summary>
  ///	<remarks>
  ///	  IEnumer&lt;T: IInterface&gt;.Add
  ///	</remarks>
  INotifyBeforeAdd = interface
  ['{C3E659F1-0645-46D6-944C-FA5B86FAB631}']
   procedure BeforeAdd();
  end;

  ///	<summary>
  ///	  вызывается во время пользовательского добавления объекта в список после
  ///	  добавления объекта в список
  ///	</summary>
  ///	<remarks>
  ///	  IEnumer&lt;T: IInterface&gt;.Add
  ///	</remarks>
  INotifyAfterAdd = interface
  ['{4CD33466-62F3-4420-B4DB-FE2CE3572F97}']
   procedure AfterAdd();
  end;

  ///	<summary>
  ///	  вызывается во время пользовательского удаления объекта из списка до
  ///	  удаления объекта из списка
  ///	</summary>
  ///	<remarks>
  ///	  IEnumer&lt;T: IInterface&gt;.Remove
  ///	</remarks>
  INotifyBeforeRemove = interface
  ['{C7DBD4A9-C19D-40C6-9D71-672586F9E409}']
   procedure BeforeRemove();
  end;

  ///	<summary>
  ///	  вызывается во время пользовательского удаления объекта из списка после
  ///	  удаления объекта из списка
  ///	</summary>
  ///	<remarks>
  ///	  IEnumer&lt;T: IInterface&gt;.Remove
  ///	</remarks>
  INotifyAfterRemove = interface
  ['{F7643533-1ACD-4C33-8D0B-DF3CAD126C19}']
   procedure AfterRemove();
  end;
{$ENDREGION}


implementation


{ CAskData }

//class procedure CAskData.Ask<T>(Data: T; Func: TResultDataAskFunc<T>);
//begin
//
//end;

end.
