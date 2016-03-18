object FrameSelectPath: TFrameSelectPath
  Left = 0
  Top = 0
  Width = 451
  Height = 305
  Align = alClient
  TabOrder = 0
  ExplicitWidth = 320
  ExplicitHeight = 240
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BorderWidth = 1
    Color = clBtnHighlight
    DragMode = dmAutomatic
    DragType = dtVCL
    Header.AutoSizeIndex = 0
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible, hoAutoSpring]
    Header.ParentFont = True
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideFocusRect, toHideSelection, toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toMultiSelect, toSimpleDrawSelection]
    OnChecked = TreeChecked
    OnGetText = TreeGetText
    OnGetNodeDataSize = TreeGetNodeDataSize
    ExplicitTop = -69
    ExplicitWidth = 275
    ExplicitHeight = 309
    Columns = <
      item
        Position = 0
        Style = vsOwnerDraw
        Width = 320
        WideText = #1055#1091#1090#1100
      end>
  end
end
