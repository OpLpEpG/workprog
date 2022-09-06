unit VCL.Dlg.ConnectIO.COM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCL.Dlg.ConnectIO, Vcl.StdCtrls, Vcl.ComCtrls, CPortCtl;

type
  TFormSetupCom = class(TFormSetupConnect)
    Label1: TLabel;
    cbCom: TComComboBox;
    cb9600: TCheckBox;
    procedure FormShow(Sender: TObject);
  public
    params: TArray<string>;
    function CreateConnectInfo: string; override;
  end;

implementation

{$R *.dfm}

function TFormSetupCom.CreateConnectInfo: string;
begin
  if cb9600.Checked then
   begin
    SetLength(params, 2);
    params[1] := '9600';
   end
  else SetLength(params, 1);

  params[0] := cbCom.Text.Trim;
  Result := string.join(';',params);
end;

procedure TFormSetupCom.FormShow(Sender: TObject);
begin
  params := Item.ConnectInfo.Split([';']);
  cbCom.Text := params[0].Trim;
  cb9600.Checked := (Length(params) = 2) and (params[1] = '9600');
  inherited;
end;

end.
