unit FileCachImpl;

interface

uses
      DeviceIntf, ExtendIntf, RootIntf, debug_except, rootimpl, PluginAPI, Container, System.TypInfo,
      System.SyncObjs, System.DateUtils, SysUtils, Xml.XMLIntf, Xml.XMLDoc, Xml.xmldom, System.IOUtils,
      Winapi.Windows,
      System.Generics.Collections,
      System.Generics.Defaults,
      System.Bindings.Helper,
      System.Classes, tools;

type
  EFileMappingCash = class(EBaseException);
  TFileMappingCash = class(TAggObject, ICashedData)
  private
    FFile: TFileStream;
    FMapping: THandle;
    FMemory: PByte;
    FMapFrom: Int64;
    FMapSize: Integer;
    FMapPosition: Int64;
    procedure Close;
    procedure Remap(MapFrom: Int64);
  protected
    // ICashedData
    procedure SetCashSize(const Value: Integer);
    function GetCashSize: Integer;
    function GetMaxCashSize: Int64;
  public
    constructor Create(FileStrm: TFileStream);
    destructor Destroy; override;
    function Read(Count: Integer; out PData: Pointer; From: Int64 = -1): Integer;
    property Cash: Integer read GetCashSize write SetCashSize;
    property MaxCash: Int64 read GetMaxCashSize;
  end;

  { TODO :
Нужно создать наследник в projectmanager3
из GFileDataFactory неренести ConstructFileName в наследник }
  TFileData = class(TIComponent, IFileData, ICashedData)
  private
    FFile: TFileStream;
    FCash: TFileMappingCash;
    FS_Write: Integer;
    FLock: TCriticalSection; // TMultiReadExclusiveWriteSynchronizer;
    procedure SetS_Write(const Value: Integer);
  protected
    // IFileData
    procedure Lock;
    procedure UnLock;
    function GetPosition: Int64;
    function GetSize: Int64;
    procedure SetPosition(const Value: Int64);
    function GetFileName: string;
    function Read(Count: Integer; out PData: Pointer; From: Int64 = -1): Integer;
    function Write(Count: Integer; PData: Pointer; From: Int64 = -1): Integer;
  public
    constructor Create; override;
    constructor CreateUser(const FileName: string);
    destructor Destroy; override;
    property Cash: TFileMappingCash read FCash implements ICashedData;
    property S_Write: Integer read FS_Write write SetS_Write;
  end;

  TFileDataclass = class of TFileData;


  GFileDataFactory = record
    class function ConstructFileName(const Root: IXMLNode): string;  static;
/// <summary>
///  {week reference}
/// </summary>
    class function Factory(cls: TFileDataclass; const FileName: string): IFileData; overload; static;
/// <summary>
///  {week reference}
/// </summary>
    class function Factory(cls: TFileDataclass; const Root: IXMLNode): IFileData;  overload; static;
  end;

implementation


{$REGION 'GFileDataFactory'}

{ GFileDataFactory }

class function GFileDataFactory.Factory(cls: TFileDataclass; const FileName: string): IFileData;
 var
  ii: IInterface;
begin
  if not (GContainer.TryGetInstance(cls.ClassInfo, FileName, ii) and Supports(ii, IFileData, Result)) then
   begin
    Result := cls.CreateUser(FileName);
    TRegistration.Create(cls.ClassInfo).Add(TypeInfo(IFileData)).AddInstance(FileName, Result);
    TIComponent(Result).WeekContainerReference := True;
   end;
end;


class function GFileDataFactory.ConstructFileName(const Root: IXMLNode): string;
 var
  fn, dir: string;
  i: Integer;
  pdf: IProjectDataFile;
begin
  if not Supports(GContainer, IProjectDataFile, pdf) then raise Exception.Create('Error IProjectDataFile не поддерживается');
  dir := pdf.ConstructDataDir(Root);
  if Root.HasAttribute(AT_FILE_NAME) then Exit(dir + Root.Attributes[AT_FILE_NAME]);
  fn := pdf.ConstructDataFileName(Root);
  Result := dir  + fn;
  i := 0;
  while TFile.Exists(Result) do
   begin
    inc(i);
    fn := pdf.ConstructDataFileName(Root, i.ToString);
    Result := dir  + fn;
   end;
  Root.Attributes[AT_FILE_NAME] := fn;
  (GContainer as IALLMetaDataFactory).Get.Save;
end;

class function GFileDataFactory.Factory(cls: TFileDataclass; const Root: IXMLNode): IFileData;
 var
  ii: IInterface;
  FileName: string;
begin
  FileName := ConstructFileName(Root);
  if not (GContainer.TryGetInstance(cls.ClassInfo, FileName, ii) and Supports(ii, IFileData, Result)) then
   begin
    Result := cls.CreateUser(FileName);
    TRegistration.Create(cls.ClassInfo).Add(TypeInfo(IFileData)).AddInstance(FileName, Result);
    TIComponent(Result).WeekContainerReference := True;
   end;
end;
{$ENDREGION}

{$REGION 'TFileMappingCash'}

constructor TFileMappingCash.Create(FileStrm: TFileStream);
 var
  gm: IGlobalMemory;
begin
  FFile := FileStrm;
  if Supports(GContainer, IGlobalMemory, gm) then Cash := (GContainer as IGlobalMemory).GetMemorySize(MaxCash)
  else Cash := MaxCash;
  FMapFrom := integer.MaxValue;
end;

destructor TFileMappingCash.Destroy;
begin
  Close;
  inherited;
end;

procedure TFileMappingCash.Close;
begin
  if FMemory <> nil then
   begin
    UnMapViewOfFile(FMemory);
    FMemory := nil;
   end;
  if FMapping <> 0 then
   begin
    CloseHandle(FMapping);
    FMapping := 0;
   end;
end;

procedure TFileMappingCash.Remap(MapFrom: Int64);
begin
  if FMapFrom = MapFrom then Exit;
  if FMemory <> nil then
   begin
    UnMapViewOfFile(FMemory);
    FMemory := nil;
   end;
  if MapFrom + Cash > MaxCash then MapFrom := MaxCash - Cash;
  FMemory := MapViewOfFile(FMapping, FILE_MAP_READ, Hi(MapFrom), Lo(MapFrom), Cash);
  if not Assigned(FMemory) then raise EFileMappingCash.CreateFmt('Ошибка вида мап длина %d файл: %s',[Cash, FFile.FileName]);
  FMapFrom := MapFrom;
end;


function TFileMappingCash.Read(Count: Integer; out PData: Pointer; From: Int64): Integer;
begin
  { TODO : в потоках если будет РЕМАП то будут проблеммы }
  if From >= 0 then FMapPosition := From;
  if Count > Cash then Count := Cash;
  if FMapPosition < FMapFrom then Remap(FMapPosition)
  else if FMapPosition + Count > FMapFrom + Cash then Remap(FMapPosition);
 // else if not Assigned(FMemory) then Remap(FMapPosition);

  PData := FMemory + FMapPosition - FMapFrom;
  if FMapPosition + Count > FMapFrom + Cash then Result := FMapFrom + Cash - FMapPosition
  else Result := Count;
  Inc(FMapPosition, Result);
end;

function TFileMappingCash.GetCashSize: Integer;
begin
  Result := FMapSize
end;

function TFileMappingCash.GetMaxCashSize: Int64;
begin
  Result := FFile.Size;
end;

procedure TFileMappingCash.SetCashSize(const Value: Integer);
begin
  if FMapSize <> Value then
   begin
    Close;
    FMapping := CreateFileMapping(FFile.Handle, nil, PAGE_READONLY, 0, Value, nil);
    if FMapping = 0 then raise EFileMappingCash.CreateFmt('Ошибка создания мап длина %d файл: %s',[Value, FFile.FileName]);
    FMapSize := Value;
   end;
end;
{$ENDREGION}

{$REGION 'TFileData'}

{ TFileData }

constructor TFileData.Create;
begin
  inherited;
  FLock := TCriticalSection.Create;// TMultiReadExclusiveWriteSynchronizer.Create;
end;

constructor TFileData.CreateUser(const FileName: string);
 var
  path: string;
begin
  Create;
  if TFile.Exists(FileName) then FFile := TFileStream.Create(FileName, fmOpenReadWrite)
  else
   begin
    path := TPath.GetDirectoryName(FileName);
    if not TDirectory.Exists(path) then TDirectory.CreateDirectory(path);
    FFile := TFileStream.Create(FileName, fmCreate);
   end;
  FFile.Position := FFile.Size;
end;

destructor TFileData.Destroy;
begin
  TBindHelper.RemoveExpressions(Self);
  FFile.Free;
  if Assigned(FCash) then FreeAndNil(FCash);
  FLock.Free;
  inherited;
end;

/// <summary>
/// Тк выдается указатель на данные то Lock делает пользователь
/// </summary>
function TFileData.Read(Count: Integer; out PData: Pointer; From: Int64 = -1): Integer;
begin
//  FSinc.BeginRead;
//  try
   if not Assigned(FCash) then FCash := TFileMappingCash.Create(FFile);
   Result := FCash.Read(Count, PData, From);
//  finally
//   FSinc.EndRead;
//  end;
end;

/// <summary>
/// Тк выдается указатель на данные то Lock делает пользователь
/// </summary>
function TFileData.Write(Count: Integer; PData: Pointer;  From: Int64 = -1): Integer;
begin
//  if not FSinc.BeginWrite then raise Exception.Create('Error Message FSinc.BeginWrite');
//  Lock;
//  try
   if Assigned(FCash) then FreeAndNil(FCash);
   if From >= 0 then FFile.Position := From;
   Result := FFile.Write(PData^, Count);
   S_Write := Result;
//  finally
//   UnLock;
//   FSinc.EndWrite;
//  end;
end;

function TFileData.GetFileName: string;
begin
  Result := FFile.FileName
end;

procedure TFileData.SetPosition(const Value: Int64);
begin
  FFile.Position := Value;
end;

procedure TFileData.SetS_Write(const Value: Integer);
begin
  FS_Write := Value;
  TBindings.Notify(Self, 'S_Write');
end;

procedure TFileData.UnLock;
begin
  FLock.Leave;
end;

function TFileData.GetPosition: Int64;
begin
  Result := FFile.Position;
end;

function TFileData.GetSize: Int64;
begin
  Result := FFile.Size;
end;
procedure TFileData.Lock;
begin
  FLock.Enter;
end;

{$ENDREGION}

initialization
  TRegister.AddType<TFileData, IFileData>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFileData>;
end.
