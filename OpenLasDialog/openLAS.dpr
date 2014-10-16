program openLAS;

uses
  Vcl.Forms,
  DialogOpenLas in 'DialogOpenLas.pas' {DlgOpenLAS};

{$R *.res}
  var
   s: string;
   sel: TArray<string>;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDlgOpenLAS, DlgOpenLAS);
  TDlgOpenLAS.Execute(s, sel);
  //Application.Run;
end.
