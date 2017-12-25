object FrameRangeSelect: TFrameRangeSelect
  Left = 0
  Top = 0
  Width = 293
  Height = 112
  TabOrder = 0
  DesignSize = (
    293
    112)
  object lbBegin: TLabel
    Left = 0
    Top = 64
    Width = 37
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1086
  end
  object lbEnd: TLabel
    Left = 0
    Top = 96
    Width = 31
    Height = 13
    Caption = #1050#1086#1085#1077#1094
  end
  object lbCnt: TLabel
    Left = 0
    Top = 80
    Width = 35
    Height = 13
    Caption = #1050#1086#1083'-'#1074#1086
  end
  object lbKaBegin: TLabel
    Left = 233
    Top = 67
    Width = 6
    Height = 13
    Caption = '0'
  end
  object lbKaCnt: TLabel
    Left = 233
    Top = 83
    Width = 6
    Height = 13
    Caption = '0'
  end
  object lbKaEnd: TLabel
    Left = 233
    Top = 99
    Width = 6
    Height = 13
    Caption = '0'
  end
  object Range: TRangeSelector
    Left = 0
    Top = 0
    Width = 293
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Max = 100.000000000000000000
    SelStart = 50.000000000000000000
    SelEnd = 70.000000000000000000
    ReadyEnd = 80.000000000000000000
    OnChange = RangeChange
    ExplicitWidth = 337
  end
  object edOtnBegin: TMaskEdit
    Left = 38
    Top = 66
    Width = 80
    Height = 16
    AutoSize = False
    EditMask = '!99 90:00:00;1;_'
    MaxLength = 11
    TabOrder = 1
    Text = '     :  :  '
    OnKeyPress = edOtnBeginKeyPress
  end
  object edOtnEnd: TMaskEdit
    Left = 38
    Top = 96
    Width = 80
    Height = 16
    AutoSize = False
    EditMask = '!99 90:00:00;1;_'
    MaxLength = 11
    TabOrder = 2
    Text = '     :  :  '
    OnKeyPress = edOtnEndKeyPress
  end
  object edOtnCnt: TMaskEdit
    Left = 38
    Top = 81
    Width = 80
    Height = 16
    AutoSize = False
    EditMask = '!99 90:00:00;1;_'
    MaxLength = 11
    TabOrder = 3
    Text = '     :  :  '
    OnKeyPress = edOtnCntKeyPress
  end
  object edGlobBegin: TMaskEdit
    Left = 120
    Top = 66
    Width = 111
    Height = 16
    AutoSize = False
    EditMask = '00/00/0000 !00:00:00;1;_'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 19
    ParentFont = False
    TabOrder = 4
    Text = '  .  .       :  :  '
    OnKeyPress = edGlobBeginKeyPress
  end
  object edGlobEnd: TMaskEdit
    Left = 120
    Top = 96
    Width = 111
    Height = 16
    AutoSize = False
    EditMask = '00/00/0000 !00:00:00;1;_'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 19
    ParentFont = False
    TabOrder = 5
    Text = '  .  .       :  :  '
    OnKeyPress = edGlobEndKeyPress
  end
end
