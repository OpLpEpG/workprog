object FormTest: TFormTest
  Left = 0
  Top = 0
  Caption = 'FormTest'
  ClientHeight = 289
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 554
    Height = 289
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button1: TButton
    Left = 496
    Top = 8
    Width = 33
    Height = 25
    Caption = 'CR'
    TabOrder = 1
    OnClick = Button1Click
  end
end
