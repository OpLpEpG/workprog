unit XMLLua.Report;

interface

 {$M+}

uses  XMLLua, VerySimple.Lua.Lib, tools, Container, debug_except, ExtendIntf,
      Winapi.ActiveX, Xml.XMLDoc, Xml.XMLIntf,
      SysUtils, System.UITypes, System.Generics.Collections, System.Classes, math, System.Variants;

type
  TXMLScriptReport = class
  private
    class procedure ExportToCalc(const ReportShablon, ReportXML, ReportFile: string; Data: IXMLNode); overload; static;
    class constructor Create;
    class destructor Destroy;
  published
//    class function CallMeth(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
    class function ExportToCalc(L: lua_State): Integer; overload; cdecl; static;
  end;


implementation

{ TXMLScriptReport }

//class function TXMLScriptReport.CallMeth(Instance: TObject; ClassType: TClass; const MethodName: String; var Params: Variant): Variant;
//begin
//  if SameText(MethodName, 'ExportToCalc') then ExportToCalc(Params[0],Params[1],Params[2],Params[3]);
//end;

class constructor TXMLScriptReport.Create;
begin
  TXMLLua.RegisterLuaMethods(TXMLScriptReport);
//  TXmlScriptInner.RegisterMethods([
//  'procedure ExportToCalc(const ReportShablon, ReportXML, ReportFile: string; Data: variant)'], CallMeth);
end;

class destructor TXMLScriptReport.Destroy;
begin

end;

class function TXMLScriptReport.ExportToCalc(L: lua_State): Integer;
 var
  ReportShablon, ReportXML, ReportFile: string;
  Data: IXMLNode;
begin
  ReportShablon := string(lua_tostring(L,1));
  ReportXML := string(lua_tostring(L,2));
  ReportFile := string(lua_tostring(L,3));
  Data := TXMLLua.XNode(L, 4);

  ExportToCalc(ReportShablon, ReportXML, ReportFile, Data);
  Result := 0;
end;

//только имя файла       файла и путь    %DEV%.Метрология.%modul%     //
class procedure TXMLScriptReport.ExportToCalc(const ReportShablon, ReportXML, ReportFile: string; Data: IXMLNode);
begin
  TThread.CreateAnonymousThread(procedure
   var
    v, varr: Variant;
    Xlo,Xhi, x, Ylo, Yhi, y, i: Integer;
    r: IReport;
    notes, sht, cell, ranges, n, root, metr: IXMLNode;
    Sheet, Range: Variant;
    Path: string;
    rngarr, Indarr, xyarr: TArray<string>;
    d: Double;
    s: string;
  begin
    try
      CoInitialize(nil);
      // открываем шаблон
      r := GlobalCore as IReport;
      r.OpenDocument(ExtractFilePath(ParamStr(0))+'Devices\'+ReportShablon);
      notes := LoadXMLDocument(ExtractFilePath(ParamStr(0))+'Devices\'+ReportXML).DocumentElement;
      root := Data;
      //Tdebug.Log(Root.NodeName);
      for sht in Xenum(notes) do
       begin
        // открываем sheet
        if sht.HasAttribute('SheetByIndex') then Sheet := r.Document.GetSheets.getByIndex(sht.Attributes['SheetByIndex'])
        else if sht.HasAttribute('SheetByName') then Sheet := r.Document.GetSheets.getByName(sht.Attributes['SheetByName'])
        else raise Exception.Create('Error SheetByIndex SheetByName');
        // заполняем единичные ячейки
        cell := sht.ChildNodes.FindNode('CELL');
        if Assigned(cell) then
          for n in XEnumAttr(cell) do
            try
             if TryValX(Root, n.NodeValue, v) and not VarIsNull(v) then
               begin
                if TryStrToFloat(v, d) then
                  Sheet.getCellRangeByName(n.NodeName).getCellByPosition(0,0).SetValue(d)
                else
                  Sheet.getCellRangeByName(n.NodeName).getCellByPosition(0,0).SetString(v)
               end
            else
              raise Exception.CreateFmt('Нет пути %s %s', [n.NodeName, n.NodeValue]);
            except
             on E: Exception do TDebug.DoException(E);
            end;
        // заполняем массивы ячеек СЧИТАЕМ ИХ КАК Double !!!
        ranges := sht.ChildNodes.FindNode('RANGES');
        if Assigned(ranges) then for n in XEnum(ranges) do
         begin
          // диапазон для офиса  С11 -С22
          rngarr := string(n.Attributes['Cells']).Split([' '], TStringSplitOptions.ExcludeEmpty);
          // диапазон для STEPi калибровки
          Indarr := string(n.Attributes['DataIndex']).Split([' '], TStringSplitOptions.ExcludeEmpty);
          if Length(rngarr) <> Length(Indarr) then raise Exception.Create(' Length(Cells) <> Length(DataIndex)');
          for i := 0 to Length(rngarr)-1 do
           try
            xyarr := Indarr[i].Trim.Split([':'], TStringSplitOptions.ExcludeEmpty);
            Xlo := xyarr[0].ToInteger;
            XHi := xyarr[1].ToInteger;
            Ylo := xyarr[2].ToInteger;
            YHi := xyarr[3].ToInteger;
            { TODO : check rng and X Y }
            // заполняем массив
            varr := VarArrayCreate([0, Xhi-Xlo, 0, Yhi-Ylo], varVariant);
            for x := Xlo to Xhi do
             for y := Ylo to Yhi do
              begin
               path := Format(n.Attributes['Source'], [x, y]);
               if TryValX(Root, path, v) then
                begin
                 d := v;
                 varr[x-Xlo, y-Ylo] := d;
                end
               else
                 raise Exception.CreateFmt('Нет пути %s ', [path]);
              end;
            // пишим в офис
            Range := Sheet.getCellRangeByName(rngarr[i]);
            Range.setDataArray(varr);
           except
            on E: Exception do TDebug.DoException(E);
           end;
         end;
       end;
      r.SaveAs(ReportFile);
      CoUnInitialize();
    except
     on E: Exception do TDebug.DoException(E);
    end;
  end).Start;
end;

end.
