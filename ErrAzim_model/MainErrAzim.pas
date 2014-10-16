unit MainErrAzim;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, XMLScript.Math, Math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, Vcl.StdCtrls,
  Vcl.ComCtrls;

type
  TFrmErrAzi = class(TForm)
    cht: TChart;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    sb: TStatusBar;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series3: TLineSeries;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Series7: TLineSeries;
    Series8: TLineSeries;
    Series9: TLineSeries;
    Series10: TLineSeries;
    Series11: TLineSeries;
    Series12: TLineSeries;
    Series13: TLineSeries;
    Series14: TLineSeries;
    Series15: TLineSeries;
    Series16: TLineSeries;
    Series17: TLineSeries;
    Series18: TLineSeries;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    MaxErr, MaxErrA, MaxErrZ, MaxErrO: Double;
    procedure ClrSeries;
    function ErrAzi(Az, Zu, Ot, ex, ey, ez: Double): Double;
  public
    ZuCur: Integer;
    procedure FindAll(Zu, Da: Double);
  end;

var
  FrmErrAzi: TFrmErrAzi;

implementation

{$R *.dfm}

procedure TFrmErrAzi.Button1Click(Sender: TObject);
 var
  x, y, z, a: Double;
  i,j, cd: Integer;
begin
  ClrSeries;
  for I := 0 to 36 do
   begin
    TXMLScriptMath.GetH(90,90, i*10, X,Y,Z);
    cht.Series[0].AddXY(i, Y);
    a := ArcSin(Y/1000);
    a := -0.05*1000*Sin(3*a);
    cht.Series[17].AddXY(i, Y+a);
   end;
end;

procedure TFrmErrAzi.Button2Click(Sender: TObject);
begin
  Dec(ZuCur, 5);
  MaxErr := 0;
  FindAll(ZuCur, 0);
end;

procedure TFrmErrAzi.Button3Click(Sender: TObject);
begin
  Inc(ZuCur, 5);
  MaxErr := 0;
  FindAll(ZuCur, 0);
end;

procedure TFrmErrAzi.ClrSeries;
 var
  i: Integer;
begin
  for i := 0 to cht.SeriesCount-1 do cht.Series[i].Clear;
end;

function TFrmErrAzi.ErrAzi(Az, Zu, Ot, ex, ey, ez: Double): Double;
 var
  x, y, z, a: Double;
begin
  TXMLScriptMath.GetH(Az,Zu, Ot, X,Y,Z);
  a := ArcSin(X/1000);
  ex := -0.005*1000*Sin(3*a + DegToRad(ex));
  a := ArcSin(Y/1000);
  ey := -0.005*1000*Sin(3*a + DegToRad(ey));
  a := ArcSin(Z/1000);
  ez := -0.005*1000*Sin(3*a + DegToRad(ez));
  Result := DegNormalize(TXMLScriptMath.GetAzi(Zu, Ot, X+Ex,Y+Ey,Z+Ez) - Az);
  if Result > 180  then Result := Result - 360;
  if Abs(MaxErr) < Abs(Result) then
   begin
    MaxErr := Result;
    MaxErrA := Az;
    MaxErrZ := Zu;
    MaxErrO := Ot;
    sb.Panels[0].Text := 'E: '+ MaxErr.ToString;
    sb.Panels[1].Text := 'A: '+ MaxErrA.ToString;
    sb.Panels[2].Text := 'Z: '+ MaxErrZ.ToString;
    sb.Panels[3].Text := 'O: '+ MaxErrO.ToString;
   end;
end;

procedure TFrmErrAzi.FindAll(Zu, Da: Double);
 const
  D_O = 72;// 51;
  D_A = 3;
 var
  i,j: Integer;
  o: Double;
begin
  ClrSeries;
  Caption := Zu.ToString;
  for j := 0 to cht.SeriesCount div D_A -1 do
   for I := 0 to 360 div D_o -1 do
   begin
    o := i*D_o ;//- D_o/cht.SeriesCount*D_A*j;
    cht.Series[j*D_A].AddXY(o, ErrAzi(20*j*D_A + Da, Zu, o, 0, 0, 0))
   end;
end;

procedure TFrmErrAzi.FormCreate(Sender: TObject);
 var
  ex, ey, ez, o: Double;
  i,j, cd: Integer;
begin
  ez := 10;
  for j := 0 to 90 do
   begin
    ex := 0;
    for I := 0 to 4 do
     begin
      ey := Sin(2*pi*4*i/5-pi*j/90);
      if Abs(ex) < Abs(ey) then ex := ey;
     end;
    if Abs(ez) > abs(ex) then
     begin
      ez :=ex;
      cd :=j;
     end;
   end;
  Caption := ez.ToString();
  cd := 250 div cht.SeriesCount;
  for i := 0 to cht.SeriesCount-1 do cht.Series[i].Color := RGB(cd * i, 250 - cd*i, 0);
  MaxErr := 0;
//  FindAll(19.3);
//  for i := 1 to 120 do FindAll(i, 90);
  FindAll(30, 0);
  FindAll(60, 0);
  FindAll(90, 0);
//
//  FindAll(45, 0);
//  FindAll(90, 0);
end;

end.
