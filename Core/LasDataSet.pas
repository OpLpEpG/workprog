unit LasDataSet;

interface

uses System.Classes, sysutils, Data.DB, IDataSets, LasImpl, LAS, DataSetIntf, Container, JDtools;

type
  TLASDataSetDef = class(TIDataSetDef)
  private
    FLasFile: string;
  public
    constructor CreateUser(const FileName: string);
    function FryGet(out ids: IDataSet): Boolean; override;
  published
   [ShowProp('LAS פאיכ', True)] property LasFile: string read FLasFile write FLasFile;
  end;

  TLasDataSet = class(TRLDataSet)
  private
    FlasDoc: ILasDoc;
    FLasFile: string;
    procedure SetLasFile(const Value: string);
  protected
    function GetRecordCount: Integer; override;
    procedure InternalClose; override;
    procedure InternalOpen; override;
//    function GetFileName: string; override;
  public
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
/// <summary>
///  {week reference container}
/// </summary>
    class procedure New(const FileName: string; out Res: IDataSet);
//  published
  public
    property LasFile: string read FLasFile write SetLasFile;
  end;

implementation

{ TLasDataSet }

class procedure TLasDataSet.New(const FileName: string; out Res: IDataSet);
 var
  ii: IInterface;
begin
//  if not (GContainer as IDataSetEnum).TryFind(FileName, Res) then
  if GContainer.TryGetInstance(ClassInfo, FileName, ii, False) then Res := ii as IDataSet
  else
   begin
    Res := Create as IDataSet;
    TLasDataSet(Res.DataSet).LasFile := FileName;
    TRegistration.Create(ClassInfo).AddInstance(Res.IName, Res);
    TLasDataSet(Res.DataSet).WeekContainerReference := True;
   end;
end;

function TLasDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
 var
  p: PRecBuffer;
begin
  Result := True;
  if not GetActiveRecBuf(p) then Exit(False);
  if Field.FieldName = 'ID' then
   begin
    SetLength(Buffer, Sizeof(Integer));
    PInteger(@Buffer[0])^ := p.ID;
   end
  else
   begin
    SetLength(Buffer, Sizeof(Double));
    PDouble(@Buffer[0])^ := Double(FlasDoc[Field.FieldName,  p.ID]);
   end;
end;

//function TLasDataSet.GetFileName: string;
//begin
//  Result := FLasFile;
//end;

function TLasDataSet.GetRecordCount: Integer;
begin
  if Assigned(FlasDoc) then Result := FlasDoc.DataCount
  else Result := -1;
end;

procedure TLasDataSet.InternalClose;
begin
  FlasDoc := nil;
  inherited;
end;

procedure TLasDataSet.InternalOpen;
begin
  inherited;
  FlasDoc := NewLasDoc;
  FlasDoc.LoadFromFile(LasFile);
end;

procedure TLasDataSet.SetLasFile(const Value: string);
 var
  s: string;
  d: ILasDoc;
  c: Char;
begin
  if FLasFile <> Value then
   begin
    if IsCursorOpen then Close;
    FLasFile := Value;
    if not (csLoading in ComponentState) then
     begin
      c := FormatSettings.DecimalSeparator;
      FormatSettings.DecimalSeparator := '.';
      try
       d := NewLasDoc;
       d.LoadFromFile(LasFile);
       FieldDefs.Clear;
       FieldDefs.Add('ID', ftInteger);
       for s in d.Curve.Mnems do FieldDefs.Add(s, ftFloat);
      finally
       FormatSettings.DecimalSeparator := c;
      end;
     end;
   end;
end;

{ TLASDataSetDef }

constructor TLASDataSetDef.CreateUser(const FileName: string);
begin
  FLasFile := FileName;
end;

function TLASDataSetDef.FryGet(out ids: IDataSet): Boolean;
begin
  TLasDataSet.New(LasFile, ids);
  Result := Assigned(ids);
end;

initialization
  RegisterClasses([TLasDataSet, TLASDataSetDef]);
  TRegister.AddType<TLasDataSet, IDataSet>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TLasDataSet>;
end.
