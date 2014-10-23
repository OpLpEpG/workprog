object FrameFindSP: TFrameFindSP
  Tag = 305419896
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 240
  ClientWidth = 320
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
    Width = 320
    Height = 240
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
    OnAfterDraw = ChartAfterDraw
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
      LinePen.Width = 4
      LinePen.Visible = False
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
