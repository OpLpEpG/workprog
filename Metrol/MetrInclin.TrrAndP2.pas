unit MetrInclin.TrrAndP2;

interface

uses System.SysUtils, Xml.XMLIntf, System.Classes, Vcl.Menus,
     PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, math, MetrForm, AutoMetr.Inclin, RootImpl,
     MetrInclin.Math, XMLScript.Math, UakiIntf, MetrInclin.CheckForm;

type
  TFormInclinTrrAndP2 = class(TFormInclinCheck)
  private
  protected
    FCurAzim, FCurViz: Double;
    FDirAzim, FDirViz: Integer;
    FNewAlg: Boolean;
    procedure NNewAlgClick(Sender: TObject);
    procedure FindMagnit(from, too: Integer; alg, trr: IXMLNode);
    procedure FindAccel(from, too: Integer; alg, trr: IXMLNode);
    function ToInp(alg: IXMLNode; from, too: Integer): TAngleFtting.TInput;
    procedure RefindAzi(from, too: Integer; alg, trr: IXMLNode);
    procedure RefindZen(from, too: Integer; alg, trr: IXMLNode);
    function AddVizir(v: Double): Variant;
    function UserSetupAlg(alg: IXMLNode): Boolean; override;
    procedure DoSetupAlg; virtual;
    function UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean; override;
    function NextAngle(DeltaAngle, DeltaCycle: Double; var IncDir: Integer; var Curr: Double): boolean;
    procedure CreateStepsFixZU(DeltaA, DeltaV, Zu: Double);
    procedure Loaded; override;
    class function ClassIcon: Integer; override;
   const
    NICON = 345;
  public
    [StaticAction('Новая тарировка 64 точки', 'Метрология', NICON, '0:Метрология.Инклинометры:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
    class function MetrolType: string; override;
  end;

implementation

uses tools;

{ TFormInclinTrrAndP2 }

class function TFormInclinTrrAndP2.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormInclinTrrAndP2.DoCreateForm(Sender: IAction);
begin
  inherited;
end;

class function TFormInclinTrrAndP2.MetrolType: string;
begin
  Result := 'P_2';
end;

function TFormInclinTrrAndP2.NextAngle(DeltaAngle, DeltaCycle: Double; var IncDir: Integer; var Curr: Double): boolean;
begin
  if IncDir = 1 then Result := Curr + DeltaAngle < 360
  else Result := Curr - DeltaAngle >= 0;
  if not Result then
   begin
    IncDir := -IncDir;
    Curr := Curr + DeltaCycle;
   end
  else Curr := Curr + IncDir * DeltaAngle
end;

procedure TFormInclinTrrAndP2.NNewAlgClick(Sender: TObject);
begin
  FNewAlg := True;
  ReCalc();
end;

function TFormInclinTrrAndP2.AddVizir(v: Double): Variant;
begin
  Result := AddStep('стол: визирный угол %g градусов.', [v]);
  Result.TASK.Vizir_Stol := v;
  Result.TASK.Dalay_Kadr := 5;
end;

procedure TFormInclinTrrAndP2.CreateStepsFixZU(DeltaA, DeltaV, Zu: Double);
 var
  s: Variant;
begin
  s := AddStep('стол: Азимут %g Зенит %g визир %g градусов.', [FCurAzim, Zu, FCurViz]);
  s.TASK.Azimut_Stol := FCurAzim;
  s.TASK.Zenit_Stol := zu;
  s.TASK.Vizir_Stol := FCurViz;
  s.TASK.Dalay_Kadr := 5;
  repeat
   while NextAngle(DeltaV, 0, FDirViz, FCurViz) do AddVizir(FCurViz);
   if not NextAngle(DeltaA, 0, FDirAzim, FCurAzim) then Break;
   s := AddStep('стол: Азимут %g градусов.', [FCurAzim]);
   s.TASK.Azimut_Stol := FCurAzim;
   s.TASK.Dalay_Kadr := 5;
  until False;
end;

procedure TFormInclinTrrAndP2.DoSetupAlg;
begin
  CreateStepsFixZU(60,72,45);
  CreateStepsFixZU(60,72,90);
end;

function TFormInclinTrrAndP2.UserSetupAlg(alg: IXMLNode): Boolean;
 var
  s: Variant;
  i: Integer;
begin
  Result := True;
  FStep.root := XToVar(alg);
  FStep.stp := 1;
  s := AddStep('стол: Зенит 0, визир %d градусов.', [270]);
  s.TASK.Vizir_Stol := 270;
  s.TASK.Zenit_Stol := 0;
  s.TASK.Dalay_Kadr := 5;

  for I := 2 downto 0 do AddVizir(i*90);

  FCurAzim := 0; FCurViz := 0;
  FDirAzim := 1; FDirViz := 1;

  DoSetupAlg;
end;

function TFormInclinTrrAndP2.ToInp(alg: IXMLNode; from, too: Integer): TAngleFtting.TInput;
 var
  i: Integer;
  v:Variant;
begin
  SetLength(Result, too-from+1);
  for i := 0 to High(Result) do
   begin
    v := XToVar(GetXNode(alg, Format('STEP%d',[I+from])));
    with Result[i] do
     begin
      gx := v.accel.X.DEV.VALUE;
      gy := v.accel.Y.DEV.VALUE;
      gz := v.accel.Z.DEV.VALUE;
      hx := v.magnit.X.DEV.VALUE;
      hy := v.magnit.Y.DEV.VALUE;
      hz := v.magnit.Z.DEV.VALUE;
      AziStol := v.СТОЛ.азимут;
      ZenStol := v.СТОЛ.зенит;
     end;
   end;
end;

procedure TFormInclinTrrAndP2.RefindZen(from, too: Integer; alg, trr: IXMLNode);
 var
  i: Integer;
  t, a: variant;
begin
  t := XtoVar(trr);
  for I := from to too do
   begin
    a := XToVar(GetXNode(alg, Format('STEP%d',[I])));
    TMetrInclinMath.FindZenViz(a, t);
    if a.СТОЛ.зенит > 180 then a.СТОЛ.err_зенит := TMetrInclinMath.DeltaAngle(a.зенит.CLC.VALUE -(360 - a.СТОЛ.зенит))
    else a.СТОЛ.err_зенит := TMetrInclinMath.DeltaAngle(a.зенит.CLC.VALUE - a.СТОЛ.зенит);
   end;
end;
procedure TFormInclinTrrAndP2.RefindAzi(from, too: Integer; alg, trr: IXMLNode);
 var
  i: Integer;
  t, a: variant;
begin
  t := XtoVar(trr);
  for I := from to too do
   begin
    a := XToVar(GetXNode(alg, Format('STEP%d',[I])));
    TMetrInclinMath.FindAzim(a, t);
    a.СТОЛ.err_азимут := TMetrInclinMath.DeltaAngle(a.азимут.CLC.VALUE - a.СТОЛ.азимут);
   end;
end;

procedure TFormInclinTrrAndP2.FindAccel(from, too: Integer; alg, trr: IXMLNode);
 var
  m: TAngleFtting.TMetr;
begin
  TAngleFtting.RunZ(ToInp(alg, from, too), m);
  m.AssignTo(XToVar(GetXNode(trr, 'accel')));
end;

procedure TFormInclinTrrAndP2.FindMagnit(from, too: Integer; alg, trr: IXMLNode);
 var
  m: TAngleFtting.TMetr;
begin
  TAngleFtting.RunA(ToInp(alg, from, too), m);
  m.AssignTo(XToVar(GetXNode(trr, 'magnit')));
end;

procedure TFormInclinTrrAndP2.Loaded;
 var
  n: TMenuItem;
begin
  inherited;
  AddToNCMenu('Рассчет новых поправок', NNewAlgClick, n);
  n.MenuIndex := 9;
end;

function TFormInclinTrrAndP2.UserExecStep(Step: Integer; alg, trr: IXMLNode): Boolean;
begin
  Result := True;
  //UserExecStepUpdateStolAngle(Step, alg, trr);
  case Step of
   64:
      begin
       if FNewAlg then
        begin
         FNewAlg := False;
         FindAccel(1, 64, alg, trr);
         RefindZen(1, 64, alg, trr);
         FindMagnit(5,64, alg, trr);
         RefindAzi(1, 64, alg, trr);
        end;
       alg.Attributes['ErrZU']  := FindMaxErr(alg, 1, 64, 'err_зенит');
       alg.Attributes['ErrAZ']  := FindMaxErr(alg, 5, 64, 'err_азимут');
       alg.Attributes['ErrAZ5']  := -1000;
      end;
  end;
end;

initialization
  RegisterClass(TFormInclinTrrAndP2);
  TRegister.AddType<TFormInclinTrrAndP2, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormInclinTrrAndP2>;
end.
