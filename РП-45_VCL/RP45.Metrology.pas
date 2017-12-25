unit RP45.Metrology;

interface

uses
  RootIntf, RootImpl, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, Container, Actns, DBIntf, DBImpl, DataExchange,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.TypInfo,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, EditControl, Data.DB, Winapi.GDIPAPI;

type
  TRPRec = record
//   id: Integer;
   nag: Integer;
   tros: Double;
  end;
  TArrayRPRec = array[0..2000] of TRPRec;
  PArrayRPRec =^TArrayRPRec;

  TGraphParamData = record
     Title: string;
     Width: Single;
     Color : TGPColor;
     DashStyle: TDashStyle;
  end;

const
    PRG_NAG = 'Порог нагрузки';
    POI_1 = '1 точка привязки';
    POI_2 = '2 точка привязки';

  GPD_POROG: TGraphParamData = (
    Title: PRG_NAG;
    Width: 2;
    Color: $C0208010;
    DashStyle: DashStyleDot);

  GPD_POI_1: TGraphParamData = (
    Title: POI_1;
    Width: 4;
    Color: $80FF00FF;
    DashStyle: DashStyleDot);

  GPD_POI_2: TGraphParamData = (
    Title: POI_2;
    Width: 4;
    Color: $800080FF;
    DashStyle: DashStyleDot);

type
  TRP45FormDlgMetrol = class(TDialogIForm, IDialog, IDialog<IDevice>)
    Memo: TMemo;
    btRUN: TButton;
    Label1: TLabel;
    edGlu1: TEdit;
    Label2: TLabel;
    edGlu2: TEdit;
    btClose: TButton;
    Label3: TLabel;
    procedure btCloseClick(Sender: TObject);
    procedure btRUNClick(Sender: TObject);
    procedure DataExchageClick(Sender: TObject);
    procedure edKeyPress(Sender: TObject; var Key: Char);
  private
    FPlot: TCustomPlot;
    FSelcol: TGraphColumn;
    FPorog, FPoint1, FPoint2: TGraphParamStrings;
    FRecs: PArrayRPRec;
    FDev: IDevice;
    FDBConn: IDBConnection;
    FQuery: TCustomAsyncADQuery;
    FRamTbl: string;
    FMaxKadr: Integer;
    function ToOption(edit: TCustomEdit): string;
    function FindNagruzka(out Nagr: TGraphParam): Boolean; // для любого глубиномера
    procedure UpdatePoint(pnt: TGraphParamStrings; Y: Double; edit: TCustomEdit);
    procedure UpdatePorog(pr: Double);
    procedure InitPoint(ans: TAnswePlotFormFormMouse; const gpd: TGraphParamData; edKadr: TDataExchangeEdit; var pnt: TGraphParamStrings);
    procedure InitPorog(Ans: TAnswePlotFormFormMouse);
    function FindParam(const tlt: string; out pnt: TGraphParamStrings): boolean;
    function FindColumn(Ans: TAnswePlotFormFormMouse): boolean;
    function CreateParam(const gpd: TGraphParamData; Ans: TAnswePlotFormFormMouse): TGraphParamStrings;
  protected
   const
    SEL_ALL = 'SELECT "РП45.время.DEV","РП45.Глубиномер.ДлинаТроса.CLC","РП45.Глубиномер.Нагрузка.DEV" FROM %s';
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: IDevice): Boolean;
    class function ClassIcon: Integer; override;
  public
    destructor Destroy; override;
  end;

implementation

uses tools;

{$R *.dfm}

{ TRP45FormDlgMetrol }

{$REGION 'Graphics Params'}

function TRP45FormDlgMetrol.FindNagruzka(out Nagr: TGraphParam): Boolean;
 var
  p: TGraphParam;
begin
  Result := False;
  if Assigned(FSelcol) then for p in FSelcol.Params do if p.Title.Contains('Глубиномер') and p.Title.Contains('Нагрузка') then
   begin
    Nagr := p;
    Exit(True);
   end;
end;

function TRP45FormDlgMetrol.FindParam(const tlt: string; out pnt: TGraphParamStrings): boolean;
 var
  p: TGraphParam;
begin
  Result := False;
  for p in FSelcol.Params do if p is TGraphParamStrings then if SameText(p.Title, Tlt) then
   begin
    pnt := TGraphParamStrings(p);
    Exit(True);
   end;
end;

function TRP45FormDlgMetrol.FindColumn(Ans: TAnswePlotFormFormMouse): boolean;
begin
  FSelcol := nil;
  FPlot := TCustomPlot((ans.Form.Plot as IInterfaceComponentReference).GetComponent);
  if Assigned(FPlot.SelectedColumn) and (FPlot.SelectedColumn is TGraphColumn) then FSelcol := TGraphColumn(FPlot.SelectedColumn);
  Result := Assigned(FSelcol);
end;

function TRP45FormDlgMetrol.CreateParam(const gpd: TGraphParamData; Ans: TAnswePlotFormFormMouse): TGraphParamStrings;
begin
  Result := FSelcol.Params.Add<TGraphParamStrings>;
  Result.HideInLegend := True;
  Result.FixedParam := True;
  Result.Title := gpd.Title;
  Result.DashStyle := gpd.DashStyle;
  Result.Width := gpd.Width;
  Result.Color := gpd.Color;
  Ans.Form.SetContextPopupParametr(Result);
end;

procedure TRP45FormDlgMetrol.UpdatePoint(pnt: TGraphParamStrings; Y: Double; edit: TCustomEdit);
begin
  if Assigned(pnt) then
   begin
    pnt.Data.Clear;
    pnt.Data.add(Format('%f;0', [Y]));
    pnt.Data.add(Format('%f;100', [Y]));
    pnt.UpdateFields;
    pnt.RecalcScale;
    pnt.Plot.UpdateDataAndRepaint();
    (Gcontainer as IProjectOptions).Option[ToOption(edit)] := Y.ToString;
   end;
end;

procedure TRP45FormDlgMetrol.UpdatePorog(pr: Double);
begin
  if Assigned(FPorog) then
   begin
    FPorog.Data.Clear;
    FPorog.Data.add(Format('%d;%f', [1, pr]));
    FPorog.Data.add(Format('%d;%f', [(FMaxKadr div 2), pr]));
    FPorog.UpdateFields;
    FPorog.RecalcScale;
    FPorog.Plot.UpdateDataAndRepaint();
    (Gcontainer as IProjectOptions).Option[ToOption(edPorog)] := pr.ToString;
   end;
end;

procedure TRP45FormDlgMetrol.InitPoint(ans: TAnswePlotFormFormMouse; const gpd: TGraphParamData; edKadr: TDataExchangeEdit; var pnt: TGraphParamStrings);
 var
  pr: Integer;
begin
  pnt := nil;
  if FindColumn(Ans) then
   begin
    FPlot.BeginUpdate;
    try
     if FindParam(gpd.Title, pnt) then Exit;
     pnt := CreateParam(gpd, ans);
    finally
     FPlot.EndUpdate;
     pr := Round(pnt.MouseToParam(Ans.X, Ans.Y).Y);
     UpdatePoint(pnt, pr, edKadr);
     edKadr.Text := pr.ToString();
    end;
   end;
end;

procedure TRP45FormDlgMetrol.InitPorog(Ans: TAnswePlotFormFormMouse);
 var
  p: TGraphParam;
  pr: Integer;
begin
  FPorog := nil;
  if FindColumn(Ans) then
   begin
    FPlot.BeginUpdate;
    try
     if FindParam(PRG_NAG, FPorog) then Exit;
     FPorog := CreateParam(GPD_POROG, Ans);
     if FindNagruzka(p) then
      begin
       FPorog.ParentTitle := p.Title;
       FPorog.Delta := p.Delta;
       FPorog.Scale := p.Scale;
      end;
    finally
      FPlot.EndUpdate;
      pr := Round(FPorog.MouseToParam(Ans.X, Ans.Y).X);
      UpdatePorog(pr);
      edPorog.Text := pr.ToString();
    end;
   end;
end;

procedure TRP45FormDlgMetrol.edKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #$D then
   begin
    if Sender = edKadr1 then UpdatePoint(FPoint1, StrToInt(edKadr1.Text), edKadr1)
    else if Sender = edKadr2 then UpdatePoint(FPoint2, StrToInt(edKadr2.Text), edKadr2)
    else UpdatePorog(StrToInt(edPorog.Text));
    Key := #0;
   end;
end;

procedure TRP45FormDlgMetrol.DataExchageClick(Sender: TObject);
begin
  CDataExchange.Ask<TAskPlotFormFormMouse, TAnswePlotFormFormMouse>(FDBConn.DataBase, procedure (Rez: StatusDataAsk; Data: TAnswePlotFormFormMouse)
  begin
    if not Data.Active then MessageDlg('Проект не активный !!!', TMsgDlgType.mtError, [mbOK], 0)
    else if Rez = sdaGood then
     if Sender = edPorog then InitPorog(Data)
     else if Sender = edKadr1 then InitPoint(Data, GPD_POI_1, edKadr1, FPoint1)
     else if Sender = edKadr2 then InitPoint(Data, GPD_POI_2, edKadr2, FPoint2);
    TDataExchangeEdit(Sender).Color := clWindow;
  end);
  TDataExchangeEdit(Sender).Color := $8080FF;
end;

{$ENDREGION}

function TRP45FormDlgMetrol.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_GlubionmerTRR);
end;

function TRP45FormDlgMetrol.ToOption(edit: TCustomEdit): string;
begin
  Result := Format('GLUBINOMER_%s_Text',[edit.Name]);
end;

procedure TRP45FormDlgMetrol.btCloseClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_GlubionmerTRR>;
end;

class function TRP45FormDlgMetrol.ClassIcon: Integer;
begin
  Result := 111;
end;

destructor TRP45FormDlgMetrol.Destroy;
 var
  po: IProjectOptions;
begin
  po := Gcontainer as IProjectOptions;
  po.Option[ToOption(edKadr1)] := edKadr1.Text;
  po.Option[ToOption(edKadr2)] := edKadr2.Text;
  po.Option[ToOption(edGlu1)] := edGlu1.Text;
  po.Option[ToOption(edGlu2)] := edGlu2.Text;
  po.Option[ToOption(edPorog)] := edPorog.Text;
  FDBConn.RemoveQuery('RP45');
  FreeMem(FRecs);
  inherited;
end;

function TRP45FormDlgMetrol.Execute(InputData: IDevice): Boolean;
 var
  po: IProjectOptions;
begin
  Result := True;
  Hide;
  FDev := InputData;
  FDBConn := ConnectionsPool.ActiveConnection;
  FQuery := FDBConn.AddOrGetQuery('RP45');
  FRamTbl := 'Ram_101_'+(FDev as IDataDevice).GetMetaData.Info.Attributes[AT_DEV_ID];
  FQuery.Acquire;
  try
 //  FMaxKadr := FQuery.Connection.ExecSQLScalar('SELECT Count(*) FROM Options WHERE Имя = :P1',['WELL'], [ftString]);
   FMaxKadr := FQuery.Connection.ExecSQLScalar('SELECT ifnull(max(id),0) FROM '+ FRamTbl);
   Memo.Lines.Add('Число Кадров '+ FMaxKadr.ToString());
  finally
   FQuery.Release;
  end;
  po := Gcontainer as IProjectOptions;

  po.AddOrIgnore(ToOption(edKadr1), 'GLUBINOMER');
  po.AddOrIgnore(ToOption(edKadr2), 'GLUBINOMER');
  po.AddOrIgnore(ToOption(edGlu1), 'GLUBINOMER');
  po.AddOrIgnore(ToOption(edGlu2), 'GLUBINOMER');
  po.AddOrIgnore(ToOption(edPorog), 'GLUBINOMER');


  edKadr1.Text := VarToStrDef(po.Option[ToOption(edKadr1)],'');
  edKadr2.Text := VarToStrDef(po.Option[ToOption(edKadr2)],'');
  edGlu1.Text  := VarToStrDef(po.Option[ToOption(edGlu1)],'');
  edGlu2.Text  := VarToStrDef(po.Option[ToOption(edGlu2)],'');
  edPorog.Text := VarToStrDef(po.Option[ToOption(edPorog)],'');

  ReallocMem(FRecs, (FMaxKadr+1)*SizeOf(TRPRec));
  FQuery.AsyncSQL(Format(SEL_ALL, [FRamTbl]) ,[],[], qcOpen, procedure
   var
    v: Variant;
  begin
    for v in FQuery do with FRecs[Integer(v.РП45_время_DEV)] do
     begin
      nag := v.Глубиномер_Нагрузка_DEV;
      tros := v.Глубиномер_ДлинаТроса_CLC;
     end;
    FQuery.Close;
    IShow;
  end);
end;

procedure TRP45FormDlgMetrol.btRUNClick(Sender: TObject);
begin
//  FRamName := 'Ram_101_'+(FDev as IDataDevice).GetMetaData.Info.Attributes[AT_DEV_ID];
end;

initialization
  RegisterDialog.Add<TRP45FormDlgMetrol, Dialog_GlubionmerTRR>;
finalization
  RegisterDialog.Remove<TRP45FormDlgMetrol>;
end.
