unit Dev.Telesistem.Data;

interface

uses System.SysUtils,  System.Classes, System.TypInfo, System.Rtti, Fibonach, MathIntf, System.Math, Math.Telesistem,
     XMLScript.Math, Xml.XMLIntf,
     Actns, DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl, RootIntf, SubDevImpl, tools;


type

  TCustomTeleData = class(TSubDevWithForm<TTelesistemDecoder>)
  private
    FFileName: string;
    FPorogXY: Integer;
    FPorogZ: Integer;
    FDMetka: Double;
    procedure SetPorogXY(const Value: Integer);
    procedure SetPorogZ(const Value: Integer);
    function TryGetRoot(var v: Variant): Boolean;
    procedure SetDMetka(const Value: Double);
  protected
    procedure SetCollection(Value: TCollection); override;
    function GetCategory: TSubDeviceInfo; override;
    function GetCaption: string; override;
     procedure OnUserRemove; override;
  public
    type
     CodeData = (cdMOtk1, cdAX, cdAy, adAz, cdMx, cdMOtk2, cdMy, cdMz,cdDxy, cdDz, cdMOtk3);
    constructor Create; override;
    procedure InputData(Data: Pointer; DataSize: integer); override;
    function GetMetaData: IXMLInfo; virtual;
    property FileName: string read FFileName;
//    property S_Otk
//    property S_Azi
//    property S_Otk
  published
    [ShowProp('Порог вибрации XY')] property PorogXY: Integer read FPorogXY write SetPorogXY default 10;
    [ShowProp('Порог вибрации Z')]  property PorogZ: Integer read FPorogZ write SetPorogZ default 10;
    [ShowProp('Сдвиг метки отклонителя (º)')]  property DMetka: Double read FDMetka write SetDMetka;
  end;

implementation

{ TCustomTeleData }

uses Dev.Telesistem;

constructor TCustomTeleData.Create;
begin
  inherited;
  FPorogXY := 10;
  FPorogZ := 10;
end;

function TCustomTeleData.GetCaption: string;
begin
  Result := 'test telesis 1'
end;

function TCustomTeleData.GetCategory: TSubDeviceInfo;
begin
  Result.Category := 'Данные';
  Result.Typ := [sdtUniqe, sdtMastExist];
end;

function TCustomTeleData.GetMetaData: IXMLInfo;
 var
  GDoc: IXMLDocument;
begin
  FFileName := ExtractFilePath(ParamStr(0)) + 'Devices\tst_telesis1.xml';
  GDoc := NewXDocument();
  GDoc.LoadFromFile(FileName);
  Result := GDoc.DocumentElement;
end;

procedure TCustomTeleData.InputData(Data: Pointer; DataSize: integer);
 var
  v: Variant;
  deltaOtk: Double;
  function cor360(a: Double): double;
  begin
    if a < 0 then Result := a + 360
    else if a >=360 then Result := a - 360
    else Result := a
  end;
begin
  // test for decoder
  if (DataSize <> $12345678) or not TryGetRoot(v) then Exit;
  with TTelesistemDecoder(Data) do
   begin
  case State of
    csFindSP: ;
    csSP: with SPData, SPIndex do
     begin
      v.СП.Уход_тактов.DEV.VALUE := 0;
      v.СП.Амплитуда.DEV.VALUE := SimpleRoundTo(Amp, -1);
      v.СП.Фаза.DEV.VALUE := Faza;
      v.СП.Q_СП.DEV.VALUE := Round(Porog);
     end;
    csCheckSP: with SPData, CheckSPIndex do
     begin
      v.СП.Уход_тактов.DEV.VALUE := Dkadr;
      v.СП.Амплитуда.DEV.VALUE := SimpleRoundTo(Amp, -1);
      v.СП.Фаза.DEV.VALUE := Fazanew;
      v.СП.Q_СП.DEV.VALUE := Round(Porog);
     end;
    csCode: with Codes do
     begin
      case CodeData(CodeCnt-1) of
        cdMOtk1:
         begin
          deltaOtk := v.Inclin.статика.отклонитель.CLC.VALUE - v.Inclin.статика.маг_отклон.CLC.VALUE;
          v.Inclin.маг_отклон1.DEV.VALUE := cor360(CodData[CodeCnt-1].Code + DMetka);
          v.Inclin.маг_отклон1.CLC.VALUE :=  cor360(CodData[CodeCnt-1].Code + deltaOtk + DMetka);
          v.Inclin.Q_маг_отклон1.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdAX:
         begin
          v.Inclin.accel.X.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.accel.Q_X.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdAy:
         begin
          v.Inclin.accel.Y.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.accel.Q_Y.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        adAz:
         begin
          v.Inclin.accel.Z.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.accel.Q_Z.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdMx:
         begin
          v.Inclin.magnit.X.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.magnit.Q_X.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdMOtk2:
         begin
          deltaOtk := v.Inclin.статика.отклонитель.CLC.VALUE - v.Inclin.статика.маг_отклон.CLC.VALUE;
          v.Inclin.маг_отклон2.DEV.VALUE := cor360(CodData[CodeCnt-1].Code + DMetka);
          v.Inclin.маг_отклон2.CLC.VALUE :=  cor360(CodData[CodeCnt-1].Code + deltaOtk + DMetka);
          v.Inclin.Q_маг_отклон2.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdMy:
         begin
          v.Inclin.magnit.Y.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.magnit.Q_Y.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdMz:
         begin
          v.Inclin.magnit.Z.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.magnit.Q_Z.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
          TTelesistem(Owner).ExecMetrology;
          v.Inclin.отклонитель.CLC.VALUE := cor360(v.Inclin.отклонитель.CLC.VALUE + DMetka);
          v.Inclin.маг_отклон.CLC.VALUE := cor360(v.Inclin.маг_отклон.CLC.VALUE + DMetka);
         end;
        cdDxy:
         begin
          v.Inclin.accel.DXY.DEV.VALUE := (CodData[CodeCnt-1].Code-1292)/2;
          v.Inclin.accel.Q_DXY.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
         end;
        cdDz:
         begin
          v.Inclin.accel.DZ.DEV.VALUE := CodData[CodeCnt-1].Code-1292;
          v.Inclin.accel.Q_DZ.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
          if (v.Inclin.accel.DXY.DEV.VALUE < PorogXY) and (v.Inclin.accel.DZ.DEV.VALUE < PorogZ) then
           begin
            v.Inclin.статика.отклонитель.CLC.VALUE := v.Inclin.отклонитель.CLC.VALUE;
            v.Inclin.статика.маг_отклон.CLC.VALUE := v.Inclin.маг_отклон.CLC.VALUE;
           end;
         end;
        cdMOtk3:
         begin
          deltaOtk := v.Inclin.статика.отклонитель.CLC.VALUE - v.Inclin.статика.маг_отклон.CLC.VALUE;
          v.Inclin.маг_отклон3.DEV.VALUE := cor360(CodData[CodeCnt-1].Code + DMetka);
          v.Inclin.маг_отклон3.CLC.VALUE :=  cor360(CodData[CodeCnt-1].Code + deltaOtk + DMetka);
          v.Inclin.Q_маг_отклон3.DEV.VALUE := Round(CodData[CodeCnt-1].Porog);
          TTelesistem(Owner).SaveLogData;
         end;
      end;
      TTelesistem(owner).CheckWorkData;
      TTelesistem(owner).Notify('S_WorkEventInfo');
     end;
  end;
   end;
end;

procedure TCustomTeleData.OnUserRemove;
begin
  inherited;
  TTelesistem(Owner).RemoveMetaData;
end;

procedure TCustomTeleData.SetCollection(Value: TCollection);
begin
  inherited;
  if (Value <> nil) then TTelesistem(Owner).InitMetaData(nil);
end;

procedure TCustomTeleData.SetDMetka(const Value: Double);
begin
  FDMetka := Value;
end;

procedure TCustomTeleData.SetPorogXY(const Value: Integer);
begin
  FPorogXY := Value;
end;

procedure TCustomTeleData.SetPorogZ(const Value: Integer);
begin
  FPorogZ := Value;
end;

function TCustomTeleData.TryGetRoot(var v: Variant): Boolean;
 var
  w: IXMLNode;
begin
  Result := False;
  if Assigned(owner) and Assigned(TTelesistem(owner).S_MetaDataInfo.Info) then
   begin
    w := FindWork(TTelesistem(owner).S_MetaDataInfo.Info, 1000);
    if Assigned(w) then
     begin
      v := XToVar(w);
      Result := True;
     end;
   end;
end;

initialization
  RegisterClasses([TCustomTeleData]);
  TRegister.AddType<TCustomTeleData, ITelesistem>.LiveTime(ltTransientNamed);
finalization
  GContainer.RemoveModel<TCustomTeleData>;
end.
