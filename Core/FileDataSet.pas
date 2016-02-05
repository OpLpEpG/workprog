unit FileDataSet;

interface

uses ExtendIntf, DataSetIntf, Container,
     System.Classes, sysutils, Data.DB, IDataSets, FileCachImpl;

type
  TFileFieldDef = class(TFieldDef)
  private
    FDataOffset: Integer;
  published
    property DataOffset: Integer read FDataOffset write FDataOffset;
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
    function GetFileData: IFileData;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function FindFieldData(Buffer: PRecBuffer; Field: TField): PByte;
    function GetFieldDefsClass: TFieldDefsClass; override;
    function GetRecordCount: Integer; override;
  public
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    property FileData: IFileData read GetFileData;
/// <summary>
///  {week reference container}
/// </summary>
    class procedure New(const FileName: string; out Res: IDataSet); virtual;
  published
    property BinFileName: string read FBinFileName write FBinFileName;
    property RecordLength: Integer read FRecordLength write FRecordLength;
  end;


implementation

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
   end;
end;

function TFileDataSet.FindFieldData(Buffer: PRecBuffer; Field: TField): PByte;
 var
  cnt: Integer;
  Index: Integer;
begin
  cnt := FileData.Read(RecordLength, Pointer(Result), Buffer.ID*RecordLength);
  if cnt <> RecordLength then Result := nil
  else
   begin
    Index := Field.FieldNo - 1; // FieldDefList index (-1 and 0 become less than zero => ignored)
    if Index >= 0 then
    begin
     Inc(Result, TFileFieldDef(FieldDefList[Index]).DataOffset);
    end;
   end;
end;

function TFileDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
 var
  RecBuf: PRecBuffer;
  Data: PByte;
begin
  Result := False;
  if not GetActiveRecBuf(RecBuf) then Exit;
  if Field.FieldNo > 0 then
  begin
   Data := FindFieldData(RecBuf, Field);
   if Data <> nil then
    begin
     Move(Data^, Buffer[0], Field.Size);
     Result := True;
    end;
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
end;

function TFileDataSet.GetRecordCount: Integer;
begin
  Result := FileData.Size div RecordLength;
end;

function TFileDataSet.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IID = IFileData then Result := FileData.QueryInterface(IID, Obj)
  else Result := inherited;
end;

{ TFileFieldDefs }

function TFileFieldDefs.GetFieldDefClass: TFieldDefClass;
begin
  Result :=  TFileFieldDef;
end;

initialization
  RegisterClass(TFileDataSet);
  TRegister.AddType<TFileDataSet, IDataSet>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFileDataSet>;
end.
