program ToGL;

uses
  Vcl.Forms,
  ToGLMainForm in 'ToGLMainForm.pas' {FormMain},
  TxtParser in 'TxtParser.pas',
  RLDataSet in 'RLDataSet.pas',
  TimeDepthTxtDataSet in 'TimeDepthTxtDataSet.pas',
  MathIntf in '..\MathIntf.pas',
  Filters in 'Filters.pas',
  LAS in '..\LAS.pas',
  LasImpl in '..\Core\LasImpl.pas',
  dtglDataSet in 'dtglDataSet.pas',
  DateTimeLasDataSet in 'DateTimeLasDataSet.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
