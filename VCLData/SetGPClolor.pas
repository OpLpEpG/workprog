unit SetGPClolor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, IGDIPlus,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, JvExControls, JvInspector, JvComponentBase;

type
  TFormSetGPColor = class(TForm)
    R: TScrollBar;
    G: TScrollBar;
    B: TScrollBar;
    A: TScrollBar;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    procedure RChange(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseEnter(Sender: TObject);
  private
   FRes: Tproc<TGPColor>;
  public
   class procedure Execute(ALeftTop: TPoint; c: TGPColor; func: Tproc<TGPColor>);
  end;


implementation

{$R *.dfm}

{ TInspGPColorItem }

type
  TInspGPColorItem = class(TJvCustomInspectorItem)
  protected
  public
    constructor Create(const AParent: TJvCustomInspectorItem; const AData: TJvCustomInspectorData); override;
    procedure DrawValue(const ACanvas: TCanvas); override;
    procedure Edit; override;
    procedure InitEdit; override;
    procedure DoneEdit(const CancelEdits: Boolean = False); override;
  end;


constructor TInspGPColorItem.Create(const AParent: TJvCustomInspectorItem; const AData: TJvCustomInspectorData);
begin
  inherited;
  Flags := Flags  + [iifEditButton];
end;

procedure TInspGPColorItem.DrawValue(const ACanvas: TCanvas);
 var
  g: IGPGraphics;
  c: TGPColor;
begin
  if not Data.HasValue then Exit;
  G := TGPGraphics.Create(ACanvas);
  c := Data.AsOrdinal;
  G.FillRectangle(TGPSolidBrush.Create(c), MakeRect(Rects[iprValueArea]));
  if  Editing then DrawEditor(ACanvas);
end;

procedure TInspGPColorItem.Edit;
begin
  TFormSetGPColor.execute(Tcontrol(Inspector.Owner).ClientToScreen(Rects[iprEditButton].TopLeft), Data.AsOrdinal,
  procedure (c: TGPColor)
  begin
    Data.AsOrdinal := c;
  end);
end;

procedure TInspGPColorItem.DoneEdit(const CancelEdits: Boolean);
begin
  SetEditing(False);
end;

procedure TInspGPColorItem.InitEdit;
begin
  SetEditing(CanEdit);
end;

{ TFormSetGPColor }

class procedure TFormSetGPColor.Execute(ALeftTop: TPoint;c: TGPColor; func: Tproc<TGPColor>);
begin
  with TFormSetGPColor.Create(nil) do
   begin
    Left := ALeftTop.X;
    Top := ALeftTop.Y;
    R.Position := GetRed(c);
    G.Position := GetGreen(c);
    B.Position := GetBlue(c);
    A.Position := GetAlpha(c);
    FRes := func;
    Show;
    SetFocus;
   end;
end;

procedure TFormSetGPColor.FormMouseEnter(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

procedure TFormSetGPColor.FormMouseLeave(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TFormSetGPColor.RChange(Sender: TObject);
begin
  if Assigned(FRes) then FRes(MakeColor(a.Position, R.Position, G.Position, B.Position));
end;

procedure TFormSetGPColor.Timer1Timer(Sender: TObject);
begin
  Free;
end;

initialization
  TJvCustomInspectorData.ItemRegister.Add(TJvInspectorTypeInfoRegItem.Create(TInspGPColorItem,TypeInfo(TGPColor)));
end.
