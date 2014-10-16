object FormDH3: TFormDH3
  Left = 0
  Top = 0
  Caption = #1050#1086#1084#1072#1085#1076#1099'  '#1080#1085#1082#1083#1080#1085#1086#1084#1077#1090#1088#1072' DH3'
  ClientHeight = 453
  ClientWidth = 683
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    683
    453)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 196
    Height = 13
    Caption = #1042#1074#1086#1076#1080#1090#1100' '#1095#1077#1088#1077#1079' "," '#1087#1088#1080#1084#1077#1088': 1F,B3,94,E6'
  end
  object btSend: TButton
    Left = 8
    Top = 58
    Width = 75
    Height = 25
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
    TabOrder = 0
    OnClick = btSendClick
  end
  object edSend: TEdit
    Left = 8
    Top = 24
    Width = 321
    Height = 22
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = 'C7'
  end
  object Memo1: TMemo
    Left = 8
    Top = 96
    Width = 665
    Height = 345
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object Button1: TButton
    Left = 96
    Top = 58
    Width = 75
    Height = 25
    Caption = 'WR_EE'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 177
    Top = 58
    Width = 75
    Height = 25
    Caption = 'RD_EE'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 258
    Top = 58
    Width = 75
    Height = 25
    Caption = 'CLR_TC'
    TabOrder = 5
    OnClick = Button3Click
  end
end
