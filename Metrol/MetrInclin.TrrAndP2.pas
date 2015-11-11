unit MetrInclin.TrrAndP2;

interface

uses System.SysUtils, Xml.XMLIntf, System.Classes, Vcl.Menus, Vector,
     PluginAPI, ExtendIntf, RootIntf, Container, Actns, debug_except, DockIForm, math, MetrForm, AutoMetr.Inclin, RootImpl,
     MetrInclin.Math, MetrInclin.Math2, XMLScript.Math, UakiIntf, MetrInclin.CheckForm;

type
  TFormInclinTrrAndP2 = class(TFormInclinCheck)
  private
    FNNoStol: TMenuItem;
    FNProblemML: TMenuItem;
    FSaveAccel: TMatrix4;
    class procedure _TEST_ApplyHGfromStol(alg: IXMLNode; from, too: Integer; Incl, Amp: Double; TrrA, TrrH: TMatrix4);
  protected
    FCurAzim, FCurViz: Double;
    FDirAzim, FDirViz: Integer;
    FNewAlg: Boolean;
    procedure NNewAlgClick(Sender: TObject);
    procedure NNoStolClick(Sender: TObject);
    procedure NProblemMLClick(Sender: TObject);
    procedure FindMagnit(from, too: Integer; alg, trr: IXMLNode);
    procedure FindAccel(from, too: Integer; alg, trr: IXMLNode);
    function ToInpML(alg: IXMLNode; from, too: Integer): TArray<TInclPoint>;
    function ToInp(alg: IXMLNode; from, too: Integer): TAngleFtting.TInput; overload;
    function ToInp(alg: IXMLNode; from, too: Integer; TrueAccFalseMag: Boolean; Trr: TMatrix4): TZAlignLS.TZConstPoints; overload;
    function ToInp(alg: IXMLNode; from, too: Integer; TrrA, TrrH: TMatrix4): TCrossConstLS.TInclPoints; overload;
    function ToInp(alg: IXMLNode; from, too: Integer; TrrA: TMatrix4): TCrossConstLS.TInclPoints; overload;
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

procedure TFormInclinTrrAndP2.NNoStolClick(Sender: TObject);
begin

end;

procedure TFormInclinTrrAndP2.NProblemMLClick(Sender: TObject);
begin

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

class procedure TFormInclinTrrAndP2._TEST_ApplyHGfromStol(alg: IXMLNode; from, too: Integer; Incl, Amp: Double; TrrA, TrrH: TMatrix4);
 var
  i: Integer;
  v:Variant;
  P: TInclPoint;
  const
   {$J+}
   a: Double = 90;
   z: Double = 90;
   o: Double = 90;
   {$J-}
begin
  for i := from to too do
   begin
     v := XToVar(GetXNode(alg, Format('STEP%d',[I])));
     try
      a := v.TASK.Azimut_Stol;
     except
     end;
     try
      z := v.TASK.Zenit_Stol;
     except
     end;
     try
      o := v.TASK.Vizir_Stol;
     except
     end;
     P := TMetrInclinMath.FindXYZ(a,z, o, Incl, Amp);
     P.G := TrrA * P.G;
     P.H := TrrH * P.H;
     v.accel.X.DEV.VALUE := p.G.X;
     v.accel.Y.DEV.VALUE := p.G.Y;
     v.accel.Z.DEV.VALUE := p.G.Z;
     v.magnit.X.DEV.VALUE := p.H.X;
     v.magnit.Y.DEV.VALUE := p.H.Y;
     v.magnit.Z.DEV.VALUE := p.H.Z;
     v.СТОЛ.азимут := a;
     v.СТОЛ.зенит := z;
   end;
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

function TFormInclinTrrAndP2.ToInp(alg: IXMLNode; from, too: Integer; TrrA, TrrH: TMatrix4): TCrossConstLS.TInclPoints;
 var
  i: Integer;
  v: Variant;
  g,h: TVector3;
begin
  SetLength(Result, too-from+1);
  for i := 0 to High(Result) do
   begin
    v := XToVar(GetXNode(alg, Format('STEP%d',[I+from])));

//  v.accel.X.DEV.VALUE := v.accel.X.DEV.VALUE*1000;
//  v.accel.Y.DEV.VALUE := v.accel.Y.DEV.VALUE*1000;
//  v.accel.Z.DEV.VALUE := v.accel.Z.DEV.VALUE*1000;
//  v.magnit.X.DEV.VALUE := v.magnit.X.DEV.VALUE*1000;
//  v.magnit.Y.DEV.VALUE := v.magnit.Y.DEV.VALUE*1000;
//  v.magnit.Z.DEV.VALUE := v.magnit.Z.DEV.VALUE*1000;

    g.x := v.accel.X.DEV.VALUE;
    g.y := v.accel.Y.DEV.VALUE;
    g.z := v.accel.Z.DEV.VALUE;
    h.x := v.magnit.X.DEV.VALUE;
    h.y := v.magnit.Y.DEV.VALUE;
    h.z := v.magnit.Z.DEV.VALUE;
    Result[i].A := TrrA * g;
    Result[i].H := TrrH * h;
   end;
end;

function TFormInclinTrrAndP2.ToInp(alg: IXMLNode; from, too: Integer; TrrA: TMatrix4): TCrossConstLS.TInclPoints;
 var
  i: Integer;
  v: Variant;
  g,h: TVector3;
begin
  SetLength(Result, too-from+1);
  for i := 0 to High(Result) do
   begin
    v := XToVar(GetXNode(alg, Format('STEP%d',[I+from])));
    g.x := v.accel.X.DEV.VALUE;
    g.y := v.accel.Y.DEV.VALUE;
    g.z := v.accel.Z.DEV.VALUE;
    h.x := v.magnit.X.DEV.VALUE;
    h.y := v.magnit.Y.DEV.VALUE;
    h.z := v.magnit.Z.DEV.VALUE;
    Result[i].A := TrrA * g;
    Result[i].H := h;
   end;
end;


function TFormInclinTrrAndP2.ToInpML(alg: IXMLNode; from, too: Integer): TArray<TInclPoint>;
 var
  i: Integer;
  v: Variant;
begin
  SetLength(Result, too-from+1);
  for i := 0 to High(Result) do Result[i] := XToVar(GetXNode(alg, Format('STEP%d',[I+from])));
end;

function TFormInclinTrrAndP2.ToInp(alg: IXMLNode; from, too: Integer; TrueAccFalseMag: Boolean; Trr: TMatrix4): TZAlignLS.TZConstPoints;
 const
  AM: array[Boolean] of string = ('magnit', 'accel');
 var
  i: Integer;
  v: Variant;
  p: TVector3;
begin
  SetLength(Result, too-from+1);
  for i := 0 to High(Result) do
   begin
    v := XToVar(GetXNode(alg, Format('STEP%d.%s',[I+from, AM[TrueAccFalseMag]])));
    p.X := v.X.DEV.VALUE;
    p.Y := v.Y.DEV.VALUE;
    p.Z := v.Z.DEV.VALUE;
    Result[i] := Trr * p;
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
  inp: TAngleFtting.TInput;
  Res, tG , tH: TMatrix4;
  alignInp: TZAlignLS.TInput;
  i: Integer;
  a, b : Double;

begin
//  with tG do
//   begin
//    m11 :=	1.1;      m12 :=	0.0012;        m13 :=	 -0.0013;   m14 := -100;
//    m21 :=	0;        m22 :=	1.2;           m23 :=	0.0023;     m24 := 200;
//    m31 :=	0.0031;   m32 :=	-0.00625;      m33 :=	 1.3;  m34 := -300;
//   end;
//
//  with tH do
//   begin
//    m11 :=	 1.11;         m21 :=	0.003;       m31 :=	-0.0031;
//    m12 :=	-0.0012;       m22 :=	1.22;         m32 :=	-0.0032;
//    m13 :=	-0.0013;       m23 :=	0.0023;       m33 :=	1.33;
//    m14 :=	-1.4;          m24 :=	2.4;          m34 :=	-3.4;
//   end;
  //_TEST_ApplyHGfromStol(alg, from, too, 10.9, 1000, tG.Invert, tH.Invert);

  inp := ToInp(alg, from, too);
  if FNNoStol.Checked then
   begin
    // без стола
    TSphereLS.RunZ(inp, Res);
    SetLength(alignInp, 12);//6
    for I := 0 to High(alignInp) do alignInp[i] := ToInp(alg, 5+i*5, 9+i*5, True, Res);
    //  SetLength(alignInp, 1);
    //  i := 1;
    //  alignInp[0] := ToInp(alg, 35+i*5, 39+i*5, True, Res);
    TZAlignLS.Run(alignInp, a,b);
    FSaveAccel := TZAlignLS.Apply(Res, a, b);

//    TZAlignLS.RunLeMa(alignInp, a,b);
//    FSaveAccel := TZAlignLS.ApplyLeMa(FSaveAccel, a, b);

    Matrix4AssignToVariant(FSaveAccel, XToVar(GetXNode(trr, 'accel')));
   end
  else
   begin
    // LEVENBERG
    TAngleFtting.RunZ(inp, m);
    m.AssignTo(XToVar(GetXNode(trr, 'accel')));
   end;
end;

//var
//__tatA: Double = -0.004;
{procedure _sts( alg: IXMLNode);
 var
  v: Variant;
  i: Integer;
begin
  for i := 1 to 4 do
   begin
    v := XToVar(GetXNode(alg, Format('STEP%d',[i])));

  v.accel.X.DEV.VALUE := v.accel.X.DEV.VALUE*1000;
  v.accel.Y.DEV.VALUE := v.accel.Y.DEV.VALUE*1000;
  v.accel.Z.DEV.VALUE := v.accel.Z.DEV.VALUE*1000;
  v.magnit.X.DEV.VALUE := v.magnit.X.DEV.VALUE*1000;
  v.magnit.Y.DEV.VALUE := v.magnit.Y.DEV.VALUE*1000;
  v.magnit.Z.DEV.VALUE := v.magnit.Z.DEV.VALUE*1000;
   end;
end;}


procedure TFormInclinTrrAndP2.FindMagnit(from, too: Integer; alg, trr: IXMLNode);
 var
  m: TAngleFtting.TMetr;
  inp: TAngleFtting.TInput;
  Res, m2, m3, m4: TMatrix4;
  alignInp: TZAlignLS.TInput;
  i: Integer;
  a, b, incl, inclML: Double;
begin
  inp := ToInp(alg, from, too);
  if FNNoStol.Checked then
   begin
//    _sts(alg);
//     без стола
    TSphereLS.RunA(inp, Res);
    SetLength(alignInp, 12);//6
    for I := 0 to High(alignInp) do alignInp[i] := ToInp(alg, 5+i*5, 9+i*5, False, Res);
    TZAlignLS.Run(alignInp, a,b);
    m2 := TZAlignLS.Apply(Res, a, b);
//    TZAlignLS.RunLeMa(alignInp, a,b);
//    m2 := TZAlignLS.ApplyLeMa(m2, a, b);
    TCrossConstLS.Run(ToInp(alg, from, too, FSaveAccel, m2), a, b);
    m3 := TCrossConstLS.Apply(m2, a);
//    m4 := TCrossConstLS.CorrectInclLeMa(ToInp(alg, from, too, FSaveAccel), m3, b);
//    incl := RadToDeg(Arccos(b/1000/1000));
//    Matrix4AssignToVariant(m3, XToVar(GetXNode(trr, 'magnit')));
    if FNProblemML.Checked then TTrrML.Run(b, m3, FSaveAccel, ToInpML(alg, 1, too), m4, inclML)
    else m4 := m3;

    Matrix4AssignToVariant(m4, XToVar(GetXNode(trr, 'magnit')));
   end
  else
   begin
    // LEVENBERG
    TAngleFtting.RunA(inp, m);
    m.AssignTo(XToVar(GetXNode(trr, 'magnit')));
   end;
end;

procedure TFormInclinTrrAndP2.Loaded;
 var
  n: TMenuItem;
begin
  inherited;
  AddToNCMenu('Рассчет новых поправок', NNewAlgClick, n);
  AddToNCMenu('Не использовать данные стола', NNoStolClick, FNNoStol);
  AddToNCMenu('Использовать метод МП', NProblemMLClick, FNProblemML);
  FNNoStol.AutoCheck := True;
  FNProblemML.AutoCheck := True;
  n.MenuIndex := 9;
  FNNoStol.MenuIndex := 10;
  FNProblemML.MenuIndex := 11;
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
