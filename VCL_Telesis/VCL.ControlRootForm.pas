unit VCL.ControlRootForm;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns,
  Winapi.Windows, Winapi.Messages,  System.Generics.Collections,
  System.SysUtils, System.Variants, System.Classes, Math.Telesistem.Custom,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,  Vcl.ExtCtrls;

type
  TControlRootFrame<T> = class(TForm)
  public
    procedure DoData(Data: T); virtual; abstract;
    constructor Create(AOwner: TComponent); override;
  end;

  TDecoderFrameclass = class of TDecoderFrame;
  TDecoderFrame = class(TForm)
  private
    FDecoder: TCustomDecoder;
    class var DecoderFrameTypes: TDictionary<string, TDecoderFrameclass>;
    class constructor Create;
    class destructor Destroy;
  protected
    procedure SetDecoder(const Value: TCustomDecoder); virtual;
    class function DecoderClassName: string; virtual; abstract;
  public
    procedure DoData(Data: TCustomDecoder); virtual; abstract;
    property Decoder: TCustomDecoder read FDecoder write SetDecoder;
    function CheckDecoder(Dc: TCustomDecoder): Boolean;
    class procedure RegisterSelfClass;
    class function New(pc: TCPageControl; Dc: TCustomDecoder): TDecoderFrame;
  end;

  TControlRootForm<T; SERV: IInterface> = class(TCustomFontIForm, IControlForm, IRootControlForm)
  private
    FSubControlName: String;
    FControlName: String;
    procedure SetC_Data(Value: T);
  protected
    FC_Data: T;
    procedure DoData; virtual;
    function GetControlName: String;
    procedure SetControlName(const AValue: String); virtual;
    function GetSubControlName: String;
    procedure SetSubControlName(const AValue: String); virtual;
    procedure Loaded; override;
  public
    class function ExistsSubDev(root: IRootDevice; const Categ, Capt: string; out dev: ISubDevice): Boolean; overload;
    class function ExistsSubDev(root: IRootDevice; const AIName: string; out dev: ISubDevice): Boolean; overload;
    property C_Data: T read FC_Data write SetC_Data;
  published
    property ControlName: String read FControlName write SetControlName;
    property SubControlName: String read FSubControlName write SetSubControlName;
  end;

implementation

{ TControlRootFrame<T> }

constructor TControlRootFrame<T>.Create(AOwner: TComponent);
begin
  inherited;
  Tag := $12345678;
  Name := Self.ClassName.Substring(1);
  Parent := TWinControl(AOwner);
end;

{ TControlRootForm<T> }

class function TControlRootForm<T, SERV>.ExistsSubDev(root: IRootDevice; const Categ, Capt: string; out dev: ISubDevice): Boolean;
 var
  sd: ISubDevice;
begin
  for sd in root.GetSubDevices do if SameText(sd.Category.Category, Categ) and (SameText(sd.Caption, Capt) or (Capt = '')) then
   begin
    dev := sd;
    Exit(True);
   end;
  Result := False;
end;

procedure TControlRootForm<T, SERV>.DoData;
begin
end;

class function TControlRootForm<T, SERV>.ExistsSubDev(root: IRootDevice; const AIName: string; out dev: ISubDevice): Boolean;
 var
  sd: ISubDevice;
begin
  for sd in root.GetSubDevices do if SameText(sd.IName, AIname) then
   begin
    dev := sd;
    Exit(True);
   end;
  Result := False;
end;

function TControlRootForm<T, SERV>.GetControlName: String;
begin
  Result := FControlName;
end;

function TControlRootForm<T, SERV>.GetSubControlName: String;
begin
  Result := FSubControlName;
end;

procedure TControlRootForm<T, SERV>.SetControlName(const AValue: String);
begin
  FControlName := AValue;
end;

procedure TControlRootForm<T, SERV>.SetC_Data(Value: T);
begin
  FC_Data := Value;
  DoData;
end;

procedure TControlRootForm<T, SERV>.SetSubControlName(const AValue: String);
 var
  i: IInterface;
begin
  FSubControlName := AValue;
  if GContainer.TryGetInstKnownServ(TypeInfo(SERV), FSubControlName, i) then
   begin
    TBindHelper.RemoveControlExpressions(Self, ['C_Data']);
    Bind('C_Data', i, ['S_Data']);
   end
end;

procedure TControlRootForm<T, SERV>.Loaded;
 var
  d: IRootDevice;
  s: ISubDevice;
  i: IInterface;
begin
  inherited;
  if GContainer.TryGetInstKnownServ(TypeInfo(IDevice), FControlName, i) and Supports(i, IRootDevice, d)
  and ExistsSubDev(d, FSubControlName, s) then Bind('C_Data', s, ['S_Data']);
end;

{ TDecoderFrame }

function TDecoderFrame.CheckDecoder(Dc: TCustomDecoder): Boolean;
 var
  c: TClass;
begin
  c := Dc.ClassType;
  if not Assigned(Decoder) then
   repeat
    if c.ClassName = DecoderClassName then
     begin
      Decoder := Dc;
      Break;
     end;
    c := c.ClassParent;
   until not Assigned(c);
  Result := Dc = Decoder;
end;

procedure TDecoderFrame.SetDecoder(const Value: TCustomDecoder);
begin
  FDecoder := Value;
end;

class constructor TDecoderFrame.Create;
begin
  DecoderFrameTypes := TDictionary<string, TDecoderFrameclass>.Create;
end;

class destructor TDecoderFrame.Destroy;
begin
  DecoderFrameTypes.Free;
end;

class function TDecoderFrame.New(pc: TCPageControl; Dc: TCustomDecoder): TDecoderFrame;
 var
  DecoderFrameclass: TDecoderFrameclass;
  tt: TCTabsheet;
  c: TClass;
  i: Integer;
  co: Tcontrol;
begin
  Result := nil;
  c := Dc.ClassType;
  repeat
    if DecoderFrameTypes.TryGetValue(c.ClassName, DecoderFrameclass) then
     begin
      tt := TCTabsheet.Create(pc.Owner);
      tt.PageControl := pc;
      tt.Name := 'Tabsheet'+ pc.PageCount.ToString;
      tt.Caption := Dc.Text;         // rootform
      Result := DecoderFrameclass.Create(pc.Owner);
 //     for I := Result.ControlCount-1 downto 0 do TWinControl(pc.Owner).InsertControl(Result.Controls[i]);
      //for I := Result.ComponentCount-1 downto 0 do pc.Owner.InsertComponent(Result.Components[i]);
      Result.Parent := tt;
      Result.Name := 'DecoderFrame' + tt.TabIndex.ToString;
      Result.Decoder := Dc;
      Result.Show;
      Result.SetSubComponent(True);
      Exit;
     end;
     c := c.ClassParent;
  until not Assigned(c);
end;

class procedure TDecoderFrame.RegisterSelfClass;
begin
  DecoderFrameTypes.AddOrSetValue(DecoderClassName, Self);
end;

end.
