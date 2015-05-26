unit ExceptionForm;

interface

uses System.SysUtils,  ExtendIntf, RootImpl, debug_except, DeviceIntf, DockIForm,
  Winapi.Windows, Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics, Rtti,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,  Winapi.ActiveX, System.Win.ComObj, JvDockControlForm,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, PluginAPI, Vcl.ActnList, Vcl.StdActns, System.Actions;

type
  TFormExceptions = class(TDockIForm)
    Memo: TMemo;
    procedure FormShow(Sender: TObject);
  private
    procedure NDialogClick(Sender: TObject);
    procedure NClearClick(Sender: TObject);
    procedure NSaveAsClick(Sender: TObject);
    procedure NCloseClick(Sender: TObject);
    class procedure AsyncException(const CsName, msg, StackTrace: WideString);
  protected
    procedure BeforeClean(var CanClean: Boolean); override;
    procedure InitializeNewForm; override;
    function Priority: Integer; override;
    class function ClassIcon: Integer; override;
  public
    NShowDebug: TMenuItem;
    NDialog: TMenuItem;
    class var This: TFormExceptions;
    destructor Destroy; override;
    class procedure Init();
    class procedure DeInit();
  end;

implementation

{$R *.dfm}

uses PluginManager, MainForm;

{ TFormDebug }

class function TFormExceptions.ClassIcon: Integer;
begin
  Result := 257;
end;

class procedure TFormExceptions.Init;
 var
  fe: IFormEnum;
begin
  if Assigned(This) then Exit;
  TDebug.ExeptionEvent := AsyncException;
  This := TFormExceptions.CreateUser('FormExceptions');
  (This as IInterface)._AddRef();
  This.NClose.OnClick := This.NCloseClick;
  if Supports(Plugins, IFormEnum, fe)then fe.Add(This as Iform);
end;

procedure TFormExceptions.InitializeNewForm;
 var
  Item : TMenuItem;
begin
  inherited;
  AddToNCMenu('-', nil, Item);
  AddToNCMenu('Очистить', NClearClick, Item);
  AddToNCMenu('-', nil, Item);
  AddToNCMenu('Показывать диалог', NDialogClick, NDialog);
  NDialog.AutoCheck := True;
  AddToNCMenu('Показывать отладочную информацию', nil, NShowDebug);
  NShowDebug.AutoCheck := True;
  NShowDebug.Checked := True;
  AddToNCMenu('-', nil, Item);
  AddToNCMenu('Сохранить в файл...', NSaveAsClick, Item);
end;

class procedure TFormExceptions.DeInit;
begin
  if Assigned(This) then FreeAndNil(This);
end;

destructor TFormExceptions.Destroy;
begin
  TDebug.ExeptionEvent := nil;
  This := nil;
  TDebug.Log('TFormExceptions.Destroy');
  inherited;
end;

procedure TFormExceptions.BeforeClean(var CanClean: Boolean);
begin
  CanClean := False;
  inherited;
end;

procedure TFormExceptions.NCloseClick(Sender: TObject);
begin
  HideDockForm(Self);
end;

procedure TFormExceptions.NDialogClick(Sender: TObject);
begin
  if NDialog.Checked then TDebug.ExeptionEvent := nil
  else TDebug.ExeptionEvent := AsyncException;
end;

procedure TFormExceptions.NSaveAsClick(Sender: TObject);
begin
  with TSaveDialog.Create(nil) do
  try
   InitialDir := ExtractFilePath(ParamStr(0));
   DefaultExt := 'txt';
   Options := Options + [ofOverwritePrompt, ofPathMustExist];
   Filter := 'Файл (*.txt)|*.txt';
   if Execute(Handle) then Memo.Lines.SaveToFile(FileName);
  finally
   Free;
  end;
end;

function TFormExceptions.Priority: Integer;
begin
  Result := PRIORITY_NoStore;
end;

procedure TFormExceptions.FormShow(Sender: TObject);
begin
  Icon := ClassIcon;
end;

procedure TFormExceptions.NClearClick(Sender: TObject);
begin
  Memo.Clear;
end;

class procedure TFormExceptions.AsyncException(const CsName, msg, StackTrace: WideString);
 var
  i: Integer;
begin
  if not Assigned(This) then Exit;
  with This do
   begin
    if CsName = 'EAbort' then Exit;
    if Pos('no user Err', string(msg)) > 0  then Exit;
    Memo.Lines.BeginUpdate;
    if NShowDebug.Checked then
     begin
      Memo.Lines.Insert(0, string(StackTrace));
      Memo.Lines.Insert(0, string(CsName) + '    ' + string(msg));
     end
    else
     begin
      i := Pos('[', string(msg));
      if i > 0 then Memo.Lines.Insert(0, string(CsName) + '    ' + Copy(string(msg), 1, i-2))
      else Memo.Lines.Insert(0, string(CsName) + '    ' + string(msg));
     end;
    while Memo.Lines.Count > 100 do Memo.Lines.Delete(Memo.Lines.Count-1);
    Memo.Lines.EndUpdate;
   end;
end;

initialization
  TFormExceptions.Init();
finalization
end.

