object FormAGK: TFormAGK
  Left = 0
  Top = 0
  ActiveControl = Tree
  Caption = #1052#1077#1090#1088#1086#1083#1086#1075#1080#1103' '#1043#1050
  ClientHeight = 409
  ClientWidth = 869
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
    Width = 869
    Height = 409
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PanelM'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 870
    ExplicitHeight = 311
    object Splitter: TSplitter
      Left = 537
      Top = 0
      Height = 383
      ExplicitLeft = 8
      ExplicitHeight = 377
    end
    object lbInfo: TLabel
      Left = 0
      Top = 396
      Width = 869
      Height = 13
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      WordWrap = True
      ExplicitTop = 402
    end
    object lbAlpha: TLabel
      Left = 0
      Top = 383
      Width = 869
      Height = 13
      Align = alBottom
      AutoSize = False
      WordWrap = True
      ExplicitTop = 377
    end
    object Tree: TVirtualStringTree
      Left = 0
      Top = 0
      Width = 537
      Height = 383
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
      ExplicitHeight = 285
      Columns = <
        item
          Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
          Position = 0
          Width = 34
          WideText = #8470
        end
        item
          Position = 1
          Width = 42
          WideText = #1050#1072#1076#1088
        end
        item
          Position = 2
          Width = 59
          WideText = 'P('#1084#1082#1088'/'#1095') '
        end
        item
          Position = 3
          Width = 53
          WideText = #948'('#1056'),%'
        end
        item
          Position = 4
          Width = 40
          WideText = '1 '#1080#1084#1087'/'#1082#1072#1076#1088
        end
        item
          Position = 5
          Width = 40
          WideText = '2 '#1080#1084#1087'/'#1082#1072#1076#1088
        end
        item
          Position = 6
          Width = 40
          WideText = '3 '#1080#1084#1087'/'#1082#1072#1076#1088
        end
        item
          Position = 7
          Width = 40
          WideText = '4 '#1080#1084#1087'/'#1082#1072#1076#1088
        end
        item
          Position = 8
          Width = 40
          WideText = '1 '#1084#1082#1088'/'#1095
        end
        item
          Position = 9
          Width = 40
          WideText = '2 '#1084#1082#1088'/'#1095
        end
        item
          Position = 10
          Width = 40
          WideText = '3 '#1084#1082#1088'/'#1095
        end
        item
          Position = 11
          Width = 63
          WideText = '4 '#1084#1082#1088'/'#1095
        end>
    end
    object Chart: TChart
      Left = 540
      Top = 0
      Width = 329
      Height = 383
      Legend.CheckBoxes = True
      Legend.TopPos = 6
      Title.Text.Strings = (
        'TChart')
      Title.Visible = False
      BottomAxis.Title.Caption = #1084#1082#1088'/'#1095
      LeftAxis.Title.Caption = #1080#1084#1087'/'#1082#1072#1076#1088
      SeriesGroups = <
        item
          Name = #1044#1072#1085#1085#1099#1077
          Series = (
            '0'
            '1'
            '3'
            '2')
        end
        item
          Name = #1054#1096#1080#1073#1082#1072
          Series = (
            '7'
            '6'
            '4'
            '5')
        end>
      View3D = False
      Zoom.Pen.Mode = pmNotXor
      Align = alClient
      TabOrder = 1
      ExplicitLeft = 456
      ExplicitWidth = 413
      ExplicitHeight = 285
      DefaultCanvas = 'TTeeCanvas3D'
      PrintMargins = (
        15
        8
        15
        8)
      ColorPaletteIndex = 1
      object ls1: TLineSeries
        Legend.Text = #1044#1072#1085#1085#1099#1077'1'
        LegendTitle = #1044#1072#1085#1085#1099#1077'1'
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
      object ls2: TLineSeries
        Legend.Text = #1044#1072#1085#1085#1099#1077'2'
        LegendTitle = #1044#1072#1085#1085#1099#1077'2'
        SeriesColor = 16715161
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
      object ls4: TLineSeries
        Legend.Text = #1044#1072#1085#1085#1099#1077'4'
        LegendTitle = #1044#1072#1085#1085#1099#1077'4'
        SeriesColor = 16750863
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
      object ls3: TLineSeries
        Legend.Text = #1044#1072#1085#1085#1099#1077'3'
        LegendTitle = #1044#1072#1085#1085#1099#1077'3'
        SeriesColor = 1876128
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
      object fs1: TFastLineSeries
        Legend.Text = #1054#1096#1080#1073#1082#1072'1'
        Legend.Visible = False
        LegendTitle = #1054#1096#1080#1073#1082#1072'1'
        ShowInLegend = False
        LinePen.Color = 6697881
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object fs2: TFastLineSeries
        Legend.Text = #1054#1096#1080#1073#1082#1072'2'
        Legend.Visible = False
        LegendTitle = #1054#1096#1080#1073#1082#1072'2'
        ShowInLegend = False
        LinePen.Color = 6697881
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object fs3: TFastLineSeries
        Legend.Text = #1054#1096#1080#1073#1082#1072'3'
        Legend.Visible = False
        LegendTitle = #1054#1096#1080#1073#1082#1072'3'
        ShowInLegend = False
        LinePen.Color = 6697881
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object fs4: TFastLineSeries
        Legend.Text = #1054#1096#1080#1073#1082#1072'4'
        Legend.Visible = False
        LegendTitle = #1054#1096#1080#1073#1082#1072'4'
        ShowInLegend = False
        LinePen.Color = 6697881
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
end
