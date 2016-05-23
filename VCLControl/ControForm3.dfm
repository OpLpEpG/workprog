object FormControl: TFormControl
  Left = 0
  Top = 0
  Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
  ClientHeight = 251
  ClientWidth = 354
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
    Width = 354
    Height = 251
    Align = alClient
    BorderWidth = 1
    Color = clBtnHighlight
    DragMode = dmAutomatic
    DragType = dtVCL
    EditDelay = 100
    Header.AutoSizeIndex = 2
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    Header.ParentFont = True
    PopupMenu = ppM
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toExtendedFocus]
    TreeOptions.StringOptions = []
    OnCreateEditor = TreeCreateEditor
    OnEditing = TreeEditing
    OnGetText = TreeGetText
    OnPaintText = TreePaintText
    OnGetImageIndex = TreeGetImageIndex
    Columns = <
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 0
        Width = 78
        WideText = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086
      end
      item
        Position = 1
        Width = 100
        WideText = #1057#1090#1072#1090#1091#1089
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
        Position = 2
        Width = 170
        WideText = #1042#1088#1077#1084#1103
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 104
    Top = 88
    object NSetup: TMenuItem
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072'...'
      OnClick = NSetupClick
    end
    object NSepConn: TMenuItem
      Caption = '-'
    end
    object NAddDev: TMenuItem
      Caption = #1053#1086#1074#1086#1077' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1086
      OnClick = NAddDevClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object NRemove: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = NRemoveClick
    end
    object NConnect: TMenuItem
      Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100
    end
    object NControl: TMenuItem
      Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
    end
    object NSetupDev: TMenuItem
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072'...'
      OnClick = NSetupDevClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NReadRam: TMenuItem
      Caption = #1063#1090#1077#1085#1080#1077' '#1087#1072#1084#1103#1090#1080' '#1084#1086#1076#1091#1083#1103'...'
      OnClick = NReadRamClick
    end
    object NInfo: TMenuItem
      Caption = #1056#1077#1078#1080#1084' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1080
    end
    object NGlu: TMenuItem
      Caption = #1044#1072#1085#1085#1099#1077' '#1089' '#1087#1088#1080#1074#1103#1079#1082#1086#1081' '#1087#1086' '#1075#1083#1091#1073#1080#1085#1077
    end
    object Neep: TMenuItem
      Caption = 'EEPROM'
    end
    object NMetrol: TMenuItem
      Caption = #1052#1077#1090#1088#1086#1083#1086#1075#1080#1103
    end
    object NSepDEv: TMenuItem
      Caption = '-'
    end
    object NUpdate: TMenuItem
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      OnClick = NUpdateClick
    end
  end
end
