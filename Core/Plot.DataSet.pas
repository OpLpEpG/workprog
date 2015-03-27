unit Plot.DataSet;

interface

uses sysutils, Classes, Controls, Db, VCL.forms, debug_except;

type
  TPlotDataSet = class(TDataSet)
  private
    FRealRecordPos: Integer;
    procedure SetRecordPosition(const Value: Integer);
  protected
    function GetRecordSize: Word; override;
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult; override;
    function GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean; override;
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    function IsCursorOpen: Boolean; override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    procedure SetBookmarkFlag(Buffer:TRecordBuffer; Value: TBookmarkFlag); override;
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
    property RecordPos: Integer read FRealRecordPos write SetRecordPosition;
  public
    constructor Create(AOwner: TComponent); override;
  end;


implementation

{ TPlotDataSet }


function TPlotDataSet.AllocRecordBuffer: TRecordBuffer;
begin
  GetMem(Result, 1000);
  InternalInitRecord(Result);
end;

constructor TPlotDataSet.Create(AOwner: TComponent);
begin
  inherited;
 BookmarkSize := Sizeof(Integer);
 RecordPos := -1;
end;

procedure TPlotDataSet.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FreeMem(Buffer, 1000);
  Buffer := nil;
end;

procedure TPlotDataSet.GetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  inherited;

end;

function TPlotDataSet.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin

end;

function TPlotDataSet.GetFieldData(Field: TField; var Buffer: TValueBuffer): Boolean;
 var
  s: string;
begin
  if Field.Index = 0 then Pinteger(Buffer)^ := RecordPos
  else
   begin
   // s := RecordPos.ToString();
   // Move(s, Buffer, Field.Size);
   end;
  Result := True;
end;

function TPlotDataSet.GetRecNo: Integer;
begin
  Result := RecordPos;
end;

function TPlotDataSet.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean): TGetResult;
var Accept: Boolean;
begin   // Дать запись. Космический код ! Править нельзя !
  Result := grOk;
  if not Assigned(Buffer) then Exit(grError);

  //Accept := True;
//  _CheckPositionCursor(RecordPos);
  case GetMode of
   gmPrior: begin   // Предыдущую
      if RecordPos <= 0 then
       begin  // Предыдущих нет
        Result := grBof;
        RecordPos := -1;
       end
      else
       begin
        RecordPos := RecordPos-1;
       { repeat // Пролистаем отфильтрованые
         RecordPos:=RecordPos-1;
         //Accept := _RecordFilter;
         //if Filtered then Accept := _RecordFilter;
        until Accept or (RecordPos =  0);
        if not Accept then
         begin
          Result := grBOF;
          RecordPos := -1;
        end;}
       end;
    end;
   gmCurrent: begin  // Текущую
     if (RecordPos < 0) or (RecordPos >= RecordCount) then Result := grError
//     else if Filtered then
//      if not _RecordFilter then Result := grError;
    end;
   gmNext: begin  // Следующую
      if (RecordPos >= RecordCount - 1) then Result := grEof
      else
       begin
         RecordPos := RecordPos + 1;
     {   repeat  // Пролистаем отфильтрованные
         RecordPos := RecordPos + 1;
         Accept := _RecordFilter;
         //if Filtered then Accept := _RecordFilter;
        until Accept or ((RecordPos > RecordCount - 1) and FIsFechAll);
        if not Accept then
         begin
          Result := grEOF;
          RecordPos := RecordCount - 1;
         end;}
       end;
    end;
  end;
  if Result = grOk then
   begin // Проверки на здравый смысл
     Pinteger(Buffer)^ := RecordPos;
     GetCalcFields(Buffer);
   end
  else
   if (Result = grError) and DoCheck then DatabaseError('str_No_Record', Self);
end;

function TPlotDataSet.GetRecordCount: Integer;
begin
  Result := 200;
end;

function TPlotDataSet.GetRecordSize: Word;
begin
  Result := 1000;
end;

procedure TPlotDataSet.InternalClose;
begin
  if DefaultFields then  DestroyFields;
end;

procedure TPlotDataSet.InternalGotoBookmark(Bookmark: Pointer);
begin
  inherited;

end;

procedure TPlotDataSet.InternalHandleException;
begin
  Application.HandleException(Self);
end;

procedure TPlotDataSet.InternalInitFieldDefs;
begin
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftInteger;
      Name := 'Field1';
    end;
    with FieldDefs.AddFieldDef do
    begin
      DataType := ftString;
      Size := 10;
      Name := 'Field2';
    end;
end;

procedure TPlotDataSet.InternalOpen;
begin
  FieldDefs.Updated := False;
  FieldDefs.Update;
  FieldDefList.Update;
//  InitFieldDefsFromFields;
  if DefaultFields then CreateFields;
  BindFields(True);
//  ActivateBuffers;
  InternalFirst;
end;

procedure TPlotDataSet.InternalSetToRecord(Buffer: TRecordBuffer);
begin

end;

function TPlotDataSet.IsCursorOpen: Boolean;
begin
  Result := Active
end;

procedure TPlotDataSet.SetBookmarkData(Buffer: TRecordBuffer; Data: Pointer);
begin
  inherited;

end;

procedure TPlotDataSet.SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag);
begin
  inherited;

end;

procedure TPlotDataSet.SetRecNo(Value: Integer);
begin
  RecordPos := Value;
end;

procedure TPlotDataSet.SetRecordPosition(const Value: Integer);
begin
  FRealRecordPos := Value;
end;

end.
