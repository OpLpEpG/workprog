unit ExportToPSK6_V3;

interface

uses DeviceIntf, PluginAPI, DockIForm, ExtendIntf, RootImpl, debug_except, Actns, Container, DBImpl, tools,
  Xml.XMLIntf, DataSetIntf, XMLDataSet,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Data.DB, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
    TFileFormatPSK6 = Record
      Dep: LongInt;                    //Время
      Par: Array [0..61] of LongInt;   //формат K-6
    end;
    TRecMap = record
     ix: Integer;
     name: string;
     k: Double;
    end;

  TFormExportToPSK6_V3 = class(TDockIForm)
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
     Table: TXMLDataSet;
     IdName: string;
     Data: TArray<TFldRec>;
    end;
  protected
    function Priority: Integer; override;
  private
    Fterminate: Boolean;
    procedure UpdateControls(FlagEna: Boolean);
    function GetProjectRams: TArray<IDataSet>;
    function GetMaxID(const rams: TArray<IDataSet>): Integer;
  public
   [StaticAction('-Сохранить как ПСК6...', 'Экспорт', 226, '0:Файл.Экспорт|1:2')]
   class procedure DoExportPSK6(Sender: IAction);
  end;


implementation

{$R *.dfm}

uses System.Math;

//'electro.БК.B.I0.DEV'

const

//{8}   FS_Import.CLList.Add('Gx,мВ');
//{9}   FS_Import.CLList.Add('Gy,мВ');
//{10}  FS_Import.CLList.Add('Gz,мВ');
//{11}  FS_Import.CLList.Add('Hx,мВ');
//{12}  FS_Import.CLList.Add('Hy,мВ');
//{13}  FS_Import.CLList.Add('Hz,мВ');

  RM_INCL: array[0..5]of TRecMap =(
    (ix:8;  name:'Inclin.accel.X.DEV'; k:100),
    (ix:9;  name:'Inclin.accel.Y.DEV'; k:100),
    (ix:10; name:'Inclin.accel.Z.DEV'; k:100),
    (ix:11; name:'Inclin.magnit.X.DEV'; k:100),
    (ix:12; name:'Inclin.magnit.Y.DEV'; k:100),
    (ix:13; name:'Inclin.magnit.Z.DEV'; k:100));

//{14}  FS_Import.CLList.Add('ГК,имп/2c');
//{15}  FS_Import.CLList.Add('ННКт-25,имп/2c');
//{16}  FS_Import.CLList.Add('ННКт-50,имп/2c');
//{17}  FS_Import.CLList.Add('НГК,имп/2c');

  RM_GK: array[0..0]of TRecMap =(
    (ix:14;  name:'ГК.гк.DEV'; k:1)
  );
  RM_NNK: array[0..2]of TRecMap =(
    (ix:15;  name:'ННК.нк1.DEV'; k:1),
    (ix:16;  name:'ННК.нк2.DEV'; k:1),
    (ix:17;  name:'ННК.нгк.DEV'; k:1)
  );

//{0}   FS_Import.CLList.Add('Gz1');
//{1}   FS_Import.CLList.Add('Gz2');
//{2}   FS_Import.CLList.Add('Gz3');
//{3}   FS_Import.CLList.Add('Gz4');
//{4}   FS_Import.CLList.Add('Gz5');
//{5}   FS_Import.CLList.Add('Gz6');
//{6}   FS_Import.CLList.Add('Ток,мВ');
//{7}   FS_Import.CLList.Add('PS1,мВ');

//{30}  FS_Import.CLList.Add('U0'); //-БК
//{31}  FS_Import.CLList.Add('I10');//-смещение
//{32}  FS_Import.CLList.Add('I20');//-смещение
//{33}  FS_Import.CLList.Add('I11');//-БК 1
//{34}  FS_Import.CLList.Add('I21');//-БК 1
//{35}  FS_Import.CLList.Add('I12');//-БК 2
//{36}  FS_Import.CLList.Add('I22');//-БК 2
//{37}  FS_Import.CLList.Add('I13');//-БК 3
//{38}  FS_Import.CLList.Add('I23');//-БК 3
//{39}  FS_Import.CLList.Add('I14');//-БК 4
//{40}  FS_Import.CLList.Add('I24');//-БК 4
//{41}  FS_Import.CLList.Add('I15');//-БК 5
//{42}  FS_Import.CLList.Add('I25');//-БК 5
//{43}  FS_Import.CLList.Add('I16');//-БК 6
//{44}  FS_Import.CLList.Add('I26');//-БК 6

//{51}  FS_Import.CLList.Add('PS2,мВ');

//{53}  FS_Import.CLList.Add('dPS,мВ');


  RM_BK : array[0..24]of TRecMap =(
    (ix:31;  name:'electro.БК.B.I0.DEV'; k:1),
    (ix:33;  name:'electro.БК.B.I1.DEV'; k:1),
    (ix:35;  name:'electro.БК.B.I2.DEV'; k:1),
    (ix:37;  name:'electro.БК.B.I3.DEV'; k:1),
    (ix:39;  name:'electro.БК.B.I4.DEV'; k:1),
    (ix:41;  name:'electro.БК.B.I5.DEV'; k:1),
    (ix:43;  name:'electro.БК.B.I6.DEV'; k:1),
    (ix:32;  name:'electro.БК.H.I0.DEV'; k:1),
    (ix:34;  name:'electro.БК.H.I1.DEV'; k:1),
    (ix:36;  name:'electro.БК.H.I2.DEV'; k:1),
    (ix:38;  name:'electro.БК.H.I3.DEV'; k:1),
    (ix:40;  name:'electro.БК.H.I4.DEV'; k:1),
    (ix:42;  name:'electro.БК.H.I5.DEV'; k:1),
    (ix:44;  name:'electro.БК.H.I6.DEV'; k:1),
    (ix:30;  name:'electro.БК.U0.DEV'; k:1),
    (ix:0;  name:'electro.КС.точно.Z1.DEV'; k:1),
    (ix:1;  name:'electro.КС.точно.Z2.DEV'; k:1),
    (ix:2;  name:'electro.КС.точно.Z3.DEV'; k:1),
    (ix:3;  name:'electro.КС.точно.Z4.DEV'; k:1),
    (ix:4;  name:'electro.КС.точно.Z5.DEV'; k:1),
    (ix:5;  name:'electro.КС.точно.Z6.DEV'; k:1),
    (ix:6;  name:'electro.КС.I.DEV'; k:1),
    (ix:7;  name:'electro.ПС.Z1.DEV'; k:1),
    (ix:51;  name:'electro.ПС.Z2.DEV'; k:1),
    (ix:53;  name:'electro.ПС.DPS.DEV'; k:1));

function TFormExportToPSK6_V3.GetMaxID(const rams: TArray<IDataSet>): Integer;
 var
  d: IDataSet;
begin
  Result := 0;
  for d in rams do if Assigned(d) then
   begin
    d.DataSet.Open;
    Result := Max(Result, d.DataSet.RecordCount);
    d.DataSet.Close;
   end;
end;

function TFormExportToPSK6_V3.GetProjectRams(): TArray<IDataSet>;
 var
  i: Integer;
  r, n, d, s: IXMLNode;
  adv: TArray<IXMLNode>;
  function GreateIDS(adr: Integer; const rms: array of TRecMap): IDataSet;
   var
    n: IXMLNode;
    function ContainsRM: Boolean;
     var
      rm: TRecMap;
      dummy: IXMLNode;
    begin
      for rm in rms do if not tools.TryGetX(n, rm.name, dummy) then Exit(False);
      Result := True;
    end;
  begin
    Result := nil;
    for n in adv do if n.ParentNode.Attributes[AT_ADDR] = adr then
     begin
      TXMLDataSet.Get(n, Result, false);
      if Assigned(Result) and ContainsRM then Exit(Result);
     end;
    Result := nil;
  end;
begin
  r := (GContainer as IALLMetaDataFactory).Get.Get.DocumentElement;
  if r.NodeName = 'PROJECT' then r := r.ChildNodes.FindNode('DEVICES');
   for n in XEnum(r) do
    begin
     for d in XEnum(n) do if d.HasAttribute(AT_ADDR) and (Integer(d.Attributes[AT_ADDR]) in [3,4,5,6]) then
     begin
      s := d.ChildNodes.FindNode(T_RAM);
      if Assigned(s) and s.HasAttribute(AT_FILE_NAME) then adv := adv + [s];
     end;
    end;
   //TODO: adv - массив секций RAM памяти возможны с одинаковыми адресами необходимо создасть диалог выбора
  Result := Result + [GreateIDS(3, RM_INCL)];
  Result := Result + [GreateIDS(4, RM_GK)];
  Result := Result + [GreateIDS(5, RM_NNK)];
  Result := Result + [GreateIDS(6, RM_BK)];
  // если нет нужного адреса устройства то Result[i] = nil;
end;

{ TFormExportToPSK6 }

procedure TFormExportToPSK6_V3.btExitClick(Sender: TObject);
begin
  Close_ItemClick(Self);
end;

procedure TFormExportToPSK6_V3.btStartClick(Sender: TObject);
  procedure StRec(ix: IdataSet; const drm: array of TRecMap; var d: TcheckRec);
   var
    i: Integer;
    ds: TXMLDataSet;
  begin
    d.Checked := False;
    if not Assigned(ix) then Exit;
    ds := TXMLDataSet(ix.DataSet);
    SetLength(d.Data, Length(drm));
    d.Table := ds;
    d.ModulName := ds.XMLSection.ParentNode.NodeName;
    d.IdName := d.ModulName +'.время.DEV';
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
  rams: TArray<IDataSet>;
 const
  N_REC_READ = 10000;
begin
  /// начало и конец
  emax := StrToInt(edTo.Text);
  emin := StrToInt(edFrom.Text);

  rams := GetProjectRams;


  rmax := GetMaxID(rams); // ConnectionsPool.Query.Connection.ExecSQLScalar('SELECT ifnull(max(id),0) FROM Ram');
  rmin := 0;              // ConnectionsPool.Query.Connection.ExecSQLScalar('SELECT ifnull(min(id),0) FROM Ram');
  if emax > 0 then umax := Min(rmax, emax) else umax := rmax;
  if emin > 0 then umin := Max(rmin, emin) else umin := rmin;
  /// инициализация имен
  SetLength(acr, 4);
  acr[0].adr := 3;
  acr[1].adr := 4;
  acr[2].adr := 5;
  acr[3].adr := 6;
  StRec(rams[0], RM_INCL, acr[0]);
  StRec(rams[1], RM_GK,   acr[1]);
  StRec(rams[2], RM_NNK,  acr[2]);
  StRec(rams[3], RM_BK,   acr[3]);
   /// поток чтения из БД и записи в Файл
   Fterminate := False;
   UpdateControls(False);
   TThread.CreateAnonymousThread(procedure
    var
     f: TFileStream;
     d: TFileFormatPSK6;
     frm, n: Integer;
     cr: TCheckRec;
     fr: TFldRec;
     fld: TField;
     dfloat: Double;
     newPos: Integer;
     procedure Open;
      var
       d: IDataSet;
     begin
       for d in rams do if Assigned(d) then
        begin
         d.DataSet.Open;
         d.DataSet.RecNo := umin;
        end;
     end;
     procedure Close;
      var
       d: IDataSet;
     begin
       for d in rams do if Assigned(d) then d.DataSet.Close;
     end;
     procedure Next;
      var
       d: IDataSet;
     begin
       for d in rams do if Assigned(d) then d.DataSet.Next;
     end;
   begin
     try
      if od.FileName <> '' then
       begin
        if TFile.Exists(od.FileName) then TFile.Delete(od.FileName);
        f := TFileStream.Create(od.FileName, fmCreate);
       end
      else Exit;
       try
          Open;
          try
           for frm := umin to umax do
            begin
               d.Dep := frm+1;
               for cr in acr do if cr.Checked then for fr in cr.Data do
                begin
                 fld := cr.Table.FieldByName(fr.FieldName);
                 try
                  if Assigned(fld) and not fld.isNull then
                   if fld is TFloatField then
                    begin
                     dfloat := cr.Table.FieldByName(fr.FieldName).AsFloat * fr.k;
                     if (dfloat < LongInt.MaxValue) and (dfloat > LongInt.MinValue)  then d.Par[fr.Index] := Round(dfloat)
                     else d.Par[fr.Index] := 0;
                    end
                   else d.Par[fr.Index] := cr.Table.FieldByName(fr.FieldName).AsInteger
                  else  d.Par[fr.Index] := 0;
                 except
                  d.Par[fr.Index] := 0;
                 end;
                end;

               f.Write(d, SizeOf(d));
               Next;

               if Fterminate then Exit;

               if (umax - umin) > 0 then newPos := Round((frm - umin)/(umax - umin)*100)
               else newPos := 0;
               if (Progress.Position <> newPos) then TThread.Synchronize(nil, procedure
                begin
                  Progress.Position := newPos;
                end);
            end;
          finally
           Close;
          end;
       finally
        f.Free;
        UpdateControls(True);
       end;
     except
      on E: Exception do TDebug.DoException(E);
     end;
   end).Start();
end;

procedure TFormExportToPSK6_V3.btTerminateClick(Sender: TObject);
begin
  Fterminate := True;
end;

class procedure TFormExportToPSK6_V3.DoExportPSK6(Sender: IAction);
begin
  GetUniqueForm('GlobalFormExportToPSK6_V3');
end;

procedure TFormExportToPSK6_V3.FormCreate(Sender: TObject);
begin
  GetDockClient.EnableDock := False;
end;

function TFormExportToPSK6_V3.Priority: Integer;
begin
  Result := PRIORITY_NoStore;
end;

procedure TFormExportToPSK6_V3.UpdateControls(FlagEna: Boolean);
begin
  btStart.Enabled := FlagEna;
  btExit.Enabled := FlagEna;
  NCanClose := FlagEna;
end;

initialization
  RegisterClass(TFormExportToPSK6_V3);
  TRegister.AddType<TFormExportToPSK6_V3, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormExportToPSK6_V3>;
end.
