object FormTG: TFormTG
  Left = 0
  Top = 0
  Caption = 'FormTG'
  ClientHeight = 469
  ClientWidth = 1025
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
    Left = 193
    Top = 0
    Width = 832
    Height = 469
    Legend.Visible = False
    MarginBottom = 0
    MarginLeft = 0
    MarginRight = 0
    MarginTop = 0
    Title.Text.Strings = (
      'TChart')
    Title.Visible = False
    BottomAxis.LabelsFormat.TextAlignment = taCenter
    DepthAxis.LabelsFormat.TextAlignment = taCenter
    DepthTopAxis.LabelsFormat.TextAlignment = taCenter
    LeftAxis.LabelsFormat.TextAlignment = taCenter
    RightAxis.LabelsFormat.TextAlignment = taCenter
    Shadow.Visible = False
    TopAxis.Axis.SmallSpace = 1
    TopAxis.LabelsFormat.TextAlignment = taCenter
    View3D = False
    View3DWalls = False
    Zoom.Pen.Mode = pmNotXor
    Align = alClient
    Color = clWhite
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    PrintMargins = (
      15
      23
      15
      23)
    ColorPaletteIndex = 4
    object Button1: TButton
      Left = 184
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Series: TFastLineSeries
      Marks.Visible = False
      LinePen.Color = clBlue
      LinePen.Width = 3
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object SeriesP: TFastLineSeries
      Marks.Visible = False
      LinePen.Color = clRed
      LinePen.Width = 3
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object Series1: TFastLineSeries
      Marks.Visible = False
      SeriesColor = clOlive
      LinePen.Color = clOlive
      LinePen.Width = 3
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
    object SeriesP1: TFastLineSeries
      Marks.Visible = False
      SeriesColor = 8388863
      LinePen.Color = 8388863
      LinePen.Width = 3
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
    end
  end
  object cm: TMemo
    Left = 0
    Top = 0
    Width = 193
    Height = 469
    Align = alLeft
    Lines.Strings = (
      'cm')
    TabOrder = 1
  end
  object Le: TButton
    Left = 234
    Top = 39
    Width = 41
    Height = 25
    Caption = 'S err'
    TabOrder = 2
    OnClick = LeClick
  end
  object Se: TButton
    Left = 234
    Top = 8
    Width = 41
    Height = 25
    Caption = 'S err L'
    TabOrder = 3
    OnClick = SeClick
  end
  object BtL: TButton
    Left = 234
    Top = 70
    Width = 41
    Height = 25
    Caption = 'L err'
    TabOrder = 4
    OnClick = LeClick
  end
end
