unit Plot.Controls;

interface

uses RootImpl, PluginAPI, RootIntf, tools, debug_except, ExtendIntf, FileCachImpl, CustomPlot, System.UITypes,
     System.Bindings.Helper, System.IOUtils,
     Vcl.Grids, Vcl.Dialogs,
     SysUtils, Controls, Messages, Winapi.Windows, Classes, System.Rtti, types,
     Vcl.Graphics, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.Themes, Vcl.GraphUtil;

type
  TPlotMenu = class(TCustomContextPlotPopup)
  private
    FNRootAddColumn: TContextMenuItem;
    FFirstMenuIndex: Integer;
    FGraph: TCustomGraph;
    FColumn: TGraphColmn;
    FRegion: TGraphRegion;
    FParam: TGraphPar;
    procedure SetFirstMenuIndex(const Value: Integer);
    procedure AddColumnClick(Sender: TObject);
    procedure DeleteColumnClick(Sender: TObject);
    procedure LegendRowVisblChahgeClick(Sender: TObject);
    procedure InfoRowVisblChahgeClick(Sender: TObject);
    procedure EditColumnClick(Sender: TObject);
    procedure DeleteParamClick(Sender: TObject);
    procedure EditParamClick(Sender: TObject);
    procedure SelectAllParamsClick(Sender: TObject);
    procedure EditSelParamsClick(Sender: TObject);
    procedure AddParamsClick(Sender: TObject);
    procedure InfoParamClick(Sender: TObject);
    function  ToAutoCheck(tip: TGraphRowClass): integer;
    function AddToMenu(const ACaption: string; AClick: TNotifyEvent; ContObj: TObject; MousePos: TPoint;
             Root: TContextMenuItem = nil; Autocheck: Integer = 0): TContextMenuItem;
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
  if Assigned(Root) then Root.Add(Result)
  else Self.Items.Add(Result);
  if Autocheck <> 0 then
   begin
    Result.AutoCheck := True;
    Result.Checked := Autocheck = 1;
   end;
end;

procedure TPlotMenu.DoContextPopup(AObject: TObject; Event: TCustomContextPlotPopup.TPopupEvent; MousePos: TPoint);
 var
  m: TContextMenuItem;
  i: Integer;
  ccd: TGraphColmn.TColClassData;
  p: TGraphPar;
begin
  case Event of
   ppeGraph:
   begin
    for i := Items.Count-1 downto 0 do if (Items[i] <> FNRootAddColumn) and (Items[i] is TInnerContextMenuItem) then Items[i].Free;
    FGraph := TCustomGraph(AObject);
    if not Assigned(FNRootAddColumn) then
     begin
      FNRootAddColumn := AddToMenu('Добавить колонку', nil, FGraph, MousePos);
      for ccd in TGraphColmn.ColClassItems do AddToMenu(ccd.DisplayName, AddColumnClick, TObject(ccd.ColCls), MousePos, FNRootAddColumn);
     end;
    AddToMenu('-', nil, FGraph, MousePos);
    AddToMenu('Показывать легенду', LegendRowVisblChahgeClick, FGraph, MousePos, nil, ToAutoCheck(TCustomGraphLegend));
    AddToMenu('Показывать Информацию', InfoRowVisblChahgeClick, FGraph, MousePos, nil, ToAutoCheck(TCustomGraphInfo));
    AddToMenu('-', nil, FGraph, MousePos);
   end;
   ppeColumn:
   begin
    FColumn := TGraphColmn(AObject);
    AddToMenu('-', nil, FColumn, MousePos);
    AddToMenu('Редактировать колонку...', EditColumnClick, FColumn, MousePos);
    AddToMenu('Удалить колонку...', DeleteColumnClick, FColumn, MousePos);
    AddToMenu('-', nil, FColumn, MousePos);
   end;
   ppeRegion:
   begin
    FRegion := TGraphRegion(AObject);
    if FRegion.Row is TCustomGraphLegend then
     begin
      m := AddToMenu('Параметры', nil, FRegion, MousePos);
      AddToMenu('Выбрать все', SelectAllParamsClick, FRegion, MousePos, m);
      AddToMenu('Редактировать выбранные...', EditSelParamsClick, FRegion, MousePos, m);
     end
    else if FRegion.Row is TCustomGraphInfo then
     begin
      m := AddToMenu('Показывать параметр', nil, FRegion, MousePos);
      for p in FColumn.Params do AddToMenu(p.Title, InfoParamClick, p, MousePos, m);
     end
    else if FRegion.Row is TCustomGraphData then
     begin
      m := AddToMenu('Добавить данные...', AddParamsClick, FRegion, MousePos);
     end
    end;
   ppeParam:
   begin
    FParam := TGraphPar(AObject);
    AddToMenu(Format('Удалить параметр [%s]',[FParam.Title]), DeleteParamClick, FParam, MousePos);
    AddToMenu(Format('Редактировать параметр [%s] ...',[FParam.Title]), EditParamClick, FParam, MousePos);
   end;
  end;
end;

procedure TPlotMenu.SelectAllParamsClick(Sender: TObject);
 var
  p: TGraphPar;
begin
  FGraph.Frost;
  try
   for p in FColumn.Params do p.Selected := True;
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
  if MessageDlg('Удалить колонку?',TMsgDlgType.mtWarning,[mbOK, mbCancel],1) = mrOk then
   begin
    FGraph.Frost;
    try
     FreeAndNil(FColumn);
    finally
     FGraph.DeFrost;
    end;
   end;
end;

procedure TPlotMenu.DeleteParamClick(Sender: TObject);
begin
  FGraph.Frost;
  try
   if Assigned(FParam) then FreeAndNil(FParam);
  finally
   FGraph.DeFrost;
  end;
end;


procedure TPlotMenu.EditColumnClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TGraphColmn>).Execute(FColumn);
end;

procedure TPlotMenu.EditParamClick(Sender: TObject);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_EditViewParameters>(d) then (d as IDialog<TGraphPar>).Execute(FParam);
end;

procedure TPlotMenu.EditSelParamsClick(Sender: TObject);
 var
  d: Idialog;
  p: TGraphPar;
  a: TArray<TObject>;
begin
  for p in FColumn.Params do if p.Selected then CArray.Add<TObject>(a, p);
  if RegisterDialog.TryGet<Dialog_EditArrayParameters>(d) then (d as IDialog<TArray<TObject>>).Execute(a);
end;

procedure TPlotMenu.InfoParamClick(Sender: TObject);
begin
  { TODO :
If (Fregion.paramIsShow(p)) then exit
else (Fregion.AddParam(p) }
end;

procedure TPlotMenu.InfoRowVisblChahgeClick(Sender: TObject);
 var
  r :TGraphRow;
begin
  FGraph.Frost;
  try
   for r in FGraph.Rows.FindRows(TCustomGraphInfo) do r.Visible := TMenuItem(Sender).Checked;
  finally
   FGraph.DeFrost;
  end;
end;

procedure TPlotMenu.LegendRowVisblChahgeClick(Sender: TObject);
 var
  r :TGraphRow;
begin
  FGraph.Frost;
  try
   for r in FGraph.Rows.FindRows(TCustomGraphLegend) do r.Visible := TMenuItem(Sender).Checked;
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
  CB: array [Boolean]of Integer = (-1, 1);
 var
  r :TGraphRow;
begin
  Result := 0;
  for r in FGraph.Rows.FindRows(tip) do Exit(CB[r.Visible])
end;

procedure TPlotMenu.AddParamsClick(Sender: TObject);
 var
  d: Idialog;
  p: TGraphPar;
  a: TArray<TGraphPar>;
begin
//  for p in FColumn.Params do if p.Selected then CArray.Add<TGraphPar>(a, p);
//  if RegisterDialog.TryGet<Dialog_EditArrayParameters>(d) then (d as IDialog<TArray<TGraphPar>>).Execute(
//  procedure (Params: TArray<TGraphPar>)
//  begin
//  end);
end;

end.
