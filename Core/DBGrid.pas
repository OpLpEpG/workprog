unit DBGrid;

interface

uses System.SysUtils, System.Classes, Vcl.Grids, Vcl.DBGrids, Vcl.Themes, Vcl.Forms;

type
  TIColumn = class(TColumn)
  private
    procedure SetExpandable(const Value: Boolean);
    function GetExpandable: Boolean;
  public
    property Expandable: Boolean read GetExpandable write SetExpandable;
  end;

  TCustomIDBGrid = class(TCustomDBGrid)
  protected
    function CreateColumns: TDBGridColumns; override;
  end;

  TIDBGrid = class(TCustomIDBGrid)
  strict private
    class constructor Create;
    class destructor Destroy;
  public
    property Canvas;
    property SelectedRows;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    [Stored(False)]
    property Columns stored False; //StoreColumns;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DrawingStyle;
    property Enabled;
    property FixedColor;
    property GradientEndColor;
    property GradientStartColor;
    property Font;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Touch;
    property Visible;
    property StyleElements;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;  { obsolete }
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

implementation

{ TIDBGrid }

class constructor TIDBGrid.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TIDBGrid, TScrollingStyleHook);
end;

class destructor TIDBGrid.Destroy;
begin
  TCustomStyleEngine.UnRegisterStyleHook(TIDBGrid, TScrollingStyleHook);
end;

function TCustomIDBGrid.CreateColumns: TDBGridColumns;
begin
  Result := TDBGridColumns.Create(Self, TIColumn);
end;

{ TIColumn }

function TIColumn.GetExpandable: Boolean;
begin
  Result := True;
end;

procedure TIColumn.SetExpandable(const Value: Boolean);
begin

end;

initialization
  RegisterClasses([TIDBGrid, TCustomIDBGrid, TIColumn]);
end.
