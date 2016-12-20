object Frame2: TFrame2
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object Chart1: TChart
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Title.Text.Strings = (
      'TChart')
    View3D = False
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 104
    ExplicitTop = 72
    ExplicitWidth = 400
    ExplicitHeight = 250
    DefaultCanvas = 'TTeeCanvas3D'
    ColorPaletteIndex = 13
    object Series1: TBarSeries
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Bar'
      YValues.Order = loNone
    end
    object Series2: TLineSeries
      Brush.BackColor = clDefault
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
end
