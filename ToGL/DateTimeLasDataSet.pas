unit DateTimeLasDataSet;

interface

uses dtglDataSet,  LAS, LasImpl,
  System.IOUtils,  System.Generics.Collections, Data.DB, Math,  Datasnap.DBClient, RLDataSet, System.DateUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls;

type
 TdtLasDataSet = class(TdtglDataSet)
 protected
    FDTMnem, FTMnem, FDptMnem: string;
    function Index(const mnem: string; las: ILasDoc): Integer;
   procedure InternalOpen;  override;
 public
   constructor Create(AOwner: TComponent; const fName,DTMnem,TMnem,DptMnem: string; ClearTmp: Boolean); reintroduce;
 end;
 TdatattimeTxtLasDataSet = class(TdtLasDataSet)
 protected
   procedure InternalOpen;  override;
 end;
 TDptTimeZaboiSecTime = class(TdtLasDataSet)
 protected
   procedure InternalOpen;  override;
 public
   AddingDays: Integer;
 end;

implementation

{ TTimeDepthTxtDataSet }

constructor TdtLasDataSet.Create(AOwner: TComponent; const fName,DTMnem,TMnem,DptMnem: string; ClearTmp: Boolean);
begin
  inherited Create(AOwner, fName, ClearTmp);
  FTMnem := TMnem;
  FDTMnem := DTMnem;
  FDptMnem := DptMnem;
end;

  function TdtLasDataSet.Index(const mnem: string; las: ILasDoc): Integer;
  begin
    for var I := 0 to Length(las.Curve.Mnems)-1 do
        if mnem = las.Curve.Mnems[i] then Exit(i);
    raise Exception.CreateFmt('мнемоника %s ненайдена',[mnem]);
  end;

procedure TdtLasDataSet.InternalOpen;
 var
  las: ILasDoc;
  Str: TStream;
  idxT,idxG: Integer;
  datetime: TDateTime;
begin
  if not TFile.Exists(BinFile) then
   begin
    las := NewLasDoc();
    las.LoadFromFile(FileName);
    idxT := Index(FDTMnem, las);
    idxG :=  Index(FDptMnem, las);
      // check true data
      for var i: Integer := 0 to 10 do
       begin
        var rd :TfileRecData;
        rd.datetime := las.Data.Items[i,idxT];
        rd.depth := las.Data.Items[i,idxG];
       end;
      try
        Str := TFileStream.Create(BinFile, fmCreate);
        datetime := 0;
        for var i: Integer := 0 to Length(las.Data.Items)-1 do
         begin
          var rd :TfileRecData;
          rd.datetime := las.Data.Items[i,idxT];
          if datetime >= rd.datetime then Continue;
          datetime := rd.datetime;
          rd.depth := las.Data.Items[i,idxG];
          Str.Write(rd, SizeOf(rd));
         end;
      finally
        Str.Free;
      end;
   end;
  inherited;
end;

{ TdatattimeTxtLasDataSet }

procedure TdatattimeTxtLasDataSet.InternalOpen;
 var
  las: ILasDoc;
  Str: TStream;
  idxD,idxT,idxG: Integer;
  datetime: TDateTime;
begin
  if not TFile.Exists(BinFile) then
   begin
    las := NewLasDoc();
    las.LoadFromFile(FileName);
    idxT := Index(FTMnem, las);
    idxD := Index(FDTMnem, las);
    idxG :=  Index(FDptMnem, las);
      // check true data
      for var i: Integer := 0 to 10 do
       begin
        var rd :TfileRecData;
        rd.datetime := StrToDateTime(las.Data.Items[i,idxD] + ' '+ las.Data.Items[i,idxT]);
        rd.depth := las.Data.Items[i,idxG];
       end;
      try
        Str := TFileStream.Create(BinFile, fmCreate);
        datetime := 0;
        for var i: Integer := 0 to Length(las.Data.Items)-1 do
         begin
          var rd :TfileRecData;
          rd.datetime := StrToDateTime(las.Data.Items[i,idxD] + ' '+ las.Data.Items[i,idxT]);
          if datetime >= rd.datetime then Continue;
          datetime := rd.datetime;
          rd.depth := las.Data.Items[i,idxG];
          Str.Write(rd, SizeOf(rd));
         end;
      finally
        Str.Free;
      end;
   end;
  inherited;
end;

{ TDptTimeZaboiSecTime }

procedure TDptTimeZaboiSecTime.InternalOpen;
 var
  las: ILasDoc;
  Str: TStream;
  idxT,idxG: Integer;
  datetime: TDateTime;
  sdt, sd: string;
begin
  if not TFile.Exists(BinFile) then
   begin
    las := NewLasDoc();
    las.LoadFromFile(FileName);
    idxT := Index(FDTMnem, las);
    idxG :=  Index(FDptMnem, las);

   // nul := las.Well.Items['NULL'].Data;

      // check true data
      for var i: Integer := 0 to 10 do
       begin
        var rd :TfileRecData;
        rd.datetime := las.Data.Items[i,idxT]/24/3600 + AddingDays;
        rd.depth := las.Data.Items[i,idxG];
       end;
      try
        Str := TFileStream.Create(BinFile, fmCreate);
        datetime := 0;
        for var i: Integer := 0 to Length(las.Data.Items)-1 do
         try
          var rd :TfileRecData;

          sdt := las.Data.Items[i,idxT];
          if VarIsNull(las.Data.Items[i,idxG]) then
          begin
            Continue;
          end;
          sd := las.Data.Items[i,idxG];
          rd.datetime := StrToFloat(sdt)/24/3600 + AddingDays;
          if datetime >= rd.datetime then Continue;
          datetime := rd.datetime;
          rd.depth := StrToFloat(sd);// las.Data.Items[i,idxG];
          Str.Write(rd, SizeOf(rd));
          except
            MessageDlg(Format('Ошибка Index %d DT:[%s] Dept:[%s] ',[i, sdt, sd]), mtError, [mbOk], 0);
          end;
      finally
        Str.Free;
      end;
   end;
  inherited;
end;

end.
