object FormFindDev: TFormFindDev
  Left = 0
  Top = 0
  Caption = #1055#1086#1080#1089#1082' '#1087#1088#1080#1073#1086#1088#1086#1074' '
  ClientHeight = 639
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 0
    Top = 245
    Width = 605
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 57
    ExplicitWidth = 295
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 605
    Height = 57
    Align = alTop
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object btStart: TButton
      Left = 16
      Top = 17
      Width = 75
      Height = 25
      Caption = #1057#1090#1072#1088#1090
      TabOrder = 0
      OnClick = btStartClick
    end
    object btCansel: TButton
      Left = 112
      Top = 17
      Width = 75
      Height = 25
      Caption = #1055#1088#1077#1088#1074#1072#1090#1100
      Enabled = False
      TabOrder = 1
      OnClick = btCanselClick
    end
    object btExit: TButton
      Left = 208
      Top = 17
      Width = 75
      Height = 25
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 2
      OnClick = btExitClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 57
    Width = 605
    Height = 188
    Align = alClient
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 2
  end
  object Memo: TMemo
    Left = 0
    Top = 248
    Width = 605
    Height = 391
    TabStop = False
    Align = alBottom
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
end
