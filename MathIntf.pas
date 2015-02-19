unit MathIntf;

interface

uses System.SysUtils;

type

  EMatLabException = class(Exception);

  ILastMathError = interface
  	function GetLastError(out err: PAnsiChar): HRESULT; stdcall;
  end;

  PRbfReport = ^TRbfReport;
  TRbfReport = record
   arows: integer;
   acols: integer;
   annz: integer;
   iterationscount: integer;
   nmv: integer;
   terminationtype: integer;
  end;

  IRbf = interface(ILastMathError)
 	  function Create(nx, ny: Integer): HRESULT; stdcall;
  	function Points(const xy: PAnsiChar): HRESULT; stdcall;
   	function Term(t: Integer): HRESULT; stdcall;
  	function AlgoQNN(q: Double; z: Double): HRESULT; stdcall;
  	function AlgoMultilayer(rbase: Double; nlayers: Integer; lambdav: Double): HRESULT; stdcall;
   	function Build(out res: PRbfReport): HRESULT; stdcall;
    function Calc2(x0, x1: Double; out res: Double): HRESULT; stdcall;
    function Calc3(x0, x1, x2: Double; out res: Double): HRESULT; stdcall;
  end;

  PPolynomialFitReport = ^TPolynomialFitReport;
  TPolynomialFitReport = record
    taskrcond, rmserror, avgerror, avgrelerror, maxerror: Double;
  end;

  IBaryCentric  = interface(ILastMathError)
 	  function Fit(const x, y: PAnsiChar; m: Integer; var info: Integer): HRESULT; stdcall;
 	  function FitWc(const x, y, w, cx, cy, cd: PAnsiChar; m: Integer; var info: Integer): HRESULT; stdcall;
 	  function FitV(const x, y: PDouble; Len, m: Integer; var info: Integer): HRESULT; stdcall;
    function GetY(x: Double; var y: Double): HRESULT; stdcall;
    function GetLastFitReport(out Rep: PPolynomialFitReport): HRESULT; stdcall;
  end;

  PComplex = ^TComplex;
  TComplex = record
    x,y: Double;
  end;

  IFourier  = interface(ILastMathError)
 	  function fft(const x: PDouble; Len: Integer): HRESULT; stdcall;
 	  function ifft(var x: PDouble): HRESULT; stdcall;
 	  function GetLastFF(out x: PComplex): HRESULT; stdcall;
  end;

  IDoubleMatrix = interface
    function GetItem(const i, j: Integer):Double; stdcall;
    function GetRows(): Integer; stdcall;
    function GetCols(): Integer; stdcall;
    property Items[const i, j: Integer]: Double read GetItem; default;
    property Rows: Integer read GetRows;
    property Cols: Integer read GetCols;
  end;

  IClusterizer  = interface(ILastMathError)
    function SetPoints(const xy: PDouble; npoints, nfeatures, disttype: Integer): HRESULT; stdcall;
    function Ahc(algo, k: Integer; out cidx: PIntegerArray; out cz: PIntegerArray): HRESULT; stdcall;
 	  function Kmeans(restarts,  maxits, k: Integer;  out cidx: PIntegerArray; out c: IDoubleMatrix; out terminationtype: Integer): HRESULT; stdcall;
  end;

  TDoubleArray  = array[0..$0ffffffe] of Double;
  PDoubleArray = ^TDoubleArray;

  PaeDynBlock = ^TaeDynBlock;
  TaeDynBlock = record
    next: PaeDynBlock;
    deallocator: TProcedure;
    ptr: Pointer;
  end;

  TaeMatrix = record
    rows: Integer;
    cols: Integer;
    stride: Integer;
    datatype: Integer;
    data: TaeDynBlock;
    ptr: Pointer;
  end;

  TaeVector = record
    cnt: Integer;
    datatype: Integer;
    data: TaeDynBlock;
    ptr: Pointer;
  end;

  PSLFittingReport = ^TSLFittingReport;
  TSLFittingReport = record
    taskrcond: Double;
    iterationscount: Integer;
    varidx: Integer;
    rmserror: Double;
    avgerror: Double;
    avgrelerror: Double;
    maxerror: Double;
    wrmserror: Double;
    covpar: TaeMatrix;
    errpar: TaeVector;
    errcurve: TaeVector;
    noise: TaeVector;
    r2: Double;
  end;

  ILSFitting = interface(ILastMathError)
    function Linear(const y, fmatrix: PDouble; n, m: Integer; var info: Integer; out c: PDoubleArray; out Rep: PSLFittingReport): HRESULT; stdcall;
    function LinearW(const y, w, fmatrix: PDouble; n, m: Integer; var info: Integer; out c: PDoubleArray; out Rep: PSLFittingReport): HRESULT; stdcall;
  end;
//__interface IEquations : public ILastMathError
//
//	SAFECALL LinearLS(const double *a, const ae_int_t nrows, const ae_int_t ncols, const double *b, ae_int_t &info, const double **x,
//double &r2, ae_int_t &n, ae_int_t &k, const IDoubleMatrix **cx);
//;

  IEquations = interface(ILastMathError)
    function LinearLS(const a: PDouble; nrows, ncols: Integer; const b: PDouble;
                      out info: Integer;
                      out x: PDoubleArray;
                      out R2: Double;
                      out n: Integer;
                      out k: Integer;
                      out cx: IDoubleMatrix): HRESULT; stdcall;
    function Linear(const a: PDouble; nrows: Integer; const b: PDouble;
                      out info: Integer;
                      out x: PDoubleArray): HRESULT; stdcall;
  end;
//  __interface ILMFitting : public ILastMathError
//
// 	SAFECALL FitV(const ae_int_t n, const ae_int_t m, const double *xin, const double *boundL, const double *boundU,
//		          const double diffstep, const double epsg, const double epsf, const double epsx, const ae_int_t maxits,
//				  void *ptr, double **xout, alglib_impl::minlmreport **Rez);
//
//
//typedef void (*Tfunc) (const double *x, double **rez);
//    ae_int_t iterationscount;
//    ae_int_t terminationtype;
//    ae_int_t funcidx;
//    ae_int_t varidx;
//    ae_int_t nfunc;
//    ae_int_t njac;
//    ae_int_t ngrad;
//    ae_int_t nhess;
//    ae_int_t ncholesky;

  PLMFittingReport = ^TLMFittingReport;
  TLMFittingReport = record
    iterationscount,
    terminationtype,
    funcidx,
    varidx,
    nfunc,
    njac,
    ngrad,
    nhess,
    ncholesky: Integer;
  end;


  TLMFittingCB = procedure(const x, f: PDoubleArray); cdecl;

  ILMFitting = interface(ILastMathError)
    function FitVB(n, m: Integer; const xin, bndL, bndU: PDoubleArray; const diffstep, epsg, epsf, epsx: Double; const maxits: Integer;
                  func: TLMFittingCB; out xout: PDoubleArray; out Rep: PLMFittingReport): HRESULT; stdcall;
    function FitV(n, m: Integer; const xin: PDoubleArray; const diffstep, epsg, epsf, epsx: Double; const maxits: Integer;
                  func: TLMFittingCB; out xout: PDoubleArray; out Rep: PLMFittingReport): HRESULT; stdcall;
  end;

{typedef struct
	double *dwt;
	int dwt_len;
	int *length;
	int length_len;
	double flag0;
	double flag1;
 wave1d_rez_t;

__interface Iwavelet : public ILastMathError

	SAFECALL setup_dwt(const char* name, const int set_J);
	SAFECALL dw_i16(const INT16 *a, const ae_int_t cnt,  wave1d_rez_t &rez);
	SAFECALL idw(const double **x, ae_int_t &cnt);
;}
  TWaveletRez = record
    dwt: PDoubleArray;
    dwt_len: Integer;
    length: PIntegerArray;
    length_len: Integer;
    flag0, flag1: double;
  end;


  Iwavelet = interface(ILastMathError)
    function setup_dwt(const name: PAnsiChar; const J: Integer): HRESULT; stdcall;
    function dw_i16(const sig: PSmallInt; len: Integer; out rez: TWaveletRez): HRESULT; stdcall;
    function dw(const sig: PDouble; len: Integer; out rez: TWaveletRez): HRESULT; stdcall;
    function idw(out sig: PDoubleArray; out len: Integer): HRESULT; stdcall;
  end;

{$WARN SYMBOL_PLATFORM OFF}
procedure RbfFactory(out Rbf: IRbf); cdecl; external 'matlab.dll' delayed;
procedure BaryCentricFactory(out BaryCentric: IBaryCentric); cdecl; external 'matlab.dll' delayed;
procedure FourierFactory(out Fourier: IFourier); cdecl; external 'matlab.dll' delayed;
procedure ClusterizerFactory(out Clusterizer: IClusterizer); cdecl; external 'matlab.dll' delayed;
procedure LSFittingFactory(out LSFitting: ILSFitting); cdecl; external 'matlab.dll' delayed;
procedure LMFittingFactory(out LMFitting: ILMFitting); cdecl; external 'matlab.dll' delayed;
procedure ToDoubleMatrix(Src: Pointer; out mtx: IDoubleMatrix); cdecl; external 'matlab.dll' delayed;
procedure EquationsFactory(out Equations: IEquations); cdecl; external 'matlab.dll' delayed;
procedure WaveletFactory(out wavelet: Iwavelet); cdecl; external 'matlab.dll' delayed;
{$WARN SYMBOL_PLATFORM ON}

procedure CheckMath(lme: ILastMathError; res: HRESULT);

implementation

procedure CheckMath(lme: ILastMathError; res: HRESULT);
 var
  er: PAnsiChar;
begin
  if res = S_OK then Exit;
  lme.GetLastError(er);
  raise EMatLabException.Create(String(er));
end;

end.
