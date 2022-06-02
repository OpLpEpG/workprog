unit Convertor;

interface

uses LAS, LasImpl,  System.DateUtils, MathIntf, tools,
  RootImpl, ExtendIntf, DockIForm, debug_except, RootIntf, Container, Actns,  System.TypInfo,  DataSetIntf,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes;

const
 DEPT = 'DEPT';
 ETIM = 'ETIM';
 KADR = 'KADR';
 TIME = 'TIME';

type
  TConvertDataRef = reference to procedure(stat: IStatistic);
// outp ID KADR DEPT TIME
procedure convert(inp, outp: ILasDoc; startTime: TDateTime; cb: TConvertDataRef);
procedure convert_terminate;

implementation

var
 Terminate_flag: Boolean;

procedure convert_terminate;
begin
  Terminate_flag := True;
end;

procedure convert(inp, outp: ILasDoc; startTime: TDateTime; cb: TConvertDataRef);
begin
  TThread.CreateAnonymousThread(procedure
   var
    st: IStatistic;
    cntKadr, stKadr, nKadr: Integer;
    tBegin, tEnd: TDateTime;
    sp: ISpline;
    Y: Double;
    nTime: TDateTime;
    i: Integer;
    t: Cardinal;
    nx, ny: TArray<Double>;
  begin
    Terminate_flag := False;
    tBegin := UnixToDateTime(inp[ETIM,0]);
    tEnd := UnixToDateTime(inp[ETIM,inp.DataCount-1]);
    cntKadr := Ctime.ToKadr(tEnd-tBegin);
    stKadr := CTime.RoundToKadr(tBegin - startTime);

    SetLength(nx, inp.DataCount);
    SetLength(ny, inp.DataCount);
    for i := 0 to inp.DataCount-1 do
      begin
        nx[i] := UnixToDateTime(inp[ETIM,i]);
        ny[i] := inp[DEPT,i];
      end;
    SplineFactory(sp);
    CheckMath(sp, sp.buld(@nx[0], @ny[0], inp.DataCount));

    st := TStatisticCreate.Create(cntKadr);

    t:=0;
    nKadr := -1;
    repeat
     inc(nKadr);
     nTime := tBegin + CTime.FromKadr(nKadr);
     if nTime <= tEnd then sp.get(nTime, Y);
     outp.Data.AddData([nKadr+stKadr, Y, nTime]);

     if ((GetTickCount - t) > 1000) or (nKadr >= cntKadr) then
      begin
       t := GetTickCount;
       st.UpdateAll(nKadr);
       if st.Statistic.ProcRun >= 100 then
        begin
         Terminate_flag := True;
         st := nil;
        end;
       TThread.Synchronize(nil, procedure
       begin
         cb(st);
       end);
      end;
    until Terminate_flag;

  end).Start;
end;

end.
