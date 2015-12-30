unit Unit2;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, Project4_TLB, StdVcl;

type
  TcoName = class(TTypedComObject, IcoName)
  protected
  end;

implementation

uses ComServ;

initialization
  TTypedComObjectFactory.Create(ComServer, TcoName, Class_coName,
    ciMultiInstance, tmApartment);
end.
