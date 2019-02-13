unit SDcardTools;

interface

uses RootIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Threading,
  System.IOUtils, JclFileUtils;

type
  TCopyAsyncEvent = procedure(car: EnumCopyAsyncRun; Stat: TStatistic; var Erminate: Boolean) of object;

  TSDStream = class(THandleStream)
  private
    FDiskSize: Int64;
    FNumSectors: DWORD;
    FSectorSize: DWORD;
  protected
    function GetSize: Int64; override;
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(const DevLetter: string; access: ULONG);
    destructor Destroy; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function AsyncCopyTo(const FlName: string; Offset, Count: Int64; ToZ: Boolean; ev: TCopyAsyncEvent): ITask;
    property SectorSize: DWORD read FSectorSize;
    property NumSectors: DWORD read FNumSectors;
    class function EnumLogicalDrives: TArray<Char>;
  end;

  TAsyncCopy = class
   const
    GIG = 1024*1024*512;
    M32 = 32*1024*1024;
    ZPOROG = 512;
  private
    FStrmSD: TSDStream;
    FStrmFile: TFileStream;
    FOffset, FCount: Int64;
    FReadCount: Int64;
    FToZ: Boolean;
    Fevent: TCopyAsyncEvent;
    FDestFile: string;
    FMap: TJclFileMapping;
    FBeginTime: TDateTime;
    procedure InnerCreateMap;
    procedure InnerCreateStream;
    function View: TJclFileMappingView;
   type
    TLoadViewResult = record
     Res: EnumCopyAsyncRun;
     NumLoad: Cardinal;
     //LastNozerro: Cardinal;
    end;
    function LoadView: TLoadViewResult;
    procedure Remap;
    procedure CheckData;
    function CheckZerroes(p: PByte; cnt: Cardinal; out ZBegin: Cardinal): Boolean;
    function GetStatistic(LocalRead: Cardinal): TStatistic;
  public
    constructor Create(SrcSD: TSDStream; const DestFile: string; Offset, Count: Int64; ToZ: Boolean; ev: TCopyAsyncEvent);
    procedure Execute;
    destructor Destroy; override;
  end;

implementation

{$REGION 'TYPES'}
type
    MEDIA_TYPE = (
      Unknown,                // Format is unknown
      F5_1Pt2_512,            // 5.25", 1.2MB,  512 bytes/sector
      F3_1Pt44_512,           // 3.5",  1.44MB, 512 bytes/sector
      F3_2Pt88_512,           // 3.5",  2.88MB, 512 bytes/sector
      F3_20Pt8_512,           // 3.5",  20.8MB, 512 bytes/sector
      F3_720_512,             // 3.5",  720KB,  512 bytes/sector
      F5_360_512,             // 5.25", 360KB,  512 bytes/sector
      F5_320_512,             // 5.25", 320KB,  512 bytes/sector
      F5_320_1024,            // 5.25", 320KB,  1024 bytes/sector
      F5_180_512,             // 5.25", 180KB,  512 bytes/sector
      F5_160_512,             // 5.25", 160KB,  512 bytes/sector
      RemovableMedia,         // Removable media other than floppy
      FixedMedia,             // Fixed hard disk media
      F3_120M_512,            // 3.5", 120M Floppy
      F3_640_512,             // 3.5" ,  640KB,  512 bytes/sector
      F5_640_512,             // 5.25",  640KB,  512 bytes/sector
      F5_720_512,             // 5.25",  720KB,  512 bytes/sector
      F3_1Pt2_512,            // 3.5" ,  1.2Mb,  512 bytes/sector
      F3_1Pt23_1024,          // 3.5" ,  1.23Mb, 1024 bytes/sector
      F5_1Pt23_1024,          // 5.25",  1.23MB, 1024 bytes/sector
      F3_128Mb_512,           // 3.5" MO 128Mb   512 bytes/sector
      F3_230Mb_512,           // 3.5" MO 230Mb   512 bytes/sector
      F8_256_128,             // 8",     256KB,  128 bytes/sector
      F3_200Mb_512,           // 3.5",   200M Floppy (HiFD)
      F3_240M_512,            // 3.5",   240Mb Floppy (HiFD)
      F3_32M_512              // 3.5",   32Mb Floppy
    );

  DISK_GEOMETRY = record
    Cylinders: Int64; //LARGE_INTEGER
    MediaType: MEDIA_TYPE;
    TracksPerCylinder: Cardinal;
    SectorsPerTrack: Cardinal;
    BytesPerSector: Cardinal;
  end;
  PDISK_GEOMETRY = ^DISK_GEOMETRY;

  DISK_GEOMETRY_EX = record
    Geometry: DISK_GEOMETRY;
    DiskSize: Int64; //LARGE_INTEGER
    Data: array [0..1-1] of Byte;
  end;
  PDISK_GEOMETRY_EX = ^DISK_GEOMETRY_EX;


//
// Device property descriptor - this is really just a rehash of the inquiry
// data retrieved from a scsi device
//
// This may only be retrieved from a target device.  Sending this to the bus
// will result in an error
//

//  Required to ensure correct PhysicalDrive IOCTL structure setup
{$ALIGN 4}

//
// IOCTL_STORAGE_QUERY_PROPERTY
//
// Input Buffer:
//      a STORAGE_PROPERTY_QUERY structure which describes what type of query
//      is being done, what property is being queried for, and any additional
//      parameters which a particular property query requires.
//
//  Output Buffer:
//      Contains a buffer to place the results of the query into.  Since all
//      property descriptors can be cast into a STORAGE_DESCRIPTOR_HEADER,
//      the IOCTL can be called once with a small buffer then again using
//      a buffer as large as the header reports is necessary.
//


//
// Types of queries
//

type
{$Z4} //size of each enumeration type should be equal 4
STORAGE_QUERY_TYPE = (
    PropertyStandardQuery = 0,          // Retrieves the descriptor
    PropertyExistsQuery,                // Used to test whether the descriptor is supported
    PropertyMaskQuery,                  // Used to retrieve a mask of writeable fields in the descriptor
    PropertyQueryMaxDefined     // use to validate the value
);
{$Z1}

//
// define some initial property id's
//
{$Z4} //size of each enumeration type should be equal 4
STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0, StorageAdapterProperty);
{$Z1}

//
// Query structure - additional parameters for specific queries can follow
// the header
//

type
	STORAGE_PROPERTY_QUERY =
                            record
    //
    // ID of the property being retrieved
    //
    PropertyId: STORAGE_PROPERTY_ID;
    //
    // Flags indicating the type of query being performed
    //
    QueryType: STORAGE_QUERY_TYPE;
    //
    // Space for additional parameters if necessary
    //
    AdditionalParameters: array [0..1-1] of UCHAR;
end;
{$ALIGN on}
PSTORAGE_PROPERTY_QUERY = ^STORAGE_PROPERTY_QUERY;


type
  STORAGE_BUS_TYPE = (
    BusTypeUnknown = $00,
    BusTypeScsi,
    BusTypeAtapi,
    BusTypeAta,
    BusType1394,
    BusTypeSsa,
    BusTypeFibre,
    BusTypeUsb,
    BusTypeRAID,
    BusTypeiScsi,
    BusTypeSas,
    BusTypeSata,
    BusTypeSd,
    BusTypeMmc,
    BusTypeMax,
    BusTypeMaxReserved = $7F);

    DEVICE_TYPE = DWORD;

//typedef struct _DEVICE_NUMBER
//{
//    DEVICE_TYPE  DeviceType;
//    ULONG  DeviceNumber;
//    ULONG  PartitionNumber;
//} DEVICE_NUMBER, *PDEVICE_NUMBER;

  PDEVICE_NUMBER =^DEVICE_NUMBER;
  DEVICE_NUMBER = record
   DeviceType: DEVICE_TYPE;
   DeviceNumber: ULONG;
   PartitionNumber: ULONG;
  end;

{$ALIGN 4}
type
  STORAGE_DEVICE_DESCRIPTOR = record
    // Sizeof(STORAGE_DEVICE_DESCRIPTOR)
    Version: Cardinal;
    // Total size of the descriptor, including the space for additional
    // data and id strings
    Size: Cardinal;
    // The SCSI-2 device type
    DeviceType: Byte;
    // The SCSI-2 device type modifier (if any) - this may be zero
    DeviceTypeModifier: Byte;
    // Flag indicating whether the device's media (if any) is removable.  This
    // field should be ignored for media-less devices
    RemovableMedia: Byte;
    // Flag indicating whether the device can support mulitple outstanding
    // commands.  The actual synchronization in this case is the responsibility
    // of the port driver.
    CommandQueueing: Byte;
    // Byte offset to the zero-terminated ascii string containing the device's
    // vendor id string.  For devices with no such ID this will be zero
    VendorIdOffset: Cardinal;
    // Byte offset to the zero-terminated ascii string containing the device's
    // product id string.  For devices with no such ID this will be zero
    ProductIdOffset: Cardinal;
    // Byte offset to the zero-terminated ascii string containing the device's
    // product revision string.  For devices with no such string this will be
    // zero
    ProductRevisionOffset: Cardinal;
    // Byte offset to the zero-terminated ascii string containing the device's
    // serial number.  For devices with no serial number this will be zero
    SerialNumberOffset: Cardinal;
    // Contains the bus type (as defined above) of the device.  It should be
    // used to interpret the raw device properties at the end of this structure
    // (if any)
    BusType: STORAGE_BUS_TYPE;
    // The number of bytes of bus-specific data which have been appended to
    // this descriptor
    RawPropertiesLength: Cardinal;
    // Place holder for the first byte of the bus specific property data
    RawDeviceProperties: array [0..1-1] of Byte;
end;
PSTORAGE_DEVICE_DESCRIPTOR = ^STORAGE_DEVICE_DESCRIPTOR;
{$ALIGN on}

{$ENDREGION 'TYPES'}

{$REGION 'FUNCS'}
function GetDisksProperty(hDevice: Thandle; pDevDesc: PSTORAGE_DEVICE_DESCRIPTOR; var devInfo: DEVICE_NUMBER): Boolean;
var
  Query: STORAGE_PROPERTY_QUERY;
  dwOutBytes: DWORD;
  //cbBytesReturned: DWORD;
begin
//  SetFilePointer(
//  ReadFile(
 	// specify the query type
  FillMemory(@Query, sizeof(Query), 0);
	Query.PropertyId := StorageDeviceProperty;
	Query.QueryType := PropertyStandardQuery;

	// Query using IOCTL_STORAGE_QUERY_PROPERTY
	Result := DeviceIoControl(hDevice, IOCTL_STORAGE_QUERY_PROPERTY,
    				@Query, sizeof(STORAGE_PROPERTY_QUERY), pDevDesc, pDevDesc.Size, dwOutBytes, nil);

	Result := Result and DeviceIoControl(hDevice, IOCTL_STORAGE_GET_DEVICE_NUMBER,
				                  	nil, 0, @devInfo, sizeof(DEVICE_NUMBER), dwOutBytes,	nil);
end;


function checkDriveType(DriveLette: Char; var pID: ULONG): Boolean;
 var
  hDevice: THandle;
  DevDesc: PSTORAGE_DEVICE_DESCRIPTOR;
  buffer: array [0..10000-1] of AnsiChar;

  deviceInfo: DEVICE_NUMBER;
  nameWithSlash, nameNoSlash: PChar;
  driveType: Integer;
  cbBytesReturned, Ntom, fs: DWORD;
begin
   nameWithSlash := PChar(Format('\\.\%s:\', [DriveLette]));
   nameNoSlash := PChar(Format('\\.\%s:', [DriveLette]));
   driveType := GetDriveType(nameWithSlash);
   Result := False;
   if driveType = DRIVE_REMOVABLE then
    begin
     hDevice := CreateFile(nameNoSlash, FILE_READ_ATTRIBUTES, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
     if hDevice = INVALID_HANDLE_VALUE then Exit(False);

     FillMemory(@buffer, sizeof(buffer), 0);
     DevDesc := @buffer[0];
     DevDesc.Size := sizeof(buffer);

     if GetDisksProperty(hDevice, DevDesc, deviceInfo) and (DevDesc.BusType <> BusTypeSata) then
      begin
      // ensure that the drive is actually accessible
     // multi-card hubs were reporting "removable" even when empty
       if DeviceIoControl(hDevice, IOCTL_STORAGE_CHECK_VERIFY2, nil, 0, nil, 0, cbBytesReturned, nil) then
        begin
         pid := deviceInfo.DeviceNumber;
         Result := true;
        end
       else
        begin
         // IOCTL_STORAGE_CHECK_VERIFY2 fails on some devices under XP/Vista, try the other (slower) method, just in case.
         CloseHandle(hDevice);
         hDevice := CreateFile(nameNoSlash, FILE_READ_DATA, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
         if DeviceIoControl(hDevice, IOCTL_STORAGE_CHECK_VERIFY, nil, 0, nil, 0, cbBytesReturned, nil) then
          begin
           pid := deviceInfo.DeviceNumber;
           Result := true;
          end;
        end;
       Result := Result and not GetVolumeInformation(nameWithSlash, nil, 0, nil, Ntom, fs, nil, 0); // нет фаиловой систкмы
      end;
     CloseHandle(hDevice);
    end;
end;


{ TSDflashStream }

class function TSDStream.EnumLogicalDrives: TArray<Char>;
 var
  driveMask: DWORD;
  pID: ULONG;
  D: Char;
//  drivename: string;
begin
  driveMask := GetLogicalDrives();
  D := 'A';
  while (driveMask <> 0) do
   begin
    if ((driveMask and 1) <> 0) and checkDriveType(D, pID) then Result := Result + [D];
    driveMask := driveMask shr 1;
    D := Succ(d);
   end;
end;
{$ENDREGION 'FUNCS'}

{$REGION 'TSDStream'}
constructor TSDStream.Create(const DevLetter: string; access: ULONG);
 var
  cbBytesReturned: DWORD;
  dg: DISK_GEOMETRY_EX;
begin
  FHandle := CreateFile(PChar(Format('\\.\%s:', [DevLetter])), access, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if FHandle = INVALID_HANDLE_VALUE then RaiseLastOSError;
  if not DeviceIoControl(FHandle, IOCTL_DISK_GET_DRIVE_GEOMETRY_EX, nil, 0, @dg, sizeof(dg), cbBytesReturned, nil) then RaiseLastOSError;
  FSectorSize := dg.Geometry.BytesPerSector;
  FDiskSize := dg.DiskSize;
  FNumSectors := FDiskSize div dg.Geometry.BytesPerSector;
  inherited Create(FHandle);
end;

destructor TSDStream.Destroy;
// var
//  cbBytesReturned: DWORD;
begin
  if FHandle <> INVALID_HANDLE_VALUE then CloseHandle(FHandle);
  inherited;
end;

function TSDStream.GetSize: Int64;
begin
  Result := FDiskSize;
end;
procedure TSDStream.SetSize(NewSize: Integer);
begin
end;
procedure TSDStream.SetSize(const NewSize: Int64);
begin
end;

function TSDStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  SetLastError(0);
  if Origin = soEnd then Result := FileSeek(FHandle, FDiskSize+Offset, Ord(soBeginning))
  else Result := FileSeek(FHandle, Offset, Ord(Origin));
  if GetLastError <> ERROR_SUCCESS then RaiseLastOSError;
end;

function TSDStream.AsyncCopyTo(const FlName: string; Offset, Count: Int64; ToZ: Boolean; ev: TCopyAsyncEvent): ITask;

begin
  // поток
  Result := TTask.Run(procedure
   var
    CapturedException : Exception;
    dummy_stat: TStatistic;
    dummy: Boolean;
  begin
    with TAsyncCopy.Create(Self, FlName, Offset, Count, ToZ, ev) do
    try
      try
       Execute;
      except
       CapturedException := TObject(AcquireExceptionObject) as Exception;
       Fevent(carError, dummy_stat, dummy);
       TThread.Queue(TThread.CurrentThread, procedure
        begin
          raise CapturedException;
        end);
      end;
    finally
     Free;
    end;
  end);
end;
{$ENDREGION 'TSDStream'}


{ TAsyncCopy }

procedure TAsyncCopy.CheckData;
begin
  // проверка на диапазон
  if FOffset mod FStrmSD.SectorSize <> 0 then raise Exception.Create('Offset mod SectorSize <> 0');
  if FCount mod FStrmSD.SectorSize <> 0 then raise Exception.Create('Count mod SectorSize <> 0');
  if FOffset >= FStrmSD.Size then raise Exception.Create('Offset >= SD Size');
  if FOffset + FCount > FStrmSD.Size then raise Exception.Create('Offset+Count > SD Size');
end;

function TAsyncCopy.CheckZerroes(p: PByte; cnt: Cardinal; out ZBegin: Cardinal): Boolean;
 var
  pdw: PDword;
  n: Cardinal;
begin
  /////
  //Exit(False);
  ////
  PByte(pdw) := p + cnt;
  n := ZPOROG div 4;
  // 512 bytes test
  repeat
   Dec(pdw);
   Dec(n);
   if pdw^ <> 0 then Exit(False);
  until n = 0;
 // find last no z
  Result := True;
  n := (cnt - ZPOROG) div 4;
  repeat
   Dec(pdw);
   Dec(n);
   if pdw^ <> 0 then Break;
  until n = 0;
  Inc(pdw); // первый нулевой указатель
  ZBegin := PByte(pdw) - p;
end;

constructor TAsyncCopy.Create(SrcSD: TSDStream; const DestFile: string; Offset, Count: Int64; ToZ: Boolean; ev: TCopyAsyncEvent);
begin
  FStrmSD := TSDStream(SrcSD);
  FOffset := Offset;
  if Count = 0 then FCount := FStrmSD.Size - FOffset else FCount := Count;
  FToZ  := ToZ;
  Fevent := ev;
  FDestFile := DestFile;
end;



destructor TAsyncCopy.Destroy;
begin
  if Assigned(FMap) then FreeAndNil(FMap);
  if Assigned(FStrmFile) then FreeAndNil(FStrmFile);
  inherited;
end;

procedure TAsyncCopy.Execute;
 var
  r: TLoadViewResult;
begin
  CheckData;
  FStrmSD.Position := FOffset;
  InnerCreateStream;
  InnerCreateMap;
  FReadCount := 0;
  FBeginTime := Now;
  repeat
   r := LoadView;
   Inc(FReadCount, r.NumLoad);
   if r.Res = carOk then Remap;
  until r.Res <> carOk;
  if Assigned(FMap) then FreeAndNil(FMap);
  FStrmFile.Size := FReadCount;
end;

procedure TAsyncCopy.InnerCreateStream;
 var
  path: string;
begin
  if Assigned(FStrmFile) then FreeAndNil(FStrmFile);
  if TFile.Exists(FDestFile) then FStrmFile := TFileStream.Create(FDestFile, fmOpenReadWrite)
  else
   begin
    path := TPath.GetDirectoryName(FDestFile);
    if not TDirectory.Exists(path) then TDirectory.CreateDirectory(path);
    FStrmFile := TFileStream.Create(FDestFile, fmCreate);
   end;
  // file Size
  if (FCount > GIG) and FToZ then FStrmFile.Size := GIG // чтение до нулей начнем с GIG
  else FStrmFile.Size := FCount; // весь файл даже если 16 гиг
end;

function TAsyncCopy.LoadView: TLoadViewResult;
 var
  nread, n, lastNZ: Cardinal;
  Cur: Pbyte;
  prc: TStatistic;
  temn: Boolean;
begin
  Result.Res := carOk;
  Result.NumLoad := 0;
  temn := False;
  n := View.Size;
  while n > 0 do
   begin
    cur := PByte(View.Memory) + Result.NumLoad;
    // read
    if n >= M32 then nread := FStrmSD.Read(cur^, M32)
    else nread := FStrmSD.Read(cur^, n);
    if nread = 0 then raise Exception.Create('nread = 0');
    // next
    inc(Result.NumLoad, nread);
    Dec(n, nread);
    prc := GetStatistic(Result.NumLoad);
    // check empty  обязательно сначала вычисляем нули  т.к. считано может быть до конца
    if FToZ and CheckZerroes(Cur, nread, lastNZ) then
     begin
      Result.Res := carZerroes;
      Result.NumLoad := Result.NumLoad - nread + lastNZ;
      Fevent(carZerroes, GetStatistic(Result.NumLoad), temn);
      Exit;
     end
    // check end
    else if prc.ProcRun >= 100 then
     begin
      Result.Res := carEnd;
      Fevent(carEnd, prc, temn);
      Exit;
     end
    else
     begin
      Fevent(carOk, prc, temn);
     // check user terminate
      if temn then
       begin
        Result.Res := carTerminate;
        Fevent(carTerminate, prc, temn);
        Exit;
       end;
     end;
   end;
end;

function TAsyncCopy.GetStatistic(LocalRead: Cardinal): TStatistic;
 var
  Spd: double;
begin
  Result.NRead := FReadCount+LocalRead;
  Result.TimeFromBegin := Now - FBeginTime;
  Result.ProcRun := Result.NRead/FCount*100;
  // speed
  Spd := Result.NRead / Result.TimeFromBegin;
  Result.Speed := Spd/1024/1024 /24/3600; // MB/sec
  Result.TimeToEnd := (FCount - Result.NRead)/spd;
end;

procedure TAsyncCopy.InnerCreateMap;
 const                        //0- малый мап all file
  NSZ: array[Boolean] of Int64 = (0, GIG);
begin
  // create Map and first view
  if Assigned(FMap) then FreeAndNil(FMap);
  FMap := TJclFileMapping.Create(FStrmFile.Handle, '', PAGE_READWRITE, 0, nil);
  FMap.Add(SECTION_MAP_WRITE, NSZ[FCount > GIG], 0);
end;

procedure TAsyncCopy.Remap;
 var
  toEnd: int64;
begin
  toEnd := FCount - FReadCount;
  if toend > GIG then toend := GIG;
  if FToZ then
   begin
    // resize and recreate map
    if Assigned(FMap) then FreeAndNil(FMap);
    FStrmFile.Size := FStrmFile.Size + toend;
    FMap := TJclFileMapping.Create(FStrmFile.Handle, '', PAGE_READWRITE, 0, nil);
   end
  // delete view
  else FMap.Delete(0);
  // add view
  FMap.Add(SECTION_MAP_WRITE, toend, FReadCount);
end;

function TAsyncCopy.View: TJclFileMappingView;
begin
  Result := FMap.Views[0];
end;

end.
