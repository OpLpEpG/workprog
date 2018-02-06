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
  TFormDACNNk_abst = class(TDialogIForm, IDialog, IDialog<Integer>)
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
    FDac1: word;
    FDac2: word;
    FDac3: word;
    FDac4: word;
    function GetDevice: IEepromDevice;
  protected
    class function ClassIcon: Integer; override;
    function GetInfo: PTypeInfo; override;
    function Execute(InputData: Integer): Boolean;
  public
    property Dac1: word read FDac1 write FDac1;
    property Dac2: word read FDac2 write FDac2;
    property Dac3: word read FDac3 write FDac3;
    property Dac4: word read FDac4 write FDac4;
  end;

  TFormDACNNk = class(TFormDACNNk_abst)
  private
   const
    NICON = 178;
  public
    [StaticAction('ЦАП ННК', 'Отладочные', NICON, '0:Показать.Отладочные')]
    class procedure DoCreateDialog5(Sender: IAction);
    [StaticAction('ЦАП Гамма', 'Отладочные', NICON, '0:Показать.Отладочные')]
    class procedure DoCreateDialog4(Sender: IAction);
    [ShowProp('ННК 1')]  property Dac1;
    [ShowProp('ННК 2')]  property Dac2;
    [ShowProp('Гамма')]  property Dac3;
  end;

  Dialog_FormDACAGK = interface
  ['{F8B148AC-F9FC-4809-B027-7268199C8B0C}']
  end;
  TFormDACAGK  = class(TFormDACNNk_abst)
  protected
    function GetInfo: PTypeInfo; override;
  public
    [StaticAction('ЦАП Азим.Гамма', 'Отладочные', TFormDACNNk.NICON, '0:Показать.Отладочные')]
    class procedure DoCreateDialog9(Sender: IAction);
    [ShowProp('Гк-1')]  property Dac1;
    [ShowProp('Гк-2')]  property Dac2;
    [ShowProp('Гк-3')]  property Dac3;
    [ShowProp('Гк-4')]  property Dac4;
  end;

implementation

uses tools;

{$R *.dfm}

{ TFormDACNNk }

class function TFormDACNNk_abst.ClassIcon: Integer;
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

function TFormDACNNk_abst.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_FormDACNNk);
end;

procedure TFormDACNNk_abst.btExitClick(Sender: TObject);
begin
  RegisterDialog.UnInitialize(GetInfo);
end;

function TFormDACNNk_abst.Execute(InputData: Integer): Boolean;
begin
  Result := True;
  Adr := InputData;
  if Adr = 9 then Caption := 'Установка ЦАП модуля AGK'
  else if Adr = 5 then Caption := 'Установка ЦАП модуля ННК'
  else Caption := 'Установка ЦАП модуля Гамма';
  ShowPropAttribute.Apply(Self, Insp);
  IShow;
end;

function TFormDACNNk_abst.GetDevice: IEepromDevice;
 var
  d: IDevice;
  a: Integer;
  de: IDeviceEnum;
begin
  if Supports(GContainer, IDeviceEnum, de) then for d in de do for a in d.GetAddrs do if a = Adr then Exit(d as IEepromDevice);
  raise EFormDACNNk.CreateFmt('Нет устройств с адресом %d',[Adr]);
end;

procedure TFormDACNNk_abst.btReadClick(Sender: TObject);
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
      if Adr = 9 then
       begin
        FDac1 := root.GR1.DEV.VALUE shr 4;
        FDac2 := root.GR2.DEV.VALUE shr 4;
        FDac3 := root.GR3.DEV.VALUE shr 4;
        FDac4 := root.GR4.DEV.VALUE shr 4;
       end
      else
       begin
        FDac1 := root.DAC.нк1.DEV.VALUE shr 4;
        FDac2 := root.DAC.нк2.DEV.VALUE shr 4;
        FDac3 := root.DAC.нгк.DEV.VALUE shr 4;
       end;
      insp.RefreshValues;
      st.Panels[0].Text := 'Read GOOD';
     end;
  end);
end;

procedure TFormDACNNk_abst.btWriteClick(Sender: TObject);
 var
  ee: IEepromDevice;
  root: Variant;
begin
  ee := GetDevice;
  root := XToVar(FindEeprom(ee.GetMetaData.Info, Adr));
  if Adr = 9 then
   begin
    Root.GR1.DEV.VALUE := FDac1 shl 4;
    Root.GR2.DEV.VALUE := FDac2 shl 4;
    Root.GR3.DEV.VALUE := FDac3 shl 4;
    Root.GR4.DEV.VALUE := FDac4 shl 4;
   end
  else
   begin
    Root.DAC.нк1.DEV.VALUE := FDac1 shl 4;
    Root.DAC.нк2.DEV.VALUE := FDac2 shl 4;
    Root.DAC.нгк.DEV.VALUE := FDac3 shl 4;
   end;
  ee.WriteEeprom(Adr, procedure (Res: Boolean)
  begin
    if Res then st.Panels[0].Text := 'write GOOD'
    else st.Panels[0].Text := 'write BAD'
  end);
end;

{ TFormDACAGK }

class procedure TFormDACAGK.DoCreateDialog9(Sender: IAction);
 var
  d: Idialog;
begin
  if RegisterDialog.TryGet<Dialog_FormDACAGK>(d) then (d as IDialog<Integer>).Execute(9);
end;

function TFormDACAGK.GetInfo: PTypeInfo;
begin
  Result := TypeInfo(Dialog_FormDACAGK);
end;

initialization
  RegisterDialog.Add<TFormDACNNk, Dialog_FormDACNNk>;
  RegisterDialog.Add<TFormDACAGK, Dialog_FormDACAGK>;
finalization
  RegisterDialog.Remove<TFormDACNNk>;
  RegisterDialog.Remove<TFormDACAGK>;
end.
