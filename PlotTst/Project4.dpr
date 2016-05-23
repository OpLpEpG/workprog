program Project4;

uses
  Vcl.Forms,
  Unit4 in 'Unit4.pas' {Form4},
  CustomPlot in '..\Core\CustomPlot.pas',
  DlgEditParam in 'DlgEditParam.pas' {FormEditParam},
  SetGPClolor in '..\VCLData\SetGPClolor.pas' {FormSetGPColor},
  Unit1 in 'Unit1.pas' {Form1},
  FileCachImpl in '..\Core\FileCachImpl.pas',
  Plot.DataSet in '..\Core\Plot.DataSet.pas',
  Plot.Controls in '..\Core\Plot.Controls.pas',
  JDtools in '..\Core\JDtools.pas',
  VCLOpenDialog in '..\Core\VCLOpenDialog.pas',
  IDataSets in '..\Core\IDataSets.pas',
  LasDataSet in '..\Core\LasDataSet.pas',
  manager3.DataImport in '..\ProjectManager\manager3.DataImport.pas',
  XMLDataSet in '..\Core\XMLDataSet.pas',
  XMLScript.Math in '..\Core\XMLScript.Math.pas',
  FileDataSet in '..\Core\FileDataSet.pas',
  VCL.Dlg.OpenLas in '..\VCLDialogs\VCL.Dlg.OpenLas.pas' {DlgOpenLASDataSet},
  LAS in '..\LAS.pas',
  VCL.Dlg.OpenP3XML in '..\VCLDialogs\VCL.Dlg.OpenP3XML.pas' {DlgOpenP3DataSet},
  VCL.Frame.SelectParam in '..\VCLDialogs\VCL.Frame.SelectParam.pas' {FrameSelectParam: TFrame},
  VCL.Frame.SelectPath in '..\VCLDialogs\VCL.Frame.SelectPath.pas' {FrameSelectPath: TFrame},
  Plot.DataLink in '..\Core\Plot.DataLink.pas',
  Plot.GR32 in '..\Core\Plot.GR32.pas',
  VCL.JDType.Form in '..\VCLDialogs\VCL.JDType.Form.pas',
  VCL.JDType.TGamma in '..\VCLDialogs\VCL.JDType.TGamma.pas' {JDTypeFormGamma},
  JvInspector in '..\..\..\Libs\jvcl\jvcl\run\JvInspector.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
