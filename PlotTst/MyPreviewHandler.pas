unit MyPreviewHandler;

interface

uses
  PreviewHandler, Classes, Controls, StdCtrls;

const
  {$REGION 'Unique ClassID of your PreviewHandler'}
  ///   <summary>Unique ClassID of your PreviewHandler</summary>
  ///   <remarks>Don't forget to create a new one. Best use Ctrl-G.</remarks>
  {$ENDREGION}
  CLASS_MyPreviewHandler: TGUID = '{64644512-C345-469F-B5FB-EB351E20129D}';

type
  {$REGION 'Sample PreviewHandler'}
  ///   <summary>Sample PreviewHandler</summary>
  ///   <remarks>A sample PreviewHandler. You only have to derive from
  ///   TFilePreviewHandler or TStreamPreviewHandler and override some methods.</remarks>
  {$ENDREGION}
  TMyPreviewHandler = class(TFilePreviewHandler)
  private
    FTextLabel: TLabel;
  protected
  public
    constructor Create(AParent: TWinControl); override;
    procedure Unload; override;
    procedure DoPreview(const FilePath: string); override;
    property TextLabel: TLabel read FTextLabel;
  end;

implementation

uses
  SysUtils;

constructor TMyPreviewHandler.Create(AParent: TWinControl);
begin
  inherited;
  FTextLabel := TLabel.Create(AParent);
  FTextLabel.Parent := AParent;
  FTextLabel.AutoSize := false;
  FTextLabel.Align := alClient;
  FTextLabel.Alignment := taCenter;
  FTextLabel.Layout := tlCenter;
  FTextLabel.WordWrap := true;
end;

procedure TMyPreviewHandler.DoPreview(const FilePath: string);
begin
  TextLabel.Caption := GetPackageDescription(PWideChar(FilePath));
end;

procedure TMyPreviewHandler.Unload;
begin
  TextLabel.Caption := '';
  inherited;
end;

initialization
  { Register your PreviewHandler with the ClassID, name, descripton and file extension }
  TMyPreviewHandler.Register(CLASS_MyPreviewHandler, 'bplfile', 'XML Проект Гопизонт просмотр и выбор параметров', '.bpl');
end.


