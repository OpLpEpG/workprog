object FrameSelectParam: TFrameSelectParam
  Left = 0
  Top = 0
  Width = 451
  Height = 305
  Align = alClient
  TabOrder = 0
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 451
    Height = 305
    Align = alClient
    BorderWidth = 1
    Color = clBtnHighlight
    DragMode = dmAutomatic
    DragType = dtVCL
    Header.AutoSizeIndex = 2
    Header.MainColumn = 2
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible, hoAutoSpring]
    Header.ParentFont = True
    PopupMenu = ppM
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideFocusRect, toHideSelection, toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toMultiSelect, toSimpleDrawSelection]
    OnAfterCellPaint = TreeAfterCellPaint
    OnGetText = TreeGetText
    OnGetNodeDataSize = TreeGetNodeDataSize
    OnMouseDown = TreeMouseDown
    Columns = <
      item
        MaxWidth = 24
        MinWidth = 24
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 24
        WideText = 'D'
      end
      item
        MaxWidth = 24
        MinWidth = 24
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 24
        WideText = 'C'
      end
      item
        Position = 2
        Width = 403
        WideText = #1048#1084#1103
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 104
    Top = 88
    object NSet: TMenuItem
      Caption = #1042#1099#1073#1088#1072#1090#1100' '
      object NSetAll: TMenuItem
        Tag = 2
        Caption = #1042#1089#1077
      end
      object NSetRow: TMenuItem
        Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
      end
      object NSetTrr: TMenuItem
        Tag = 1
        Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
      end
    end
    object NDel: TMenuItem
      Caption = #1057#1085#1103#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1080#1077
      object NClrAll: TMenuItem
        Tag = 2
        Caption = #1042#1089#1077
      end
      object NClrRow: TMenuItem
        Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
      end
      object NClrTrr: TMenuItem
        Tag = 1
        Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NSetChild: TMenuItem
      Caption = #1042#1099#1073#1088#1072#1090#1100' '#1076#1086#1095#1077#1088#1085#1080#1077
      object NSetChildALL: TMenuItem
        Tag = 2
        Caption = #1042#1089#1077
      end
      object NSetChildRow: TMenuItem
        Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
      end
      object NSetChildTRR: TMenuItem
        Tag = 1
        Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
      end
    end
    object NClrChild: TMenuItem
      Caption = #1057#1085#1103#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1080#1077' '#1076#1086#1095#1077#1088#1085#1080#1093
      object NClrChildALL: TMenuItem
        Tag = 2
        Caption = #1042#1089#1077
      end
      object NClrChildRow: TMenuItem
        Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
      end
      object NClrChildTrr: TMenuItem
        Tag = 1
        Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
      end
    end
  end
end
