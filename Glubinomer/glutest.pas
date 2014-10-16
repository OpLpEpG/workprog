unit glutest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine, Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, Vcl.StdCtrls;

type
  TFormTG = class(TForm)
    Chart: TChart;
    Series: TFastLineSeries;
    Se: TButton;
    SeriesP: TFastLineSeries;
    cm: TMemo;
    Le: TButton;
    Series1: TFastLineSeries;
    SeriesP1: TFastLineSeries;
    BtL: TButton;
    Button1: TButton;
    procedure SeClick(Sender: TObject);
    procedure LeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
   const
    L_ERR = 0;//sm
    S_ERR = 10;//cm
    K_ERR = 0;//cm/n
    S = 100;//cm
    K = 0.018686833;//cm/n
    L_0 = 20;//sm
    H_0 = S;//45;//grad
    H_X0 = 100;
    H_X1 = 4000;
    H_MAX = 4000;

   LMIN = 1.75;
   LMAX = 40;
   var
    a, b: Double;
    function HeightToImp(h: Double): Double;
    function HeightToBadHeit(h: Double): Double;
    function HeightToGoodHeit(h: Double): Double;
    procedure FindAB;
    function FindH(L, S: Double): Double;
    function FindERR(L: Double; El: Double = 0.0; Es: Double = 0.0; S: Double = 1.0): Double;
//    function ImpToHeight(n: Double): Double;
  end;

var
  FormTG: TFormTG;

implementation

{$R *.dfm}

uses Math;

{ TFormTG }

{$REGION 'OLD'}

function TFormTG.HeightToBadHeit(h: Double): Double;
 var
  imp: Double;
begin
  imp := HeightToImp(h);
  Result := a*imp + b;
end;

function TFormTG.HeightToGoodHeit(h: Double): Double;
 var
  imp, sr, kr, lr: Double;
begin
  sr := S-S_ERR;
  kr := K+K_ERR;
  lr := L_0 + L_ERR;
  imp := HeightToImp(h);
  Result := kr*imp + lr;
  Result := Sqrt(Result*Result - sr*sr);
end;

function TFormTG.HeightToImp(h: Double): Double;
 var
  g: Double;
begin
  g := Hypot(S, h) - L_0;
  Result := g/K;
end;

procedure TFormTG.Button1Click(Sender: TObject);
const
 m11=1;
 m14=-11;
 m22=1;
 m24=-7;
 m33=1.00139470013947;
 m34=16.0223152022315;

{ m12= 0.000206660366560061;
 m13=-0.000595406728823423;

 m21=-0.0022140221402214;
 m23=-0.00212018522789773;

 m31= 0.00295806077809489;
 m32=-0.00147903038904744;}


 var
  tx, ty, tz, m12, m13, m21,m23,m31,m32: Double;
  procedure find(x, y,  z: Double);
  begin
    tx := m11*x + m12*y + m13*z + m14;
    ty := m21*x + m22*y + m23*z + m24;
    tz := m31*x + m32*y + m33*z + m34;
  end;
//  1                 -0.04083403248887  -0.125978383609669
// -0.126766803551342  1                   0.121647096520742
// -0.376121095274133  0.125236681094701  1

begin
 m12:= 0.000737463126843658;
 m13:=-0.00212469626029752;

 m21:=-0.0022140221402214;
 m23:=-0.00212018522789773;

 m31 :=  0.00629999909651385;
 m32 := -0.000854437377464678;
// m31:=  0.00369276218611521418020679468242;
// m32:=  -0.00147710487444608567208271787297;

  find(-665,6, 222);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  find(11,685, 220);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));

  find(690,9, 217);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  find(12,-671, 218);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));

  find(-667,-230, -12);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  find(-225,685, -14);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  cm.Lines.Add('   ');

 m12:= -0.04083403248887/-180*pi;
 m13:= -0.125978383609669/180*pi;

 m21:= -0.126766803551342/180*pi;
 m23:=  0.121647096520742/-180*pi;

 m31:= -0.376121095274133/-180*pi;
 m32:=  0.125236681094701/180*pi;

  cm.Lines.Add('   ');
  cm.Lines.Add(Format('xY:%-1.8f', [m12]));
  cm.Lines.Add(Format('xZ:%-1.8f', [m13]));

  cm.Lines.Add(Format('yX:%-1.8f', [m21]));
  cm.Lines.Add(Format('yZ:%-1.8f', [m23]));

  cm.Lines.Add(Format('zX:%-1.8f', [m31]));
  cm.Lines.Add(Format('zY:%-1.8f', [m32]));
  cm.Lines.Add('   ');
  find(-665,6, 222);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  find(11,685, 220);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));

  find(690,9, 217);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  find(12,-671, 218);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));

  find(-667,-230, -12);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  find(-225,685, -14);
  cm.Lines.Add(Format('X:%-8.1f Y:%-8.1f Z:%-8.1f',[tx,ty,tz]));
  cm.Lines.Add('   ');
end;

procedure TFormTG.FindAB;
 var
  y0, y1: Double;
begin
  y0 := HeightToImp(H_X0);
  y1 := HeightToImp(H_X1);
  a := (H_X1 - H_X0)/(y1-y0);
  b := H_X1 - a*y1;
end;

{$ENDREGION}

function TFormTG.FindH(L, S: Double): Double;
begin
  Result := Sqrt(1-S*S/(L*L))*L;
end;

function TFormTG.FindERR(L, El, Es, S: Double): Double;
begin
  Result := (FindH(LMAX, S) - FindH(L, S)) - (FindH(LMAX+El, S+Es) - FindH(L+El, S+Es));
end;

procedure TFormTG.SeClick(Sender: TObject);
 var
  i: Integer;
begin
//  FindAB;
  Series.Clear;
  SeriesP.Clear;
  Series1.Clear;
  SeriesP1.Clear;
  for i := 0 to LMAX do
   begin
    Series.AddXY(i+LMIN, FindERR(i+LMIN, 0, 0.20)*100);
    SeriesP.AddXY(i+LMIN, FindERR(i+LMIN, 0, -0.20)*100);
    Series1.AddXY(i+LMIN, FindERR(i+LMIN, 0, 0.10)*100);
    SeriesP1.AddXY(i+LMIN, FindERR(i+LMIN, 0, -0.10)*100);
//    SeriesP.AddXY(i, i-HeightToGoodHeit(i));
   end;
end;

procedure TFormTG.LeClick(Sender: TObject);
 var
  i: Integer;
  Es: Double;
begin
//  FindAB;
  Series.Clear;
  SeriesP.Clear;
  Series1.Clear;
  SeriesP1.Clear;
  for i := -10 to 10 do
   begin
    Es := i*0.05;
    Series.AddXY(Es*100, FindERR(LMIN, 0.0, Es)*100);
    Series1.AddXY(Es*100, FindERR(LMIN+1, 0.0, Es)*100);
    SeriesP.AddXY(Es*100, FindERR(LMIN+2, 0.0, Es)*100);
    SeriesP1.AddXY(Es*100, FindERR(LMIN+3, 0.0, Es)*100);
   end;
end;

end.
