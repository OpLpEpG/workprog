unit VCL.FormShowArray;

interface

uses  DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Xml.XMLIntf,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCLTee.TeEngine, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VclTee.TeeGDIPlus;

type
  TFormShowArray = class(TDockIForm)
    ChartCode: TChart;
    srDev: TFastLineSeries;
    srCLC: TFastLineSeries;
  private
    FDataDevice: string;
    FBindWorkRes: TWorkEventRes;
    FXMLPath: string;
    procedure SetBindWorkRes(const Value: TWorkEventRes);
    procedure SetRemoveDevice(const Value: string);
    procedure SetBind;
  protected
    procedure Loaded; override;
  public
    destructor Destroy; override;
    class procedure Execute(const ADataDevice, AXMLPath: string);
    property C_BindWorkRes: TWorkEventRes read FBindWorkRes write SetBindWorkRes;
    property C_RemoveDevice: string read FDataDevice write SetRemoveDevice;
  published
    property DataDevice: string read FDataDevice write FDataDevice;
    property XMLPath: string read FXMLPath write FXMLPath;
  end;

implementation

{$R *.dfm}

uses tools, Parser;

{ TFormShowArray }

procedure TFormShowArray.SetBind;
 var
  d: IDevice;
  de: IDeviceEnum;
begin
  if FDataDevice = '' then Exit;
  if Supports(GlobalCore, IDeviceEnum, de) then
   begin
    Bind('C_RemoveDevice', de, ['S_BeforeRemove']);
    d := de.Get(FDataDevice);
    if Assigned(d) then Bind('C_BindWorkRes',d, ['S_WorkEventInfo']);
   end;
end;

destructor TFormShowArray.Destroy;
begin

  inherited;
end;

class procedure TFormShowArray.Execute(const ADataDevice, AXMLPath: string);
 var
  f: TFormShowArray;
begin
  f := CreateUser();
  (GContainer as IFormEnum).Add(f as Iform);
  f.DataDevice := ADataDevice;
  f.XMLPath := AXMLPath;
  f.Caption := AXMLPath;
  f.SetBind;
  f.IShow;
end;

procedure TFormShowArray.Loaded;
begin
  inherited;
  SetBind;
end;

procedure TFormShowArray.SetBindWorkRes(const Value: TWorkEventRes);
 var
  n: IXMLNode;
  a: TArray<Double>;
  //d: Double;
begin
  FBindWorkRes := Value;
  if TryGetX(FBindWorkRes.Work, XMLPath+'.'+T_DEV, n, AT_VALUE) then if (n.NodeValue <> '') and (n.NodeValue <> null) then
   begin
    srDev.BeginUpdate;
    try
      srDev.Clear;
      a := TPars.ArrayStrToArray(n.NodeValue);
      if Length(a) <> 681 then
       begin
        TDebug.Log('  BAD LEM ARRAY %d',[Length(a)]);
       end;
  //    for d in a do srDev.Add(d);
      srDev.AddArray(a);
    finally
     srDev.EndUpdate;
    end
   end
  else
   begin
    TDebug.Log('  BAD NO DATA  ');
   end;
//  if TryGetX(FBindWorkRes.Work, XMLPath+'.'+T_CLC, n, AT_VALUE) and (n.NodeValue <> '') then
//   begin
//    srCLC.Clear;
//    srCLC.AddArray(TPars.ArrayStrToArray(n.NodeValue));
//   end;
end;

procedure TFormShowArray.SetRemoveDevice(const Value: string);
begin
  if DataDevice = Value then
   begin
    (GContainer as IMainScreen).Changed;
    (GlobalCore as IFormEnum).Remove(Self as Iform);
   end;
end;

initialization
  RegisterClass(TFormShowArray);
  TRegister.AddType<TFormShowArray, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormShowArray>;
end.
