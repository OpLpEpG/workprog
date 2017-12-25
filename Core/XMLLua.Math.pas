unit XMLLua.Math;

interface

uses  XMLLua, tools, debug_except, MathIntf, System.UITypes, VerySimple.Lua.Lib,
    SysUtils, Xml.XMLIntf, System.Generics.Collections, System.Classes, math, System.Variants;

 {$M+}

type
  TXMLScriptMath = class
  private
    class constructor Create;
    class destructor Destroy;
  public
//    class function CallMeth(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
//    class procedure ExecStepGK1_t(stp: integer; alg, trr: IXMLNode; IsGk: boolean); static;

  //  class function AddMetrology(root: Variant; const Title, eu: string; Znd: Double = 0; varTip: Integer = 5): Variant; static;
//    class function AddMetrologyFM(root: Variant; Digits, Aqu: Integer): Variant; static;
//    class function AddMetrologyRG(root: Variant; Lo, Hi: Double): Variant; static;
//    class function AddMetrologyCL(root: Variant; Color: TAlphaColor; Width: Single = 2; Dash: Integer = 1): Variant; static;

      class procedure TrrVect3D(r, Inp: IXMLNode;  var x: Double; var y: Double; var z: Double; Scale: Integer = 1); overload; static;
//    class procedure AddXmlMatrix(root: IXMLNode; Row, col: Integer); overload; static;
//    class function AddXmlPath(root: Variant; const path: string): Variant; static;
//    class function FindXmlRoot(cur: Variant; const Section, root: string; var p: Variant): Boolean; static;
    class function Hypot3D(X, Y, Z: Double): Double; overload; static;
    class procedure GetH(Azi, Zen, Otk: Double; out X,Y,Z: Double; I: Double = 19.2;  Amp: Double = 1000); static;
    class function GetAzi(Zen, Otk, X,Y,Z: Double): Double; static;
//    class procedure ImportNNK10(const TrrFile: string; NewTrr: Variant); static;
//    class procedure SGK_FindGK(root: variant); static;
//    class function RadToDeg180(Rad: Double): Double; static;
//    class function RadToDeg360(Rad: Double): Double; static;
    class function RbfInterp(xy: variant; x1, x2: Double): Double;overload; static;
//    class function XmlPathExists(root: Variant; const path: string): Boolean; static;
    class function AddMetrology(r: IXMLNode; const Title, eu: string; Znd: Double = 0; varTip: Integer = 5): IXMLNode; overload; static;
    class function AddMetrologyFM(r: IXMLNode; Digits, Aqu: Integer): IXMLNode; overload; static;
    class function AddMetrologyRG(r: IXMLNode; Lo, Hi: Double): IXMLNode; overload; static;
    class function AddMetrologyCL(r: IXMLNode; Color: TAlphaColor; Width: Single = 2; Dash: Integer = 1): IXMLNode; overload; static;
    class function AddXmlPath(root: IXMLNode; const path: string): IXMLNode; overload;  static;
    class function RadToDeg360(r: Double): Double; overload; static;
  published
    class function ExecStepGK1(L: lua_State): Integer; cdecl; static;
    class function AddMetrology(L: lua_State): Integer; overload; cdecl; static;
    class function AddMetrologyFM(L: lua_State): Integer; overload; cdecl; static;
    class function AddMetrologyRG(L: lua_State): Integer; overload; cdecl; static;
    class function AddMetrologyCL(L: lua_State): Integer; overload; cdecl; static;
    class function TrrVect3D(L: lua_State): Integer; overload; cdecl; static;
    class function AddXmlMatrix(L: lua_State): Integer; cdecl; static;
    class function AddXmlPath(L: lua_State): Integer; overload; cdecl; static;
    class function FindXmlRoot(L: lua_State): Integer; cdecl; static;

    class function ArcTan2(L: lua_State): Integer; cdecl; static;
    class function KadrToStr(L: lua_State): Integer; cdecl; static;
    class function Hypot(L: lua_State): Integer; cdecl; static;
    class function Hypot3D(L: lua_State): Integer; overload; cdecl; static;
    class function RadToDeg(L: lua_State): Integer; cdecl; static;
    class function RadToDeg180(L: lua_State): Integer; cdecl; static;
    class function RadToDeg360(L: lua_State): Integer;overload; cdecl; static;
    class function Arccos(L: lua_State): Integer; cdecl; static;
    class function Now(L: lua_State): Integer; cdecl; static;
//    class function VarAsType(L: lua_State): Integer; cdecl; static;
    class function RbfInterp(L: lua_State): Integer; overload; cdecl; static;
    class function XmlPathExists(L: lua_State): Integer; cdecl; static;
    class function SGK_FindGK(L: lua_State): Integer; cdecl; static;
    class function ImportNNK10(L: lua_State): Integer; cdecl; static;
  end;

implementation

class constructor TXMLScriptMath.Create;
begin
  TXMLLua.RegisterLuaMethods(TXMLScriptMath);
end;

class destructor TXMLScriptMath.Destroy;
begin
//  TXmlScriptInner.UnRegisterMethods(CallMeth);
end;

class function TXMLScriptMath.ExecStepGK1(L: lua_State): Integer;
 var
  //stp: integer;
  alg, trr: IXMLNode; IsGk: boolean;
 type
  Tfuncs = array[0..1] of Double;
 var
  ls: ILSFitting;
  y: TArray<Double>;
  fmatrix: TArray<Tfuncs>;
  n, info: Integer;
  c: PDoubleArray;
  Rep: PSLFittingReport;
  x: IXMLNode;
  v, vngk: Variant;
  fx: Tfuncs;
  procedure vTovngk;
  begin
    if IsGk then vngk := v.гк
    else  vngk := v.нгк
  end;
begin
  //stp := lua_tointeger(L,1);
  alg := TXMLLua.XNode(L,2);
  trr := TXMLLua.XNode(L,3);
  IsGK := Boolean(lua_toboolean(L,4));

  LSFittingFactory(ls);
  SetLength(Y,0);
  SetLength(fmatrix, 0);
  fx[0]:= 1;
  n := 0;
  for x in XEnum(alg) do if x.HasAttribute('EXECUTED') then
   begin
    v := XToVar(x);
    fx[1] := v.RT;
    vTovngk;
    CArray.Add<Double>(y, vngk.DEV.VALUE);
    CArray.Add<Tfuncs>(fmatrix, fx);
    inc(n);
   end;
  if n > 1 then
   begin
    CheckMath(ls, ls.Linear(@y[0], @fmatrix[0, 0], n, 2, info, c, Rep));
    if info <> 1 then raise Exception.Create('Error ILSFitting');
    trr.Attributes['Delta'] := c[0];
    if c[1] = 0 then Exit(0);

   if IsGk then trr.Attributes['kGK'] := 1/c[1] else trr.Attributes['kNGK'] := 1/c[1];
  //  i :=0;
    for x in XEnum(alg) do if x.HasAttribute('EXECUTED') then
     begin
      v := XToVar(x);
      vTovngk;
      vngk.CLC.VALUE := (vngk.DEV.VALUE-c[0])/c[1];
      if v.RT>0 then v.DELTA := (vngk.CLC.VALUE - v.RT)*100/v.RT
      else v.DELTA := (vngk.CLC.VALUE - v.RT)*100/5;
      //v.DELTA := PDoubleArray(Rep.errcurve.ptr)[i];
  //    inc(i);
     end;
   end;
  Result := 0;
end;

class function TXMLScriptMath.AddMetrology(L: lua_State): Integer;
 var
  Title, eu: string;
  Znd: Double;// = 0;
  varTip: Integer;// = 5
  r: IXMLNode;
  ArgCount: integer;
begin
  ArgCount := Lua_GetTop(L);
  r := TXMLLua.XNode(L, 1);
  Title := string(lua_tostring(L,2));
  eu := string(lua_tostring(L,3));
  Znd := lua_tonumber(L,4);
  if ArgCount>=5 then varTip := lua_tointeger(L,5)
  else varTip := 5;

  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  if not r.HasAttribute(AT_TIP) then r.Attributes[AT_TIP] := varTip;
  if eu <> '' then r.Attributes[AT_EU] := eu;
  if Title <> '' then r.Attributes[AT_TITLE] := Title;
  if Znd <> 0 then r.Attributes[AT_ZND] := Znd;

  TXMLLua.PushXmlToTable(L, r);
  Result := 1;
end;

class function TXMLScriptMath.AddMetrology(r: IXMLNode; const Title, eu: string; Znd: Double; varTip: Integer): IXMLNode;
begin
  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  if not r.HasAttribute(AT_TIP) then r.Attributes[AT_TIP] := varTip;
  if eu <> '' then r.Attributes[AT_EU] := eu;
  if Title <> '' then r.Attributes[AT_TITLE] := Title;
  if Znd <> 0 then r.Attributes[AT_ZND] := Znd;
  Result := r;
end;

class function TXMLScriptMath.AddMetrologyCL(L: lua_State): Integer;
 var
  Color: TAlphaColor;
  Width: Single;
  Dash: Integer;
  r: IXMLNode;
  ArgCount: integer;
//  Width: Single = 2; Dash: Integer = 1
begin
  ArgCount := Lua_GetTop(L);
  r := TXMLLua.XNode(L, 1);
  Color := lua_tointeger(L, 2);
  if ArgCount>=3 then Width := lua_tonumber(L,3) else Width := 1;
  Dash := lua_tointeger(L, 4);

  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  r.Attributes[AT_COLOR] := Color;
  r.Attributes[AT_WIDTH] := Width;
  r.Attributes[AT_DASH] := Dash;

  TXMLLua.PushXmlToTable(L, r);
  Result := 1;
end;

class function TXMLScriptMath.AddMetrologyCL(r: IXMLNode; Color: TAlphaColor; Width: Single; Dash: Integer): IXMLNode;
begin
  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  r.Attributes[AT_COLOR] := Color;
  r.Attributes[AT_WIDTH] := Width;
  r.Attributes[AT_DASH] := Dash;
  Result := r;
end;

class function TXMLScriptMath.AddMetrologyFM(r: IXMLNode; Digits, Aqu: Integer): IXMLNode;
begin
  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  r.Attributes[AT_DIGITS] := Digits;
  r.Attributes[AT_AQURICY] := Aqu;
  Result := r;
end;

class function TXMLScriptMath.AddMetrologyFM(L: lua_State): Integer;
 var
  r: IXMLNode;
  Digits, Aqu: Integer;
begin
  r := TXMLLua.XNode(L, 1);
  Digits := lua_tointeger(L,2);
  Aqu := lua_tointeger(L,3);

  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  r.Attributes[AT_DIGITS] := Digits;
  r.Attributes[AT_AQURICY] := Aqu;

  TXMLLua.PushXmlToTable(L, r);
  Result := 1;
end;

class function TXMLScriptMath.AddMetrologyRG(r: IXMLNode; Lo, Hi: Double): IXMLNode;
begin
  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  r.Attributes[AT_RLO] := Lo;
  r.Attributes[AT_RHI] := Hi;
  r.Attributes[AT_VALUE] := (Hi - Lo)/2;
  Result := r;
end;

class function TXMLScriptMath.AddMetrologyRG(L: lua_State): Integer;
 var
  Lo, Hi: Double;
  r: IXMLNode;
begin
  r := TXMLLua.XNode(L, 1);
  Lo := lua_tonumber(L,2);
  Hi := lua_tonumber(L,3);

  if not CNode.IsData(r) then r := CNode.GetCalc(r);
  r.Attributes[AT_RLO] := Lo;
  r.Attributes[AT_RHI] := Hi;
  r.Attributes[AT_VALUE] := (Hi - Lo)/2;

  TXMLLua.PushXmlToTable(L, r);
  Result := 1;
end;

class procedure TXMLScriptMath.TrrVect3D(r, Inp: IXMLNode; var x: Double; var y: Double; var z: Double; Scale: Integer = 1);
 var
  tx,ty,tz: Double;
  ix,iy,iz, rx,ry,rz: IXMLNode;
  m11,m12,m13,m14, m21,m22,m23,m24, m31,m32,m33,m34: Double;
begin
  rx := Inp.ChildNodes.FindNode('X');
  ry := Inp.ChildNodes.FindNode('Y');
  rz := Inp.ChildNodes.FindNode('Z');

  ix := DevNode(rx);
  iy := DevNode(ry);
  iz := DevNode(rz);

  tx := Double(ix.Attributes[AT_VALUE])*Scale;
  ty := Double(iy.Attributes[AT_VALUE])*Scale;
  tz := Double(iz.Attributes[AT_VALUE])*Scale;
  m11 := Double(r.Attributes['m11']);
  m12 := Double(r.Attributes['m12']);
  m13 := Double(r.Attributes['m13']);
  m14 := Double(r.Attributes['m14']);
  m21 := Double(r.Attributes['m21']);
  m22 := Double(r.Attributes['m22']);
  m23 := Double(r.Attributes['m23']);
  m24 := Double(r.Attributes['m24']);
  m31 := Double(r.Attributes['m31']);
  m32 := Double(r.Attributes['m32']);
  m33 := Double(r.Attributes['m33']);
  m34 := Double(r.Attributes['m34']);

  ix := CalcNode(rx);
  iy := CalcNode(ry);
  iz := CalcNode(rz);

  x := m11*tx + m12*ty + m13*tz + m14;
  y := m21*tx + m22*ty + m23*tz + m24;
  z := m31*tx + m32*ty + m33*tz + m34;
  ix.Attributes[AT_VALUE] := x;
  iy.Attributes[AT_VALUE] := y;
  iz.Attributes[AT_VALUE] := z;
//  ix.Attributes[AT_TIP] := varDouble;
//  iy.Attributes[AT_TIP] := varDouble;
//  iz.Attributes[AT_TIP] := varDouble;
//  x := Double(Inp.X.ROW)*Scale;
//  y := Double(Inp.Y.ROW)*Scale;
//  z := Double(Inp.Z.ROW)*Scale;
//  Inp.X.TRR := 1;//root.m21*x + root.m22*y + root.m23*z + root.m24;
//  Inp.Y.TRR := 1;//root.m21*x + root.m22*y + root.m23*z + root.m24;
//  Inp.Z.TRR := 1;//root.m31*x + root.m32*y + root.m33*z + root.m34;}
end;

class function TXMLScriptMath.TrrVect3D(L: lua_State): Integer;
 var
  x,y,z: Double;
  r, Inp: IXMLNode;
  Scale: Integer;
//  m11,m12,m13,m14, m21,m22,m23,m24, m31,m32,m33,m34: Double;
  ArgCount: integer;
begin
  ArgCount := Lua_GetTop(L);
  r := TXMLLua.XNode(L, 1);
  inp := TXMLLua.XNode(L, 2);
  if ArgCount>=3 then Scale := lua_tointeger(L,3)  else Scale := 1;

  TrrVect3D(r,inp, x,y,z, scale);

  lua_pushnumber(L, x);
  lua_pushnumber(L, y);
  lua_pushnumber(L, z);

  Result := 3;

{  rx := Inp.ChildNodes.FindNode('X');
  ry := Inp.ChildNodes.FindNode('Y');
  rz := Inp.ChildNodes.FindNode('Z');

  ix := DevNode(rx);
  iy := DevNode(ry);
  iz := DevNode(rz);

  x := Double(ix.Attributes[AT_VALUE])*Scale;
  y := Double(iy.Attributes[AT_VALUE])*Scale;
  z := Double(iz.Attributes[AT_VALUE])*Scale;
  m11 := Double(r.Attributes['m11']);
  m12 := Double(r.Attributes['m12']);
  m13 := Double(r.Attributes['m13']);
  m14 := Double(r.Attributes['m14']);
  m21 := Double(r.Attributes['m21']);
  m22 := Double(r.Attributes['m22']);
  m23 := Double(r.Attributes['m23']);
  m24 := Double(r.Attributes['m24']);
  m31 := Double(r.Attributes['m31']);
  m32 := Double(r.Attributes['m32']);
  m33 := Double(r.Attributes['m33']);
  m34 := Double(r.Attributes['m34']);

  ix := CalcNode(rx);
  iy := CalcNode(ry);
  iz := CalcNode(rz);

  ix.Attributes[AT_VALUE] := m11*x + m12*y + m13*z + m14;
  iy.Attributes[AT_VALUE] := m21*x + m22*y + m23*z + m24;
  iz.Attributes[AT_VALUE] := m31*x + m32*y + m33*z + m34;
//  ix.Attributes[AT_TIP] := varDouble;
//  iy.Attributes[AT_TIP] := varDouble;
//  iz.Attributes[AT_TIP] := varDouble;
//  x := Double(Inp.X.ROW)*Scale;
//  y := Double(Inp.Y.ROW)*Scale;
//  z := Double(Inp.Z.ROW)*Scale;
//  Inp.X.TRR := 1;//root.m21*x + root.m22*y + root.m23*z + root.m24;
//  Inp.Y.TRR := 1;//root.m21*x + root.m22*y + root.m23*z + root.m24;
//  Inp.Z.TRR := 1;//root.m31*x + root.m32*y + root.m33*z + root.m34;}
end;

class function TXMLScriptMath.AddXmlMatrix(L: lua_State): Integer;
 var
  r, c: Integer;
  Row, col: Integer;
  mn: string;
  root: IXMLNode;
begin
  root := TXMLLua.XNode(L, 1);
  Row := lua_tointeger(L,2);
  Col := lua_tointeger(L,3);
  mn := Format('m%dx%d',[Row, col]);
  if Assigned(root.ChildNodes.FindNode(mn)) then Exit(0);
  root := root.AddChild(mn);
  for r := 1 to Row do for c := 1 to Col do root.Attributes[Format('m%d%d',[r, c])] := 0;
  Result := 0;
end;

class function TXMLScriptMath.AddXmlPath(root: IXMLNode; const path: string): IXMLNode;
begin
  Result := GetXNode(root, path, True);
end;

class function TXMLScriptMath.AddXmlPath(L: lua_State): Integer;
 var
  root: IXMLNode;
  path: string;
//  ArgCount: Integer;
begin
//  ArgCount := Lua_GetTop(L);

  root := TXMLLua.XNode(L, 1);
  path := string(lua_tostring(L,2));
  TXMLLua.PushXmlToTable(L, GetXNode(root, path, True));
  Result := 1;
end;

class function TXMLScriptMath.XmlPathExists(L: lua_State): Integer;
 var
  root: IXMLNode;
  path: string;
begin
  root := TXMLLua.XNode(L, 1);
  path := string(lua_tostring(L,2));
//  TDebug.Log(TVxmlData(root).Node.NodeName);
  lua_pushboolean(L, Integer(Assigned(GetXNode(root, path, False))));
  Result := 1;
end;

class function TXMLScriptMath.FindXmlRoot(L: lua_State): Integer;
 var
  Section, root: string;
  r, n: IXMLNode;
begin
  r := TXMLLua.XNode(L, 1);
  Section := string(lua_tostring(L, 2));
  root := string(lua_tostring(L, 3));
  Result := 2;

  while Assigned(r.ParentNode) do r := r.ParentNode;
  lua_pushboolean(L, Integer(FindXmlNode(r, Section, root, n)));
  if Assigned(n) then TXMLLua.PushXmlToTable(L, n) else Result := 1;
end;

class function TXMLScriptMath.GetAzi(Zen, Otk, X, Y, Z: Double): Double;
 var
  os,oc,zs,zc: Double;
  Hx, Hy : Double;
begin
  Zen := DegToRad(Zen);
  Otk := DegToRad(Otk);

  os := Sin(Otk);
  oc := Cos(Otk);
  zs := Sin(Zen);
  zc := Cos(Zen);

  Hx := (x*oc - y*os)*zc + z*zs;
  Hy :=  x*os + y*oc;
//  Hz :=-(x*oc - y*os)*zs + z*zc;

  Result := DegNormalize(Math.RadToDeg(-math.Arctan2(Hy, Hx)));
end;

class procedure TXMLScriptMath.GetH(Azi, Zen, Otk: Double; out X, Y, Z: Double; I, Amp: Double);
 var
  so,co,sz,cz,sa,ca, si, ci: Double;
begin
  Azi := DegToRad(Azi);
  Zen := DegToRad(Zen);
  Otk := DegToRad(Otk);
  I := DegToRad(I);

  so := Sin(Otk);
  co := Cos(Otk);
  sa := Sin(Azi);
  ca := Cos(Azi);
  sz := Sin(Zen);
  cz := Cos(Zen);
  si := Sin(I);
  ci := Cos(I);

  X := (si*( co*cz*ca - so*sa) - ci*co*sz)*Amp;
  Y := (si*(-so*cz*ca - co*sa) + ci*so*sz)*Amp;
  Z := (si*     sz*ca          + ci   *cz)*Amp;
end;

class function TXMLScriptMath.Hypot3D(L: lua_State): Integer;
 var
  X, Y, Z, r: Double;
begin
  X := Abs(lua_tonumber(L, 1));
  Y := Abs(lua_tonumber(L, 2));
  Z := Abs(lua_tonumber(L, 3));

  if (X.SpecialType = fsZero) and (Y.SpecialType = fsZero) and (z.SpecialType = fsZero) then r := 0
  else if (X<=Z) and (Y<=Z) then R := Z * Sqrt(1 + Sqr(X/Z)+ Sqr(Y/Z))
  else if (X<=Y) and (Z<=Y) then R := Y * Sqrt(1 + Sqr(X/Y)+ Sqr(Z/Y))
  else R := X * Sqrt(1 + Sqr(Z/X)+ Sqr(Y/X));

  lua_pushnumber(L, r);
  Result :=1;
end;

//class function TXMLScriptMath.VarAsType(L: lua_State): Integer;
//begin
//  lua_pushinteger(System.Variants.VarAsType(
//end;

class function TXMLScriptMath.Arccos(L: lua_State): Integer;
begin
  lua_pushnumber(L, math.ArcCos(lua_tonumber(L, 1)));
  Result := 1;
end;

class function TXMLScriptMath.ArcTan2(L: lua_State): Integer;
begin
  lua_pushnumber(L, math.ArcTan2(lua_tonumber(L, 1), lua_tonumber(L, 2)));
  Result := 1;
end;

class function TXMLScriptMath.Hypot3D(X, Y, Z: Double): Double;
begin
  X := Abs(X);
  Y := Abs(Y);
  Z := Abs(Z);

  if (X.SpecialType = fsZero) and (Y.SpecialType = fsZero) and (z.SpecialType = fsZero) then Result := 0
  else if (X<=Z) and (Y<=Z) then Result := Z * Sqrt(1 + Sqr(X/Z)+ Sqr(Y/Z))
  else if (X<=Y) and (Z<=Y) then Result := Y * Sqrt(1 + Sqr(X/Y)+ Sqr(Z/Y))
  else Result := X * Sqrt(1 + Sqr(Z/X)+ Sqr(Y/X));
end;

class function TXMLScriptMath.Hypot(L: lua_State): Integer;
begin
  lua_pushnumber(L, math.Hypot(lua_tonumber(L, 1), lua_tonumber(L, 2)));
  Result := 1;
end;

class function TXMLScriptMath.KadrToStr(L: lua_State): Integer;
 var
  m: TMarshaller;
begin
  lua_pushstring(L, m.AsAnsi((CTime.AsString(CTime.FromKadr(lua_tointeger(L,1))))).ToPointer);
  Result := 1;
end;

class function TXMLScriptMath.Now(L: lua_State): Integer;
begin
  lua_pushnumber(L, SysUtils.now);
  Result := 1;
end;

class function TXMLScriptMath.RadToDeg(L: lua_State): Integer;
begin
  lua_pushnumber(L, DegNormalize(math.RadToDeg(lua_tonumber(L, 1))));
  Result := 1;
end;

class function TXMLScriptMath.RadToDeg180(L: lua_State): Integer;
begin
  lua_pushnumber(L, DegNormalize(math.RadToDeg(lua_tonumber(L, 1))));
  Result := 1;
end;

class function TXMLScriptMath.RadToDeg360(r: Double): Double;
begin
  Result :=  DegNormalize(math.RadToDeg(r));
end;

class function TXMLScriptMath.RadToDeg360(L: lua_State): Integer;
begin
  lua_pushnumber(L, DegNormalize(math.RadToDeg(lua_tonumber(L, 1))));
  Result := 1;
end;

class function TXMLScriptMath.RbfInterp(xy: Variant; x1, x2: Double): Double;
 var
  r: IXMLNode;
  oi: IOwnIntfXMLNode;
  rbf: IRbf;
  res: PRbfReport;
   rz: Double;
begin
  r := TVxmlData(xy).node;

  if not Supports(r, IOwnIntfXMLNode, oi) then raise EBaseException.Create('Not Supports IOwnIntfXMLNode');
  if not Assigned(oi.Intf) then
   begin
    RbfFactory(rbf);
    oi.Intf := IInterface(rbf);
    rbf.Create(2,1);
    CheckMath(rbf, rbf.Points(PAnsiChar(AnsiString(r.Attributes['XY']))));
    CheckMath(rbf, rbf.Build(res));
   end;
  rbf := IRbf(oi.Intf);
  CheckMath(rbf, rbf.Calc2(x1,x2, Rz));
  Result := Rz;
end;

class function TXMLScriptMath.RbfInterp(L: lua_State): Integer;
 var
  r: IXMLNode;
  oi: IOwnIntfXMLNode;
  rbf: IRbf;
  res: PRbfReport;
  x1, x2, rz: Double;
begin
  r := TXMLLua.XNode(L, 1);
  x1 := lua_tonumber(L, 2);
  x2 := lua_tonumber(L, 3);

  if not Supports(r, IOwnIntfXMLNode, oi) then raise EBaseException.Create('Not Supports IOwnIntfXMLNode');
  if not Assigned(oi.Intf) then
   begin
    RbfFactory(rbf);
    oi.Intf := IInterface(rbf);
    rbf.Create(2,1);
    CheckMath(rbf, rbf.Points(PAnsiChar(AnsiString(r.Attributes['XY']))));
    CheckMath(rbf, rbf.Build(res));
   end;
  rbf := IRbf(oi.Intf);
  CheckMath(rbf, rbf.Calc2(x1,x2, Rz));
  lua_pushnumber(L, rz);
  Result := 1;
end;

class function TXMLScriptMath.SGK_FindGK(L: lua_State): Integer;
 var
  s,d: string;
  Sm : Integer;
  root: variant;
begin
  root := Xtovar(TXMLLua.XNode(L, 1));
  s := root.СГК.DEV.VALUE;
  sm := 0;
  for d in s.Split([' '], ExcludeEmpty) do sm := sm + d.ToInteger;
  root.гк.DEV.VALUE := Sm;
  Result := 0;
end;


class function TXMLScriptMath.ImportNNK10(L: lua_State): Integer;
 var
  ss: TStrings;
  i: Integer;
//  s: string;
  root, dev: IXMLNode;
  sp: TArray<string>;
  TrrFile: string;
//  NewTrr: Variant);
  procedure UpdatePoint(d, kp, k1, k2, gk: Double);
    var
     skp: string;
     n: IXMLNode;
  begin
    if kp = 100 then skp := 'Вода' else skp := FloatToStr(kp);
    for n in XEnum(root) do if (n.Attributes['KP'] = skp) and (n.Attributes['D'] = d) then
     begin
      n.Attributes['EXECUTED'] := True;
      DevNode(n.ChildNodes['нк1']).Attributes[AT_VALUE] := k1;
      DevNode(n.ChildNodes['нк2']).Attributes[AT_VALUE] := k2;
      DevNode(n.ChildNodes['нгк']).Attributes[AT_VALUE] := gk;
      Break;
     end;
  end;
{  function Next(): Double ;
  begin
    if pos(' ', s) >0  then
     begin
      Result := StrToFloat(Copy(s, 1, pos(' ', s)));
      Delete(s, 1, pos(' ', s));
      s := Trim(s);
     end
    else Result := StrToFloat(s);
  end;}
begin
  root := TXMLLua.XNode(L, 1);//TVxmlData(NewTrr).Node;
  dev := root.ParentNode.ParentNode.ParentNode;
 // TDebug.Log(root.NodeName);
  ss := TStringList.Create();
  try
   ss.LoadFromFile(TrrFile);
   if ss.Count <> 17 then raise EBaseException.Createfmt('У файла %s %d (17)строк', [TrrFile, ss.Count]);
   dev.Attributes[AT_SERIAL] := Trim(Copy(ss[0],5 ,3));
   root.Attributes[AT_TIMEATT] := Trim(Copy(ss[1],1 , 12));
   root.Attributes['ISTOCHNIK'] := Trim(Copy(ss[2],1 , pos('Источник', ss[2])-1));
   for i := 1 to 13 do
    begin
     sp := ss[i+3].Trim.split([' '], ExcludeEmpty);
     UpdatePoint(sp[0].ToDouble, sp[1].ToDouble, sp[2].ToDouble, sp[3].ToDouble, sp[4].ToDouble);
    end;
{    begin
     s := Trim(ss[i+3]);
     UpdatePoint(Next(), Next(), Next(), Next(), Next());
    end;}
  finally
   ss.Free;
  end;
  Result := 0;
end;

end.
