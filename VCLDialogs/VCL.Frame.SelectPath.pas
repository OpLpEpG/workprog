unit VCL.Frame.SelectPath;

interface

uses Container, ExtendIntf,
  Xml.XMLIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees;

type
  PNodeExData = ^TNodeExData;
  TNodeExData = record
    Caption: string;
    XMLSection: IXMLNode;
  end;

  TCheckEvent = reference to procedure( XMLSection: IXMLNode);
  TFrameSelectPath = class(TFrame)
    Tree: TVirtualStringTree;
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure TreeChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    FLastChecked: PVirtualNode;
    FCheckEvent: TCheckEvent;
    procedure ClearTree;
  public
    procedure Execute(const FileName: string; CheckEvent: TCheckEvent);
  end;

implementation

uses tools, debug_except;

{$R *.dfm}

{ TFrameSelectPath }

procedure TFrameSelectPath.ClearTree;
 var
  pv: PVirtualNode;
begin
  for pv in Tree.Nodes do PNodeExData(Tree.GetNodeData(pv)).XMLSection := nil;
  Tree.Clear;
end;

procedure TFrameSelectPath.Execute(const FileName: string; CheckEvent: TCheckEvent);
  function CreatePV(Parent :PVirtualNode; const Caption: string; u: IXMLNode = nil; ct: TCheckType = ctNone): PVirtualNode;
   var
    ex: PNodeExData;
  begin
    Result := Tree.AddChild(Parent);
    Include(Result.States, vsExpanded);
    Result.CheckType := ct;
    ex := Tree.GetNodeData(Result);
    ex.Caption := Caption;
    ex.XMLSection := u;
  end;
 var
  r, n, d, s: IXMLNode;
  pvDev, pvModul, pvSect: PVirtualNode;
begin
  FCheckEvent := CheckEvent;
  r := (GContainer as IALLMetaDataFactory).Get(FileName).Get.DocumentElement;
  if r.NodeName = 'PROJECT' then r := r.ChildNodes.FindNode('DEVICES');
  Tree.BeginUpdate;
  try
   ClearTree;
   for n in XEnum(r) do
    begin
     pvDev := CreatePV(nil, n.NodeName);
     for d in XEnum(n) do
     begin
      pvModul := CreatePV(pvDev, d.NodeName);
      s := d.ChildNodes.FindNode(T_WRK);
      if Assigned(s) and s.HasAttribute(AT_FILE_NAME) then CreatePV(pvModul, 'история данных информации', s, ctRadioButton)
      else CreatePV(pvModul, 'история данных информации', s, ctNone);
      s := d.ChildNodes.FindNode(T_RAM);
      if Assigned(s) and s.HasAttribute(AT_FILE_NAME) then CreatePV(pvModul, 'память по кадрам', s, ctRadioButton)
      else CreatePV(pvModul, 'память по кадрам', s, ctNone);
      s := d.ChildNodes.FindNode(T_GLU);
      if Assigned(s) and s.HasAttribute(AT_FILE_NAME) then CreatePV(pvModul, 'память по глубине', s, ctRadioButton)
      else CreatePV(pvModul, 'память по глубине', s, ctNone)
     end;
    end;
  finally
   Tree.EndUpdate;
  end;
end;

procedure TFrameSelectPath.TreeChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  if FLastChecked <> Node then
   begin
    FLastChecked := Node;
    FCheckEvent(PNodeExData(Tree.GetNodeData(Node)).XMLSection);
   end;
end;

procedure TFrameSelectPath.TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TNodeExData);
end;

procedure TFrameSelectPath.TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;  var CellText: string);
begin
  CellText := PNodeExData(Tree.GetNodeData(Node)).Caption;
end;

end.
