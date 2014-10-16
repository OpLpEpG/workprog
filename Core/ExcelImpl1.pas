unit ExcelImpl1;

interface

uses System.SysUtils, Container, ExtendIntf, RootImpl, debug_except, System.TypInfo, ComObj, ActiveX;

//type
//  EExcelException = class(EBaseException);
//
//  TExcelImpl11 = class(TIComponent, IExcel)
//  const APP = 'Excel.Application';
//  protected
//    function GetExcel: OleVariant;
//  end;

implementation

{ TExcelImpl }

//function TExcelImpl11.GetExcel: OleVariant;
//var
//  ClassID: TCLSID;
//  i: IInterface;
//  d: IDispatch;
//begin
//   »щем CLSID OLE-объекта
//  if CLSIDFromProgID(APP, ClassID) <> S_OK then raise EExcelException.Create('класс Excel не найден !!!');
//  if GetActiveObject(ClassID, nil, i) = S_OK then
//    if i.QueryInterface(IDispatch, d) = S_OK then Exit(d)
//    else raise EExcelException.Create('объект Excel не найден !!!');
//  Result := CreateOleObject(APP);
//end;

initialization
//  TRegister.AddType<TExcelImpl11, IExcel>.LiveTime(ltSingleton);
finalization
//  GContainer.RemoveModel<TExcelImpl>;
end.
