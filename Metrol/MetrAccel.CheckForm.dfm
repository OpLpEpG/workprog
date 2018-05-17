object FormAccelCheck: TFormAccelCheck
  Left = 0
  Top = 0
  ActiveControl = Tree
  Caption = #1040#1090#1090#1077#1089#1090#1072#1094#1080#1103' '#1072#1082#1089#1077#1083#1077#1088#1086#1084#1077#1090#1088#1072
  ClientHeight = 314
  ClientWidth = 672
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
    Width = 672
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 280
  end
  object PanelM: TPanel
    Left = 0
    Top = 0
    Width = 672
    Height = 227
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PanelM'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 757
    object lbInfo: TLabel
      Left = 0
      Top = 214
      Width = 672
      Height = 13
      Align = alBottom
      Alignment = taCenter
      WordWrap = True
      ExplicitWidth = 3
    end
    object pc: TCPageControl
      Left = 0
      Top = 0
      Width = 672
      Height = 214
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 757
    end
    object Tree: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 672
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
      ExplicitWidth = 757
      Columns = <
        item
          Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Width = 60
          WideText = #8470
        end
        item
          Position = 1
          Width = 69
          WideText = #1047#1077#1085#1080#1090
        end
        item
          Position = 2
          Width = 61
          WideText = #1042#1080#1079#1080#1088
        end
        item
          Position = 3
          Width = 72
          WideText = 'G'
        end
        item
          Position = 4
          Width = 68
          WideText = 'Gx'
        end
        item
          Position = 5
          Width = 63
          WideText = 'Gy'
        end
        item
          Position = 6
          Width = 67
          WideText = 'Gz'
        end
        item
          Position = 7
          Width = 69
          WideText = 'Gx.'#1090#1072#1088#1080#1088'.'
        end
        item
          Position = 8
          Width = 69
          WideText = 'Gy.'#1090#1072#1088#1080#1088'.'
        end
        item
          Position = 9
          Width = 68
          WideText = 'Gz.'#1090#1072#1088#1080#1088'.'
        end>
    end
  end
  object PanelP: TPanel
    Left = 0
    Top = 230
    Width = 672
    Height = 84
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'PanelP'
    ShowCaption = False
    TabOrder = 1
    Visible = False
    ExplicitWidth = 757
    object TreeA: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 672
      Height = 84
      Align = alClient
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
      ExplicitWidth = 757
      Columns = <
        item
          Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Width = 34
          WideText = 'G'
        end
        item
          Position = 1
          Width = 126
          WideText = 'X'
        end
        item
          Position = 2
          Width = 136
          WideText = 'Y'
        end
        item
          Position = 3
          Width = 126
          WideText = 'Z'
        end
        item
          Position = 4
          Width = 244
          WideText = 'D'
        end>
    end
  end
end
