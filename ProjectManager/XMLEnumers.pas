unit XMLEnumers;

interface

uses System.SysUtils, System.Generics.Collections, System.Classes, Xml.XMLIntf,
  debug_except, RootIntf, DeviceIntf, ExtendIntf, Container, RootImpl;

type
  TXMEnum<T: IManagItem> = class(TRootServiceManager<T>)
  protected
    class function SupportPublishedChanged: Boolean; override;
    procedure SetItemChanged(const Value: string); override;
    procedure DoAfterAdd(mi: IManagItem); override;
    procedure DoAfterAddIner(n: IXMLNode; mi: IManagItem); virtual;
    procedure DoAfterRemove(mi: IManagItem); override;
    procedure Load; override;
    procedure UpdateProject;
    function Root: IXmlNode; virtual; abstract;
  end;

  TConnectIOs = class(TXMEnum<IConnectIO>, IConnectIOEnum)
  protected
    function Root: IXmlNode; override;
  end;

  TDevices = class(TXMEnum<IDevice>, IDeviceEnum)
  protected
    procedure DoAfterAddIner(n: IXMLNode; mi: IManagItem); override;
  protected
    function Root: IXmlNode; override;
  end;


implementation

uses tools, manager3;

{$REGION 'TXMEnum<T>'}

{ TXMEnum<T> }

class function TXMEnum<T>.SupportPublishedChanged: Boolean;
begin
  Result := True;
end;

procedure TXMEnum<T>.UpdateProject;
begin
  TManager.This.FProjecDoc.SaveToFile(TManager.This.FProjectFile);
end;

procedure TXMEnum<T>.DoAfterAdd(mi: IManagItem);
 var
  ir: TInstanceRec;
  n: IXMLNode;
begin
  if GContainer.TryGetInstRec(mi.Model, mi.IName, ir) then
  begin
   n := Root.AddChild(mi.IName);
   n.Attributes[AT_PRIORITY] := mi.Priority;
   n.Attributes[AT_OBJ] := ir.Text;
   DoAfterAddIner(n, mi);
  end;
  inherited;
  UpdateProject;
end;

procedure TXMEnum<T>.DoAfterAddIner(n: IXMLNode; mi: IManagItem);
begin
end;

procedure TXMEnum<T>.DoAfterRemove(mi: IManagItem);
 var
  n: IXMLNode;
begin
  n := Root.ChildNodes.FindNode(mi.IName);
  Root.ChildNodes.Remove(n);
  inherited;
  UpdateProject;
end;

procedure TXMEnum<T>.SetItemChanged(const Value: string);
 var
  ir: TInstanceRec;
  n: IXMLNode;
begin
  inherited;
  if not GContainer.TryGetInstRecKnownServ(TypeInfo(T), Value, ir) then Exit;
  n := Root.ChildNodes.FindNode(Value);
  n.Attributes[AT_OBJ] := ir.Text;
  UpdateProject;
end;

procedure TXMEnum<T>.Load;
 var
  v: IXMLNode;
begin
  for v in XEnum(Root) do
   try
    DoLoadItem(v.Attributes[AT_OBJ]);
   except
    on E: Exception do TDebug.DoException(E, False);
   end;
end;
{$ENDREGION}

{ TConnectIOs }

function TConnectIOs.Root: IXmlNode;
begin
  Result := TManager.This.FConnect;
end;

{ TDevices }

procedure TDevices.DoAfterAddIner(n: IXMLNode; mi: IManagItem);
begin
  inherited;
  n.Attributes[AT_CAPTION] := (mi as ICaption).Text;
end;

function TDevices.Root: IXmlNode;
begin
  Result := TManager.This.FDevices;
end;


initialization
  RegisterClasses([TDevices, TConnectIOs]);
  TRegister.AddType<TDevices, IDeviceEnum>
           .LiveTime(ltSingletonNamed)
           .AddInstance(TDevices.Create as IInterface);
  TRegister.AddType<TConnectIOs, IConnectIOEnum>
           .LiveTime(ltSingletonNamed)
           .AddInstance(TConnectIOs.Create as IInterface);
finalization
  GContainer.RemoveModel<TDevices>;
  GContainer.RemoveModel<TConnectIOs>;
end.
