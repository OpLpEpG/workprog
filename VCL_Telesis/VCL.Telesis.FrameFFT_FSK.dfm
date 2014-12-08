object FrameFFT_FSK: TFrameFFT_FSK
  Tag = 305419896
  Left = 0
  Top = 0
  Width = 451
  Height = 252
  Align = alTop
  TabOrder = 0
  object Splitter: TSplitter
    Left = 0
    Top = 117
    Width = 451
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = -137
    ExplicitTop = 301
    ExplicitWidth = 726
  end
  object Chart: TChart
    Left = 0
    Top = 0
    Width = 451
    Height = 117
    AllowPanning = pmNone
    Legend.Visible = False
    MarginBottom = 0
    MarginLeft = 0
    MarginRight = 0
    MarginTop = 0
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    LeftAxis.AxisValuesFormat = '#0.#'
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Align = alClient
    PopupMenu = PopupMenu
    TabOrder = 0
    ExplicitHeight = 121
    DefaultCanvas = 'TTeeCanvas3D'
    PrintMargins = (
      15
      29
      15
      29)
    ColorPaletteIndex = 13
    object scFFT: TAreaSeries
      SeriesColor = clYellow
      AreaChartBrush.Color = clGray
      AreaChartBrush.BackColor = clDefault
      AreaLinesPen.Visible = False
      DrawArea = True
      LinePen.Width = 0
      LinePen.Visible = False
      Pointer.Dark3D = False
      Pointer.Draw3D = False
      Pointer.InflateMargins = True
      Pointer.Pen.Visible = False
      Pointer.Style = psRectangle
      Pointer.Visible = False
      Transparency = 50
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object scFlt: TAreaSeries
      SeriesColor = clBlack
      AreaChartBrush.Color = clGray
      AreaChartBrush.BackColor = clDefault
      AreaLinesPen.Visible = False
      DrawArea = True
      LinePen.Visible = False
      Pointer.InflateMargins = True
      Pointer.Pen.Width = 0
      Pointer.Pen.Visible = False
      Pointer.Style = psRectangle
      Pointer.Visible = False
      Transparency = 50
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object ChartT: TChart
    Left = 0
    Top = 120
    Width = 451
    Height = 132
    AllowPanning = pmNone
    Legend.CheckBoxes = True
    Legend.Symbol.Pen.Visible = False
    Legend.Symbol.Shadow.Visible = False
    Legend.Symbol.Squared = False
    Legend.TopPos = 0
    Legend.Transparent = True
    Legend.VertSpacing = -2
    Legend.Visible = False
    MarginBottom = 0
    MarginLeft = 0
    MarginRight = 0
    MarginTop = 0
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    BottomAxis.Increment = 16.000000000000000000
    LeftAxis.AxisValuesFormat = '#0.#'
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Align = alBottom
    PopupMenu = PopupMenu
    TabOrder = 1
    DefaultCanvas = 'TTeeCanvas3D'
    ColorPaletteIndex = 13
    object csInData: TFastLineSeries
      Title = #1042#1093#1086#1076
      LinePen.Color = clTeal
      LinePen.Width = 2
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object scOut: TFastLineSeries
      Title = #1042#1099#1093#1086#1076
      LinePen.Color = clNavy
      LinePen.Width = 2
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object csBit: TFastLineSeries
      Title = #1041#1080#1090
      LinePen.Color = clRed
      LinePen.Width = 2
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object csOI: TFastLineSeries
      Title = #1054#1048
      LinePen.Color = clPurple
      LinePen.Width = 2
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object PopupMenu: TPopupMenu
    Left = 152
    Top = 64
    object N1: TMenuItem
      Caption = #1087#1088#1080#1085#1091#1076#1080#1090#1077#1083#1100#1085#1086' '#1087#1086#1080#1089#1082' '#1057#1055
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #1057#1073#1088#1086#1089#1080#1090#1100' '#1089#1090#1072#1090#1080#1089#1090#1080#1082#1091
      OnClick = N2Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #1047#1072#1076#1072#1090#1100' '#1074#1099#1089#1086#1090#1091'...'
      OnClick = N3Click
    end
  end
end
