object FormExceptions: TFormExceptions
  Left = 0
  Top = 0
  Caption = #1048#1089#1082#1083#1102#1095#1077#1085#1080#1103
  ClientHeight = 301
  ClientWidth = 562
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 562
    Height = 301
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PopupMenu = ppM
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object ppM: TPopupActionBar
    Left = 8
    Top = 8
    object NClear: TMenuItem
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      OnClick = NClearClick
    end
    object NDialog: TMenuItem
      AutoCheck = True
      Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1076#1080#1072#1083#1086#1075
      OnClick = NDialogClick
    end
    object NShowDebug: TMenuItem
      AutoCheck = True
      Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1086#1090#1083#1072#1076#1086#1095#1085#1091#1102' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102
      Checked = True
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Action = FileSaveAs
    end
  end
  object ActionList: TActionList
    Left = 64
    Top = 8
    object FileSaveAs: TFileSaveAs
      Category = #1060#1072#1081#1083
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1092#1072#1081#1083'...'
      Dialog.DefaultExt = 'txt'
      Dialog.Filter = #1090#1077#1082#1089#1090' (*.txt)|*.txt'
      Hint = 'Save As|Saves the active file with a new name'
      ImageIndex = 30
      OnAccept = FileSaveAsAccept
    end
  end
end
