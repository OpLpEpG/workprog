unit Plot.Controls;

interface

uses
  RootImpl, PluginAPI, RootIntf, tools, debug_except, ExtendIntf, FileCachImpl,
  CustomPlot, System.UITypes, System.Bindings.Helper, System.IOUtils,
  DataSetIntf, Data.DB, Vcl.Grids, Vcl.Dialogs, SysUtils, Controls, Messages,
  Winapi.Windows, Classes, System.Rtti, types, Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Themes, Vcl.GraphUtil;

type
  TPlotMenu = class(TCustomContextPlotPopup)
  private
    FNRootAddColumn, FNRootEditGraph, FNUpdateDataGraph: TContextMenuItem;
    FFirstMenuIndex: Integer;
    FGraph: TCustomGraph;
    FColumn: TGraphColmn;
    FRegion: TGraphRegion;
    FParam: TGraphPar;
    procedure BeforeEditParams(Sender: TObject);
    procedure AfteEditParams(Sender: TObject);
    procedure SetFirstMenuIndex(const Value: Integer);
    procedure AddColumnClick(Sender: TObject);
    procedure DeleteColumnClick(Sender: TObject);
    procedure LegendRowVisblChahgeClick(Sender: TObject);
    procedure InfoRowVisblChahgeClick(Sender: TObject);
    procedure EditColumnClick(Sender: TObject);
    procedure EditGraphClick(Sender: TObject);
    procedure UpdateGraphClick(Sender: TObject);
    procedure DeleteParamClick(Sender: TObject);
    procedure EditParamClick(Sender: TObject);
    procedure SelectAllParamsClick(Sender: TObject);
    procedure EditSelParamsClick(Sender: TObject);
    procedure AddParamsClick(Sender: TObject);
    procedure InfoParamClick(Sender: TObject);
    function ToAutoCheck(tip: TGraphRowClass): integer;
    function AddToMenu(const ACaption: string; AClick: TNotifyEvent; ContObj: TObject; MousePos: TPoint; Root: TContextMenuItem = nil; Autocheck: Integer = 0): TContextMenuItem;
  protected
    procedure DoContextPopup(AObject: TObject; Event: TCustomContextPlotPopup.TPopupEvent; MousePos: TPoint); override;
  published
    property FirstMenuIndex: Integer read FFirstMenuIndex write SetFirstMenuIndex;
  end;

implementation

type
  TInnerContextMenuItem = class(TContextMenuItem);

{ TPlotMenu }

function TPlotMenu.AddToMenu(const ACaption: string; AClick: TNotifyEvent; ContObj: TObject; MousePos: TPoint; Root: TContextMenuItem; Autocheck: Integer): TContextMenuItem;
begin
  Result := TInnerContextMenuItem.Create(Self);
  Result.Caption := ACaption;
  Result.OnClick := AClick;
  Result.ContextObj := ContObj;
  Result.ContextMousePos := MousePos;
  if Assigned(Root) then
    Root.Add(Result)
  else
    Self.Items.Add(Result);
  if Autocheck <> 0 then
  begin
    Result.AutoCheck := True;
    Result.Checked := Autocheck = 1;
  end;
end;

procedure TPlotMenu.AfteEditParams(Sender: TObject);
begin
  FGraph.DeFrost;
end;

procedure TPlotMenu.BeforeEditParams(Sender: TObject);
begin
  FGraph.Frost;
end;

procedure TPlotMenu.DoContextPopup(AObject: TObject; Event: TCustomContextPlotPopup.TPopupEvent; MousePos: TPoint);
var
  m: TContextMenuItem;
  i: Integer;
  ccd: TGraphColmn.TColClassData;
  p: TGraphPar;
  s: string;
begin
  case Event of
    ppeGraph:
      begin
        for i := Items.Count - 1 downto 0 do
          if (Items[i] <> FNRootAddColumn) and
             (Items[i] <> FNRootEditGraph) and
             (Items[i] <> FNUpdateDataGraph) and
             (Items[i] is TInnerContextMenuItem) then
            Items[i].Free;
        FGraph := TCustomGraph(AObject);
        if not Assigned(FNRootAddColumn) then
        begin
          FNUpdateDataGraph := AddToMenu('�������� �����', UpdateGraphClick, FGraph, MousePos);
          FNRootEditGraph := AddToMenu('������������� ������...', EditGraphClick, FGraph, MousePos);
          FNRootAddColumn := AddToMenu('�������� �������', nil, FGraph, MousePos);
          for ccd in TGraphColmn.ColClassItems do
            AddToMenu(ccd.DisplayName, AddColumnClick, TObject(ccd.ColCls), MousePos, FNRootAddColumn);
        end;
        AddToMenu('-', nil, FGraph, MousePos);
        AddToMenu('���������� �������', LegendRowVisblChahgeClick, FGraph, MousePos, nil, ToAutoCheck(TCustomGraphLegendRow));
        AddToMenu('���������� ����������', InfoRowVisblChahgeClick, FGraph, MousePos, nil, ToAutoCheck(TCustomGraphInfoRow));
        AddToMenu('-', nil, FGraph, MousePos);
      end;
    ppeColumn:
      begin
        FColumn := TGraphColmn(AObject);
        AddToMenu('-', nil, FColumn, MousePos);
        AddToMenu('������������� �������...', EditColumnClick, FColumn, MousePos);
        AddToMenu('������� �������...', DeleteColumnClick, FColumn, MousePos);
        AddToMenu('-', nil, FColumn, MousePos);
      end;
    ppeRegion:
      begin
        FRegion := TGraphRegion(AObject);
        if FRegion.Row is TCustomGraphLegendRow then
        begin
          m := AddToMenu('���������', nil, FRegion, MousePos);
          AddToMenu('������� ���', SelectAllParamsClick, FRegion, MousePos, m);
          AddToMenu('������������� ���������...', EditSelParamsClick, FRegion, MousePos, m);
        end
        else if FRegion.Row is TCustomGraphInfoRow then
        begin
          m := AddToMenu('���������� ��������', nil, FRegion, MousePos);
          for p in FColumn.Params do
            AddToMenu(p.Title, InfoParamClick, p, MousePos, m);
        end
        else if FRegion.Row is TCustomGraphDataRow then
        begin
          m := AddToMenu('�������� ������...', nil, FRegion, MousePos);
          for s in RegisterDialog.CategoryDescriptions(IMPORT_DB_DIALOG_CATEGORY) do
            AddToMenu(s, AddParamsClick, FRegion, MousePos, m);
        end
      end;
    ppeParam:
      begin
        FParam := TGraphPar(AObject);
        AddToMenu(Format('������� �������� [%s]', [FParam.Title]), DeleteParamClick, FParam, MousePos);
        AddToMenu(Format('������������� �������� [%s] ...', [FParam.Title]), EditParamClick, FParam, MousePos);
      end;
  end;
end;

procedure TPlotMenu.SelectAllParamsClick(Sender: TObject);
var
  p: TGraphPar;
begin
  FGraph.Frost;
  try
    for p in FColumn.Params do
      p.Selected := True;
  finally
    FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.AddColumnClick(Sender: TObject);
begin
  FGraph.Frost;
  try
    FGraph.Columns.Add(TGraphColumnClass(TContextMenuItem(Sender).ContextObj));
  finally
    FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.DeleteColumnClick(Sender: TObject);
begin
  if MessageDlg('������� �������?', TMsgDlgType.mtWarning, [mbOK, mbCancel], 1) = mrOk then
  begin
    FGraph.Frost;
    try
      FreeAndNil(FColumn);
      FGraph.UpdateData;
    finally
      FGraph.DeFrost;
    end;
  end;
end;

procedure TPlotMenu.DeleteParamClick(Sender: TObject);
begin
  FGraph.Frost;
  try
    if Assigned(FParam) then
      FreeAndNil(FParam);
    FGraph.UpdateData;
  finally
    FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.EditColumnClick(Sender: TObject);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then
    (d as IDialog<TGraphColmn>).Execute(FColumn);
end;

procedure TPlotMenu.EditGraphClick(Sender: TObject);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then
    (d as IDialog<TCustomGraph>).Execute(FGraph);
end;

procedure TPlotMenu.EditParamClick(Sender: TObject);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then
    (d as IDialog<TGraphPar>).Execute(FParam);
end;

procedure TPlotMenu.EditSelParamsClick(Sender: TObject);
var
  d: Idialog;
  p: TGraphPar;
  a: TArray<TObject>;
begin
  for p in FColumn.Params do
    if p.Selected then
      CArray.Add<TObject>(a, p);
  if RegisterDialog.TryGet<Dialog_EditArrayParameters>(d) then
    (d as IDialog<TArray<TObject>, TNotifyEvent, TNotifyEvent>).Execute(a, BeforeEditParams, AfteEditParams);
end;

procedure TPlotMenu.InfoParamClick(Sender: TObject);
begin
  { TODO :
If (Fregion.paramIsShow(p)) then exit
else (Fregion.AddParam(p) }
end;

procedure TPlotMenu.InfoRowVisblChahgeClick(Sender: TObject);
var
  r: TGraphRow;
begin
  FGraph.Frost;
  try
    for r in FGraph.Rows.FindRows(TCustomGraphInfoRow) do
      r.Visible := TMenuItem(Sender).Checked;
  finally
    FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.LegendRowVisblChahgeClick(Sender: TObject);
var
  r: TGraphRow;
begin
  FGraph.Frost;
  try
    for r in FGraph.Rows.FindRows(TCustomGraphLegendRow) do
      r.Visible := TMenuItem(Sender).Checked;
  finally
    FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.SetFirstMenuIndex(const Value: Integer);
begin
  FFirstMenuIndex := Value;
end;

function TPlotMenu.ToAutoCheck(tip: TGraphRowClass): integer;
const
  CB: array[Boolean] of Integer = (-1, 1);
var
  r: TGraphRow;
begin
  Result := 0;
  for r in FGraph.Rows.FindRows(tip) do
    Exit(CB[r.Visible])
end;

procedure TPlotMenu.UpdateGraphClick(Sender: TObject);
begin
  FGraph.Frost;
  try
    FGraph.UpdateData;
  finally
    FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.AddParamsClick(Sender: TObject);
var
  d: Idialog;
  m: TContextMenuItem;
  reg: TGraphRegion;
begin
  m := TContextMenuItem(Sender);
  reg := TGraphRegion(m.ContextObj);
  if RegisterDialog.TryGet(IMPORT_DB_DIALOG_CATEGORY, StripHotKey(m.Caption), d) then
    (d as IDialog<TGraphColmn>).Execute(reg.Column);
end;

initialization
//  RegisterClasses([TPlotMenu]);


end.

