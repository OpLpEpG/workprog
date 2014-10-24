unit Dev.Telesistem.Decoder;

interface

uses System.SysUtils,  System.Classes, System.TypInfo, System.Rtti, Fibonach, MathIntf, System.Math, Math.Telesistem,
     Actns, DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl, RootIntf, SubDevImpl, tools;
type
  TCustomDecoder = class(TSubDevWithForm<TTelesistemDecoder>)
  private
    FDecoder: TTelesistemDecoder;
    FPorogCode: Real;
    FNumBadCode: Integer;
    FPorogSP: Real;
    FSPCodLen: Integer;
    FDataCnt: Integer;
    FDataCodLen: Integer;
    FBits: Integer;
    procedure SetNumBadCode(const Value: Integer);
    procedure SetPorogCode(const Value: Real);
    procedure SetPorogSP(const Value: Real);
    procedure SetBits(const Value: Integer);
    procedure SetDataCnt(const Value: Integer);
    procedure SetDataCodLen(const Value: Integer);
    procedure SetSPCodLen(const Value: Integer);
  protected
    procedure OnDecoder(Sender: TObject);
    procedure InputData(Data: Pointer; DataSize: integer); override; final;
    function GetCategory: TSubDeviceInfo; override;
    function GetDecoderClass: TDecoderClass; virtual; abstract;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    [ShowProp('Порог СП %')]               property PorogSP    : Real   read FPorogSP     write SetPorogSP;
    [ShowProp('Порог данных %')]           property PorogCode  : Real   read FPorogCode   write SetPorogCode;
    [ShowProp('Число ошибочных данных')]   property NumBadCode : Integer read FNumBadCode write SetNumBadCode default 6;
    property Bits: Integer read FBits write SetBits default 8;
    property DataCnt: Integer read FDataCnt write SetDataCnt default 10;
    property DataCodLen: Integer read FDataCodLen write SetDataCodLen default 17;
    property SPCodLen: Integer read FSPCodLen write SetSPCodLen default 128;
  end;

implementation

{ TCustomDecoder }

constructor TCustomDecoder.Create;
begin
  PorogSP := 50;
  PorogCode := 50;
  NumBadCode := 6;
  FBits := 8;
  FDataCnt := 16;
  FDataCodLen := 17;
  FSPCodLen := 128;
  inherited;
end;

destructor TCustomDecoder.Destroy;
begin
  if Assigned(FDecoder) then FDecoder.Free;
  inherited;
end;

procedure TCustomDecoder.SetBits(const Value: Integer);
begin
  if FBits <> Value then
   begin
    FBits := Value;
    if Assigned(FDecoder) then FreeAndNil(FDecoder);
   end;
end;

procedure TCustomDecoder.SetDataCnt(const Value: Integer);
begin
  if FDataCnt <> Value then
   begin
    FDataCnt := Value;
    if Assigned(FDecoder) then FreeAndNil(FDecoder);
   end;
end;

procedure TCustomDecoder.SetDataCodLen(const Value: Integer);
begin
  if FDataCodLen <> Value then
   begin
    FDataCodLen := Value;
    if Assigned(FDecoder) then FreeAndNil(FDecoder);
   end;
end;

procedure TCustomDecoder.SetSPCodLen(const Value: Integer);
begin
  if FSPCodLen <> Value then
   begin
    FSPCodLen := Value;
    if Assigned(FDecoder) then FreeAndNil(FDecoder);
   end;
end;

procedure TCustomDecoder.SetNumBadCode(const Value: Integer);
begin
  FNumBadCode := Value;
  if Assigned(FDecoder) then FDecoder.PorogBadCodes := Value;
end;

procedure TCustomDecoder.SetPorogCode(const Value: Real);
begin
  FPorogCode := Value;
  if Assigned(FDecoder) then FDecoder.PorogCod := Value;
end;

procedure TCustomDecoder.SetPorogSP(const Value: Real);
begin
  FPorogSP := Value;
  if Assigned(FDecoder) then FDecoder.PorogSP := Value;
end;

function TCustomDecoder.GetCategory: TSubDeviceInfo;
begin
  Result.Category := 'Декодер';
  Result.Typ := [sdtUniqe, sdtMastExist];
end;

procedure TCustomDecoder.InputData(Data: Pointer; DataSize: integer);
begin
  if not Assigned(FDecoder) then
   begin
    FDecoder := GetDecoderClass.Create(Bits, DataCnt, DataCodLen, SPCodLen, OnDecoder);
    FS_Data := FDecoder;
    FDecoder.PorogSP := PorogSP;
    FDecoder.PorogCod := PorogCode;
    FDecoder.PorogBadCodes := NumBadCode;
   end;
  FDecoder.AddData(Data, DataSize);
end;

procedure TCustomDecoder.OnDecoder(Sender: TObject);
begin
  NotifyData;
end;

end.
