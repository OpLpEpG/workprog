object FormLogg: TFormLogg
  Left = 0
  Top = 0
  Caption = #1050#1086#1085#1074#1077#1088#1090#1086#1088
  ClientHeight = 297
  ClientWidth = 294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    294
    297)
  PixelsPerInch = 96
  TextHeight = 13
  object lbDelaycap: TLabel
    Left = 8
    Top = 98
    Width = 155
    Height = 13
    Caption = #1074#1088#1077#1084#1103' '#1085#1072#1095#1072#1083#1072' '#1088#1072#1073#1086#1090#1099' '#1087#1088#1080#1073#1086#1088#1072
  end
  object lbDelay: TLabel
    Left = 8
    Top = 117
    Width = 181
    Height = 16
    Caption = '__________________'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Courier'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 8
    Width = 183
    Height = 13
    Caption = #1042#1093#1086#1076': LOGG '#1087#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1085#1085#1099#1081' '#1074' LAS'
  end
  object Label3: TLabel
    Left = 8
    Top = 52
    Width = 133
    Height = 13
    Caption = #1042#1099#1093#1086#1076': LAS '#1092#1072#1081#1083' '#1075#1083#1091#1073#1080#1085#1099
  end
  object Label1: TLabel
    Left = 8
    Top = 138
    Width = 178
    Height = 13
    Caption = #1074#1088#1077#1084#1103' '#1085#1072#1095#1072#1083#1072' '#1088#1072#1073#1086#1090#1099' '#1075#1083#1091#1073#1080#1085#1086#1084#1077#1088#1072
  end
  object lbGluStart: TLabel
    Left = 8
    Top = 157
    Width = 181
    Height = 16
    Caption = '__________________'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Courier'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 8
    Top = 179
    Width = 90
    Height = 13
    Caption = #1089#1084#1077#1097#1077#1085#1080#1077' '#1082#1072#1076#1088#1086#1074
  end
  object lbDradr: TLabel
    Left = 8
    Top = 198
    Width = 181
    Height = 16
    Caption = '__________________'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clNavy
    Font.Height = -16
    Font.Name = 'Courier'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object sb: TStatusBar
    Left = 0
    Top = 278
    Width = 294
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
  object btExit: TButton
    Left = 211
    Top = 250
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1093#1086#1076
    ModalResult = 1
    TabOrder = 1
    OnClick = btExitClick
  end
  object btStart: TButton
    Left = 8
    Top = 250
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 2
    OnClick = btStartClick
  end
  object Progress: TProgressBar
    Left = 8
    Top = 227
    Width = 278
    Height = 17
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  object od: TJvFilenameEdit
    Left = 8
    Top = 24
    Width = 278
    Height = 21
    OnAfterDialog = odAfterDialog
    DefaultExt = 'las'
    Filter = 'LOGG '#1089#1082#1086#1085#1074#1077#1088#1090#1080#1088#1086#1074#1072#1085#1085#1099#1081' '#1074' Las|*.las'
    DialogOptions = [ofHideReadOnly, ofPathMustExist, ofFileMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    Text = ''
  end
  object sd: TJvFilenameEdit
    Left = 8
    Top = 71
    Width = 278
    Height = 21
    OnAfterDialog = sdAfterDialog
    DialogKind = dkSave
    DefaultExt = 'if'
    Filter = #1075#1083#1091#1073#1080#1085#1072' Las|*.las'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    Text = ''
  end
  object btTerminate: TButton
    Left = 89
    Top = 250
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1077#1088#1074#1072#1090#1100
    TabOrder = 6
    OnClick = btTerminateClick
  end
end
