unit VCLDlgExportAcoustics;

interface
{$INCLUDE global.inc}

uses DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, RootIntf, debug_except, Actns, Container, tools,
  Xml.XMLIntf, DataSetIntf, XMLDataSet,  System.TypInfo, System.Math, System.IOUtils, DB,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit, VCLFrameRangeSelect;

const
  APPB_END_IF:  PAnsiChar = '#1#90  ';
  APPB_END_AK1: PAnsiChar = '#1#91  ';
  APPB_END_AK1_1024: PAnsiChar = '#1#92  ';

{$IFDEF ENG_VERSION}
 const
  RS_caliper = '-Acoustics...';
  RS_Export = 'Export';
  RS_file ='0:File.Export|1:3';
{$ELSE}
 const
  RS_caliper = '-��������...';
  RS_Export = '�������';
  RS_file ='0:����.�������|1:3';
{$ENDIF}

type
    TRecMap = record
     ix: Integer;
     name: string;
     k: Integer;
    end;

  TFormDlgExportAcoustics = class(TDialogIForm, IDialog, IDialog<TDialogResult>)
    od: TJvFilenameEdit;
    btStart: TButton;
    btTerminate: TButton;
    btExit: TButton;
    Progress: TProgressBar;
    Label3: TLabel;
    edFKD: TEdit;
    RangeSelect: TFrameRangeSelect;
    sb: TStatusBar;
    cbFKD: TComboBox;
    Label1: TLabel;
    cbAuto: TCheckBox;
    procedure btExitClick(Sender: TObject);
    procedure btExportClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
    procedure cbFKDChange(Sender: TObject);
    procedure cbAutoClick(Sender: TObject);
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
   [StaticAction(RS_caliper, RS_Export, 128, RS_file)]
   class procedure DoExportCalip(Sender: IAction);
  end;

  resourcestring
   RS_EmptyFileName='������ ��� �����';
   RS_run='������';
   RS_terminated='��������';
   RS_End='�����';
   RS_NoModule='��� ��������� ������ ��� ������ ��������!!!';
   RS_No_bd_Calip='��� ���� ������ ��������!!!';

implementation

{$R *.dfm}

    const
     SUB_EXP = '��������';

     ZOND_SB:array [0..1]of string=('�������_����', '�������_����');
//     SB = '�������_����';
//     SD = '�������_����';

     FKDN = '%s.AKWD_RX.%s.���_�������.d%d.DEV';
     FKDGEINN = '%s.AKWD_RX.%s.Ku_�������.gain_%d.DEV';

     FI_FORMAT:array [0..7] of TRecMap=(
     (ix: 0; name: '.�����.DEV'; k: 1),
     (ix: 1; name: '.SYNC_RECIEVER.flag.DEV'; k: 1),
     (ix: 2; name: '.AKWD_RX.T.DEV'; k: 1),
     (ix: 3; name: '.AKWD_RX.�����������_��.DEV'; k: 1),
     (ix: 4; name: '.AKWD_RX.����������_�������_�.DEV'; k: 1),
     (ix: 5; name: '.AKWD_RX.accel.X.DEV'; k: 1),
     (ix: 6; name: '.AKWD_RX.accel.Y.DEV'; k: 1),
     (ix: 7; name: '.AKWD_RX.accel.Z.DEV'; k: 1)

//     (ix: 8;  name: '.AKWD_RX.�������_����.Ku_�������.gain_0.DEV'; k: 1),
//     (ix: 9;  name: '.AKWD_RX.�������_����.Ku_�������.gain_1.DEV'; k: 1),
//     (ix: 10; name: '.AKWD_RX.�������_����.Ku_�������.gain_2.DEV'; k: 1),
//     (ix: 11; name: '.AKWD_RX.�������_����.Ku_�������.gain_3.DEV'; k: 1),
//     (ix: 12; name: '.AKWD_RX.�������_����.Ku_�������.gain_4.DEV'; k: 1),
//     (ix: 13; name: '.AKWD_RX.�������_����.Ku_�������.gain_5.DEV'; k: 1),
//     (ix: 14; name: '.AKWD_RX.�������_����.Ku_�������.gain_6.DEV'; k: 1),
//     (ix: 15; name: '.AKWD_RX.�������_����.Ku_�������.gain_7.DEV'; k: 1),
//
//     (ix: 16; name: '.AKWD_RX.�������_����.Ku_�������.gain_0.DEV'; k: 1),
//     (ix: 17; name: '.AKWD_RX.�������_����.Ku_�������.gain_1.DEV'; k: 1),
//     (ix: 18; name: '.AKWD_RX.�������_����.Ku_�������.gain_2.DEV'; k: 1),
//     (ix: 19; name: '.AKWD_RX.�������_����.Ku_�������.gain_3.DEV'; k: 1),
//     (ix: 20; name: '.AKWD_RX.�������_����.Ku_�������.gain_4.DEV'; k: 1),
//     (ix: 21; name: '.AKWD_RX.�������_����.Ku_�������.gain_5.DEV'; k: 1),
//     (ix: 22; name: '.AKWD_RX.�������_����.Ku_�������.gain_6.DEV'; k: 1),
//     (ix: 23; name: '.AKWD_RX.�������_����.Ku_�������.gain_7.DEV'; k: 1)
     );


{ TFormDlgExportCaliper }

procedure TFormDlgExportAcoustics.btExportClick(Sender: TObject);
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
//   raise EBaseException.Create('��� ������ �����������!!!');
//  end;
begin
//  TXMLDataSet.Get(getCal, FIDataSet);
//  if not Assigned(FIDataSet) then raise EBaseException.Create('��� ���� ������ �����������!!!');
  Fterminate := False;
  UpdateControls(False);
  TThread.CreateAnonymousThread(procedure
   var
    f,ak: TFileStream;
    akFileName, ifFileName: string;
    frm, i, j: Integer;
    newPos: Integer;
    akLen: Integer;
    akFields, akGainFields: array[0..15] of TField;
    Geinbuf: array[0..15] of word;
    ifarr: TArray<Integer>;
//    cs0: array[0..1] of word;
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
          UpdateSb4(RS_EmptyFileName);
          Exit;
         end;
        FXDataSet.DisableControls;
//        fldID := FXDataSet.FieldByName('ID');
        //Setlength(akFields, 16);
        for j := 0 to 1 do
         for i := 0 to 7 do
          begin
           akFields[i+j*8] := FXDataSet.FieldByName(Format(FKDN,
                              [FXDataSet.XMLSection.ParentNode.NodeName, ZOND_SB[j], i]));
           akGainFields[i+j*8] := FXDataSet.FieldByName(Format(FKDGEINN,
                              [FXDataSet.XMLSection.ParentNode.NodeName, ZOND_SB[j], i]));
          end;
        ///
        if cbAuto.Checked then
         begin
          if Abs(akFields[0].Size - 2*1024) < 10 then akLen := 1024*2
          else akLen := 512*2;
          edFKD.Text := IntToStr(akLen div 2);
         end
        ///
        else akLen := StrToInt(edFKD.Text)*2;
        Setlength(bdef, akLen);
        Setlength(ifarr, Length(FI_FORMAT));
        umin := RangeSelect.kadr.first - FkadrFirst;
        umax := RangeSelect.kadr.last - FkadrFirst;
        FXDataSet.RecNo := umin;
        FIStat := TStatisticCreate.Create((umax-umin)*Length(ifarr)*Sizeof(Integer));
        UpdateSb4(RS_run);
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

///         ID <> �����.DEV !!! ���� ��������� ������ �� �������
//          if ifarr[0] = fldID.AsInteger then
//           begin
            f.Write(ifarr[0], Length(ifarr)*Sizeof(Integer));
            FIStat.UpdateAdd(Length(ifarr)*Sizeof(Integer));

            ak.Write(ifarr[0], Sizeof(Integer));

            for i := 0 to 15 do
             if Assigned(akFields[i]) and not akFields[i].isNull then
              begin
               FXDataSet.GetFieldData(akFields[i], b);
               if akFields[i].Size < akLen then
                   move(PPointer(@b[0])^^, bdef[0], akFields[i].Size)
               else
                   move(PPointer(@b[0])^^, bdef[0], akLen);
               ak.Write(bdef[0], akLen);
               FillChar(bdef[0], akLen, 0);
              end
             else ak.Write(bdef[0], akLen);

             for i := 0 to 15 do
              if Assigned(akGainFields[i]) and not akGainFields[i].isNull then
               Geinbuf[i] := akGainFields[i].AsInteger;

             ak.Write(Geinbuf[0], Length(Geinbuf)*Sizeof(word));

          FXDataSet.Next;

          if Fterminate then
            begin
             UpdateSb4(RS_terminated);
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
        f.Write(APPB_END_IF[0], 7);
        if akLen = 1024*2 then
           ak.Write(APPB_END_AK1_1024[0], 7)
         else
           ak.Write(APPB_END_AK1[0], 7);
        UpdateSb4(RS_End);
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

procedure TFormDlgExportAcoustics.UpdateControls(FlagEna: Boolean);
begin
  RangeSelect.Enabled := FlagEna;
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
end;

procedure TFormDlgExportAcoustics.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize(EXPORT_DIALOG_CATEGORY, SUB_EXP);
end;

procedure TFormDlgExportAcoustics.btTerminateClick(Sender: TObject);
begin
  Fterminate := True;
end;

procedure TFormDlgExportAcoustics.cbAutoClick(Sender: TObject);
 var
  akField: TField;
  akLen : Integer;
begin
  cbFKD.Enabled := not cbAuto.Checked;
  if cbAuto.Checked then
  begin
    akField := FXDataSet.FieldByName(Format(FKDN,[FXDataSet.XMLSection.ParentNode.NodeName,ZOND_SB[0], 0]));
    if Abs(akField.Size - 2*1024) < 10 then akLen := 1024*2
    else akLen := 512*2;
    edFKD.Text := IntToStr(akLen div 2);
  end;

end;

procedure TFormDlgExportAcoustics.cbFKDChange(Sender: TObject);
begin
  if cbFKD.ItemIndex in [2,3] then edFKD.Text := '1024'
  else edFKD.Text := '512'
end;

class procedure TFormDlgExportAcoustics.DoExportCalip(Sender: IAction);
var
  d: Idialog;
begin
  if RegisterDialog.TryGet(EXPORT_DIALOG_CATEGORY, SUB_EXP, d) then (d as IDialog<TDialogResult>).Execute(nil);
end;

function TFormDlgExportAcoustics.Execute(Res: TDialogResult): Boolean;
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
   raise ENeedDialogException.Create(RS_NoModule);
  end;
 var
  i: Integer;
begin
  TXMLDataSet.Get(getCal, FIDataSet);
  if not Assigned(FIDataSet) then raise ENeedDialogException.Create(RS_No_bd_Calip);
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
   if (FkadrFirst = 1)and (FkadrLast =0) then
   while (FkadrLast = 0) do
    begin
      FXDataSet.Prior;
      FkadrLast := IfFields[0].AsInteger;
    end;
   RangeSelect.Init(FXDataSet.RecordLength, FkadrFirst, FkadrLast, (GContainer as IProjectOptions).DelayStart);
   RangeSelect.Range.SelEnd := RangeSelect.Range.Max;
  finally
   FXDataSet.EnableControls;
  end;
  //RangeSelect.Init(d.RecordLength);
  cbAutoClick(nil);
  IShow;
end;

function TFormDlgExportAcoustics.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_Export);
end;

initialization
  RegisterDialog.Add<TFormDlgExportAcoustics, Dialog_Export>(EXPORT_DIALOG_CATEGORY, SUB_EXP);
finalization
  RegisterDialog.Remove<TFormDlgExportAcoustics>;
end.
