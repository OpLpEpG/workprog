object OscForm: TOscForm
  Left = 0
  Top = 0
  Caption = #1054#1082#1085#1086' '#1086#1089#1094#1080#1083#1086#1075#1088#1072#1084#1084
  ClientHeight = 289
  ClientWidth = 825
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Chart: TChart
    Left = 0
    Top = 0
    Width = 825
    Height = 289
    Cursor = crCross
    AllowPanning = pmNone
    Legend.CheckBoxes = True
    Legend.LegendStyle = lsSeries
    Legend.ResizeChart = False
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Increment = 16.000000000000000000
    BottomAxis.LabelsSeparation = 0
    BottomAxis.LabelStyle = talValue
    BottomAxis.Maximum = 512.000000000000000000
    LeftAxis.AxisValuesFormat = '#0.#'
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Align = alClient
    TabOrder = 0
    DefaultCanvas = 'TTeeCanvas3D'
    PrintMargins = (
      15
      24
      15
      24)
    ColorPaletteIndex = 13
  end
end
