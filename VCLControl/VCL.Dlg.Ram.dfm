object FormDlgRam: TFormDlgRam
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1095#1090#1077#1085#1080#1103' '#1087#1072#1084#1103#1090#1080
  ClientHeight = 279
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    385
    279)
  PixelsPerInch = 96
  TextHeight = 13
  object lbFile: TLabel
    Left = 18
    Top = 8
    Width = 125
    Height = 13
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1073#1080#1085#1072#1088#1085#1099#1081' '#1092#1072#1081#1083
  end
  object lbLen: TLabel
    Left = 225
    Top = 66
    Width = 85
    Height = 13
    Caption = #1076#1083#1080#1085#1072' '#1087#1072#1082#1077#1090#1072' 0x'
  end
  object lbEnd: TLabel
    Left = 250
    Top = 112
    Width = 115
    Height = 13
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1052#1073' (0-'#1074#1089#1077')'
    Enabled = False
  end
  object lbBegin: TLabel
    Left = 121
    Top = 112
    Width = 54
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1086' '#1052#1073
    Enabled = False
  end
  object lbSD: TLabel
    Left = 18
    Top = 112
    Width = 44
    Height = 13
    Caption = #1044#1080#1089#1082'  SD'
    Enabled = False
  end
  object btStart: TButton
    Left = 17
    Top = 223
    Width = 75
    Height = 25
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 0
    OnClick = btStartClick
  end
  object btExit: TButton
    Left = 294
    Top = 223
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    ModalResult = 1
    TabOrder = 1
    OnClick = btExitClick
  end
  object cbToFF: TCheckBox
    Left = 18
    Top = 165
    Width = 151
    Height = 17
    Caption = #1063#1080#1090#1072#1090#1100' '#1076#1086' '#1087#1091#1089#1090#1086#1081' '#1087#1072#1084#1103#1090#1080
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object Progress: TProgressBar
    Left = 18
    Top = 196
    Width = 350
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object btTerminate: TButton
    Left = 98
    Top = 223
    Width = 75
    Height = 25
    Caption = #1055#1088#1077#1088#1074#1072#1090#1100
    TabOrder = 4
    OnClick = btTerminateClick
  end
  object sb: TStatusBar
    Left = 0
    Top = 260
    Width = 385
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object rg: TRadioGroup
    Left = 18
    Top = 48
    Width = 201
    Height = 63
    Caption = #1042#1099#1089#1086#1082#1072#1103' '#1089#1082#1086#1088#1086#1089#1090#1100
    Columns = 4
    ItemIndex = 0
    Items.Strings = (
      '125'#1050
      '0.5M'
      '1M'
      '2M'
      '3M'
      '8M'
      '12M'
      '100'#1052)
    TabOrder = 6
    OnClick = rgClick
  end
  object od: TJvFilenameEdit
    Left = 18
    Top = 21
    Width = 349
    Height = 21
    OnBeforeDialog = odBeforeDialog
    DialogKind = dkSave
    DefaultExt = 'bin'
    Filter = #1041#1080#1085#1072#1088#1085#1099#1081' '#1092#1072#1081#1083' (*.bin)|*.bin'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = ''
  end
  object edLen: TEdit
    Left = 309
    Top = 63
    Width = 57
    Height = 21
    TabOrder = 8
    Text = '3FFF'
  end
  object edBegin: TEdit
    Left = 121
    Top = 131
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 9
    Text = '0'
  end
  object edCnt: TEdit
    Left = 248
    Top = 131
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 10
    Text = '0'
  end
  object cbSD: TComboBox
    Left = 18
    Top = 131
    Width = 97
    Height = 21
    Style = csDropDownList
    Enabled = False
    TabOrder = 11
    OnChange = cbSDChange
    OnDropDown = cbSDDropDown
  end
end
