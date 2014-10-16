unit TestRAMForm;

interface

uses RootIntf, ExtendIntf, DockIForm, debug_except, DeviceIntf, DlgSetupForm, Parser, Container, Actns,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;
{// чтение внешней памяти
#define CMD_ERAM 0x1 | ADDRESS
// запись внешней памяти ТОЛЬКО В ТЕСТОВЫХ ЦЕЛЯХ
#define CMD_ERAM_WRITE 0x9 | ADDRESS
// стирание внешней памяти ТОЛЬКО В ТЕСТОВЫХ ЦЕЛЯХ
#define CMD_ERAM_CLEAR 0xA | ADDRESS
// установка страницы для записи
#define CMD_ERAM_SET_BASE 0xC | ADDRESS}
const
   CMD_ERAM = 1;
   CMD_ERAM_WRITE  = 9;
   CMD_ERAM_CLEAR  = $A;
   CMD_ERAM_SET_BASE = $C;

type
  TSetWritePage = packed record
    CmdAdr: Byte;
    Page: Word;
    constructor Create(addr: Byte; Apg: Word);
  end;

  PRamWrite =^TRamWrite;
  TRamWrite = packed record
    CmdAdr: Byte;
    len: Byte;
    data: array [0..61] of DWORD;
    constructor Create(DevAdr: Byte; var addr: DWORD);
  end;

  PRamRead =^TRamRead;
  TRamRead = packed record
    CmdAdr: Byte;
    PH, P6LB2H, BL: Byte;
    Length: word;
    constructor Create(DevAdr: Byte; RmAdr: DWord; len: word);
  end;

  EFormRamTestError = class(EBaseException);
  TFormRamTest = class(TDockIForm)
    sb: TStatusBar;
    Memo: TMemo;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edADR: TEdit;
    edPageW: TEdit;
    btSetBase: TButton;
    btRead: TButton;
    btWrite: TButton;
    edBaseR: TEdit;
    lbBaseW: TLabel;
    edPageR: TEdit;
    btClear: TButton;
    procedure btSetBaseClick(Sender: TObject);
    procedure btWriteClick(Sender: TObject);
    procedure btReadClick(Sender: TObject);
    procedure btClearClick(Sender: TObject);
  private
    function GetDevice(adr: Integer): ILowLevelDeviceIO;
    { Private declarations }
  protected
   const
    NICON = 294;
    class function ClassIcon: Integer; override;
  public
    [StaticAction('Проверка памяти', 'Отладочные', NICON, '0:Показать.Отладочные:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
  end;


implementation

{$R *.dfm}

{ TFormRamTest }

class function TFormRamTest.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormRamTest.DoCreateForm(Sender: IAction);
begin
  GetUniqueForm('GlobalFormRamTest');
end;

function TFormRamTest.GetDevice(adr: Integer): ILowLevelDeviceIO;
 var
  d: IDevice;
  a: Integer;
  de: IDeviceEnum;
begin
  if Supports(GlobalCore, IDeviceEnum, de) then
   for d in de do for a in d.GetAddrs do if a = adr then
     if d.Status in [dsNoInit, dsPartReady, dsReady] then Exit(d as ILowLevelDeviceIO)
     else raise EFormRamTestError.Create(Format('Устройство с адресом %d в работе',[adr]));
  raise EFormRamTestError.Create(Format('Нет устройств с адресом %d',[adr]));
end;

procedure TFormRamTest.btClearClick(Sender: TObject);
begin
  Memo.Clear;
end;

procedure TFormRamTest.btReadClick(Sender: TObject);
  type
   PDwordArray = ^Tda;
   Tda = array [0..$8000-1] of DWORD;
  const
   RLEN = 62*4;
 var
  lld: ILowLevelDeviceIO;
  a: TRamRead;
  adr: Integer;
  base, page: word;
  adres: DWORD;
begin
  adr := StrToInt(edADR.Text);
  base := StrToInt('$' + edBaseR.Text);
  page := StrToInt('$' + edPageR.Text);
  adres := page*$210+base;
  a := TRamRead.Create(Adr, adres, RLEN);
  lld := GetDevice(adr);
 // edRam.Text := IntToStr(StrToInt(edRam.Text) + RLEN);
  lld.SendROW(@a, SizeOf(a), procedure(p: Pointer; n: integer)
   var
    i: Integer;
    d: PDwordArray;
  begin
    if ((RLEN+1) = n) and (PByteArray(p)[0] = a.CmdAdr) then
     begin
       memo.Lines.BeginUpdate;
       d := @PByteArray(p)[1];
       for i := 0 to RLEN div 4 - 1 do memo.Text := memo.Text + Format('%8.8x ',[d[i]]);
       memo.Lines.EndUpdate;
       Inc(adres, RLEN);
       edBaseR.Text := IntToHex(adres mod $210, 3);
       edPageR.Text := IntToHex(adres div $210, 4);
     end;
  end);
end;

procedure TFormRamTest.btSetBaseClick(Sender: TObject);
 var
  lld: ILowLevelDeviceIO;
  d: TSetWritePage;
  adr: Integer;
begin
  adr := StrToInt(edADR.Text);
  d := TSetWritePage.Create(Adr, StrToInt('$'+edPagew.Text));
  lld := GetDevice(adr);
  lld.SendROW(@d, SizeOf(d), procedure(p: Pointer; n: integer)
  begin
    lbBaseW.Caption := '0';
    if (1 = n) and (d.CmdAdr = PByteArray(p)[0]) then
         sb.Panels[0].Text := 'OK адрес базовый в памяти'
    else sb.Panels[0].Text := 'BAD адрес базовый в памяти'
  end, 1000);
end;

procedure TFormRamTest.btWriteClick(Sender: TObject);
 var
  lld: ILowLevelDeviceIO;
  d: TRamWrite;
  adr: Integer;
  base, page: word;
  adres: DWORD;
begin
  adr := StrToInt(edADR.Text);
  base := StrToInt('$' + lbBaseW.Caption);
  page := StrToInt('$' + edPageW.Text);
  adres := (page*$210+base) div 4;
  d := TRamWrite.Create(Adr, adres);
  lld := GetDevice(adr);
  lld.SendROW(@d, SizeOf(d), procedure(p: Pointer; n: integer)
  begin
    adres := adres*4;
    if (n = 2) and (PByteArray(p)[0] = d.CmdAdr) and (PByteArray(p)[1] = 1) then
      begin
       sb.Panels[0].Text := Format('Записано %d ', [adres]);
       lbBaseW.Caption := IntToHex(adres mod $210, 3);
       edPageW.Text :=    IntToHex(adres div $210, 4);
      end
    else sb.Panels[0].Text := Format('Ошибка записи %d ', [adres]);
  end, 2000);
end;


function ToAdrCmd(a, cmd: Byte): Byte;
begin
  Result := (a shl 4) or cmd;
end;

{ TRamWrite }

constructor TRamWrite.Create(DevAdr: Byte; var addr: DWORD);
 var
  i: Integer;
begin
  CmdAdr := ToAdrCmd(DevAdr, CMD_ERAM_WRITE);
  len := 62 * 4;
  for i := 0 to 61 do
    begin
     Data[i] := addr;// xor $A55A;
     Inc(addr);
    end;
end;

{ TSetWritePage }

constructor TSetWritePage.Create(addr: Byte; Apg: Word);
begin
  CmdAdr := ToAdrCmd(addr, CMD_ERAM_SET_BASE);
  Page := Apg;
end;

{ TRamRead }

constructor TRamRead.Create(DevAdr: Byte; RmAdr: DWord; len: word);
 var
  page, base: Word;
begin
  CmdAdr := ToAdrCmd(DevAdr, CMD_ERAM);
  page := RmAdr div 528;
  base := RmAdr mod 528;
  PH := page shr 6;
  BL := base and $FF;
  P6LB2H := (page shl 2) or (base shr 8);
  Length := len;
end;

initialization
  RegisterClass(TFormRamTest);
  TRegister.AddType<TFormRamTest, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormRamTest>;
end.
