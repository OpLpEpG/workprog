unit VCL.Dlg.ExportLAS;

interface

uses DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, Actns, Container, tools,
  Xml.XMLIntf, DataSetIntf, XMLDataSet, System.TypInfo, LAS, LasImpl,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids, VCL.Frame.SelectParam, Vcl.StdCtrls, Vcl.ExtCtrls,
  VCL.Frame.SelectPath, Vcl.ComCtrls, Vcl.Menus, Vcl.DBCtrls, Vcl.Mask, JvExMask, JvToolEdit, VCL.Frame.RangeSelect;

type
  TFormExportLASP3 = class(TDialogIForm, IDialog, IDialog<Integer>)
    pc: TPageControl;
    tshSelDir: TTabSheet;
    FrameSelectPath: TFrameSelectPath;
    tshSelParam: TTabSheet;
    FrameSelectParam1: TFrameSelectParam;
    tshData: TTabSheet;
    DBGrid1: TDBGrid;
    btCancel: TButton;
    btOK: TButton;
    tshLas: TTabSheet;
    cb: TComboBox;
    Label4: TLabel;
    ds: TDataSource;
    od: TJvFilenameEdit;
    Label1: TLabel;
    Memo: TMemo;
    RangeSelect: TFrameRangeSelect;
    sb: TStatusBar;
    Label2: TLabel;
    lbAq: TEdit;
    procedure btCancelClick(Sender: TObject);
    procedure btOKClick(Sender: TObject);
    procedure odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
    procedure tshLasShow(Sender: TObject);
  private
    ids: IDataSet;
    fldKadr: TField;
    FirstKadr, LastKadr: Integer;
    flds: TArray<TField>;
  public
   function Execute(dummy: Integer): Boolean;
   function GetInfo: PTypeInfo; override;
   class function ClassIcon: Integer; override;
   [StaticAction('-LAS...', 'Экспорт', 128, '0:Файл.Экспорт|1:2')]
   class procedure DoExportLAS(Sender: IAction);
  end;

implementation

{$R *.dfm}

{ TFormExportLASP3 }

class function TFormExportLASP3.ClassIcon: Integer;
begin
  Result := 128;
end;

class procedure TFormExportLASP3.DoExportLAS(Sender: IAction);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet(EXPORT_DIALOG_CATEGORY, 'LAS', d) then (d as IDialog<Integer>).Execute(0);
end;

procedure TFormExportLASP3.btCancelClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize(EXPORT_DIALOG_CATEGORY, 'LAS');
end;

function TFormExportLASP3.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_Export);
end;

procedure TFormExportLASP3.odBeforeDialog(Sender: TObject; var AName: string; var AAction: Boolean);
begin
  od.FileName := '';
end;

procedure TFormExportLASP3.tshLasShow(Sender: TObject);
 var 
  f: TField;
  n: IXMLNode;
  s: string;
begin
  flds := FrameSelectParam1.GetSelected;
  memo.Clear;
  for f in flds do 
   begin
    s := f.FullName.Replace('.','_');
    if TXMLDataSet(ids).TryGetX(f.FullName, n) then
     begin
      if n.HasAttribute(AT_TITLE) then s := n.Attributes[AT_TITLE];
      if n.HasAttribute(AT_EU) then s := s+'.'+ n.Attributes[AT_EU];
      if n.HasAttribute(AT_AQURICY) then s := s+'    |   %1.'+ n.Attributes[AT_AQURICY]+'f';
     end;
    memo.Lines.Add(s);
   end;
end;

function TFormExportLASP3.Execute(dummy: Integer): Boolean;

begin
  Result := True;
  IShow;
    FrameSelectPath.Execute(Caption, procedure(XMLSection: IXMLNode)
    begin
      TXMLDataSet.Get(XMLSection,  ids,  True);
      ids.DataSet.Open;
      fldKadr := ids.DataSet.FieldByName(TXMLDataSet(ids.DataSet).XMLSection.ParentNode.NodeName +'.время.DEV');
      ids.DataSet.Last;
      LastKadr := fldKadr.AsInteger;
      ids.DataSet.First;
      FirstKadr := fldKadr.AsInteger;
      RangeSelect.Init(TXMLDataSet(ids.DataSet).RecordLength, FirstKadr, LastKadr, (GContainer as IProjectOptions).DelayStart);
      FrameSelectParam1.InitTree(ids.DataSet);
      ds.DataSet := ids.DataSet;
    end);
end;

procedure TFormExportLASP3.btOKClick(Sender: TObject);
 var
  from, last, i : Integer;
  il: ILasDoc;
  f: TField;
  n: IXMLNode;
  mnem, eu, desc, aq: string;
  v: array of Variant;
     procedure UpdateSb4(const s: string);
     begin
       TThread.Synchronize(nil, procedure
        begin
          sb.Panels[4].Text := s;
        end);
     end;
begin
  if Length(flds) = 0 then raise ENeedDialogException.Create('Не выбраны параметры');
  if od.FileName = '' then raise ENeedDialogException.Create('Не выбран файл');
  if not Assigned(ids) then raise ENeedDialogException.Create('Не выбран файл');
  from := RangeSelect.kadr.first;
  last := RangeSelect.kadr.last;
  il := NewLasDoc();
   UpdateSb4('работа');
   Application.ProcessMessages;
  // инициализируем поля
  for f in flds do
   begin
    mnem :='';
    eu := '';
    desc := '';
    aq := '%10.'+ lbAq.Text +'f';
    mnem := f.FullName.Replace('.','_');
    if TXMLDataSet(ids).TryGetX(f.FullName, n) then
     begin
      if n.HasAttribute(AT_TITLE) then 
       begin
        desc :=  mnem;
        mnem := n.Attributes[AT_TITLE];
       end;
      if n.HasAttribute(AT_EU) then eu := n.Attributes[AT_EU];
      if n.HasAttribute(AT_AQURICY) then aq := '%10.'+ n.Attributes[AT_AQURICY]+'f';
     end;
    il.Curve.Add(TlasFormat.Create(mnem,eu,'',desc));
    il.Curve.DisplayFormat[mnem] := aq;
   end;
  
//  if from = 0 then
//    ids.DataSet.First
//  else
    ids.DataSet.RecNo := from - FirstKadr;
//  if last = 0 then last := ids.DataSet.RecordCount;

  SetLength(v, Length(flds)+1);
  // пишем данные
  while (not ids.DataSet.Eof) and (last >= fldKadr.AsInteger {ids.DataSet.FieldByName('ID').AsInteger}) do
   begin
    v[0] := fldKadr.AsInteger;// ids.DataSet.FieldByName('ID').AsInteger;
    for i := 1 to Length(flds) do
     if flds[i-1] is TNumericField then  v[i] := flds[i-1].AsFloat
     else v[i] := flds[i-1].AsString;
    il.Data.AddData(v);
    ids.DataSet.Next;
   end;
  il.Encoding := LasEncoding(cb.ItemIndex); 
  il.SaveToFile(od.FileName);
  UpdateSb4('конец');
end;


initialization
  RegisterDialog.Add<TFormExportLASP3, Dialog_Export>(EXPORT_DIALOG_CATEGORY, 'LAS');
finalization
  RegisterDialog.Remove<TFormExportLASP3>;
end.
