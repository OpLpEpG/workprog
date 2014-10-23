object FrameFindSP: TFrameFindSP
  Tag = 305419896
  Left = 0
  Top = 0
  Align = alClient
  ClientHeight = 266
  ClientWidth = 555
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Chart: TChart
    Left = 0
    Top = 0
    Width = 555
    Height = 266
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
    BottomAxis.Maximum = 24.000000000000000000
    BottomAxis.Visible = False
    LeftAxis.Automatic = False
    LeftAxis.AutomaticMaximum = False
    LeftAxis.AutomaticMinimum = False
    LeftAxis.Axis.Visible = False
    LeftAxis.AxisValuesFormat = '#.#'
    LeftAxis.LabelsFormat.Font.Shadow.Smooth = False
    LeftAxis.LabelsFormat.Font.Shadow.Visible = False
    LeftAxis.LabelsFormat.Shadow.Visible = False
    LeftAxis.LabelsSeparation = 20
    LeftAxis.LabelStyle = talValue
    LeftAxis.Maximum = 270.000000000000000000
    LeftAxis.Minimum = 15.000000000000000000
    RightAxis.Visible = False
    Shadow.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Zoom.Pen.Visible = False
    Align = alClient
    BevelOuter = bvNone
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
      LinePen.Width = 2
      LinePen.Visible = False
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object SeriesCorr: TFastLineSeries
      DrawAllPoints = False
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
