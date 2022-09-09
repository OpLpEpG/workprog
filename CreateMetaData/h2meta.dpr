program h2meta;

{$APPTYPE CONSOLE}

{$R *.res}

{$DEFINE UNUSE_debug_except}

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Types,
  MetaData in 'MetaData.pas',
  MetaData2.CParser in 'MetaData2.CParser.pas',
  MetaData2.Classes in 'MetaData2.Classes.pas',
  MetaData2.BParser in 'MetaData2.BParser.pas';

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
     Result := (YesSequences > NoSequences);

   finally
     Stream.Free;
   end;
end;


const
 PREAMB1 = '#pragma once';
 EMPTY = '';
 PREAMB2 = 'const unsigned char __attribute__ ((section(".meta_data"), used)) cmetaAll[] = {';
 AMB1 = '}; ';
 var
  ss: TStrings;
  outStr: TStringDynArray;
  a: TBytes;
  function BytesToStringArray(const a: TBytes): string;
   var
    s: string;
    i,n: Integer;
  begin
    n := 0;
    Result := '';
    while n < Length(a) do
    begin
     s := '';
     for I := 0 to 80 do
      begin
       s := s + a[n].ToString;
       inc(n);
       if n = Length(a) then exit(Result + s)
       else s := s + ',';
       if Length(s) > 80 then break;
      end;
     Result := Result + s + #$D#$A;
    end;
  end;
begin
  try
    ss := TStringList.Create;
    try
     if FileMayBeUTF8(ParamStr(1)) then
       try
        ss.LoadFromFile(ParamStr(1), TEncoding.UTF8)
       except
        on E: Exception do
         begin
           Writeln(E.ClassName, ': ', E.Message);
           ss.LoadFromFile(ParamStr(1));
         end;
       end
     else ss.LoadFromFile(ParamStr(1));

     TheaderFileParser.Parse(ss);
     a := TheaderFileParser.GetMetaData;
     TFile.WriteAllBytes(ParamStr(2), a);

     TBinaryToXMLParser.Parse(a);
     TBinaryToXMLParser.AssignAndExpandArrayStructData;
    // TBinaryToXMLParser.ExpandStructData;
     exit;

//     a := TMetaData.Generate(ss);

     if ParamCount = 2 then
      begin
       outStr := outStr + [PREAMB1, EMPTY, EMPTY,{ PREAMB3,} EMPTY, EMPTY, PREAMB2];
       outStr := outStr + [BytesToStringArray(a), AMB1, EMPTY,EMPTY];
       TFile.WriteAllLines(ParamStr(2), outStr, TEncoding.ANSI);
      end
     else
      begin
       TFile.WriteAllText(ParamStr(2), Format(TFile.ReadAllText(ParamStr(3)), [BytesToStringArray(a)]), TEncoding.ANSI);
      end;

     Writeln('MetaData created : ', ParamStr(2));
    finally
     ss.Free;
    end;
  except
    on E: Exception do
      begin
       Writeln(E.ClassName, ': ', E.Message);
       raise;
      end;
  end;
end.
