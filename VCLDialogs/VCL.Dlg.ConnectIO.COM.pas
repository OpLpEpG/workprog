unit VCL.Dlg.ConnectIO.COM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VCL.Dlg.ConnectIO, Vcl.StdCtrls, Vcl.ComCtrls, CPortCtl;

type
  TFormSetupCom = class(TFormSetupConnect)
    Label1: TLabel;
    cbCom: TComComboBox;
    procedure FormShow(Sender: TObject);
  public
    params: TArray<string>;
    function CreateConnectInfo: string; override;
  end;

implementation

{$R *.dfm}

function TFormSetupCom.CreateConnectInfo: string;
begin
  params[0] := cbCom.Text;
  Result := string.join(';',params);
end;

procedure TFormSetupCom.FormShow(Sender: TObject);
begin
  params := Item.ConnectInfo.Split([';']);
  cbCom.Text := params[0];
  inherited;
end;

end.
