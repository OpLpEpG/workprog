object FrmDlgRam: TFrmDlgRam
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1095#1090#1077#1085#1080#1103' '#1087#1072#1084#1103#1090#1080
  ClientHeight = 141
  ClientWidth = 348
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btStart: TButton
    Left = 17
    Top = 81
    Width = 75
    Height = 25
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 0
    OnClick = btStartClick
  end
  object btExit: TButton
    Left = 243
    Top = 81
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    ModalResult = 1
    TabOrder = 1
    OnClick = btExitClick
  end
  object cbTurbo: TCheckBox
    Left = 214
    Top = 16
    Width = 121
    Height = 17
    Caption = #1042#1099#1089#1086#1082#1072#1103' '#1089#1082#1086#1088#1086#1089#1090#1100
    TabOrder = 2
  end
  object cbToFF: TCheckBox
    Left = 18
    Top = 16
    Width = 151
    Height = 17
    Caption = #1063#1080#1090#1072#1090#1100' '#1076#1086' '#1087#1091#1089#1090#1086#1081' '#1087#1072#1084#1103#1090#1080
    TabOrder = 3
  end
  object Progress: TProgressBar
    Left = 18
    Top = 48
    Width = 301
    Height = 17
    TabOrder = 4
  end
  object btTerminate: TButton
    Left = 98
    Top = 81
    Width = 75
    Height = 25
    Caption = #1055#1088#1077#1088#1074#1072#1090#1100
    TabOrder = 5
    OnClick = btTerminateClick
  end
  object sb: TStatusBar
    Left = 0
    Top = 122
    Width = 348
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
end
