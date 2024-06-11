object FrameFindDev: TFrameFindDev
  Left = 0
  Top = 0
  Width = 352
  Height = 40
  Align = alTop
  TabOrder = 0
  DesignSize = (
    352
    40)
  object lbCon: TLabel
    Left = 3
    Top = 3
    Width = 126
    Height = 23
    AutoSize = False
    Caption = 'Connection'
    Color = clCream
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Transparent = False
    StyleElements = []
  end
  object edName: TEdit
    Left = 135
    Top = 3
    Width = 126
    Height = 23
    Enabled = False
    TabOrder = 0
    Text = 'Device name'
  end
  object btAdd: TButton
    Left = 266
    Top = 3
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Add'
    Enabled = False
    TabOrder = 1
    OnClick = btAddClick
  end
  object cbx: TCheckListBox
    Left = 3
    Top = 32
    Width = 338
    Height = 0
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    ItemHeight = 15
    TabOrder = 2
  end
end
