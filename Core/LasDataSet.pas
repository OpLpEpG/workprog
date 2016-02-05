unit LasDataSet;

interface

uses System.Classes, sysutils, Data.DB, IDataSets, LasImpl, LAS, DataSetIntf, Container;

type
  TLasDataSet = class(TRLDataSet)
  private
    FlasDoc: ILasDoc;
    FLasFile: string;
    procedure SetLasFile(const Value: string);
  protected
    function GetRecordCount: Integer; override;
    procedure InternalClose; override;
    procedure InternalOpen; override;
  public
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
/// <summary>
///  {week reference container}
/// </summary>
    class procedure New(const FileName: string; out Res: IDataSet); virtual;
  published
    property LasFile: string read FLasFile write SetLasFile;
  end;

implementation

{ TLasDataSet }

class procedure TLasDataSet.New(const FileName: string; out Res: IDataSet);
 var
  ii: IInterface;
begin
  if GContainer.TryGetInstance(ClassInfo, FileName, ii, False) then Res := ii as IDataSet
  else
   begin
    Res := Create as IDataSet;
    TLasDataSet(Res.DataSet).LasFile := FileName;
    TRegistration.Create(ClassInfo).AddInstance(FileName, Res);
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

initialization
  RegisterClass(TLasDataSet);
  TRegister.AddType<TLasDataSet, IDataSet>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TLasDataSet>;
end.
