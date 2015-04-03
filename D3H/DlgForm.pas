unit DlgForm;

interface

uses RootIntf, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, Winapi.Windows, Container, Actns,
   System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Rtti;

type
  EFormDH3Error = class(EBaseException);
  TFormDH3 = class(TDockIForm)
    btSend: TButton;
    edSend: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure btSendClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
   const
    NICON = 78;
   var
    d: array[0..256] of Byte;
    function GetDevice(var adr: Integer): ILowLevelDeviceIO;
  protected
    class function ClassIcon: Integer; override;
  public
    [StaticAction('Команды 3DMDH3', 'Отладочные', NICON, '0:Показать.Отладочные:-1')]
    class procedure DoCreateForm(Sender: IAction); override;
  end;


implementation

{$R *.dfm}

uses tools;

class function TFormDH3.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormDH3.DoCreateForm(Sender: IAction);
begin
  GetUniqueForm('GlobalFormDH3');
end;

procedure TFormDH3.btSendClick(Sender: TObject);
  procedure safe; safecall;
   var
    i, c, saveW: Integer;
    ss: TStrings;
    lld: ILowLevelDeviceIO;
    adr: Integer;
  begin
    lld := GetDevice(adr);
    if Assigned(lld.IConnect) then saveW := lld.IConnect.Wait
    else saveW := 500;
    ss := TStringList.Create;
    d[0] := (adr shl 4) or  $0B;
    d[1] := muldiv(saveW,1000,65536); // 65ms * 7
    try
     ss.Delimiter := ',';
     ss.DelimitedText := edSend.Text;
     c := ss.Count;
     for i := 0 to c-1 do d[i+2] := StrToInt('$'+ Trim(ss[i]));
    finally
     ss.Free;
    end;
    lld.SendROW(@d[0], c+2, procedure(Data: Pointer; DataSize: integer)
     var
      s: string;
      i: Integer;
    begin
      s :='';
      for I := 1 to DataSize-1 do s := s + ' ' + IntToHex(PByte(Data)[i], 2);
      Memo1.Text := S;
    end);
  end;
begin
  safe;
end;

procedure TFormDH3.Button1Click(Sender: TObject);
begin
  edSend.Text := 'E0,C1,29,00,00,ADL,DATA';
end;

procedure TFormDH3.Button2Click(Sender: TObject);
begin
  edSend.Text := 'E8,00,00,ADL';
end;

procedure TFormDH3.Button3Click(Sender: TObject);
begin
  edSend.Text := '20,11,D9,2B,A9';
end;

function TFormDH3.GetDevice(var adr: Integer): ILowLevelDeviceIO;
 var
  d: IDevice;
  a: Integer;
  de: IDeviceEnum;
begin
  if Supports(GContainer, IDeviceEnum, de) then for d in de do for a in d.GetAddrs do if a in [3,14] then
   begin
    adr := a;
    Exit(d as ILowLevelDeviceIO);
   end;
  raise EFormDH3Error.Create('Нет устройств с адресом 3, 14(Inclin)');
end;

initialization
  RegisterClass(TFormDH3);
  TRegister.AddType<TFormDH3, IForm>.LiveTime(ltSingletonNamed);
finalization
  GContainer.RemoveModel<TFormDH3>;
end.
