unit SucopAdapter;

interface

uses RootImpl, debug_except,
     Classes, SysUtils, math, windows, IniFiles, ShellAPI, Messages, DateUtils, forms;
//10 70 0 1 0 2 3 4 5 6 7 8 100 0.5 0.005 0.3 10 5 7 0 0

type
  TOnNewCorrData = reference to procedure(Data: TArray<Variant>);

  ISucopAdapter = interface
  ['{75BEBAC4-A606-425D-BBA0-D74DE3D20DB8}']
    /// преобразование в SUCOP
    procedure Add(Data: TArray<Variant>);
    procedure SaveToFile(const AFileName: String);
    procedure Reset;
    /// импортирование из SUCOP
    procedure ImportCorrData(const AFileName: String; event: TOnNewCorrData);
  end;

  Tsur = class(TIObject, ISucopAdapter)
   const
      LHS = 21;
      DEF_HEADER_SUR: array [0..LHS-1] of string =
      (' 10',' 70',' 0',' 1',' 0',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 100',' 0.5',
      ' 0.005',' 0.3',' 10',' 5',' 583',' 0',' 0');
      BEGIN_TBL = 'Summary of corrected data';
      TBL_INDEX: array [0..6] of integer = (1, 2,3,4, 6,7,8);
   var
    FlagReady: Boolean;
    Fstrings: TStrings;
    FkoefH, FkoefG: Double;
    constructor Create(H, Dip, koefG, koefH: Double);
    destructor Destroy; override;

    procedure Add(Data: TArray<Variant>);
    procedure SaveToFile(const AFileName: String);
    procedure Reset;

    procedure ImportCorrData(const AFileName: String; event: TOnNewCorrData);
  end;

implementation

{ Tsur }

constructor Tsur.Create(H, Dip, koefG, koefH: Double);
var
  i: integer;
  s: string;
begin
  FkoefH := koefH;
  FkoefG := koefG;
  Fstrings := TStringList.Create;
  s := Format('%1.3f', [H*koefH]);
  s := s + Format(' %1.3f', [dip]);
  for i := 2 to LHS - 1 do s := s + DEF_HEADER_SUR[i];
  Fstrings.Add(S);
end;

destructor Tsur.Destroy;
begin
  Fstrings.Free;
  inherited;
end;

procedure Tsur.ImportCorrData(const AFileName: String; event: TOnNewCorrData);
 var
  ss: TStrings;
  i,j: Integer;
  a: TArray<string>;
  v: TArray<Variant>;
begin
  ss := TStringList.Create;
  try
   ss.LoadFromFile(AFileName);
   i := 0;
   SetLength(v, 7);
   repeat
    while (i < ss.Count) and (ss[i].Trim <> BEGIN_TBL) do Inc(i);
    Inc(i, 4);
    while i < ss.Count do
     begin
      a := ss[i].Trim.Split([' '], ExcludeEmpty);
      if Length(a) < 9 then Break;
      for j := 0 to High(TBL_INDEX) do v[j] := a[TBL_INDEX[j]];
      event(v);
      Inc(i);
     end;
   until i >= ss.Count;
  finally
   ss.Free;
  end;
end;

procedure Tsur.Reset;
 var
  s: string;
begin
  s := Fstrings[0];
  Fstrings.Clear;
  Fstrings.Add(S);
end;

procedure Tsur.SaveToFile(const AFileName: String);
begin
  Fstrings.SaveToFile(AFileName);
end;

procedure Tsur.Add(Data: TArray<Variant>);
begin
  Fstrings.Add(Format(' %1.2f  %1.5f %1.5f  %1.5f %1.5f  %1.5f %1.5f',
  [Double(Data[0]), Double(Data[1])*FkoefG, Double(Data[2])*FkoefG,
   Double(Data[3])*FkoefG, Double(Data[4])*FkoefH,
   Double(Data[5])*FkoefH, Double(Data[6])*FkoefH]));
end;

end.
