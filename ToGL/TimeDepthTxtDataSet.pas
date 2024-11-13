unit TimeDepthTxtDataSet;

interface

uses dtglDataSet,
  System.IOUtils,  System.Generics.Collections, Data.DB, Math,  Datasnap.DBClient, RLDataSet, System.DateUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls;

type
 TTimeDepthTxtDataSet = class(TdtglDataSet)
 private
  type
   EDtType = (etDelphi,etString,etUnix);
  var
   FSeparator: Char;
   FdtFormat: TFormatSettings;
   function Str2DT(const sdt:string):TdateTime;
   function FindTypeStringDatetype(const dt: string): EDtType;
   function ToDt(const dt:string; t:EDtType):TDateTime;
 protected
   procedure InternalOpen;  override;
 public
   constructor Create(AOwner: TComponent; const fName: string; Separator: Char; const DTFormat: string; ClearTmp: Boolean); reintroduce;
   property Separator: Char  read FSeparator;
 end;

implementation

{ TTimeDepthTxtDataSet }

function TTimeDepthTxtDataSet.Str2DT(const sdt: string): TdateTime;
begin
//   if FdtFormat = '' then  Result := StrToDateTime(sdt)
//   else
   Result := StrToDateTime(sdt, FdtFormat);
end;


constructor TTimeDepthTxtDataSet.Create(AOwner: TComponent; const fName: string; Separator: Char; const DTFormat: string; ClearTmp: Boolean);
begin
  inherited Create(AOwner, fName, ClearTmp);
  FSeparator := Separator;
  FdtFormat:= TFormatSettings.Create;
  if DTFormat<> '' then
  begin
    var a := DTFormat.Split(['(',')'],TStringSplitOptions.ExcludeEmpty);
    FdtFormat.DateSeparator := a[0][1];
    FdtFormat.ShortDateFormat := a[1];
    FdtFormat.TimeSeparator := a[3][1];
    FdtFormat.LongTimeFormat := a[4];
  end;
end;

function TTimeDepthTxtDataSet.FindTypeStringDatetype(const dt: string): EDtType;
begin
  try
    Str2DT(dt);
    Exit(etString);
  except
    try
      var i := StrToInt64(dt);
      if i < 1600000000 then raise Exception.Create('Error Not Unix Time');
      Exit(etUnix);
    except
     var d := TDateTime(StrToFloat(dt));
     Exit(etDelphi);
    end;
  end;
end;

function TTimeDepthTxtDataSet.ToDt(const dt: string; t: EDtType): TDateTime;
begin
  case t of
    etDelphi: Exit(StrToFloat(dt));
    etString: Exit(Str2DT(dt));
    etUnix: Exit(UnixToDateTime(StrToInt64(dt),False));
  end;
end;

procedure TTimeDepthTxtDataSet.InternalOpen;
 var
  FStrings: TStrings;
  FLineFrom, idx: Integer;
  Str: TStream;
  tdt: EDtType;
  toall:Boolean;
begin
  if not TFile.Exists(BinFile) then
   begin
    FStrings := TStringList.Create;
    try
      FStrings.NameValueSeparator := FSeparator;
      FStrings.LoadFromFile(FileName);
      FLineFrom := 0;
      try
        FStrings.ValueFromIndex[0].ToDouble;
      except
        FLineFrom := 1;
      end;
      // check true data
      for var i: Integer := FLineFrom to FLineFrom+10 do
       begin
        var rd :TfileRecData;
        tdt := FindTypeStringDatetype(FStrings.Names[i]);
        rd.datetime := ToDt(FStrings.Names[i], tdt);
        rd.depth := FStrings.ValueFromIndex[i].ToDouble;
       end;
      try
        Str := TFileStream.Create(BinFile, fmCreate);
        var OldTime :TDateTime;
        for idx := FLineFrom to FStrings.Count-1 do
         begin
          var rd :TfileRecData;
          try
            rd.datetime := ToDt(FStrings.Names[idx], tdt);
            if rd.datetime <= OldTime then
             begin
               if toall then Continue;

               var r := MessageDlg(Format('Error At:%d'+#$D#$A+'old %s > then %s',[idx, DateTimeToStr(OldTime), DateTimeToStr(rd.datetime)]),mtError, [mbIgnore, mbYesToAll, mbCancel],0);
               if r = mrCancel then Exit
               else if r = mrYesToAll then toall := True;

               Continue;
             end;
            OldTime := rd.datetime;
            rd.depth := FStrings.ValueFromIndex[idx].ToDouble;
            Str.Write(rd, SizeOf(rd));
          except
           on E: Exception do
           begin
            var res := MessageDlg(Format('Error At:%d String:%s Msg: %s',[idx, FStrings[idx],  e.Message]),mtError, [mbIgnore, mbCancel],0);
            if res = mrCancel then Exit;
           end;
          end;
         end;
      finally
        Str.Free;
      end;
    finally
      FStrings.Free;
    end;
   end;
  inherited;
end;

end.
