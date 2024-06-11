object DialogDelay: TDialogDelay
  Left = 0
  Top = 0
  HelpType = htKeyword
  HelpKeyword = 'Delay'
  Caption = 'DialogDelay'
  ClientHeight = 474
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object pnEdit: TPanel
    Left = 0
    Top = 0
    Width = 439
    Height = 113
    Align = alTop
    Caption = 'pnEdit'
    ShowCaption = False
    TabOrder = 1
    object lbSetDelay: TLabel
      Left = 16
      Top = 9
      Width = 51
      Height = 13
      Caption = 'lbSetDelay'
    end
    object lbWork: TLabel
      Left = 226
      Top = 9
      Width = 189
      Height = 26
      AutoSize = False
      Caption = 'Operation interval '#13#10'(0 00:00:00 - not set)'
      WordWrap = True
    end
    object medDelay: TMaskEdit
      Left = 16
      Top = 41
      Width = 190
      Height = 24
      EditMask = '00/00/0000 00:00:00;1;_'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'Courier'
      Font.Style = []
      MaxLength = 19
      ParentFont = False
      TabOrder = 1
      Text = '  .  .       :  :  '
      OnChange = EditsChange
    end
    object medWork: TMaskEdit
      Left = 226
      Top = 41
      Width = 189
      Height = 24
      EditMask = '!9 00:00:00;1;_'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlue
      Font.Height = -16
      Font.Name = 'Courier'
      Font.Style = []
      MaxLength = 10
      ParentFont = False
      TabOrder = 2
      Text = '0 00:00:00'
      OnChange = EditsChange
    end
    object btApply: TButton
      Left = 226
      Top = 71
      Width = 189
      Height = 25
      Caption = 'Setup Delay'
      Enabled = False
      TabOrder = 0
      OnClick = btApplyClick
    end
  end
  object pnShow: TPanel
    Left = 0
    Top = 420
    Width = 439
    Height = 54
    Align = alBottom
    Caption = 'pnShow'
    ShowCaption = False
    TabOrder = 2
    object btClose: TButton
      Left = 326
      Top = 14
      Width = 89
      Height = 27
      HelpContext = 20
      Cancel = True
      Caption = 'Close window'
      TabOrder = 0
      OnClick = btCloseClick
    end
    object btDelay: TButton
      Left = 16
      Top = 14
      Width = 190
      Height = 27
      HelpKeyword = 'BUTTONHELP'
      HelpContext = 1
      Cancel = True
      Caption = 'delay'
      Enabled = False
      TabOrder = 1
      OnClick = btDelayClick
    end
  end
  object Memo: TMemo
    Left = 0
    Top = 226
    Width = 439
    Height = 194
    TabStop = False
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlue
    Font.Height = -16
    Font.Name = 'Courier'
    Font.Style = []
    Lines.Strings = (
      '*****   Delay Status   *****')
    ParentColor = True
    ParentFont = False
    ParentShowHint = False
    ReadOnly = True
    ShowHint = False
    TabOrder = 0
  end
  object pnCtatus: TPanel
    Left = 0
    Top = 113
    Width = 439
    Height = 113
    Align = alTop
    Caption = 'pnEdit'
    ShowCaption = False
    TabOrder = 3
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 16
    Top = 264
  end
  object TimerErr: TTimer
    Interval = 3000
    OnTimer = TimerErrTimer
    Left = 72
    Top = 264
  end
end
