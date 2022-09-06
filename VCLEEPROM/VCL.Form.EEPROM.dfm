object FormDlgEeprom: TFormDlgEeprom
  Left = 0
  Top = 0
  Caption = 'FormDlgEeprom'
  ClientHeight = 498
  ClientWidth = 551
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  DesignSize = (
    551
    498)
  TextHeight = 13
  object btRead: TButton
    Left = 21
    Top = 448
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1063#1080#1090#1072#1090#1100
    TabOrder = 0
    OnClick = btReadClick
  end
  object btWrite: TButton
    Left = 117
    Top = 448
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1080#1089#1072#1090#1100
    TabOrder = 1
    OnClick = btWriteClick
  end
  object btExit: TButton
    Left = 216
    Top = 448
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1093#1086#1076
    ModalResult = 1
    TabOrder = 2
    OnClick = btExitClick
  end
  object st: TStatusBar
    Left = 0
    Top = 479
    Width = 551
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 551
    Height = 442
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderWidth = 1
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
    Header.AutoSizeIndex = 2
    Header.Height = 17
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    PopupMenu = ppm
    TabOrder = 4
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toExtendedFocus]
    TreeOptions.StringOptions = []
    OnCreateEditor = TreeCreateEditor
    OnEditing = TreeEditing
    OnGetText = TreeGetText
    OnPaintText = TreePaintText
    OnGetNodeDataSize = TreeGetNodeDataSize
    Columns = <
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Text = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '
        Width = 182
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 1
        Text = 'EEPROM'
        Width = 60
      end
      item
        Position = 2
        Text = #1056#1072#1089#1095#1077#1090#1085#1099#1077
        Width = 82
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coSmartResize, coAllowFocus]
        Position = 3
        Text = #1052#1077#1090#1088#1086#1083#1086#1075#1080#1103
        Width = 161
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus, coStyleColor]
        Position = 4
        Text = #1077#1076#1080#1085#1080#1094#1099
        Width = 60
      end>
  end
  object ppm: TPopupMenu
    OnPopup = ppmPopup
    Left = 248
    Top = 176
    object EEPROM1: TMenuItem
      Caption = #1047#1072#1087#1080#1089#1072#1090#1100' '#1057#1077#1082#1094#1080#1102' EEPROM'
      OnClick = EEPROM1Click
    end
  end
end
