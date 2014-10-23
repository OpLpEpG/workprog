object UsoOscForm: TUsoOscForm
  Left = 0
  Top = 0
  Caption = #1054#1089#1094'.'#1059#1089#1086
  ClientHeight = 214
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
  object Chart: TChart
    Left = 0
    Top = 0
    Width = 554
    Height = 214
    Cursor = crCross
    AllowPanning = pmNone
    Legend.Visible = False
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Maximum = 383.000000000000000000
    LeftAxis.AxisValuesFormat = '#0.#'
    RightAxis.Visible = False
    TopAxis.Visible = False
    View3D = False
    Zoom.Allow = False
    Align = alClient
    TabOrder = 0
    DefaultCanvas = 'TTeeCanvas3D'
    ColorPaletteIndex = 13
    object Series: TFastLineSeries
      LinePen.Color = 10708548
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
end
