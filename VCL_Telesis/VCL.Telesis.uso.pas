unit VCL.Telesis.uso;

interface

uses DeviceIntf, PluginAPI, ExtendIntf, RootImpl, debug_except, DockIForm, RootIntf, Container, Actns,
  Winapi.Windows, Winapi.Messages, Math.Telesistem,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VCL.ControlRootForm,
  VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
  TUsoOscForm = class(TControlRootForm<TUsoData, ITelesistem>)
    Chart: TChart;
    Series: TFastLineSeries;
  protected
    procedure DoData; override;
  end;

  TBitOscForm = class(TUsoOscForm)
  public
   constructor CreateUser(const aName: string =''); override;
  end;

  TPalsOscForm = class(TUsoOscForm)
  public
   constructor CreateUser(const aName: string =''); override;
  end;

implementation

{$R *.dfm}

procedure TUsoOscForm.DoData;
begin
  if Series.Count>Chart.BottomAxis.Maximum-1 then Series.Clear;
  while C_Data.Size > 0 do
   begin
    Series.Add(FC_Data.Data^);
    Inc(FC_Data.Data);
    Dec(FC_Data.Size);
   end;
end;

{ TBitOscForm }

constructor TBitOscForm.CreateUser(const aName: string);
begin
  inherited;
  Series.Color := clRed;
  Series.Pen.Width := 2;
  Caption := 'Îñö.Bit';
end;

{ TPalsOscForm }

constructor TPalsOscForm.CreateUser(const aName: string);
begin
  inherited;
  Series.Color := clBlack;
  Series.Pen.Width := 2;
  Caption := 'Îñö.Pals';
end;

initialization
  RegisterClasses([TUsoOscForm, TBitOscForm, TPalsOscForm]);
  TRegister.AddType<TPalsOscForm, IForm>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TUsoOscForm, IForm>.LiveTime(ltSingletonNamed);
  TRegister.AddType<TBitOscForm, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TUsoOscForm>;
  GContainer.RemoveModel<TPalsOscForm>;
  GContainer.RemoveModel<TBitOscForm>;
end.
