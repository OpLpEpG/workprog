object FormWrok: TFormWrok
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1076#1077#1088#1077#1074#1086' '#1076#1072#1085#1085#1099#1093
  ClientHeight = 338
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 636
    Height = 338
    Align = alClient
    BorderWidth = 1
    Header.AutoSizeIndex = 2
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    PopupMenu = ppM
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.PaintOptions = [toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toSimpleDrawSelection]
    TreeOptions.StringOptions = [toSaveCaptions, toShowStaticText, toAutoAcceptEditChange]
    OnGetText = TreeGetText
    Columns = <
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Text = #1055#1072#1088#1072#1084#1077#1090#1088#1099
        Width = 180
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 1
        Text = #1041#1077#1079' '#1092#1086#1088#1084#1072#1090#1080#1088#1086#1074#1072#1085#1080#1103
        Width = 170
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coSmartResize, coAllowFocus]
        Position = 2
        Text = #1057' '#1084#1077#1090#1088#1086#1083#1086#1075#1080#1077#1081
        Width = 286
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 240
    Top = 136
    object NShow: TMenuItem
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1085#1072' '#1085#1086#1074#1086#1084' '#1075#1088#1072#1092#1080#1082#1077
      OnClick = NShowClick
    end
  end
end
