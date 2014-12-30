object FormShowArray: TFormShowArray
  Left = 0
  Top = 0
  Caption = 'FormShowArray'
  ClientHeight = 289
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ChartCode: TChart
    Left = 0
    Top = 0
    Width = 554
    Height = 289
    AllowPanning = pmNone
    BottomWall.Visible = False
    LeftWall.Visible = False
    Legend.CheckBoxes = True
    Legend.GlobalTransparency = 18
    Legend.ResizeChart = False
    Legend.TopPos = 0
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
    View3DOptions.Orthogonal = False
    View3DWalls = False
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
    object srDev: TFastLineSeries
      Title = #1089#1099#1088#1099#1077
      LinePen.Color = 15054131
      LinePen.Width = 2
      TreatNulls = tnDontPaint
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object srCLC: TFastLineSeries
      Title = #1089' '#1084#1077#1090#1088#1086#1083#1086#1075#1080#1077#1081
      LinePen.Color = 13395626
      LinePen.Width = 3
      TreatNulls = tnDontPaint
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
end
