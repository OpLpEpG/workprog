object FormInclinCheck: TFormInclinCheck
  Left = 0
  Top = 0
  ActiveControl = Tree
  Caption = #1055#1086#1074#1077#1088#1082#1072' '#1080#1085#1082#1083#1080#1085#1086#1084#1077#1090#1088#1072
  ClientHeight = 314
  ClientWidth = 757
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 227
    Width = 757
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 280
  end
  object PanelM: TPanel
    Left = 0
    Top = 0
    Width = 757
    Height = 227
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PanelM'
    ShowCaption = False
    TabOrder = 0
    object lbInfo: TLabel
      Left = 0
      Top = 214
      Width = 757
      Height = 13
      Align = alBottom
      Alignment = taCenter
      WordWrap = True
      ExplicitWidth = 3
    end
    object pc: TCPageControl
      Left = 0
      Top = 0
      Width = 757
      Height = 214
      Align = alClient
      TabOrder = 1
    end
    object Tree: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 757
      Height = 214
      Align = alClient
      BorderWidth = 1
      Header.AutoSizeIndex = -1
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring]
      Header.ParentFont = True
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnAddToSelection = TreeAddToSelection
      OnGetText = TreeGetText
      Columns = <
        item
          Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Width = 60
          WideText = #8470
        end
        item
          Position = 1
          Width = 60
          WideText = #1040#1079#1080'.'#1089#1090#1086#1083
        end
        item
          Position = 2
          Width = 60
          WideText = #1040#1079#1080#1084#1091#1090
        end
        item
          Position = 3
          Width = 60
          WideText = #1040#1079#1080#1084'.'#1086#1096
        end
        item
          Position = 4
          Width = 60
          WideText = #1047#1077#1085'.'#1089#1090#1086#1083
        end
        item
          Position = 5
          Width = 60
          WideText = #1047#1077#1085#1080#1090
        end
        item
          Position = 6
          Width = 60
          WideText = #1047#1077#1085'.'#1086#1096
        end
        item
          Position = 7
          Width = 60
          WideText = #1042#1080#1079#1080#1088
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 8
          Width = 60
          WideText = #1042#1080#1079#1080#1088' '#1084#1072#1075#1085#1080#1090#1085#1099#1081
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 9
          Width = 60
          WideText = 'G'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 10
          Width = 60
          WideText = 'H'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 11
          Width = 60
          WideText = 'I'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 12
          Width = 60
          WideText = 'Gx'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 13
          Width = 60
          WideText = 'Gy'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 14
          Width = 60
          WideText = 'Gz'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 15
          Width = 60
          WideText = 'Hx'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 16
          Width = 60
          WideText = 'Hy'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 17
          Width = 60
          WideText = 'Hz'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 18
          Width = 60
          WideText = 'Gx.'#1090#1072#1088#1080#1088'.'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 19
          Width = 60
          WideText = 'Gy.'#1090#1072#1088#1080#1088'.'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 20
          Width = 60
          WideText = 'Gz.'#1090#1072#1088#1080#1088'.'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 21
          Width = 60
          WideText = 'Hx.'#1090#1072#1088#1080#1088'.'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 22
          Width = 60
          WideText = 'Hy.'#1090#1072#1088#1080#1088'.'
        end
        item
          Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
          Position = 23
          Width = 271
          WideText = 'Hz.'#1090#1072#1088#1080#1088'.'
        end>
    end
  end
  object PanelP: TPanel
    Left = 0
    Top = 230
    Width = 757
    Height = 84
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'PanelP'
    ShowCaption = False
    TabOrder = 1
    Visible = False
    object Splitter2: TSplitter
      Left = 321
      Top = 0
      Height = 84
      ExplicitLeft = 392
      ExplicitTop = 40
      ExplicitHeight = 100
    end
    object TreeA: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 321
      Height = 84
      Align = alLeft
      BorderWidth = 1
      Header.AutoSizeIndex = -1
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring]
      Header.ParentFont = True
      TabOrder = 0
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toMiddleClickSelect, toMultiSelect, toRightClickSelect]
      OnGetText = TreeAHGetText
      Columns = <
        item
          Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Width = 24
          WideText = 'G'
        end
        item
          Position = 1
          Width = 75
          WideText = 'X'
        end
        item
          Position = 2
          Width = 75
          WideText = 'Y'
        end
        item
          Position = 3
          Width = 75
          WideText = 'Z'
        end
        item
          Position = 4
          Width = 66
          WideText = 'D'
        end>
    end
    object TreeH: TVirtualStringTree
      Left = 324
      Top = 0
      Width = 433
      Height = 84
      Align = alClient
      BorderWidth = 1
      Header.AutoSizeIndex = -1
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring]
      Header.ParentFont = True
      TabOrder = 1
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
      TreeOptions.PaintOptions = [toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toSimpleDrawSelection]
      OnGetText = TreeAHGetText
      Columns = <
        item
          Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Width = 24
          WideText = 'H'
        end
        item
          Position = 1
          Width = 75
          WideText = 'X'
        end
        item
          Position = 2
          Width = 75
          WideText = 'Y'
        end
        item
          Position = 3
          Width = 75
          WideText = 'Z'
        end
        item
          Position = 4
          Width = 178
          WideText = 'D'
        end>
    end
  end
end
