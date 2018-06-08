object FormGK: TFormGK
  Left = 0
  Top = 0
  Caption = #1052#1077#1090#1088#1086#1083#1086#1075#1080#1103' '#1043#1050
  ClientHeight = 311
  ClientWidth = 670
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PanelM: TPanel
    Left = 0
    Top = 0
    Width = 670
    Height = 311
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PanelM'
    ShowCaption = False
    TabOrder = 0
    object Splitter: TSplitter
      Left = 329
      Top = 0
      Height = 285
      ExplicitLeft = 8
      ExplicitHeight = 377
    end
    object lbInfo: TLabel
      Left = 0
      Top = 298
      Width = 670
      Height = 13
      Align = alBottom
      Alignment = taCenter
      ExplicitWidth = 3
    end
    object lbAlpha: TLabel
      Left = 0
      Top = 285
      Width = 670
      Height = 13
      Align = alBottom
      ExplicitWidth = 3
    end
    object Tree: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 329
      Height = 285
      Align = alLeft
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
          WideText = #8470
        end
        item
          Position = 1
          WideText = 'R,'#1084
        end
        item
          Position = 2
          Width = 61
          WideText = 'P('#1084#1082#1088'/'#1095') '
        end
        item
          Position = 3
          Width = 52
          WideText = #1080#1084#1087'/'#1082#1072#1076#1088
        end
        item
          Position = 4
          WideText = 'P('#1084#1082#1088'/'#1095') '#1088#1072#1089#1095#1080#1090#1072#1085#1085#1086#1077
        end
        item
          Position = 5
          Width = 60
          WideText = #948'('#1056'),%'
        end>
    end
    object Chart: TChart
      Left = 332
      Top = 0
      Width = 338
      Height = 285
      Legend.Alignment = laTop
      Legend.LegendStyle = lsSeries
      Legend.ResizeChart = False
      Legend.TopPos = 6
      Legend.Visible = False
      Title.Text.Strings = (
        'TChart')
      Title.Visible = False
      BottomAxis.Title.Caption = #1084#1082#1088'/'#1095
      LeftAxis.Title.Caption = #1080#1084#1087'/'#1082#1072#1076#1088
      View3D = False
      Zoom.Pen.Mode = pmNotXor
      Align = alClient
      TabOrder = 1
      DefaultCanvas = 'TTeeCanvas3D'
      PrintMargins = (
        15
        8
        15
        8)
      ColorPaletteIndex = 1
      object Series: TLineSeries
        Legend.Text = #1044#1072#1085#1085#1099#1077
        LegendTitle = #1044#1072#1085#1085#1099#1077
        Brush.BackColor = clDefault
        LinePen.Width = 3
        Pointer.Brush.Gradient.EndColor = 16751001
        Pointer.Gradient.EndColor = 16751001
        Pointer.InflateMargins = True
        Pointer.Style = psRectangle
        Pointer.Visible = True
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
        Transparency = 8
      end
      object SeriesLS: TFastLineSeries
        LinePen.Color = 6697881
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
end
