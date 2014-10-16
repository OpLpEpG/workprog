object Form1: TForm1
  Left = 0
  Top = 0
  ActiveControl = Plot1
  Caption = 'Form1'
  ClientHeight = 510
  ClientWidth = 890
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 655
    Top = 8
    Width = 75
    Height = 25
    Caption = 'legend'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 752
    Top = 8
    Width = 75
    Height = 25
    Caption = 'add gr col'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Plot1: TPlot
    Left = 0
    Top = 0
    Width = 890
    Height = 510
    ScaleY = 1.000000000000000000
    YOffset = 0
    Align = alClient
    PlotColumns = <>
  end
  object pp: TPopupActionBar
    Left = 512
    Top = 136
    object q1: TMenuItem
      Caption = 'q'
    end
    object rwer1: TMenuItem
      Caption = 'rwer'
    end
    object fwe1: TMenuItem
      Caption = 'fwe'
    end
  end
end
