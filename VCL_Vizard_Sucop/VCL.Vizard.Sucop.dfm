object FormSUCOPconverter: TFormSUCOPconverter
  Left = 0
  Top = 0
  Caption = #1050#1086#1088#1088#1077#1082#1094#1080#1103'  '#1084#1072#1075#1085#1080#1090#1085#1086#1075#1086' '#1087#1086#1083#1103
  ClientHeight = 413
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    411
    413)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 170
    Height = 13
    Caption = #1042#1093#1086#1076#1085#1086#1081' LAS '#1092#1072#1081#1083' '#1073#1077#1079' '#1082#1086#1088#1088#1077#1082#1094#1080#1080
  end
  object Label2: TLabel
    Left = 10
    Top = 190
    Width = 156
    Height = 13
    Caption = #1060#1072#1081#1083' '#1074#1093#1086#1076#1085#1099#1093' '#1076#1072#1085#1085#1099#1093' SUCOP '
  end
  object Label3: TLabel
    Left = 8
    Top = 334
    Width = 172
    Height = 13
    Caption = #1042#1099#1093#1086#1076#1085#1086#1081' LAS '#1092#1072#1081#1083' '#1089' '#1082#1086#1088#1088#1077#1082#1094#1080#1077#1081
  end
  object Label4: TLabel
    Left = 10
    Top = 96
    Width = 189
    Height = 13
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1084#1072#1075#1085#1080#1090#1085#1086#1075#1086' '#1087#1086#1083#1103' '#1073#1091#1088#1086#1074#1086#1081
  end
  object Label5: TLabel
    Left = 10
    Top = 54
    Width = 276
    Height = 13
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1084#1072#1075#1085#1080#1090#1085#1086#1075#1086' '#1087#1086#1083#1103' '#1084#1077#1089#1090#1072' '#1089#1085#1103#1090#1080#1103' '#1084#1077#1090#1088#1086#1083#1086#1075#1080#1080
  end
  object Label6: TLabel
    Left = 10
    Top = 142
    Width = 178
    Height = 13
    Caption = #1052#1072#1075#1085#1080#1090#1085#1086#1077' '#1085#1072#1082#1083#1086#1085#1077#1085#1080#1077' '#1085#1072' '#1073#1091#1088#1086#1074#1086#1081
  end
  object Label7: TLabel
    Left = 10
    Top = 294
    Width = 131
    Height = 13
    Caption = #1060#1072#1081#1083' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' SUCOP'
  end
  object flSucop: TJvFilenameEdit
    Left = 10
    Top = 203
    Width = 395
    Height = 21
    DialogKind = dkSave
    DefaultExt = 'sur'
    Filter = #1060#1072#1081#1083' '#1074#1093#1086#1076#1085#1099#1093' '#1076#1072#1085#1085#1099#1093' SUCOP (*.SUR) |*.SUR'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = ''
  end
  object flLASOut: TJvFilenameEdit
    Left = 8
    Top = 353
    Width = 395
    Height = 21
    DialogKind = dkSave
    DefaultExt = 'las'
    Filter = 'LAS '#1092#1072#1081#1083' (*.las)|*.las'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = ''
  end
  object flLASInput: TJvFilenameEdit
    Left = 8
    Top = 24
    Width = 395
    Height = 21
    OnAfterDialog = flLASInputAfterDialog
    DefaultExt = 'las'
    Filter = 'LAS '#1092#1072#1081#1083' (*.las)|*.las'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    Text = ''
  end
  object btToSUCOP: TButton
    Left = 8
    Top = 230
    Width = 89
    Height = 25
    Caption = 'LAS '#1074' SUCOP'
    TabOrder = 3
    OnClick = btToSUCOPClick
  end
  object btToLAS: TButton
    Left = 8
    Top = 380
    Width = 89
    Height = 25
    Caption = 'SUCOP '#1074' LAS'
    TabOrder = 4
    OnClick = btToLASClick
  end
  object edAmpBUR: TEdit
    Left = 8
    Top = 115
    Width = 121
    Height = 21
    TabOrder = 5
    Text = '1000'
  end
  object edAmpMET: TEdit
    Left = 8
    Top = 73
    Width = 121
    Height = 21
    TabOrder = 6
    Text = '1000'
  end
  object edI: TEdit
    Left = 8
    Top = 161
    Width = 121
    Height = 21
    TabOrder = 7
    Text = '70'
  end
  object flSUCOPInput: TJvFilenameEdit
    Left = 8
    Top = 307
    Width = 395
    Height = 21
    DefaultExt = 'LOG'
    Filter = #1060#1072#1081#1083' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' SUCOP (*.LOG)|*.LOG'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 8
    Text = ''
  end
end
