unit VCL.Dlg.Export.Caliper;

interface

uses DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, RootIntf, debug_except, Actns, Container, tools,
  Xml.XMLIntf, DataSetIntf, XMLDataSet,  System.TypInfo, System.Math, System.IOUtils, DB,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit, VCL.Frame.RangeSelect;

type
    TRecMap = record
     ix: Integer;
     name: string;
     k: Integer;
    end;

  TFormDlgExportCaliper = class(TDialogIForm, IDialog, IDialog<TDialogResult>)
    od: TJvFilenameEdit;
    btStart: TButton;
    btTerminate: TButton;
    btExit: TButton;
    Progress: TProgressBar;
    Label3: TLabel;
    edFKD: TEdit;
    RangeSelect: TFrameRangeSelect;
    sb: TStatusBar;
    procedure btExitClick(Sender: TObject);
    procedure btExportClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
  private
    FIStat: IStatistic;
    FkadrFirst, FkadrLast: Integer;
    FIDataSet: IDataSet;
    FXDataSet: TXMLDataSet;
    IfFields: TArray<TField>;
    Fterminate: Boolean;
    procedure UpdateControls(FlagEna: Boolean);
  public
    function GetInfo: PTypeInfo; override;
    function Execute(Res: TDialogResult): Boolean;
   [StaticAction('-Профилемер...', 'Экспорт', 128, '0:Файл.Экспорт|1:3')]
   class procedure DoExportCalip(Sender: IAction);
  end;

implementation

{$R *.dfm}

    const
     SUB_EXP = 'Профилемер';

     FKDN = '%s.Caliper.fkd.d%d.DEV';

     FI_FORMAT:array [0..6] of TRecMap=(
     (ix: 0; name: '.время.DEV'; k: 1),
     (ix: 1; name: '.Caliper.accel.X.CLC'; k: 1),
     (ix: 2; name: '.Caliper.accel.Y.CLC'; k: 1),
     (ix: 3; name: '.Caliper.accel.Z.CLC'; k: 1),
     (ix: 4; name: '.Caliper.T.DEV'; k: 100),
     (ix: 5; name: '.Caliper.потребление.DEV'; k: 1),
     (ix: 6; name: '.Caliper.ГК.гк.DEV'; k: 1)
     );


{ TFormDlgExportCaliper }

procedure TFormDlgExportCaliper.btExportClick(Sender: TObject);
//  function getCal: IXMLNode;
//   var
//    n: IXMLNode;
//  begin
//   Result := nil;
//    for n in FindDevs((GContainer as IALLMetaDataFactory).Get.Get.DocumentElement) do
//     if n.Attributes[AT_ADDR] = 7 then
//      begin
//       Result := n.ChildNodes.FindNode(T_RAM);
//       if Assigned(Result) and Result.HasAttribute(AT_FILE_NAME) then Exit(Result);
//      end;
//   raise EBaseException.Create('Нет данных профилемера!!!');
//  end;
begin
//  TXMLDataSet.Get(getCal, FIDataSet);
//  if not Assigned(FIDataSet) then raise EBaseException.Create('Нет базы данных профилемера!!!');
  Fterminate := False;
  UpdateControls(False);
  TThread.CreateAnonymousThread(procedure
   var
    f,ak: TFileStream;
    akFileName, ifFileName: string;
    frm, i: Integer;
    newPos: Integer;
    akLen: Integer;
    akFields: TArray<TField>;
    ifarr: TArray<Integer>;
    cs0: array[0..1] of word;
    b, bdef: TArray<Byte>;
    umin, umax: Integer;
   // fldID: TField;
     procedure UpdateSb4(const s: string);
     begin
       TThread.Synchronize(nil, procedure
        begin
          sb.Panels[4].Text := s;
        end);
     end;
  begin
     try
      try
        if od.FileName <> '' then
         begin
          akFileName := TPath.ChangeExtension(od.FileName, 'ak1');
          ifFileName := TPath.ChangeExtension(od.FileName, 'if');
          if TFile.Exists(ifFileName) then TFile.Delete(ifFileName);
          if TFile.Exists(akFileName) then TFile.Delete(akFileName);
          f := TFileStream.Create(ifFileName, fmCreate);
          ak := TFileStream.Create(akFileName, fmCreate);
         end
        else
         begin
          UpdateSb4('пустое имя файла');
          Exit;
         end;
        FXDataSet.DisableControls;
//        fldID := FXDataSet.FieldByName('ID');
        Setlength(akFields, 9);
        for I := 0 to 8 do akFields[i] := FXDataSet.FieldByName(Format(FKDN,[FXDataSet.XMLSection.ParentNode.NodeName, i]));
        akLen := StrToInt(edFKD.Text)*2;
        Setlength(bdef, akLen);
        Setlength(ifarr, Length(FI_FORMAT));
        umin := RangeSelect.kadr.first - FkadrFirst;
        umax := RangeSelect.kadr.last - FkadrFirst;
        FXDataSet.RecNo := umin;
        FIStat := TStatisticCreate.Create((umax-umin)*Length(ifarr)*Sizeof(Integer));
        UpdateSb4('работа');
        for frm := umin to umax do
         begin
          for I := 0 to High(ifarr) do
           if Assigned(IfFields[i]) and not IfFields[i].isNull then
            if IfFields[i] is TNumericField then
             if IfFields[i] is TFloatField then
              begin
               ifarr[FI_FORMAT[i].ix] := Round(IfFields[i].AsFloat * FI_FORMAT[i].k);
              end
             else ifarr[FI_FORMAT[i].ix] := IfFields[i].AsInteger * FI_FORMAT[i].k
            else ifarr[FI_FORMAT[i].ix] := 0
           else ifarr[FI_FORMAT[i].ix] := 0;

///         ID <> время.DEV !!! если считывали память не сначала
//          if ifarr[0] = fldID.AsInteger then
//           begin
            f.Write(ifarr[0], Length(ifarr)*Sizeof(Integer));
            FIStat.UpdateAdd(Length(ifarr)*Sizeof(Integer));

            cs0[0] := ifarr[0] mod 10;
            cs0[1] := ifarr[0] div 10;
            ak.Write(cs0, Length(cs0)*Sizeof(Word));
            for I := 0 to 8 do
             if Assigned(akFields[i]) and not akFields[i].isNull then
              begin
               FXDataSet.GetFieldData(akFields[i], b);
               ak.Write(PPointer(@b[0])^^, akLen);
              end
             else ak.Write(bdef[0], akLen);
//           end
//          else raise Exception.CreateFmt('ID %d <> Кадру  %d',[ifarr[0], fldID.AsInteger]);

          FXDataSet.Next;

          if Fterminate then
            begin
             UpdateSb4('прервано');
             Exit;
            end;

          if (umax - umin) > 0 then newPos := Round((frm - umin)/(umax -umin)*100)
          else newPos := 0;
          if (Progress.Position <> newPos) then TThread.Synchronize(nil, procedure
          begin
            Progress.Position := newPos;
            TStatisticCreate.UpdateStandardStatusBar(sb, FIStat.Statistic);
          end);
         end;
        UpdateSb4('конец');
      finally
       UpdateControls(True);
       FXDataSet.EnableControls;
       f.Free;
       ak.Free;
      end;
     except
      on E: Exception do TDebug.DoException(E);
     end;
  end).Start();
end;

procedure TFormDlgExportCaliper.UpdateControls(FlagEna: Boolean);
begin
  RangeSelect.Enabled := FlagEna;
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
end;

procedure TFormDlgExportCaliper.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize(EXPORT_DIALOG_CATEGORY, SUB_EXP);
end;

procedure TFormDlgExportCaliper.btTerminateClick(Sender: TObject);
begin
  Fterminate := True;
end;

class procedure TFormDlgExportCaliper.DoExportCalip(Sender: IAction);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet(EXPORT_DIALOG_CATEGORY, SUB_EXP, d) then (d as IDialog<TDialogResult>).Execute(nil);
end;

function TFormDlgExportCaliper.Execute(Res: TDialogResult): Boolean;
  function getCal: IXMLNode;
   var
    n: IXMLNode;
  begin
   Result := nil;
    for n in FindDevs((GContainer as IALLMetaDataFactory).Get.Get.DocumentElement) do
     if n.Attributes[AT_ADDR] = 7 then
      begin
       Result := n.ChildNodes.FindNode(T_RAM);
       if Assigned(Result) and Result.HasAttribute(AT_FILE_NAME) then Exit(Result);
      end;
   raise ENeedDialogException.Create('Нет считанных данных или модуля профилемера!!!');
  end;
 var
  i: Integer;
begin
  TXMLDataSet.Get(getCal, FIDataSet);
  if not Assigned(FIDataSet) then raise ENeedDialogException.Create('Нет базы данных профилемера!!!');
  FXDataSet := FIDataSet.DataSet as TXMLDataSet;
  FXDataSet.Open;
  FXDataSet.DisableControls;
  try
   Setlength(IfFields, Length(FI_FORMAT));
   for I := 0 to High(IfFields) do IfFields[i] := FXDataSet.FieldByName(FXDataSet.XMLSection.ParentNode.NodeName+FI_FORMAT[i].name);
   FXDataSet.First;
   FkadrFirst := IfFields[0].AsInteger;
   FXDataSet.Last;
   FkadrLast := IfFields[0].AsInteger;
   RangeSelect.Init(FXDataSet.RecordLength, FkadrFirst, FkadrLast, (GContainer as IProjectOptions).DelayStart);
   RangeSelect.Range.SelEnd := RangeSelect.Range.Max;
  finally
   FXDataSet.EnableControls;
  end;
  //RangeSelect.Init(d.RecordLength);
  IShow;
end;

function TFormDlgExportCaliper.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_Export);
end;

initialization
  RegisterDialog.Add<TFormDlgExportCaliper, Dialog_Export>(EXPORT_DIALOG_CATEGORY, SUB_EXP);
finalization
  RegisterDialog.Remove<TFormDlgExportCaliper>;
end.
