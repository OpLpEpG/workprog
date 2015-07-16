unit ExportToPSK6;

interface

uses DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, Actns, Container, DBImpl, tools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Data.DB, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
    TFileFormatPSK6 = Record
      Dep: LongInt;                    //�����
      Par: Array [0..61] of LongInt;   //������ K-6
    end;
    TRecMap = record
     ix: Integer;
     name: string;
     k: Double;
    end;

  TFormExportToPSK6 = class(TDockIForm)
    Label1: TLabel;
    Label2: TLabel;
    edFrom: TEdit;
    edTo: TEdit;
    od: TJvFilenameEdit;
    sb: TStatusBar;
    btStart: TButton;
    btTerminate: TButton;
    btExit: TButton;
    Progress: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure btExitClick(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btTerminateClick(Sender: TObject);
  public
   type
    TFldRec = record
     FieldName: string;
     k: Double;
     Index: Integer;
    end;
    TcheckRec = record
     adr: Integer;
     Checked: Boolean;
     ModulName: string;
     TableName: string;
     Data: TArray<TFldRec>;
    end;
  private
    Fterminate: Boolean;
    procedure UpdateControls(FlagEna: Boolean);
  public
   [StaticAction('-��������� ��� ���6...', '�������', 226, '0:����.�������|1:2')]
   class procedure DoExportPSK6(Sender: IAction);
  end;


implementation

{$R *.dfm}

uses System.Math;

//'electro.��.B.I0.DEV'

const

//{8}   FS_Import.CLList.Add('Gx,��');
//{9}   FS_Import.CLList.Add('Gy,��');
//{10}  FS_Import.CLList.Add('Gz,��');
//{11}  FS_Import.CLList.Add('Hx,��');
//{12}  FS_Import.CLList.Add('Hy,��');
//{13}  FS_Import.CLList.Add('Hz,��');

  RM_INCL: array[0..5]of TRecMap =(
    (ix:8;  name:'Inclin.accel.X.CLC'; k:100),
    (ix:9;  name:'Inclin.accel.Y.CLC'; k:100),
    (ix:10; name:'Inclin.accel.Z.CLC'; k:100),
    (ix:11; name:'Inclin.magnit.X.CLC'; k:100),
    (ix:12; name:'Inclin.magnit.Y.CLC'; k:100),
    (ix:13; name:'Inclin.magnit.Z.CLC'; k:100));

//{14}  FS_Import.CLList.Add('��,���/2c');
//{15}  FS_Import.CLList.Add('����-25,���/2c');
//{16}  FS_Import.CLList.Add('����-50,���/2c');
//{17}  FS_Import.CLList.Add('���,���/2c');

  RM_GK: array[0..0]of TRecMap =(
    (ix:14;  name:'��.��.CLC'; k:1)
  );
  RM_NNK: array[0..2]of TRecMap =(
    (ix:15;  name:'���.��1.DEV'; k:1),
    (ix:16;  name:'���.��2.DEV'; k:1),
    (ix:17;  name:'���.���.CLC'; k:1)
  );

//{0}   FS_Import.CLList.Add('Gz1');
//{1}   FS_Import.CLList.Add('Gz2');
//{2}   FS_Import.CLList.Add('Gz3');
//{3}   FS_Import.CLList.Add('Gz4');
//{4}   FS_Import.CLList.Add('Gz5');
//{5}   FS_Import.CLList.Add('Gz6');
//{6}   FS_Import.CLList.Add('���,��');
//{7}   FS_Import.CLList.Add('PS1,��');

//{30}  FS_Import.CLList.Add('U0'); //-��
//{31}  FS_Import.CLList.Add('I10');//-��������
//{32}  FS_Import.CLList.Add('I20');//-��������
//{33}  FS_Import.CLList.Add('I11');//-�� 1
//{34}  FS_Import.CLList.Add('I21');//-�� 1
//{35}  FS_Import.CLList.Add('I12');//-�� 2
//{36}  FS_Import.CLList.Add('I22');//-�� 2
//{37}  FS_Import.CLList.Add('I13');//-�� 3
//{38}  FS_Import.CLList.Add('I23');//-�� 3
//{39}  FS_Import.CLList.Add('I14');//-�� 4
//{40}  FS_Import.CLList.Add('I24');//-�� 4
//{41}  FS_Import.CLList.Add('I15');//-�� 5
//{42}  FS_Import.CLList.Add('I25');//-�� 5
//{43}  FS_Import.CLList.Add('I16');//-�� 6
//{44}  FS_Import.CLList.Add('I26');//-�� 6

//{51}  FS_Import.CLList.Add('PS2,��');

//{53}  FS_Import.CLList.Add('dPS,��');


  RM_BK : array[0..24]of TRecMap =(
    (ix:31;  name:'electro.��.B.I0.DEV'; k:1),
    (ix:33;  name:'electro.��.B.I1.DEV'; k:1),
    (ix:35;  name:'electro.��.B.I2.DEV'; k:1),
    (ix:37;  name:'electro.��.B.I3.DEV'; k:1),
    (ix:39;  name:'electro.��.B.I4.DEV'; k:1),
    (ix:41;  name:'electro.��.B.I5.DEV'; k:1),
    (ix:43;  name:'electro.��.B.I6.DEV'; k:1),
    (ix:32;  name:'electro.��.H.I0.DEV'; k:1),
    (ix:34;  name:'electro.��.H.I1.DEV'; k:1),
    (ix:36;  name:'electro.��.H.I2.DEV'; k:1),
    (ix:38;  name:'electro.��.H.I3.DEV'; k:1),
    (ix:40;  name:'electro.��.H.I4.DEV'; k:1),
    (ix:42;  name:'electro.��.H.I5.DEV'; k:1),
    (ix:44;  name:'electro.��.H.I6.DEV'; k:1),
    (ix:30;  name:'electro.��.U0.DEV'; k:1),
    (ix:0;  name:'electro.��.�����.Z1.DEV'; k:1),
    (ix:1;  name:'electro.��.�����.Z2.DEV'; k:1),
    (ix:2;  name:'electro.��.�����.Z3.DEV'; k:1),
    (ix:3;  name:'electro.��.�����.Z4.DEV'; k:1),
    (ix:4;  name:'electro.��.�����.Z5.DEV'; k:1),
    (ix:5;  name:'electro.��.�����.Z6.DEV'; k:1),
    (ix:6;  name:'electro.��.I.DEV'; k:1),
    (ix:7;  name:'electro.��.Z1.DEV'; k:1),
    (ix:51;  name:'electro.��.Z2.DEV'; k:1),
    (ix:53;  name:'electro.��.DPS.DEV'; k:1));

{ TFormExportToPSK6 }

procedure TFormExportToPSK6.btExitClick(Sender: TObject);
begin
  Close_ItemClick(Self);
end;

procedure TFormExportToPSK6.btStartClick(Sender: TObject);
  procedure StRec(ix: variant; const drm: array of TRecMap; var d: TcheckRec);
   var
    i: Integer;
  begin
    SetLength(d.Data, Length(drm));
    d.TableName := 'Ram_'+IntToStr(ix.�����) +'_'+ IntToStr(ix.fk);
    d.ModulName := ix.������;
    for I := 0 to High(drm) do
     begin
      d.Data[i].FieldName := d.ModulName+'.' + drm[i].name;
      d.Data[i].k := drm[i].k;
      d.Data[i].Index := drm[i].ix;
     end;
    d.Checked := True;
  end;
 var
  v: Variant;
  acr: TArray<TCheckRec>;
  i: integer;
  sql, s: string;
  r: TCheckRec;
  Alias: char;
  f: TFldRec;
  flds: TArray<string>;
  LeftOuterJoins: TArray<string>;
  rmax, rmin: Integer;
  emax, emin: Integer;
  umax, umin: Integer;
 const
  N_REC_READ = 10000;
begin
  UpdateControls(False);
  /// ������ � �����
  emax := StrToInt(edTo.Text);
  emin := StrToInt(edFrom.Text);
  rmax := ConnectionsPool.Query.Connection.ExecSQLScalar('SELECT ifnull(max(id),0) FROM Ram');
  rmin := ConnectionsPool.Query.Connection.ExecSQLScalar('SELECT ifnull(min(id),0) FROM Ram');
  if emax > 0 then umax := Min(rmax, emax) else umax := rmax;
  if emin > 0 then umin := Max(rmin, emin) else umin := rmin;
  /// ������������� ����
  SetLength(acr, 4);
  acr[0].adr := 3;
  acr[1].adr := 4;
  acr[2].adr := 5;
  acr[3].adr := 6;
  ConnectionsPool.Query.Acquire;
  try
   ConnectionsPool.Query.Open('SELECT * FROM Modul');
    try
     for v in ConnectionsPool.Query do
      for i := 0 to High(acr) do
       if (acr[i].adr = v.�����) and not acr[i].Checked and not VarIsNull(v.MetaData) and (v.MetaData <> '') then
        case v.����� of
          3: StRec(v, RM_INCL, acr[i]);
          4: StRec(v, RM_GK,   acr[i]);
          5: StRec(v, RM_NNK,  acr[i]);
          6: StRec(v, RM_BK,   acr[i]);
        end;
    finally
     ConnectionsPool.Query.Close;
    end;
  finally
   ConnectionsPool.Query.Release;
  end;
  /// �������� ������� � ��
  Alias := 'a';
  for r in acr do if r.Checked then
   begin
    s := '';
    for f in r.Data do s := Format('%s,%s."%s"',[s, alias,  f.FieldName]);
    CArray.Add<string>(flds, s);
    CArray.Add<string>(LeftOuterJoins, Format('LEFT OUTER JOIN %s AS %s ON %s.id = Ram.ID',[r.TableName, alias, alias]));
    inc(alias);
   end;                                      //LIMIT %d,%d
   sql := Format('SELECT Ram.ID AS "ID"%s FROM Ram %s ',[string.Join('', flds), string.Join(' ', LeftOuterJoins)]);
   /// ����� ������ �� �� � ������ � ����
   Fterminate := False;
   sql := sql + 'LIMIT %d,%d';
   TThread.CreateAnonymousThread(procedure
    var
     f: TFileStream;
     d: TFileFormatPSK6;
     frm, n: Integer;
     cr: TCheckRec;
     fr: TFldRec;
     fld: TField;
     dfloat: Double;
   begin
     try
      if od.FileName <> '' then
       begin
        if TFile.Exists(od.FileName) then TFile.Delete(od.FileName);
        f := TFileStream.Create(od.FileName, fmCreate);
       end
      else Exit;
       try
        frm := umin-rmin;
        repeat
         ConnectionsPool.Query.Acquire;
         try
          try
           n := Min(N_REC_READ, umax - frm);
           ConnectionsPool.Query.Open(Format(sql,[frm, n]));
           Inc(frm, n);
           ConnectionsPool.Query.First;
           while not ConnectionsPool.Query.Eof do
            begin
             d.Dep := ConnectionsPool.Query.FieldByName('ID').AsInteger;
             for cr in acr do if cr.Checked then for fr in cr.Data do
              begin
               fld := ConnectionsPool.Query.FieldByName(fr.FieldName);
               try
                if Assigned(fld) and not fld.isNull then
                 if fld is TFloatField then
                  begin
                   dfloat := ConnectionsPool.Query.FieldByName(fr.FieldName).AsFloat * fr.k;
                   if (dfloat < LongInt.MaxValue) and (dfloat > LongInt.MinValue)  then d.Par[fr.Index] := Round(dfloat)
                   else d.Par[fr.Index] := 0;
                  end
                 else d.Par[fr.Index] := ConnectionsPool.Query.FieldByName(fr.FieldName).AsInteger
                else  d.Par[fr.Index] := 0;
               except
                d.Par[fr.Index] := 0;
               end;
              end;
             f.Write(d, SizeOf(d));
             ConnectionsPool.Query.Next;
            end;
          finally
           ConnectionsPool.Query.Close;
          end;
         finally
          ConnectionsPool.Query.Release;
         end;
         TThread.Synchronize(nil, procedure
         begin
           Progress.Position := Round((frm - umin)/(umax - umin)*100);
         end);
        until not (Fterminate or ((umax - frm) > 0));
       finally
        f.Free;
        UpdateControls(True);
       end;

     except
      on E: Exception do TDebug.DoException(E);
     end;
   end).Start();
end;

procedure TFormExportToPSK6.btTerminateClick(Sender: TObject);
begin
  Fterminate := True;
end;

class procedure TFormExportToPSK6.DoExportPSK6(Sender: IAction);
begin
  GetUniqueForm('GlobalFormExportToPSK6');
end;

procedure TFormExportToPSK6.FormCreate(Sender: TObject);
begin
  GetDockClient.EnableDock := False;
end;

procedure TFormExportToPSK6.UpdateControls(FlagEna: Boolean);
begin
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
end;

initialization
  RegisterClass(TFormExportToPSK6);
  TRegister.AddType<TFormExportToPSK6, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormExportToPSK6>;
end.
