unit FrameDelayDev;

interface

uses  XMLIntf,tools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFrameDelayInfo = class(TFrame)
    lbCon: TLabel;
    lbStatus: TLabel;
    lbNStat: TLabel;
    lbKadr: TLabel;
    lbAdr: TLabel;
  private
    FKadr: IXMLNode;
    FNst: IXMLNode;
    FSt: IXMLNode;
    function Nstat: string;
    function stat: string;
    function kadr: string;
    function statColor: TColor;
  public
    Adr: Integer;
    Dev: IXMLNode;
    LastUpdate:TDateTime;
    procedure UpdateData;
    procedure UpdateInit;
    procedure UpdateTimout;
    class function GetNew(Adr: Integer; Dev: IXMLNode; Parent: TWinControl): TFrameDelayInfo;
  end;

implementation

{$R *.dfm}

{ TFrameDelayInfo }

var nameNo: Integer = 1;
class function TFrameDelayInfo.GetNew(Adr: Integer; Dev: IXMLNode; Parent: TWinControl): TFrameDelayInfo;
begin
  Result := Create(Parent);
  Result.Name := 'FrameDelayInfo'+nameNo.ToString;
  Inc(nameNo);
  Result.Adr := Adr;
  Result.Dev := Dev;
  Result.lbAdr.Caption := Adr.ToString;
//  if not Assigned(Dev) then
  Result.UpdateInit;
  Result.Parent := Parent;
  Result.Show;
end;

function TFrameDelayInfo.kadr: string;
begin
  if not Assigned(FKadr) then FKadr := Dev.ChildNodes.FindNode(T_WRK).ChildNodes.FindNode('�����').ChildNodes.FindNode(T_CLC);
  Result := FKadr.Attributes[AT_VALUE];
end;

function TFrameDelayInfo.Nstat: string;
begin
  if not Assigned(FNst) then FNst := Dev.ChildNodes.FindNode(T_WRK).ChildNodes.FindNode('�������').ChildNodes.FindNode(T_DEV);
  Result := FNst.Attributes[AT_VALUE];
end;

function TFrameDelayInfo.stat: string;
begin
  if not Assigned(FSt) then FSt := Dev.ChildNodes.FindNode(T_WRK).ChildNodes.FindNode('�������').ChildNodes.FindNode(T_CLC);
  Result := FSt.Attributes[AT_VALUE];
end;

function TFrameDelayInfo.statColor: TColor;
 var
  bstat: Byte;
begin
  Result := clCream;
  if Assigned(FNst) then
   begin
     bstat := FNst.Attributes[AT_VALUE] and $3F;
     case bstat of
      1: Result := RGB(255,128,100);
      2: Result := RGB(128,255,128);
      3: Result := RGB(255,255,128);
      4: Result := RGB(255,196,196);
     end;
   end;
end;

procedure TFrameDelayInfo.UpdateData;
begin
  LastUpdate := Now;
  if Assigned(Dev) then
   begin
    lbKadr.Color := clCream;
    lbCon.Color := clCream;
    lbKadr.Caption := kadr;
    lbStatus.Caption := stat;
    lbNStat.Caption := Nstat;
    lbStatus.Color := statColor;
    lbNStat.Color := statColor;
   end
end;

procedure TFrameDelayInfo.UpdateInit;
begin
  if Assigned(Dev) then
   begin
    lbCon.Caption := Dev.NodeName;
    lbKadr.Caption := kadr;
    lbStatus.Caption := stat;
    lbNStat.Caption := Nstat;
    lbStatus.Color := statColor;
    lbNStat.Color := statColor;
   end
  else
   begin
    lbCon.Caption := 'noinit';
   end;
end;

procedure TFrameDelayInfo.UpdateTimout;
begin
  lbCon.Color := clRed;
  if Assigned(Dev) then
   begin
    lbKadr.Caption := '��� ������';
    lbKadr.Color := clRed;
    lbStatus.Caption := '��� ������';
    lbStatus.Color := clRed;
    lbNStat.Caption := '';
    lbNStat.Color := clRed;
   end
  else
   begin
    lbCon.Caption := 'noinit';
   end;
end;

end.
