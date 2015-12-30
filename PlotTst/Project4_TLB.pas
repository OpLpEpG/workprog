unit Project4_TLB;

// ************************************************************************ //
// WARNING
// -------
// The types declared in this file were generated from data read from a
// Type Library. If this type library is explicitly or indirectly (via
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the
// Type Library, the contents of this file will be regenerated and all
// manual modifications will be lost.
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 27.11.2015 14:54:50 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\XE\Projects\Device2\PlotTst\Project4 (1)
// LIBID: {2B5240AD-42BF-495A-A9CD-492FB8292932}
// LCID: 0
// Helpfile:
// HelpString:
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\System32\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  Project4MajorVersion = 1;
  Project4MinorVersion = 0;

  LIBID_Project4: TGUID = '{2B5240AD-42BF-495A-A9CD-492FB8292932}';

  IID_IcoName: TGUID = '{7349AC2D-495B-4512-A2B8-3C38C7054A23}';
  CLASS_coName: TGUID = '{143CC499-B035-46A1-B948-1245B345053A}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IcoName = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  coName = IcoName;


// *********************************************************************//
// Interface: IcoName
// Flags:     (256) OleAutomation
// GUID:      {7349AC2D-495B-4512-A2B8-3C38C7054A23}
// *********************************************************************//
  IcoName = interface(IUnknown)
    ['{7349AC2D-495B-4512-A2B8-3C38C7054A23}']
  end;

// *********************************************************************//
// The Class CocoName provides a Create and CreateRemote method to
// create instances of the default interface IcoName exposed by
// the CoClass coName. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CocoName = class
    class function Create: IcoName;
    class function CreateRemote(const MachineName: string): IcoName;
  end;

implementation

uses System.Win.ComObj;

class function CocoName.Create: IcoName;
begin
  Result := CreateComObject(CLASS_coName) as IcoName;
end;

class function CocoName.CreateRemote(const MachineName: string): IcoName;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_coName) as IcoName;
end;

end.

