object FormRamTest: TFormRamTest
  Left = 0
  Top = 0
  Caption = #1055#1088#1086#1074#1077#1088#1082#1072' '#1087#1072#1084#1103#1090#1080
  ClientHeight = 307
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object sb: TStatusBar
    Left = 0
    Top = 288
    Width = 584
    Height = 19
    Panels = <
      item
        Width = 600
      end>
  end
  object Memo: TMemo
    Left = 121
    Top = 0
    Width = 463
    Height = 288
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 121
    Height = 288
    Align = alLeft
    TabOrder = 2
    object Label1: TLabel
      Left = 10
      Top = 0
      Width = 59
      Height = 30
      AutoSize = False
      Caption = #1072#1076#1088#1077#1089' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072
      WordWrap = True
    end
    object Label2: TLabel
      Left = 40
      Top = 43
      Width = 49
      Height = 27
      AutoSize = False
      Caption = #1089#1090#1088#1072#1085#1080#1094#1072' '#1079#1072#1087#1080#1089#1080
      WordWrap = True
    end
    object lbBaseW: TLabel
      Left = 87
      Top = 72
      Width = 6
      Height = 13
      Caption = '0'
    end
    object edADR: TEdit
      Left = 87
      Top = 2
      Width = 29
      Height = 21
      TabOrder = 0
      Text = '4'
    end
    object edPageW: TEdit
      Left = 40
      Top = 69
      Width = 41
      Height = 21
      TabOrder = 1
      Text = '0'
    end
    object btSetBase: TButton
      Left = 6
      Top = 67
      Width = 28
      Height = 25
      Caption = 'Set'
      TabOrder = 2
      OnClick = btSetBaseClick
    end
    object btRead: TButton
      Left = 6
      Top = 154
      Width = 110
      Height = 25
      Caption = #1095#1080#1090#1072#1090#1100' '#1087#1072#1084#1103#1090#1100
      TabOrder = 3
      OnClick = btReadClick
    end
    object btWrite: TButton
      Left = 6
      Top = 96
      Width = 110
      Height = 25
      Caption = #1079#1072#1087#1080#1089#1100' '#1074' '#1087#1072#1084#1103#1090#1100
      TabOrder = 4
      OnClick = btWriteClick
    end
    object edBaseR: TEdit
      Left = 80
      Top = 127
      Width = 34
      Height = 21
      TabOrder = 5
      Text = '0'
    end
    object edPageR: TEdit
      Left = 39
      Top = 127
      Width = 41
      Height = 21
      TabOrder = 6
      Text = '0'
    end
    object btClear: TButton
      Left = 6
      Top = 193
      Width = 109
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100' memo'
      TabOrder = 7
      OnClick = btClearClick
    end
  end
end
