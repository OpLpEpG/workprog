program h2meta;

{$APPTYPE CONSOLE}

{$R *.res}

{$DEFINE UNUSE_debug_except}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Types,
  MetaData in 'MetaData.pas';


function FileMayBeUTF8(const FileName: string): Boolean;
var
 Stream: TMemoryStream;
 BytesRead: integer;
 ArrayBuff: array[0..127] of byte;
 PreviousByte: byte;
 i: integer;
 YesSequences, NoSequences: integer;

begin
   YesSequences := 0;
   NoSequences := 0;
   Stream := TMemoryStream.Create;
   try
     Stream.LoadFromFile(FileName);
     repeat

     {read from the TMemoryStream}

       BytesRead := Stream.Read(ArrayBuff, High(ArrayBuff) + 1);
           {Do the work on the bytes in the buffer}
       if BytesRead > 1 then
         begin
           for i := 1 to BytesRead-1 do
             begin
               PreviousByte := ArrayBuff[i-1];
               if ((ArrayBuff[i] and $c0) = $80) then
                 begin
                   if ((PreviousByte and $c0) = $c0) then
                     begin
                       inc(YesSequences)
                     end
                   else
                     begin
                       if ((PreviousByte and $80) = $0) then
                         inc(NoSequences);
                     end;
                 end;
             end;
         end;
     until (BytesRead < (High(ArrayBuff) + 1));
//Below, >= makes ASCII files = UTF-8, which is no problem.
//Simple > would catch only UTF-8;
     Result := (YesSequences >= NoSequences);

   finally
     Stream.Free;
   end;
end;


const
 PREAMB1 = '#pragma once';
 EMPTY = '';
// PREAMB3 = 'extern uint8_t ReadMetaData(uint8_t* p, uint8_t n, uint16_t from);';

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
     if FileMayBeUTF8(ParamStr(1)) then
        ss.LoadFromFile(ParamStr(1), TEncoding.UTF8)
     else
        ss.LoadFromFile(ParamStr(1));//, TEncoding.ANSI);

//     BinFile := TPath.ChangeExtension(ParamStr(1), 'Bin');
//     if TFile.Exists(BinFile) then TFile.Delete(BinFile);
//     TFile.WriteAllBytes(BinFile, TMetaData.Generate(ss));
     a := TMetaData.Generate(ss);
     outStr := outStr + [PREAMB1, EMPTY, EMPTY,{ PREAMB3,} EMPTY, EMPTY, PREAMB2];
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
     Writeln('MetaData созданы : ', ParamStr(2));
    finally
     ss.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
