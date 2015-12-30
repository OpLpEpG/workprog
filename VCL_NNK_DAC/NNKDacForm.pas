unit NNKDacForm;

interface

uses RootIntf, ExtendIntf, DockIForm, debug_except, DeviceIntf, PluginAPI, Container, Actns, RootImpl, System.TypInfo,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, JDtools,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, JvExControls, JvInspector, JvComponentBase;

type
  Dialog_FormDACNNk = interface
  ['{676897CD-846A-4CEE-B3C8-572DA1535FE5}']
  end;
  EFormDACNNk = class(EBaseException);
  TFormDACNNk = class(TDialogIForm, IDialog, IDialog<Integer>)
    btRead: TButton;
    btWrite: TButton;
    btExit: TButton;
    st: TStatusBar;
    InspectorBorlandPainter: TJvInspectorBorlandPainter;
    insp: TJvInspector;
    procedure btExitClick(Sender: TObject);
    procedure btReadClick(Sender: TObject);
    procedure btWriteClick(Sender: TObject);
  private
   const
    NICON = 178;
   var
    Adr: Integer;
    FGamma: word;
    FDac2: word;
    FDac1: word;
    function GetDevice: IEepromDevice;
  protected
    class function ClassIcon: Integer; override;
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: Integer): Boolean;
  public
    [StaticAction('ЦАП ННК', 'Отладочные', NICON, '0:Показать.Отладочные')]
    class procedure DoCreateDialog5(Sender: IAction);
    [StaticAction('ЦАП Гамма', 'Отладочные', NICON, '0:Показать.Отладочные')]
    class procedure DoCreateDialog4(Sender: IAction);
    [ShowProp('ННК 1')]  property Dac1: word read FDac1 write FDac1;
    [ShowProp('ННК 2')]  property Dac2: word read FDac2 write FDac2;
    [ShowProp('Гамма')]  property Gamma: word read FGamma write FGamma;
  end;

implementation

uses tools;

{$R *.dfm}

{ TFormDACNNk }

class function TFormDACNNk.ClassIcon: Integer;
begin
  Result := NICON;
end;

class procedure TFormDACNNk.DoCreateDialog5(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_FormDACNNk>(d) then (d as IDialog<Integer>).Execute(5);
end;

class procedure TFormDACNNk.DoCreateDialog4(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_FormDACNNk>(d) then (d as IDialog<Integer>).Execute(4);
end;

function TFormDACNNk.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_FormDACNNk);
end;

procedure TFormDACNNk.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize<Dialog_FormDACNNk>;
end;

function TFormDACNNk.Execute(InputData: Integer): Boolean;
begin
  Result := True;
  Adr := InputData;
  if Adr = 5 then Caption := 'Установка ЦАП модуля ННК'
  else Caption := 'Установка ЦАП модуля Гамма';
  ShowPropAttribute.Apply(Self, Insp);
  IShow;
end;

function TFormDACNNk.GetDevice: IEepromDevice;
 var
  d: IDevice;
  a: Integer;
  de: IDeviceEnum;
begin
  if Supports(GContainer, IDeviceEnum, de) then for d in de do for a in d.GetAddrs do if a = Adr then Exit(d as IEepromDevice);
  raise EFormDACNNk.CreateFmt('Нет устройств с адресом %d',[Adr]);
end;

procedure TFormDACNNk.btReadClick(Sender: TObject);
 var
  ee: IEepromDevice;
  root: Variant;
begin
  st.Panels[0].Text := 'Read BAD';
  ee := GetDevice;
//  TDebug.Log(FindEeprom(ee.GetMetaData.Info, Adr).NodeName);
  root := XToVar(FindEeprom(ee.GetMetaData.Info, Adr));
  ee.ReadEeprom(procedure (Res: TEepromEventRes)
  begin
    if Res.DevAdr = Adr then
     begin
//      ee.GetMetaData.Info.OwnerDocument.SaveToFile(ExtractFilePath(ParamStr(0))+'EEP.xml');
      FDac1 := root.DAC.нк1.DEV.VALUE shr 4;
      FDac2 := root.DAC.нк2.DEV.VALUE shr 4;
      FGamma := root.DAC.нгк.DEV.VALUE shr 4;
      insp.RefreshValues;
      st.Panels[0].Text := 'Read GOOD';
     end;
  end);
end;

procedure TFormDACNNk.btWriteClick(Sender: TObject);
 var
  ee: IEepromDevice;
  root: Variant;
begin
  ee := GetDevice;
  root := XToVar(FindEeprom(ee.GetMetaData.Info, Adr));
  Root.DAC.нк1.DEV.VALUE := FDac1 shl 4;
  Root.DAC.нк2.DEV.VALUE := FDac2 shl 4;
  Root.DAC.нгк.DEV.VALUE := FGamma shl 4;
  ee.WriteEeprom(Adr, procedure (Res: Boolean)
  begin
    if Res then st.Panels[0].Text := 'write GOOD'
    else st.Panels[0].Text := 'write BAD'
  end);
end;

initialization
  RegisterDialog.Add<TFormDACNNk, Dialog_FormDACNNk>;
finalization
  RegisterDialog.Remove<TFormDACNNk>;
end.
