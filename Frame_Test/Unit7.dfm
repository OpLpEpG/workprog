object Form7: TForm7
  Left = 0
  Top = 0
  Caption = 'Form7'
  ClientHeight = 371
  ClientWidth = 636
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 536
    Top = 328
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 152
    Top = 32
    Width = 459
    Height = 273
    Caption = 'Panel1'
    TabOrder = 1
    inline Frame21: TFrame2
      Left = 1
      Top = 1
      Width = 457
      Height = 271
      Align = alClient
      TabOrder = 0
      ExplicitLeft = -29
      ExplicitTop = 17
      inherited Chart1: TChart
        Width = 457
        Height = 271
        ExplicitLeft = 184
        ExplicitTop = -3
        ExplicitWidth = 320
        ExplicitHeight = 240
      end
    end
  end
  object Button2: TButton
    Left = 432
    Top = 328
    Width = 75
    Height = 25
    Caption = 'load'
    TabOrder = 2
    OnClick = Button2Click
  end
end
