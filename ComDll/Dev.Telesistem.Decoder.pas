unit Dev.Telesistem.Decoder;

interface

uses System.SysUtils,  System.Classes, System.TypInfo, System.Rtti, Fibonach, MathIntf, System.Math,
     Actns, DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl, RootIntf, SubDevImpl, tools;
type
   TCorrelatorState = (
    ///	<summary>
    ///	  Поиск СП, длительный процесс
    ///	</summary>
   csFindSP,
    ///	<summary>
    ///	  принятие решения о синхронизации
    ///	</summary>
   csSP,
    ///	<summary>
    ///	  проверка СП в состоянии csCode
    ///	</summary>
   csCheckSP,
    ///	<summary>
    ///	  выдаются коды
    ///	</summary>
   csCode,
    ///	<summary>
    ///	  принято решение о потере синхронизации из-за множества ошибок
    ///   и начале поиска СП
    ///	</summary>
   csBadCodes,
    ///	<summary>
    ///	  пользователь принял решение о потере синхронизации
    ///   и начале поиска СП
    ///	</summary>
   csUserToFindSP);

   TDecoderData = record
     State: TCorrelatorState;
     function SetFindSP(): TDecoderData;
     case TCorrelatorState of
       csFindSP:       ();
       csSP:           ();
       csCheckSP:      ();
       csCode:         ();
       csBadCodes:     ();
       csUserToFindSP: ();
   end;

   TCustomDecoder = class(TSubDevWithForm<TDecoderData>)
  private
    procedure SetBufSize(const Value: integer);
    function GetBufSize: integer;
   protected
     FBuf: TFifoBuffer<Double>;
     procedure InputData(Data: Pointer; DataSize: integer); override;
     function GetCategory: TSubDeviceInfo; override;
   public
     constructor Create; override;
     destructor Destroy; override;
   published
     property BufSize: integer read GetBufSize write SetBufSize;
   end;

implementation

{ TDecoderData }

function TDecoderData.SetFindSP: TDecoderData;
begin
  Result := Self;
end;

{ TCustomDecoder }

constructor TCustomDecoder.Create;
begin
  FBuf := TFifoBuffer<Double>.Create;
  FBuf.Size := (128{SP} + 17*16{DATA} + 1{START-TRUE})*8{BIT}*2;
  inherited;
end;

destructor TCustomDecoder.Destroy;
begin
  FBuf.Free;
  inherited;
end;

function TCustomDecoder.GetCategory: TSubDeviceInfo;
begin
  Result.Category := 'Декодер';
  Result.Typ := [sdtUniqe, sdtMastExist];
end;

function TCustomDecoder.GetBufSize: integer;
begin
  Result := FBuf.Size;
end;

procedure TCustomDecoder.SetBufSize(const Value: integer);
begin
  if Assigned(FBuf) then FBuf.Size := Value;
end;

procedure TCustomDecoder.InputData(Data: Pointer; DataSize: integer);
begin
  Assert(FBuf.Push(Data, DataSize, true), 'FBuf.Push(Data, DataSize, False)');

end;

end.
