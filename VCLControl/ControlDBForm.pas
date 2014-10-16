unit ControlDBForm;

interface

uses RootImpl, ExtendIntf, RootIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, Container,
     System.Classes, System.SysUtils, Vcl.Forms, Vcl.Controls, Vcl.Graphics, Data.DB, DBIntf, DBImpl,
     FireDAC.Comp.Client, FireDAC.Stan.Intf,
     Vcl.Grids, Vcl.DBGrids, Vcl.Menus;

type
  TFormControlDB = class(TDockIForm)
  private
    FColumnMenu: TPopupMenu;
    FColumnsText: string;
    FTableChange: string;
    function GetDBColunms: string;
    procedure SetDBColunms;
    procedure SetProjectChange(const Value: string);
    procedure SetDeviceChange(const Value: string);
    procedure NColumnClick(Sender: TObject);
  protected
    FDBGrid: TDBGrid;
    FDataSource: TDataSource;
    FIConnection: IDBConnection;
    FDataSet: TCustomAsyncADQuery;
    FProject: string;
    FDevice: string;
    procedure Loaded; override;
    procedure DoAfterOpen; virtual;
    procedure CreateConnection; virtual;
    procedure SetTableChange(const Value: string); virtual;
    function GetQueryName: string; virtual; abstract;
    function GetSQL: string; virtual; abstract;
  public
    property ProjectChange: string read FProject write SetProjectChange;
    property DeviceChange: string read FDevice write SetDeviceChange;
    property TableChange: string read FTableChange write SetTableChange;
  published
    property DBColunms: string read GetDBColunms write FColumnsText;
  end;

implementation

uses tools, math;

{ TFormControlTrr }

procedure TFormControlDB.CreateConnection;
begin
  FIConnection := ConnectionsPool.ActiveConnection;
  FDataSet := FIConnection.AddOrGetQuery(GetQueryName);
  FDataSet.SQL.Text := GetSQL;
  FDataSource.DataSet := FDataSet;
end;

procedure TFormControlDB.Loaded;
 var
  m: IManager;
begin
  inherited;
  FColumnMenu := CreateUnLoad<TPopupMenu>;
  FDBGrid := CreateUnLoad<TDBGrid>;
  FDBGrid.Align := alClient;
  FDBGrid.Parent := Self;
  FDBGrid.Font.Color := clBlue;
  FDataSource := CreateUnLoad<TDataSource>;
  FDBGrid.DataSource := FDataSource;
  if Supports(GlobalCore, IManager, m) then
   begin
    Bind('ProjectChange', m, ['S_ProjectChange']);
    SetProjectChange(m.ProjectName);
    Bind('TableChange', m, ['S_TableUpdate']);
   end;
  Bind('DeviceChange', GlobalCore as IDeviceEnum, ['S_AfterAdd', 'S_AfterRemove', 'S_PublishedChanged']);
end;

procedure TFormControlDB.NColumnClick(Sender: TObject);
 var
  m: TMenuItem;
  c: TColumn;
begin
  m := TMenuItem(Sender);
  c := TColumn(Pointer(m.Tag));
  c.Visible := m.Checked;
end;

procedure TFormControlDB.SetDeviceChange(const Value: string);
begin
  FDevice := Value;
  FDataSet.Acquire;
  try
   FDataSet.Refresh;
  finally
   FDataSet.Release
  end;
  DoAfterOpen;
end;

procedure TFormControlDB.SetProjectChange(const Value: string);
begin
  if (FProject <> Value) and ('' <> Value) then
   begin
    FProject := Value;
    CreateConnection();
    FDataSet.Acquire;
    FDataSet.DisableControls;
    try
     FDataSet.Open;
    finally
     FDataSet.Release;
     FDataSet.EnableControls;
    end;
    DoAfterOpen;
   end;
end;

procedure TFormControlDB.SetTableChange(const Value: string);
begin
  FTableChange := Value;
  FDataSet.Acquire;
  try
   if FDataSet.Active then FDataSet.Refresh;
  finally
   FDataSet.Release;
  end;
end;

procedure TFormControlDB.DoAfterOpen;
 var
  i: Integer;
  Item: TMenuItem;
begin
  SetDBColunms;
  FColumnMenu.Items.Clear;
  for I := 0 to FDBGrid.Columns.Count-1 do
   begin
    Item := TMenuItem.Create(FColumnMenu);
    Item.Caption := FDBGrid.Columns[i].FieldName;
    Item.Tag := Integer(Pointer(FDBGrid.Columns[i]));
    Item.AutoCheck := True;
    Item.Checked := FDBGrid.Columns[i].Visible;
    Item.OnClick := NColumnClick;
    FColumnMenu.Items.Add(Item);
   end;
end;

function TFormControlDB.GetDBColunms: string;
// const TOSIGN : array [Boolean] of Integer = (-1, 1);
 var
  a: TArray<Integer>;
  i: Integer;
begin
  SetLength(a, FDBGrid.Columns.Count);
  for I := 0 to FDBGrid.Columns.Count-1 do a[i] :=  FDBGrid.Columns[i].Width;
  Result := TAddressRec(a).ToStr;
end;

procedure TFormControlDB.SetDBColunms;
 var
  i: Integer;
  a: TArray<Integer>;
begin
  for i := 0 to FDBGrid.Columns.Count-1 do FDBGrid.Columns[i].PopupMenu := FColumnMenu;
  if FColumnsText <> '' then
   begin
    a := TAddressRec(FColumnsText);
    for i := 0 to min(Length(a), FDBGrid.Columns.Count)-1 do
     begin
      FDBGrid.Columns[i].Visible := a[i] > 0;
      FDBGrid.Columns[i].Width := a[i];
     end;
   end
  else for i := 0 to FDBGrid.Columns.Count-1 do if FDBGrid.Columns[i].Width > 80 then FDBGrid.Columns[i].Width := 80;
end;

end.
