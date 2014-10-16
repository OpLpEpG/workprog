unit GraphMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Plot, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, intf;

type
  TForm1 = class(TForm)
    Button1: TButton;
    pp: TPopupActionBar;
    q1: TMenuItem;
    rwer1: TMenuItem;
    fwe1: TMenuItem;
    Button2: TButton;
    Plot1: TPlot;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Plot1ScaleChanged(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
   procedure OnCurve(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
   procedure OnColumn(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
   procedure OnPlot(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
 public
   { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses IGDIPlus;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Plot1.ShowLegend := not Plot1.ShowLegend;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Plot1.Columns.Add<TGraphColumn>;
  Plot1.Repaint;
end;

procedure TForm1.FormCreate(Sender: TObject);
 var
  c: TGraphColumn;
  p: TGraphParam;
  t: TYColumn;
  i: Integer;
  procedure ADDD;
  begin
    c.OnContextPopup := OnColumn;
    C.Width := 100;
    p := TGraphParam(c.Params.Add);
    p.OnContextPopup := OnCurve;
    p.Title := 'Отклонитель1';
    p.EUnit := 'град.';
    p.Scale := 0.005;
    p := TGraphParam(c.Params.Add);
    p.OnContextPopup := OnCurve;
    p.Title := 'Зент';
    p.EUnit := 'град.';
    p.Color := aclRed;
    p.Scale := 0.015;
    p := TGraphParam(c.Params.Add);
    p.OnContextPopup := OnCurve;
    p.Title := 'Азимут';
    p.EUnit := 'град.';
    p.Color := aclDarkCyan;
    p := TGraphParam(c.Params.Add);
    p.OnContextPopup := OnCurve;
    p.Title := 'Отклонитель5';
    p.EUnit := 'град.';
    p.Color := aclChocolate;
    p := TGraphParam(c.Params.Add);
    p.OnContextPopup := OnCurve;
    p.Title := 'Отклонитель4';
    p.EUnit := 'град.';
    p.Color := $808A2BE2;
    p.Width := 8;
    p.Delta := -100;
    p.Scale := 0.02;
//    p.DashStyle := DashStyleDashDotDot;
  end;
begin
  Plot1.OnContextPopup := OnPlot;
  Plot1.Popupmenu := pp;
  t := Plot1.Columns.Add<TYColumn>;
  t.OnContextPopup := OnColumn;
  t.Width := 40;
//  t.Title := 'Глубина (метры)';
//  t := Plot1.Columns.Add<TStringColumn>;
//  t.Width := 40;
//  t.Title := 'Время (дд.ММ.ГГ чч:мм:сс)';
  c := Plot1.Columns.Add<TGraphColumn>;
  ADDD;
  c := Plot1.Columns.Add<TGraphColumn>;
  ADDD;
  c := Plot1.Columns.Add<TGraphColumn>;
  ADDD;
    p := TGraphParam(c.Params.Add);
    p.OnContextPopup := OnCurve;
    for i := 0 to Length(p.Points)-1 do with p.Points[i] do X := 995 + Random(10);
    p.Title := 'Амплитуда G';
    p.EUnit := 'mG';
    p.Color := aclIndigo;
    p.DashStyle := DashStyleDot;
    p.Width := 2;
    p.Delta := 970;
    p.Scale := 0.5;
end;

procedure TForm1.OnCurve(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  pp.Items[0].Caption := TGraphParam(Sender).Title;
end;

procedure TForm1.OnColumn(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  pp.Items[1].Caption :=  TPlotColumn(Sender).ClassName;
end;

procedure TForm1.OnPlot(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  pp.Items[2].Caption := TPlot(Sender).TitleY;
end;

procedure TForm1.Plot1ScaleChanged(Sender: TObject);
begin
  Caption := floattostr(Plot1.ScaleY);
end;

initialization
  StartIGDIPlus;
finalization
  StopIGDIPlus;
end.
