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
    DragMode = dmAutomatic
    DragType = dtVCL
    Header.AutoSizeIndex = 2
    Header.MainColumn = 2
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible, hoAutoSpring]
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
        Text = 'D'
        Width = 24
      end
      item
        MaxWidth = 24
        MinWidth = 24
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Text = 'C'
        Width = 24
      end
      item
        Position = 2
        Text = 'Name'
        Width = 403
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 104
    Top = 88
    object NSet: TMenuItem
      Caption = 'Select '
      object NSetAll: TMenuItem
        Tag = 2
        Caption = 'all'
        OnClick = ppClick
      end
      object NSetRow: TMenuItem
        Caption = '[D] Row data'
        OnClick = ppClick
      end
      object NSetTrr: TMenuItem
        Tag = 1
        Caption = '[C] Calculated'
        OnClick = ppClick
      end
    end
    object NDel: TMenuItem
      Caption = 'Deselect'
      object NClrAll: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ppClick
      end
      object NClrRow: TMenuItem
        Caption = '[D] Row data'
        OnClick = ppClick
      end
      object NClrTrr: TMenuItem
        Tag = 1
        Caption = '[C] Calculated'
        OnClick = ppClick
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NSetChild: TMenuItem
      Caption = 'Select children'
      object NSetChildALL: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ppClick
      end
      object NSetChildRow: TMenuItem
        Caption = '[D] Row data'
        OnClick = ppClick
      end
      object NSetChildTRR: TMenuItem
        Tag = 1
        Caption = '[C] Calculated'
        OnClick = ppClick
      end
    end
    object NClrChild: TMenuItem
      Caption = 'Deselect children'
      object NClrChildALL: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ppClick
      end
      object NClrChildRow: TMenuItem
        Caption = '[D] Row data'
        OnClick = ppClick
      end
      object NClrChildTrr: TMenuItem
        Tag = 1
        Caption = '[C] Calculated'
        OnClick = ppClick
      end
    end
  end
end
