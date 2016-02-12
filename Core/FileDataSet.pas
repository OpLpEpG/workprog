unit FileDataSet;

interface

uses ExtendIntf, DataSetIntf, Container, debug_except,
     System.Classes, sysutils, Data.DB, IDataSets, FileCachImpl;

type
  TFileFieldDef = class(TFieldDef)
  private
    FDataOffset: Integer;
    FArraySize: Integer;
    FArrayType: Integer;
    FCalcField: Boolean;
  public
    function IsArrray: Boolean;
    function GetPath: string;
  published
    property DataOffset: Integer read FDataOffset write FDataOffset;
    property ArraySize: Integer read FArraySize write FArraySize default 0;
    property ArrayType: Integer read FArrayType write FArrayType default 0;
    property CalcField: Boolean read FCalcField write FCalcField;
  end;

  TFileFieldDefs = class(TFieldDefs)
  protected
    function GetFieldDefClass: TFieldDefClass; override;
  end;

  TFileDataSet = class(TRLDataSet)
  private
    FFileData: IFileData;
    FBinFileName: string;
    FRecordLength: Integer;
    FCurrDataBuffer: PByte;
    FCurrDataID: Integer;
    function GetFileData: IFileData;
  protected
    procedure SetFieldProps(Field: TField; FieldDef: TFieldDef); override;
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function GetRecData(Buffer: PRecBuffer): PByte;
    function InternalCalcRecBuffer(Buffer: PRecBuffer): Boolean; virtual;
    function FindFieldData(Buffer: PRecBuffer; Field: TField): PByte;
    function GetFieldDefsClass: TFieldDefsClass; override;
    function GetRecordCount: Integer; override;
  public
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    property FileData: IFileData read GetFileData;
/// <summary>
///  {week reference container}
/// </summary>
    class procedure New(const FileName: string; out Res: IDataSet); //virtual;
  published
    property BinFileName: string read FBinFileName write FBinFileName;
    property RecordLength: Integer read FRecordLength write FRecordLength;
  end;


implementation

function ToDBDisplayFormat(Precision: Integer): string;
 var
  i: Integer;
begin
  Result := '#0.';
  for i:= 1 to Precision do Result := Result + '0';
end;

{ TFileDataSet }

class procedure TFileDataSet.New(const FileName: string; out Res: IDataSet);
 var
  ii: IInterface;
begin
  if GContainer.TryGetInstance(ClassInfo, FileName, ii, False) then Res := ii as IDataSet
  else
   begin
    Res := Create as IDataSet;
    TFileDataSet(Res.DataSet).BinFileName := FileName;
    TRegistration.Create(ClassInfo).AddInstance(FileName, Res);
    TFileDataSet(Res.DataSet).WeekContainerReference := True;
    TFileDataSet(Res.DataSet).FCurrDataID := -1;
   end;
end;

function TFileDataSet.GetRecData(Buffer: PRecBuffer): PByte;
begin
  if FCurrDataID = Buffer.ID then Exit(FCurrDataBuffer)
  else if FileData.Read(RecordLength, Pointer(Result), Buffer.ID*RecordLength) <> RecordLength then Result := nil
  else
   begin
    FCurrDataBuffer := Result;
    FCurrDataID := Buffer.ID;
   end;
end;

function TFileDataSet.FindFieldData(Buffer: PRecBuffer; Field: TField): PByte;
 var
  Index: Integer;
  pb: PBoolean;
  f: TFileFieldDef;
begin
  ////
  //  Tdebug.log(Buffer.ID.ToString());
  ////
  Result := nil;
  Index := Field.FieldNo - 1; // FieldDefList index (-1 and 0 become less than zero => ignored)
  if Index < 0 then Exit;
  if Index = 0 then Exit(@(Buffer^.ID));
  f := TFileFieldDef(FieldDefList[Index]);
  if f.CalcField and AutoCalcFields then
   begin
    PByte(pb) := PByte(Buffer) + SizeOf(TRecBuffer);
    if not pb^ and not InternalCalcRecBuffer(Buffer) then Exit;
    Result := PByte(pb) + SizeOf(Boolean);
   end
   else if Field.FieldKind = fkData then Result := GetRecData(Buffer);
  if not Assigned(Result) then Exit;
  Inc(Result, f.DataOffset);
end;

function TFileDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
 var
  RecBuf: PRecBuffer;
  Data: PByte;
  l: Integer;
begin
  Result := False;
  if Field.DataType in [ftADT] then Exit;
//  TDebug.Log('  Field.FieldNo %d  %s   ', [Field.FieldNo, Field.FullName]);
  if not GetActiveRecBuf(RecBuf) then Exit;
  Data := FindFieldData(RecBuf, Field);
  if Data <> nil then
   begin
    l := Field.DataSize;
    SetLength(Buffer, l);
    Move(Data^, Buffer[0], l);
    Result := True;
   end;
end;

function TFileDataSet.GetFieldDefsClass: TFieldDefsClass;
begin
  Result := TFileFieldDefs;
end;

function TFileDataSet.GetFileData: IFileData;
begin
  if Assigned(FFileData) then Exit(FFileData);
  FFileData := GFileDataFactory.Factory(TFileData, BinFileName);
  Result := FFileData;
end;

function TFileDataSet.GetRecordCount: Integer;
 var
  n: Int64;
begin
  n := FileData.Size;
  Result := n div RecordLength;
end;

function TFileDataSet.InternalCalcRecBuffer(Buffer: PRecBuffer): Boolean;
begin
  Result := False;
end;

function TFileDataSet.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IID = IFileData then Result := FileData.QueryInterface(IID, Obj)
  else Result := inherited;
end;

procedure TFileDataSet.SetFieldProps(Field: TField; FieldDef: TFieldDef);
begin
  inherited;
  if (Field is TNumericField) and (FieldDef.Precision > 0) then
     TNumericField(Field).DisplayFormat := ToDBDisplayFormat(FieldDef.Precision);
end;

{ TFileFieldDefs }

function TFileFieldDefs.GetFieldDefClass: TFieldDefClass;
begin
  Result :=  TFileFieldDef;
end;

{ TFileFieldDef }

function TFileFieldDef.GetPath: string;
 var
  f: TFieldDef;
begin
  Result := Name;
  f := Self;
  while Assigned(f.ParentDef) do
   begin
    f := f.ParentDef;
    Result := f.Name + '.' + Result;
   end;
end;

function TFileFieldDef.IsArrray: Boolean;
begin
  Result := FArraySize <> 0;
end;

initialization
  RegisterClass(TFileDataSet);
  TRegister.AddType<TFileDataSet, IDataSet>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFileDataSet>;
end.
