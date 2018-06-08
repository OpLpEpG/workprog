object FormExportToPSK6_V3: TFormExportToPSK6_V3
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1101#1082#1089#1087#1086#1088#1090' '#1074' '#1055#1057#1050'6'
  ClientHeight = 235
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    295
    235)
  PixelsPerInch = 96
  TextHeight = 13
  object od: TJvFilenameEdit
    Left = 8
    Top = 8
    Width = 273
    Height = 21
    DialogKind = dkSave
    DefaultExt = 'if'
    Filter = #1041#1080#1085#1072#1088#1085#1099#1081' '#1092#1072#1081#1083' (*.if)|*.if'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = ''
  end
  object sb: TStatusBar
    Left = 0
    Top = 216
    Width = 295
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object btStart: TButton
    Left = 8
    Top = 178
    Width = 75
    Height = 25
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 2
    OnClick = btStartClick
  end
  object btTerminate: TButton
    Left = 89
    Top = 178
    Width = 75
    Height = 25
    Caption = #1055#1088#1077#1088#1074#1072#1090#1100
    TabOrder = 3
    OnClick = btTerminateClick
  end
  object btExit: TButton
    Left = 207
    Top = 178
    Width = 75
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    ModalResult = 1
    TabOrder = 4
    OnClick = btExitClick
  end
  object Progress: TProgressBar
    Left = 8
    Top = 155
    Width = 273
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  inline RangeSelect: TFrameRangeSelect
    Left = 8
    Top = 30
    Width = 273
    Height = 122
    Anchors = [akLeft, akTop, akRight]
    AutoSize = True
    TabOrder = 6
    ExplicitLeft = 8
    ExplicitTop = 30
    ExplicitWidth = 273
    inherited Range: TRangeSelector
      Width = 273
      ExplicitWidth = 273
    end
  end
end
