 unit RootIntf;

interface

uses Container,
     System.Classes, System.Bindings.Expression, System.Generics.Collections, RTTI, System.TypInfo;

type
  ///	<summary>
  ///	    ���������� ��������� ����������
  ///	</summary>
  IBind = interface
  ['{5D67707A-60C4-46AC-9F7E-2FDC6B5C676A}']
    ///	<summary>
    ///	  ���������� ������ IBindControl.Bind y Source
    ///	</summary>
    procedure _EnableNotify;
    ///	<summary>
    ///	  ������ ���������� ���������
    ///	</summary>
    procedure Notify(const Prop: string);
  end;

//  IBindControl = interface
//  ['{E080FB25-50E2-4949-AA9A-4AB8230D50A8}']
//    ///	<summary>
//    ///	  ���������� �������� ����������
//    ///	</summary>
//    procedure Bind(const ControlExprStr: string; Source: IInterface; const SourceExpr: array of string);
//  end;

//  IBind = interface
//  ['{4191625C-FBA5-4AEA-A36C-E31C54277B31}']
{    ///	<summary>
    ///	  �������������� ������� ������������ ������� ������� ����������
    ///	  ���������
    ///	</summary>
    ///	<param name="Control">
    ///	  ����������� ��������� ������ Self
    ///	</param>
    ///	<param name="ControlExprStr">
    ///	  ��� �������� ������������ �������
    ///	</param>
    ///	<param name="SourceExprStr">
    ///	  ��� ��������������� ���������
    ///	</param>
    ///	<remarks>
    ///	  �������� _Add(const ControlExprStr: string; Expression:
    ///	  TBindingExpression); ������������ ����������
    ///	</remarks>
    procedure CreateManagedBinding(Control: TObject; const ControlExprStr: string; const SourceExpr: array of string);
    ///	<summary>
    ///	  ����������� �� ������� ������������ ���������� Control
    ///	</summary>
    procedure RemoveManagedBinding(const ControlExprStr: string); overload;
    procedure RemoveManagedBinding(const ControlExprStr: array of string); overload;
    procedure RemoveManagedBinding; overload;
    procedure RemoveManagedBinding(Source: TObject); overload;
    ///	<summary>
    ///	  ������������ �� ������ �������� ���� ����� ���������� ������ CreateManagedBinding
    ///	</summary>
    procedure _Add(Source: TObject; const ControlExprStr: string; Expression: TBindingExpression); // inner use

    procedure Notify(const PropName: string);
  end;  }


// ������� ���������������� ����������� ������ ��� �������� ������� ��������

//  IEnum<T: IManagItem> = interface
//    function GetCurrent: T;
//    function MoveNext: Boolean;
//    property Current: T read GetCurrent;
//  end;
//
//  IEnumer = interface
//  ['{8BC2D155-CB98-44A2-B93B-FE2ADACE1E19}']
//    procedure Save(const Storage: IInterface);// ��������� Storage ������������ �� ������ ���������
//    procedure New (const Storage: IInterface);
//    procedure Load(const Storage: IInterface);
//    procedure Clear;
//    function GetVal(const ItemName: string): TValue;
//  end;
//
//  IEnumer<T: IManagItem> = interface(IEnumer)
//    function GetEnumerator: IEnum<T>;
//    procedure Add(const Item: T);
//    procedure Remove(const Item: T);
//    function Get(const ItemName: string): T;
//  end;

// ������ IEnumer Enumer<T: IManagItem> ����� �������� �� ���� ����������
  IServiceManagerType = interface
  ['{C178A420-FB3D-4B5E-BCB2-18359158E357}']
    function GetService: ServiceType;
  end;

  IServiceManager = interface(IServiceManagerType)
  ['{B7A66A2E-2F30-4DC3-BA00-37C95C69BECE}']
    procedure Add(const Item: IManagItem);
    ///	<summary>
    ///   ������� ����� � �� ���� ���� ������ �����������
    ///	  ������� ����������� �������� ������
    ///	</summary>
    procedure Remove(model: ModelType; const Item: string); overload;
    procedure Remove(const Item: string); overload;
    procedure Remove(const Item: IManagItem); overload;
    ///	<summary>
    ///	  ������� ��������� �������� ������
    ///	</summary>
    function GetManagItem(model: ModelType; const ItemName: string; Initialize: Boolean = True): IManagItem; overload;
    function GetManagItem(const ItemName: string; Initialize: Boolean = True): IManagItem; overload;
    procedure Clear();
    ///	<summary>
    ///	  �.�. �������� ���������� �������� �������� �� ��� ���� ����������� �
    ///	  ����� �������� � ��������� Loaded
    ///	</summary>
    ///	<remarks>
    ///	  Add- ���������� ���������������� �������� �������� ItemInitialized
    ///	  �� ������� � ����������
    ///	</remarks>
    procedure ItemInitialized(mi: IManagItem);
  end;

 { ServiceManager = record // helper for IServiceManager
  private
    sm: IServiceManager;
  public
    procedure Remove<C: class>(const Item: string); overload;
    function Get<C: class>(const ItemName: string; Initialize: Boolean = True): IManagItem; overload;
    function Get(const ItemName: string; Initialize: Boolean = True): IManagItem; overload;
    class operator Implicit(const Value: ServiceManager): IServiceManager;
    class operator Implicit(const Value: IServiceManager): ServiceManager;
  end;}

  IServiceManager<T: IManagItem> = interface(IServiceManager)
    function GetEnumerator: TEnumerator<T>; // ��� �������������
    function Enum(Initialize: Boolean = True): TEnumerable<T>; // � ��������������
    function AsArrayRec: TArray<TInstanceRec<T>>;
    function Get(const ItemName: string; Initialize: Boolean = True): T; overload;
    function Get(model: ModelType; const ItemName: string; Initialize: Boolean = True): T; overload;
  end;

  {ServiceManager<T: IManagItem> = record // helper for IServiceManager
  private
    sm: IServiceManager<T>;
  public
    function Get<C: class>(const ItemName: string; Initialize: Boolean = True): T;
    class operator Implicit(const Value: ServiceManager<T>): IServiceManager<T>;
    class operator Implicit(const Value: IServiceManager<T>): ServiceManager<T>;
  end;}

  IStorable = interface(IServiceManagerType)
  ['{6C738181-69CF-49F5-86B7-C2867E13A6FF}']
  // private
//    procedure SetPath(const Value: string);
//    function GetPath: string;
  // public
    procedure New;
    procedure Save;
    procedure Load;
//    property Path: string read GetPath write SetPath;
  end;

  TStatistic = record
    NRead: int64;
    ProcRun: Double;
    Speed: Double; // MB/sec
    TimeToEnd: TTime;
    TimeFromBegin: TTime;
  end;

 EnumCopyAsyncRun = (carOk, carZerroes, carEnd,  carTerminate, carError, carErrorSector);

 const
   COPY_STOP_EVENT = [carZerroes, carEnd,  carTerminate, carError];


implementation

{ ServiceManager }

{class operator ServiceManager.Implicit(const Value: ServiceManager): IServiceManager;
begin
  Result := Value.sm;
end;

class operator ServiceManager.Implicit(const value: IServiceManager): ServiceManager;
begin
  Result.sm := Value;
end;

procedure ServiceManager.Remove<C>(const Item: string);
begin
  sm.Remove(TypeInfo(C), Item);
end;

function ServiceManager.Get(const ItemName: string; Initialize: Boolean): IManagItem;
begin
  Result := sm.GetManagItem(ItemName, Initialize);
end;

function ServiceManager.Get<C>(const ItemName: string; Initialize: Boolean): IManagItem;
begin
  Result := sm.GetManagItem(TypeInfo(C), ItemName, Initialize);
end;}

end.
