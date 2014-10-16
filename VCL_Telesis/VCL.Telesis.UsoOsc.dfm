object FFTForm: TFFTForm
  Left = 0
  Top = 0
  Caption = #1057#1087#1077#1082#1090#1088
  ClientHeight = 489
  ClientWidth = 726
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
    Top = 301
    Width = 726
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 214
    ExplicitWidth = 275
  end
  object Chart: TChart
    Left = 0
    Top = 0
    Width = 726
    Height = 301
    Cursor = crCross
    AllowPanning = pmNone
    Legend.Visible = False
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    LeftAxis.AxisValuesFormat = '0000.00'
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Align = alClient
    TabOrder = 0
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
    Top = 304
    Width = 726
    Height = 185
    Cursor = crCross
    AllowPanning = pmNone
    Legend.CheckBoxes = True
    Legend.ResizeChart = False
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    BottomAxis.Increment = 16.000000000000000000
    LeftAxis.AxisValuesFormat = '0000.00'
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Align = alBottom
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
end
