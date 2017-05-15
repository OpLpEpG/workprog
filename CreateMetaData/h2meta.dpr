program h2meta;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Types,
  MetaData in 'MetaData.pas';

const
 PREAMB1 = '#pragma once';
 EMPTY = '';
 PREAMB3 = 'extern uint8_t ReadMetaData(uint8_t* p, uint8_t n, uint16_t from);';

 PREAMB2 = 'const unsigned char __attribute__ ((section(".meta_data"), used)) cmetaAll[] = {';
 var
  ss: TStrings;
  outStr: TStringDynArray;
  s: string;
  i,n: Integer;
  //BinFile: string;
  a: TBytes;
begin
  try
    ss := TStringList.Create;
    try
     ss.LoadFromFile(ParamStr(1));
//     BinFile := TPath.ChangeExtension(ParamStr(1), 'Bin');
//     if TFile.Exists(BinFile) then TFile.Delete(BinFile);
//     TFile.WriteAllBytes(BinFile, TMetaData.Generate(ss));
     a := TMetaData.Generate(ss);
     outStr := outStr + [PREAMB1, EMPTY, EMPTY, PREAMB3, EMPTY, EMPTY, PREAMB2];
     n := 0;
     while n < Length(a) do
      begin
       s := '';
       for I := 0 to 80 do
        begin
         s := s + a[n].ToString;
         inc(n);
         if n = Length(a) then
          begin
           s := s + '}; ';
           Break;
          end
         else s := s + ',';
         if Length(s) > 80 then Break;         
        end;
       outStr := outStr + [s];
      end;
     outStr := outStr + [EMPTY,EMPTY];
     TFile.WriteAllLines(ParamStr(2), outStr, TEncoding.ANSI);
    finally
     ss.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
