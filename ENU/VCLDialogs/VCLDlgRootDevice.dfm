object FormSetupRootDevice: TFormSetupRootDevice
  Left = 0
  Top = 0
  ClientHeight = 444
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 13
  object Splitter: TSplitter
    Left = 169
    Top = 0
    Height = 444
    ExplicitLeft = 152
    ExplicitTop = 136
    ExplicitHeight = 100
  end
  object PanelRoot: TPanel
    Left = 172
    Top = 0
    Width = 442
    Height = 444
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    ExplicitHeight = 435
    object PanelBoot: TPanel
      Left = 0
      Top = 403
      Width = 442
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      ExplicitTop = 394
      object btClose: TButton
        Left = 9
        Top = 6
        Width = 89
        Height = 27
        HelpContext = 20
        Cancel = True
        Caption = 'Close window'
        TabOrder = 0
        OnClick = btCloseClick
      end
      object btUpdate: TButton
        Left = 104
        Top = 6
        Width = 89
        Height = 27
        HelpContext = 20
        Cancel = True
        Caption = 'Update'
        TabOrder = 1
        OnClick = btUpdateClick
      end
    end
    object insp: TJvInspector
      Left = 0
      Top = 0
      Width = 442
      Height = 403
      Style = isItemPainter
      Align = alClient
      Divider = 200
      ItemHeight = 16
      Painter = InspectorBorlandPainter
      TabStop = True
      TabOrder = 1
      OnDataValueChanged = inspDataValueChanged
      OnEditorKeyDown = inspEditorKeyDown
      ExplicitHeight = 394
    end
  end
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 169
    Height = 444
    Align = alLeft
    Colors.BorderColor = 15987699
    Colors.DisabledColor = clGray
    Colors.DropMarkColor = 15385233
    Colors.DropTargetColor = 15385233
    Colors.DropTargetBorderColor = 15385233
    Colors.FocusedSelectionColor = 15385233
    Colors.FocusedSelectionBorderColor = 15385233
    Colors.GridLineColor = 15987699
    Colors.HeaderHotColor = clBlack
    Colors.HotColor = clBlack
    Colors.SelectionRectangleBlendColor = 15385233
    Colors.SelectionRectangleBorderColor = 15385233
    Colors.SelectionTextColor = clBlack
    Colors.TreeLineColor = 9471874
    Colors.UnfocusedColor = clGray
    Colors.UnfocusedSelectionColor = 13421772
    Colors.UnfocusedSelectionBorderColor = 13421772
    Header.AutoSizeIndex = 0
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoAutoSpring]
    PopupMenu = ppM
    TabOrder = 1
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    OnAddToSelection = TreeAddToSelection
    OnGetText = TreeGetText
    ExplicitHeight = 435
    Columns = <
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Text = 'Device'
        Width = 169
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 88
    Top = 40
    object NConnect: TMenuItem
      Caption = 'Connect (Add) '
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NRemove: TMenuItem
      Caption = 'delete'
      OnClick = NRemoveClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object NUp: TMenuItem
      Caption = 'Up'
      OnClick = NUpClick
    end
    object NDown: TMenuItem
      Caption = 'Down'
      OnClick = NDownClick
    end
  end
  object InspectorBorlandPainter: TJvInspectorBorlandPainter
    CategoryFont.Charset = DEFAULT_CHARSET
    CategoryFont.Color = clBlack
    CategoryFont.Height = -11
    CategoryFont.Name = 'Tahoma'
    CategoryFont.Style = []
    NameFont.Charset = DEFAULT_CHARSET
    NameFont.Color = clWindowText
    NameFont.Height = -11
    NameFont.Name = 'Tahoma'
    NameFont.Style = []
    ValueFont.Charset = DEFAULT_CHARSET
    ValueFont.Color = clNavy
    ValueFont.Height = -11
    ValueFont.Name = 'Tahoma'
    ValueFont.Style = [fsBold]
    DrawNameEndEllipsis = True
    Left = 120
    Top = 40
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 48
    Top = 32
  end
end
