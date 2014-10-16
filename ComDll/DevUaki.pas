unit DevUaki;

interface

uses System.SysUtils, System.Classes, Vcl.Graphics, tools,
     UakiIntf, DeviceIntf, AbstractDev, debug_except, ExtendIntf, Container, PluginAPI, RootImpl;
type

  TAxis = class(TAggObject, IAxis)
  private
    FCurrentAngle: TAngle;
    FNeedAngle: TAngle;
    FDeltaAngle: TAngle;
    FAdr: Integer;
    FMotor: Char;
    FReper: Char;
    FEndTumbler: Char;
    FError: Byte;
    FInfo: string;
    procedure OnCurrentData(const Data: string; status: integer);
  protected
//�E7; E6; E5; WDTR; MAX; MIN; WDG; PCC� , ���
  const
   ERR_COD: array[0..4] of string = ('�PCC� � ������ ����� � �����������'#$A,
                                   '�WDG� � ������������'#$A,
                                   '�MIN� � ����� �� ����������� �������'#$A,
                                   '�MAX� � ����� �� ������������ �������'#$A, '�WDTR� � ������������ ����������� �������');
    procedure UpdateAngleData;
    procedure FindMarker;
    procedure ClearDeltaAngle;
    procedure TermimateMoving;
    procedure GotoAngle(Angle: TAngle; MaxSpeed: Integer = 255);

    function MotorToString: string;
    function MotorToColor: TColor;
    function ReperToString: string;
    function ReperToColor: TColor;
    function EndTumblerToString: string;
    function EndTumblerToColor: TColor;
    function ErrorToText: string;
  // private
    function GetEndTumbler: Char;
    function GetReper: Char;
    function GetMotor: Char;
    function GetError: Byte;

    function GetAdr: Integer;

    function GetCurrentAngle: TAngle;
    function GetNeedAngle: TAngle;
    function GetDeltaAngle: TAngle;
    procedure SetDeltaAngle(Value: TAngle);

    procedure SetNeedAngle(Value: TAngle);

    function GetTOlerance: Double;
    procedure SetTolerance(const Value: Double);
   public
    constructor Create(const Controller: IInterface; addr: Integer);
    property NeedAngle: TAngle read FNeedAngle write SetNeedAngle;
  end;

  TAxisAzi = class(TAxis, IAxisAZI);
  TAxisZen = class(TAxis, IAxisZEN);
  TAxisViz = class(TAxis, IAxisVIZ);

  EDevUakiException = class(EDeviceException);

  TDevUaki = class(TDevice, IDevice, IUaki, ICycle, IAxisAZI, IAxisZEN, IAxisVIZ)
  private
    FAzi: TAxisAzi;
    FZen: TAxisZen;
    FViz: TAxisViz;
    FS_AxisUpdate: Integer;
    procedure SetS_AxisUpdate(const Value: Integer);
   type
    TCycleUAK = class(TCycle)
    protected
      procedure DoCycle; override;
    end;
   var
    FCycle: TCycleUAK;
  protected
    function GetAzi: IAxisAZI;
    function GetZen: IAxisZEN;
    function GetViz: IAxisVIZ;

    procedure SetConnect(AIConnectIO: IConnectIO); override;
  public
    constructor Create(); override;
    constructor CreateWithAddr(const AddressArray: TAddressArray; const DeviceName: string); override;
    destructor Destroy; override;
    property Cycle: TCycleUAK read FCycle implements  ICycle;
    property Azi: TAxisAzi read FAzi implements  IAxisAZI;
    property Zen: TAxisZen read FZen implements  IAxisZEN;
    property Viz: TAxisViz read FViz implements  IAxisVIZ;
    property S_AxisUpdate: Integer read FS_AxisUpdate write SetS_AxisUpdate;
  published
    property CyclePeriod;
  end;

implementation

{ TDevUaki.TCycleUAK }

procedure TDevUaki.TCycleUAK.DoCycle;
begin
  with Controller as IUaki do
   begin
    Azi.UpdateAngleData;
    Zen.UpdateAngleData;
    Viz.UpdateAngleData;
   end;
end;

{ TDevUaki }

constructor TDevUaki.Create;
begin
  inherited;
  FAzi := TAxisAzi.Create(self, ADR_AXIS_AZI);
  FZen := TAxisZen.Create(self, ADR_AXIS_ZU);
  FViz := TAxisViz.Create(self, ADR_AXIS_VIZ);
  FCycle := TCycleUAK.Create(Self);
  FAddressArray := TAddressRec(ADR_UAKI.ToString());
  FDName := 'UAKI';
  FStatus := dsReady;
  FCyclePeriod := 500;
end;

constructor TDevUaki.CreateWithAddr(const AddressArray: TAddressArray; const DeviceName: string);
begin
  inherited;
  TRegister.AddType<TDevUaki>.AddInstance(Name, Self as IInterface);
end;

destructor TDevUaki.Destroy;
begin
  FCycle.Free;
  FAzi.Free;
  FZen.Free;
  FViz.Free;
  inherited;
end;

function TDevUaki.GetAzi: IAxisAZI;
begin
  Result := Fazi;
end;

function TDevUaki.GetViz: IAxisVIZ;
begin
  Result := FViz;
end;

function TDevUaki.GetZen: IAxisZEN;
begin
  Result := FZen;
end;

procedure TDevUaki.SetConnect(AIConnectIO: IConnectIO);
begin
  if Assigned(AIConnectIO) and not Supports(AIConnectIO, IUDPConnectIO) then raise EDevUakiException.Create('�������� ������ UDP ����������!');
  inherited;
end;

procedure TDevUaki.SetS_AxisUpdate(const Value: Integer);
begin
  FS_AxisUpdate := Value;
  Notify('S_AxisUpdate');
end;

{ TAxis }

procedure TAxis.ClearDeltaAngle;
begin
  FDeltaAngle.Angle := 0;
end;

constructor TAxis.Create(const Controller: IInterface; addr: Integer);
begin
  inherited Create(Controller);
  FMotor := 'x';
  FReper := 'x';
  FEndTumbler := 'x';
  Fadr := Addr;
end;

function TAxis.EndTumblerToColor: TColor;
begin
  Result := clYellow;
  case FEndTumbler of
   'o': Result := clBtnFace;
   'L', 'R': Result := clRed;
  end;
end;

function TAxis.EndTumblerToString: string;
begin
  Result := '����������: (' + FEndTumbler +')';
  case FEndTumbler of
   'o': Result := '�� ���� �������� ����������� �� ��������';
   'L': Result := '������������ ������ ��������� �����������';
   'R': Result := '������������ ������� ��������� �����������';
  end;
end;

function TAxis.ReperToColor: TColor;
begin
  Result := clYellow;
  case FReper of
   'p': Result := clRed;
   'M': Result := clBtnFace;
   'f': Result := clRed;
   'n': Result := clRed;
   'b': Result := clRed;
   'e': Result := clRed;
   'w': Result := clRed;
   'E': Result := clRed;
  end;
end;

function TAxis.ReperToString: string;
begin
  case FReper of
   'p': Result := '����� �� ��������� �������(��������� ���������)';
   'M': Result := '����� ������(������� ���������)';
   'f': Result := '����� ������';
   'n': Result := '����� �� ������';
   'b': Result := '����� �� �������� �������';
   'e': Result := '���������� �����';
   'w': Result := '����� �� ����������� �������';
   'E': Result := '������';
  else  Result := '����������: (' + FReper +')';
  end;
end;

procedure TAxis.SetDeltaAngle(Value: TAngle);
 var
  d: TAngle;
begin
  d := Value - FCurrentAngle;
  if FDeltaAngle.Angle <> d.Angle then
   begin
    FDeltaAngle := d;
    (Controller as TDevUaki).PubChange;
   end;
end;

procedure TAxis.SetNeedAngle(Value: TAngle);
begin
  if FNeedAngle.Angle <> Value.Angle then
   begin
    FNeedAngle := Value;
    (Controller as TDevUaki).PubChange;
   end;
end;

function TAxis.MotorToColor: TColor;
begin
  case FMotor of
   's': Result := clBtnFace;
   'G': Result := clRed;
  else  Result := clYellow;
  end;
end;

function TAxis.MotorToString: string;
begin
  case FMotor of
   's': Result := '����������';
   'G': Result := '���������';
  else  Result := '����������: (' + FMotor +')';
  end;
end;

function TAxis.ErrorToText: string;
 var
  i: Integer;
begin
  Result := '';
  for i := 0 to 4 do if (FError and (1 shl i)) <> 0 then Result := Result+ERR_COD[i];
  if Result = '' then Result := '��� ������';
end;

procedure TAxis.FindMarker;
begin
  ((Controller as IDevice).IConnect as IUDPConnectIO).Send(Fadr.ToString()+'m');
end;

function TAxis.GetAdr: Integer;
begin
  Result := Fadr;
end;

function TAxis.GetCurrentAngle: TAngle;
begin
  Result := FCurrentAngle + FDeltaAngle;
end;

function TAxis.GetDeltaAngle: TAngle;
begin
  Result := FDeltaAngle;
end;

function TAxis.GetEndTumbler: Char;
begin
  Result := FEndTumbler;
end;

function TAxis.GetError: Byte;
begin
  Result := FError;
end;

function TAxis.GetMotor: Char;
begin
  Result := FMotor;
end;

function TAxis.GetNeedAngle: TAngle;
begin
  Result.Angle := FNeedAngle.Angle;
end;

function TAxis.GetReper: Char;
begin
  Result := FReper;
end;

function TAxis.GetTOlerance: Double;
begin
//  FInfo := '-360000; 360000; 255; 500';
  if FInfo <> '' then
   begin
    Result := FInfo.Split([','])[3].Trim.ToInteger/1000
   end
  else
   begin
    Result := 0.05;
    ((Controller as IDevice).IConnect as IUDPConnectIO).Send(Fadr.ToString + '?', procedure(const Data: string; status: integer)
    begin
      if Data <> '' then FInfo := Data.Split(['[',']'])[1];
    end);
   end;
end;

procedure TAxis.SetTolerance(const Value: Double);
 var
  a: TArray<string>;
  s: string;
begin
  if FInfo = '' then raise EDevUakiException.Create('������ �� �������');
  a := FInfo.Split([',']);
  a[0] := a[0].Trim;
  a[1] := a[1].Trim;
  a[2] := a[2].Trim;
  a[3] := Round(Value*1000).ToString;
  s := Fadr.ToString + '!'+string.Join(' ', a)+'';
  ((Controller as IDevice).IConnect as IUDPConnectIO).Send(s, procedure(const Data: string; status: integer)
  begin
    if Data <> '' then FInfo := Data.Split(['[',']'])[1];
  end);
end;

procedure TAxis.GotoAngle(Angle: TAngle; MaxSpeed: Integer);
begin
  FMotor := 'G';
  if Freper <> 'M' then ((Controller as IDevice).IConnect as IUDPConnectIO).Send(Fadr.ToString + 'g' + Round(Angle.Angle*1000).ToString + ','+ MaxSpeed.ToString, OnCurrentData)
  else ((Controller as IDevice).IConnect as IUDPConnectIO).Send(Fadr.ToString + 'g' + Round(Double(Angle-FDeltaAngle)*1000).ToString + ','+ MaxSpeed.ToString, OnCurrentData);
end;

procedure TAxis.OnCurrentData(const Data: string; status: integer);
 var
  a: TArray<string>;
  s: string;
begin
  if status >= 21 then
   begin
    a := Data.Split(['{', ',', '}'], ExcludeEmpty);
    FCurrentAngle := a[1].Trim.ToInteger / 1000;
  //  NeedAngle :=     a[2].Trim.ToInteger / 1000;
    s :=             a[3].Trim;
    FReper := s.Chars[0];
    FMotor := s.Chars[1];
    FEndTumbler := s.Chars[2];
    FError := ('$'+ s.Substring(4,2)).ToInteger;
    (Controller as TDevUaki).S_AxisUpdate := FAdr;
   end;
end;

procedure TAxis.TermimateMoving;
begin
  ((Controller as IDevice).IConnect as IUDPConnectIO).Send(Fadr.ToString()+'s');
end;

procedure TAxis.UpdateAngleData;
begin
  ((Controller as IDevice).IConnect as IUDPConnectIO).Send(Fadr.ToString()+'a', OnCurrentData);
end;

initialization
  RegisterClass(TDevUaki);
  TRegister.AddType<TDevUaki, IDevice>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TDevUaki>;
end.
