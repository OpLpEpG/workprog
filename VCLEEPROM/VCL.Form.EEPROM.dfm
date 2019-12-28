object FormDlgEeprom: TFormDlgEeprom
  Left = 0
  Top = 0
  Caption = 'FormDlgEeprom'
  ClientHeight = 498
  ClientWidth = 507
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    507
    498)
  PixelsPerInch = 96
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
    Width = 507
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 507
    Height = 442
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderWidth = 1
    Header.AutoSizeIndex = 2
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    Header.ParentFont = True
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
    Columns = <
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Width = 182
        WideText = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 1
        Width = 87
        WideText = 'EEPROM'
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coSmartResize, coAllowFocus]
        Position = 2
        Width = 232
        WideText = #1052#1077#1090#1088#1086#1083#1086#1075#1080#1103
      end>
  end
end
