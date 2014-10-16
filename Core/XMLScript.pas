unit XMLScript;

interface

uses debug_except, MathIntf,  o_iclassesrtti,
    SysUtils, o_iinterpreter, o_ipascal, Xml.XMLIntf, System.Generics.Collections, System.Classes, math, System.Variants;

type
  TXmlScript = class(TfsScript)
  private
    type
     TRunScriptRec = record
       TrrRoot: IXMLNode;
       RunRoot: IXMLNode;
       RunFunc: string;
       RunPath: string;
       RunAdr: Integer;
       V: Variant;
      constructor Create(TrRoot, RnRoot: IXMLNode; const RnPath, RnFuncName: string; Aadr: Integer);
     end;
   var
    FRunScript: TList<TRunScriptRec>;
    class var UserMethods: TDictionary<string, TfsCallMethodEvent>;
    class constructor Create;
    class destructor Destroy;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddXML(Aadr: Integer; const RnPath: string; TrRoot, RnRoot: IXMLNode;  Script: IXMLNode; const ScriptAtr: string; const RootPrefix: string = '');
    procedure ClearLines;

    procedure Execute(); reintroduce; overload;
    procedure Execute(const ExePath: string); overload;
    procedure Execute(const ExePath: string; adr: Integer); overload;

    class procedure RegisterMethods(const method: array of string; CallMeth: TfsCallMethodEvent);
    class procedure UnRegisterMethods(CallMeth: TfsCallMethodEvent);
  end;

function ScriptExec(TrrData, Data: IXMLNode; const RootName, Name, Attr: string): Boolean;


implementation

uses tools, Parser;


function ScriptExec(TrrData, Data: IXMLNode; const RootName, Name, Attr: string): Boolean;
 var
  sc: TXmlScript;
  scr: IXMLNode;
begin
  scr := TPars.XMLScript.ChildNodes.FindNode(RootName);
  if not Assigned(scr) then Exit(False);
  if Name <> '' then scr := GetXNode(scr, 'MODEL.'+ Name);
  if not (Assigned(scr) and scr.HasAttribute(Attr))  then Exit(False);
  sc := TXmlScript.Create(nil);
  try
   sc.AddXML(1,'',TrrData, Data, scr, Attr, RootName);
   sc.Lines.Add('begin');
   sc.Lines.Add('end.');
   Result := sc.Compile;
   if Result then sc.Execute;
  finally
   sc.Free;
  end;
end;


{$REGION 'TXmlScript'}

{ TXmlScript.TAdrFnRec }

constructor TXmlScript.TRunScriptRec.Create(TrRoot, RnRoot: IXMLNode; const RnPath, RnFuncName: string; Aadr: Integer);
begin
  TrrRoot := TrRoot;
  RunRoot := RnRoot;
  RunPath := RnPath;
  RunFunc := RnFuncName;
  RunAdr := Aadr;
  V := VarArrayOf([XToVar(RunRoot), XToVar(TrrRoot)]);
end;

{ TXmlScript }

class constructor TXmlScript.Create;
begin
  TDebug.Log('class constructor TXmlScript.Create');
  fsRTTIModules.Add(o_iclassesrtti.TFunctions);
  UserMethods := TDictionary<string, TfsCallMethodEvent>.Create();
end;

class destructor TXmlScript.Destroy;
begin
  UserMethods.Free;
  fsRTTIModules.Remove(TFunctions);
  TDebug.Log('class destructor TXmlScript.Destroy;');
end;

class procedure TXmlScript.RegisterMethods(const method: array of string; CallMeth: TfsCallMethodEvent);
 var
  s: string;
begin
  for s in method do UserMethods.Add(s, CallMeth);
end;

class procedure TXmlScript.UnRegisterMethods(CallMeth: TfsCallMethodEvent);
 var
  p: TPair<string, TfsCallMethodEvent>;
begin
  for p in UserMethods.ToArray do if Addr(p.Value) = Addr(CallMeth) then UserMethods.Remove(p.Key);
end;

procedure TXmlScript.AddXML(Aadr: Integer; const RnPath: string; TrRoot, RnRoot: IXMLNode;  Script: IXMLNode; const ScriptAtr: string; const RootPrefix: string = '');
 const
  NL = #$D#$A;
  FUNC_FMT = 'procedure %s(v, t: variant);';
 var
  fs, fn: string;
  function fnd(): Boolean;
   var
    s: string;
  begin
    Result := False;
    for s in Lines do if SameText(s,fn) then Exit(True);
  end;
begin
  if not Assigned(Script) or not Script.HasAttribute(ScriptAtr) then Exit;
  fs := RootPrefix + Script.NodeName + ScriptAtr;
  fn := Format(FUNC_FMT, [fs]);
  if not Fnd() then Lines.Text := Lines.Text + NL + fn + NL + Script.Attributes[ScriptAtr];
  FRunScript.Add(TRunScriptRec.Create(TrRoot, RnRoot, RnPath, fs, AAdr));
end;

procedure TXmlScript.ClearLines;
 var
  r: TRunScriptRec;
  v: TfsCustomVariable;
begin
  Lines.Clear;
  for r in FRunScript do
   begin
    v := Find(r.RunFunc);
    if Assigned(v) then Remove(v);
   end;
  FRunScript.Clear;
end;

constructor TXmlScript.Create(AOwner: TComponent);
 var
  p: TPair<string, TfsCallMethodEvent>;
begin
  inherited Create(AOwner);
  Parent := fsGlobalUnit;
  FRunScript := TList<TRunScriptRec>.Create;

//  TDebug.Log('Count %d',[Count]);

  for p in UserMethods do AddMethod(p.Key, p.Value);

//  TDebug.Log('Count %d',[Count]);
end;

destructor TXmlScript.Destroy;
begin
  FRunScript.Free;
  inherited;
end;

procedure TXmlScript.Execute;
 var
  p: TRunScriptRec;
begin
  for p in FRunScript do CallFunction(p.RunFunc, VarArrayOf([XToVar(p.RunRoot), XToVar(p.TrrRoot)]));
end;

procedure TXmlScript.Execute(const ExePath: string);
 var
  p: TRunScriptRec;
begin
  for p in FRunScript do
    if ExePath = p.RunPath then
      CallFunction(p.RunFunc, VarArrayOf([XToVar(p.RunRoot), XToVar(p.TrrRoot)]));
end;

procedure TXmlScript.Execute(const ExePath: string; adr: Integer);
 var
  p: TRunScriptRec;
begin
  for p in FRunScript do
   if (p.RunAdr = adr) and (ExePath = p.RunPath) then
    CallFunction(p.RunFunc, p.V);//([XToVar(p.RunRoot), XToVar(p.TrrRoot)]));
end;

{$ENDREGION}


end.
