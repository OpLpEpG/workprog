unit VCL.Vizard.Sucop;

interface

uses LAS, LasImpl, System.IOUtils, SucopAdapter,  MetrInclin.Math,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TFormSUCOPconverter = class(TForm)
    flSucop: TJvFilenameEdit;
    flLASOut: TJvFilenameEdit;
    flLASInput: TJvFilenameEdit;
    flSUCOPInput: TJvFilenameEdit;
    edAmpBUR: TEdit;
    edAmpMET: TEdit;
    edI: TEdit;
    btToSUCOP: TButton;
    btToLAS: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure btToSUCOPClick(Sender: TObject);
    procedure btToLASClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure flLASInputAfterDialog(Sender: TObject; var AName: string; var AAction: Boolean);
  private
    FHbur, FHmetr, FDip: Double;
    Flasdoc: ILasDoc;
    Fsur: ISucopAdapter;
    procedure CheckInputLAS;
    function GetIndexFileName(const RootName: string; var index: integer): string;
  public
    const INCL_MNEM: array [0..6] of string = ('DEPT','GX','GY','GZ','HX','HY','HZ');
  end;

var
  FormSUCOPconverter: TFormSUCOPconverter;

implementation

uses tools;

{$R *.dfm}

function TFormSUCOPconverter.GetIndexFileName(const RootName: string; var index: integer): string;
begin
  if index = 0 then Result := RootName
  else Result := Format('%s\%s_%d%s', [TPath.GetDirectoryName(RootName),
                                        TPath.GetFileNameWithoutExtension(RootName),
                                        index,
                                        TPath.GetExtension(RootName)]);
  inc(index);
end;



procedure TFormSUCOPconverter.btToSUCOPClick(Sender: TObject);
 var
  data: TArray<Variant>;
  kH: Double;
  i, Nfile: Integer;
begin
  FHbur := StrToFloat(edAmpBUR.Text);
  FHmetr := StrToFloat(edAmpMET.Text);
  kH := FHbur/FHmetr;
  FDip := StrToFloat(edI.Text);

  Flasdoc := NewLasDoc;
  Flasdoc.LoadFromFile(flLASInput.FileName);

  CheckInputLAS;

  Fsur := Tsur.Create(1000*kH, FDip, 1/1000, 1/100);

  Nfile := 0;
  i := 0;

  for data in Flasdoc.Data.Items do
   begin
    Fsur.Add(Data);
    Inc(i);
    if i >= 499 then
     begin
      i := 0;
      Fsur.SaveToFile(GetIndexFileName(flSucop.FileName, Nfile));
      Fsur.Reset;
     end;
   end;
  Fsur.SaveToFile(GetIndexFileName(flSucop.FileName, Nfile));
end;

procedure TFormSUCOPconverter.CheckInputLAS;
 var
  i: Integer;
  m: TArray<string>;
begin
  m := Flasdoc.Curve.Mnems;
  if Length(m) <> 7 then raise Exception.Create('Количество кривых не равно 7');
  for i := 0 to High(INCL_MNEM) do if not SameText(INCL_MNEM[i], m[i]) then raise Exception.Create('Неверная структура LAS');
end;

procedure TFormSUCOPconverter.flLASInputAfterDialog(Sender: TObject; var AName: string; var AAction: Boolean);
 var
  path, fl: string;
begin
  path := TPath.GetDirectoryName(AName);
  fl := TPath.GetFileNameWithoutExtension(AName);

  if flSucop.FileName = '' then flSucop.FileName := TPath.ChangeExtension(AName, 'SUR');
  if flSUCOPInput.FileName = '' then flSUCOPInput.FileName := TPath.ChangeExtension(AName, 'LOG');
  if flLASOut.FileName = '' then flLASOut.FileName := path +'\'+ fl + '_corr.LAS';
end;

procedure TFormSUCOPconverter.FormCreate(Sender: TObject);
begin
  FormatSettings.DecimalSeparator := '.';
  flLASInput.InitialDir := TPath.GetLibraryPath;
  flLASOut.InitialDir := TPath.GetLibraryPath;
  flSucop.InitialDir := TPath.GetLibraryPath;
  flSUCOPInput.InitialDir := TPath.GetLibraryPath;
end;

procedure TFormSUCOPconverter.btToLASClick(Sender: TObject);
 var
  s: string;
  nfile: Integer;
  a, z, o, i, h: Double;
begin
  nfile := 0;
  Flasdoc.Data.Clear;
  Flasdoc.Curve.Add(Tlasformat.Create('AZIM', 'DEG'));
  Flasdoc.Curve.Add(Tlasformat.Create('DEVI', 'DEG'));
  Flasdoc.Curve.Add(Tlasformat.Create('DIP', 'DEG'));
  Flasdoc.Curve.Add(Tlasformat.Create('HTTL', ''));

  Flasdoc.Curve.DisplayFormat['AZIM'] := '%10.1f';
  Flasdoc.Curve.DisplayFormat['DEVI'] := '%10.2f';
  Flasdoc.Curve.DisplayFormat['DIP'] := '%10.1f';
  Flasdoc.Curve.DisplayFormat['HTTL'] := '%10.1f';
  repeat
   s := GetIndexFileName(flSUCOPInput.FileName, nfile);
   if not FileExists(s) then Break;
   Fsur.ImportCorrData(s, procedure(Data: TArray<Variant>)
   begin
     Data[1] := Double(Data[1])*1000;
     Data[2] := Double(Data[2])*1000;
     Data[3] := Double(Data[3])*1000;

     Data[4] := Double(Data[4])*100;
     Data[5] := Double(Data[5])*100;
     Data[6] := Double(Data[6])*100;

     TMetrInclinMath.FindZenViz(Data[1], Data[2], Data[3], o, z);
     TMetrInclinMath.FindAzim(Data[4], Data[5], Data[6], o, z, a, i, h);

     Data := Data + [a, z, i, h];

     Flasdoc.Data.AddData(Data);
   end);
  until False;
  Flasdoc.SaveToFile(flLASOut.FileName);
end;

end.
