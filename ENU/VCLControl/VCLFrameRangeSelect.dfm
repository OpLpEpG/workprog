object FrameRangeSelect: TFrameRangeSelect
  Left = 0
  Top = 0
  Width = 293
  Height = 124
  AutoSize = True
  TabOrder = 0
  DesignSize = (
    293
    124)
  object lbBegin: TLabel
    Left = 0
    Top = 74
    Width = 42
    Height = 15
    Caption = 'Begin'
  end
  object lbEnd: TLabel
    Left = 0
    Top = 106
    Width = 34
    Height = 15
    Caption = 'End'
  end
  object lbCnt: TLabel
    Left = 0
    Top = 90
    Width = 39
    Height = 15
    Caption = 'Cnt'
  end
  object lbKaBegin: TLabel
    Left = 233
    Top = 77
    Width = 6
    Height = 15
    Caption = '0'
  end
  object lbKaCnt: TLabel
    Left = 233
    Top = 93
    Width = 6
    Height = 15
    Caption = '0'
  end
  object lbKaEnd: TLabel
    Left = 233
    Top = 109
    Width = 6
    Height = 15
    Caption = '0'
  end
  object Label1: TLabel
    Left = 38
    Top = 63
    Width = 74
    Height = 15
    Caption = 'Time from on'
  end
  object Label2: TLabel
    Left = 124
    Top = 63
    Width = 60
    Height = 15
    Caption = 'Date time'
  end
  object Label3: TLabel
    Left = 232
    Top = 63
    Width = 34
    Height = 15
    Caption = 'frames'
  end
  object Range: TRangeSelector
    Left = 0
    Top = 0
    Width = 293
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Max = 100
    SelStart = 50
    SelEnd = 70
    ReadyEnd = 80
    OnChange = RangeChange
  end
  object edOtnBegin: TMaskEdit
    Left = 38
    Top = 76
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
    Top = 106
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
    Top = 91
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
    Top = 76
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
    Top = 106
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
