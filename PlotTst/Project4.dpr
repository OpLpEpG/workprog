program Project4;

uses
  Vcl.Forms,
  Unit4 in 'Unit4.pas' {Form4},
  CustomPlot in '..\Core\CustomPlot.pas',
  DlgEditParam in 'DlgEditParam.pas' {FormEditParam},
  SetGPClolor in '..\VCLData\SetGPClolor.pas' {FormSetGPColor},
  Unit1 in 'Unit1.pas' {Form1},
  FileCachImpl in '..\Core\FileCachImpl.pas',
  Plot.DataSet in '..\Core\Plot.DataSet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
