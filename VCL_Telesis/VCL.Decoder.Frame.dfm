object FrameDecoderStandart: TFrameDecoderStandart
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 404
  ClientWidth = 610
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object PanelCOD: TPanel
    Left = 0
    Top = 0
    Width = 610
    Height = 404
    Align = alClient
    Caption = 'PanelFindSP'
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 452
      Top = 1
      Height = 402
      Align = alRight
      Color = clRed
      ParentColor = False
      ExplicitLeft = 288
      ExplicitTop = 40
      ExplicitHeight = 100
    end
    object Panel: TPanel
      Left = 1
      Top = 1
      Width = 451
      Height = 402
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel'
      TabOrder = 0
      object Splitter1: TSplitter
        Left = 0
        Top = 129
        Width = 451
        Height = 3
        Cursor = crVSplit
        Align = alTop
        Color = clRed
        ParentColor = False
        ExplicitTop = 105
        ExplicitWidth = 281
      end
      object Chart: TChart
        Left = 0
        Top = 0
        Width = 451
        Height = 129
        AllowPanning = pmNone
        BottomWall.Visible = False
        LeftWall.Visible = False
        Legend.Visible = False
        MarginBottom = 1
        MarginLeft = 0
        MarginRight = 1
        MarginTop = 1
        MarginUnits = muPixels
        Title.Text.Strings = (
          'TChart')
        Title.Visible = False
        BottomAxis.Axis.Width = 0
        LeftAxis.Axis.Width = 0
        LeftAxis.AxisValuesFormat = '#0.#'
        LeftAxis.LabelsFormat.Font.Shadow.Smooth = False
        LeftAxis.LabelsFormat.Font.Shadow.Visible = False
        LeftAxis.LabelsFormat.Shadow.Visible = False
        LeftAxis.LabelsSeparation = 20
        LeftAxis.LabelStyle = talValue
        RightAxis.Visible = False
        Shadow.Visible = False
        TopAxis.Visible = False
        View3D = False
        View3DWalls = False
        Zoom.Allow = False
        Zoom.Pen.Visible = False
        Align = alTop
        BevelOuter = bvNone
        PopupMenu = PopupMenu
        TabOrder = 0
        DefaultCanvas = 'TTeeCanvas3D'
        PrintMargins = (
          15
          23
          15
          23)
        ColorPaletteIndex = 19
        object BarSeriesSP: TBarSeries
          BarBrush.BackColor = clDefault
          BarPen.Width = 4
          BarPen.Visible = False
          Marks.Visible = False
          Marks.Callout.Length = 8
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Bar'
          YValues.Order = loNone
        end
      end
      object ChartCode: TChart
        Left = 0
        Top = 132
        Width = 451
        Height = 270
        AllowPanning = pmNone
        BottomWall.Visible = False
        LeftWall.Visible = False
        Legend.CheckBoxes = True
        Legend.ResizeChart = False
        MarginBottom = 1
        MarginLeft = 0
        MarginRight = 1
        MarginTop = 1
        MarginUnits = muPixels
        Title.Text.Strings = (
          'TChart')
        Title.Visible = False
        BottomAxis.Axis.Width = 0
        BottomAxis.LabelStyle = talValue
        LeftAxis.Axis.Width = 0
        LeftAxis.AxisValuesFormat = '#0.#'
        LeftAxis.LabelsFormat.Font.Shadow.Smooth = False
        LeftAxis.LabelsFormat.Font.Shadow.Visible = False
        LeftAxis.LabelsFormat.Shadow.Visible = False
        LeftAxis.LabelsSeparation = 20
        LeftAxis.LabelStyle = talValue
        RightAxis.Visible = False
        Shadow.Visible = False
        TopAxis.Increment = 8.000000000000000000
        TopAxis.Visible = False
        View3D = False
        View3DWalls = False
        Zoom.Allow = False
        Zoom.Pen.Visible = False
        Align = alClient
        BevelOuter = bvNone
        PopupMenu = PopupMenu
        TabOrder = 1
        DefaultCanvas = 'TTeeCanvas3D'
        PrintMargins = (
          15
          23
          15
          23)
        ColorPaletteIndex = 19
        object srCorr: TBarSeries
          BarBrush.BackColor = clDefault
          BarPen.Width = 4
          BarPen.Visible = False
          Marks.Visible = False
          Marks.AutoPosition = False
          Marks.Callout.Length = 8
          Title = #1050#1086#1088#1088
          Transparency = 71
          BarWidthPercent = 100
          MultiBar = mbNone
          OffsetPercent = 50
          Shadow.Visible = False
          SideMargins = False
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Bar'
          YValues.Order = loNone
        end
        object srPorog: TFastLineSeries
          Title = #1055#1086#1088#1086#1075
          LinePen.Color = 13395626
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object srData: TFastLineSeries
          SeriesColor = 64
          Title = #1057#1080#1075#1085#1072#1083
          LinePen.Color = 64
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object srNoise: TFastLineSeries
          SeriesColor = 8388863
          Title = #1064#1091#1084
          LinePen.Color = 8388863
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object srSignalShum: TFastLineSeries
          SeriesColor = 10485760
          Title = #1057'+'#1064
          LinePen.Color = 10485760
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object srMul: TFastLineSeries
          SeriesColor = 8421631
          Title = 'Mul'
          LinePen.Color = 8421631
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object srBit: TFastLineSeries
          SeriesColor = clTeal
          Title = 'bit'
          LinePen.Color = clTeal
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
        object srZerro: TFastLineSeries
          SeriesColor = 16711808
          Title = 'zerro'
          LinePen.Color = 16711808
          LinePen.Width = 3
          XValues.Name = 'X'
          XValues.Order = loAscending
          YValues.Name = 'Y'
          YValues.Order = loNone
        end
      end
    end
    object Memo: TMemo
      Left = 455
      Top = 1
      Width = 154
      Height = 402
      Align = alRight
      BorderStyle = bsNone
      Color = clBtnFace
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      PopupMenu = PopupMenu
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object PanelFindSP: TPanel
    Left = 0
    Top = 0
    Width = 610
    Height = 404
    Align = alClient
    Caption = 'PanelFindSP'
    ShowCaption = False
    TabOrder = 0
    object ChartSP: TChart
      Left = 1
      Top = 1
      Width = 608
      Height = 402
      AllowPanning = pmNone
      BottomWall.Visible = False
      LeftWall.Visible = False
      Legend.Visible = False
      MarginBottom = 1
      MarginLeft = 0
      MarginRight = 1
      MarginTop = 1
      MarginUnits = muPixels
      Title.Text.Strings = (
        'TChart')
      Title.Visible = False
      BottomAxis.Automatic = False
      BottomAxis.AutomaticMaximum = False
      BottomAxis.AutomaticMinimum = False
      BottomAxis.Axis.Width = 0
      BottomAxis.Maximum = 24.000000000000000000
      LeftAxis.Axis.Width = 0
      LeftAxis.AxisValuesFormat = '#0.#'
      LeftAxis.LabelsFormat.Font.Shadow.Smooth = False
      LeftAxis.LabelsFormat.Font.Shadow.Visible = False
      LeftAxis.LabelsFormat.Shadow.Visible = False
      LeftAxis.LabelsSeparation = 20
      LeftAxis.LabelStyle = talValue
      RightAxis.Visible = False
      Shadow.Visible = False
      TopAxis.Visible = False
      View3D = False
      View3DWalls = False
      Zoom.Allow = False
      Zoom.Pen.Visible = False
      OnAfterDraw = ChartSPAfterDraw
      Align = alClient
      BevelOuter = bvNone
      PopupMenu = PopupMenuSP
      TabOrder = 0
      DefaultCanvas = 'TTeeCanvas3D'
      PrintMargins = (
        15
        23
        15
        23)
      ColorPaletteIndex = 19
      object SeriesSP: TLineSeries
        Shadow.Visible = False
        Brush.BackColor = clDefault
        Dark3D = False
        LinePen.Width = 4
        Pointer.InflateMargins = True
        Pointer.Style = psRectangle
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object SeriesCorr: TFastLineSeries
        DrawAllPointsStyle = daMinMax
        FastPen = True
        LinePen.Color = clDefault
        LinePen.Width = 0
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
  object PopupMenuSP: TPopupMenu
    Left = 64
    Top = 48
    object N1: TMenuItem
      Caption = #1087#1088#1080#1085#1091#1076#1080#1090#1077#1083#1100#1085#1086' '#1057#1055
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object NPause: TMenuItem
      AutoCheck = True
      Caption = #1055#1072#1091#1079#1072
    end
  end
  object PopupMenu: TPopupMenu
    Left = 144
    Top = 48
    object MenuItem1: TMenuItem
      Caption = #1087#1088#1080#1085#1091#1076#1080#1090#1077#1083#1100#1085#1086' '#1087#1086#1080#1089#1082' '#1057#1055
      OnClick = MenuItem1Click
    end
    object MenuItem2: TMenuItem
      Caption = #1057#1073#1088#1086#1089#1080#1090#1100' '#1089#1090#1072#1090#1080#1089#1090#1080#1082#1091
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object NPauseCode: TMenuItem
      AutoCheck = True
      Caption = #1055#1072#1091#1079#1072
    end
    object NShowCode: TMenuItem
      Caption = #1087#1077#1088#1082#1081#1090#1080' '#1082' '#1076#1072#1085#1085#1099#1084
    end
    object NLegend: TMenuItem
      AutoCheck = True
      Caption = #1051#1077#1075#1077#1085#1076#1072
      Checked = True
      OnClick = NLegendClick
    end
    object N6: TMenuItem
      Caption = #1052#1077#1084#1086' '#1086#1095#1080#1089#1090#1080#1090#1100
      OnClick = N6Click
    end
  end
end
