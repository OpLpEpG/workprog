unit ExceptionForm;

interface

uses System.SysUtils,  ExtendIntf, RootImpl, debug_except, DeviceIntf, DockIForm,
  Winapi.Windows, Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics, Rtti,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus,  ActiveX, ComObj, JvDockControlForm,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, PluginAPI, Vcl.ActnList, Vcl.StdActns, System.Actions;

type
  TFormExceptions = class(TDockIForm, INotifyBeforeClean)
    Memo: TMemo;
    ppM: TPopupActionBar;
    NClear: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    ActionList: TActionList;
    FileSaveAs: TFileSaveAs;
    NShowDebug: TMenuItem;
    NDialog: TMenuItem;
    procedure NClearClick(Sender: TObject);
    procedure FileSaveAsAccept(Sender: TObject);
    procedure NDialogClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure NCloseClick(Sender: TObject);
    class procedure AsyncException(const CsName, msg, StackTrace: WideString);
  protected
    procedure BeforeClean(var CanClean: Boolean);
    function Priority: Integer; override;
    class function ClassIcon: Integer; override;
  public
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
  HideDockForm(Self);
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

function TFormExceptions.Priority: Integer;
begin
  Result := PRIORITY_NoStore;
end;

procedure TFormExceptions.FileSaveAsAccept(Sender: TObject);
begin
  Memo.Lines.SaveToFile(FileSaveAs.Dialog.FileName);
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

