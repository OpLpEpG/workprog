object FormParamsAbstract: TFormParamsAbstract
  Left = 0
  Top = 0
  Caption = 'Select data'
  ClientHeight = 424
  ClientWidth = 296
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    296
    424)
  PixelsPerInch = 96
  TextHeight = 13
  object Tree: TVirtualStringTree
    Left = 8
    Top = 8
    Width = 280
    Height = 368
    Anchors = [akLeft, akTop, akRight, akBottom]
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
    OnMouseDown = TreeMouseDown
    Columns = <
      item
        MaxWidth = 24
        MinWidth = 24
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 24
        WideText = #1057
      end
      item
        MaxWidth = 24
        MinWidth = 24
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 24
        WideText = #1056
      end
      item
        Position = 2
        Style = vsOwnerDraw
        Width = 226
        WideText = 'Name'
      end>
  end
  object btExit: TButton
    Left = 8
    Top = 391
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    TabOrder = 1
    OnClick = btExitClick
  end
  object btApply: TButton
    Left = 96
    Top = 391
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Apply'
    Enabled = False
    TabOrder = 2
    OnClick = btApplyClick
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 104
    Top = 88
    object NSet: TMenuItem
      Caption = 'Select '
      object NSetAll: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ClickAllMenu
      end
      object NSetRow: TMenuItem
        Caption = 'Row data'
        OnClick = ClickAllMenu
      end
      object SetTrr: TMenuItem
        Tag = 1
        Caption = 'Calculated'
        OnClick = ClickAllMenu
      end
    end
    object NDel: TMenuItem
      Caption = 'Remove selection'
      object NClrAll: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ClickAllMenu
      end
      object NClrRow: TMenuItem
        Caption = 'Row data'
        OnClick = ClickAllMenu
      end
      object NClrTrr: TMenuItem
        Tag = 1
        Caption = 'Calculated'
        OnClick = ClickAllMenu
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NSetChild: TMenuItem
      Caption = 'Select children'
      object N5: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ClickAllChild
      end
      object N6: TMenuItem
        Caption = 'Row data'
        OnClick = ClickAllChild
      end
      object N7: TMenuItem
        Tag = 1
        Caption = 'Calculated'
        OnClick = ClickAllChild
      end
    end
    object NClrChild: TMenuItem
      Caption = 'Deselect children'
      object N2: TMenuItem
        Tag = 2
        Caption = 'All'
        OnClick = ClickAllChild
      end
      object N3: TMenuItem
        Caption = 'Row data'
        OnClick = ClickAllChild
      end
      object N4: TMenuItem
        Tag = 1
        Caption = 'Calculated'
        OnClick = ClickAllChild
      end
    end
  end
end
