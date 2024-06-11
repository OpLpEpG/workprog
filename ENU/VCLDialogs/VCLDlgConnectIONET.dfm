inherited FormSetupNet: TFormSetupNet
  Caption = 'Network settings'
  ClientHeight = 226
  ExplicitHeight = 265
  DesignSize = (
    300
    226)
  TextHeight = 13
  inherited Label2: TLabel
    Top = 104
    ExplicitTop = 104
  end
  object Label1: TLabel [1]
    Left = 16
    Top = 11
    Width = 54
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'server IP'
  end
  object Label3: TLabel [2]
    Left = 208
    Top = 12
    Width = 24
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'port'
  end
  inherited sb: TStatusBar
    Top = 207
    ExplicitTop = 207
  end
  inherited ButtonOK: TButton
    Top = 167
    ExplicitTop = 167
  end
  inherited btTest: TButton
    Top = 166
    ExplicitTop = 166
  end
  inherited EdWait: TEdit
    Top = 123
    ExplicitTop = 123
  end
  inherited Button1: TButton
    Top = 167
    ExplicitTop = 167
  end
  inherited btClose: TButton
    Top = 117
    ExplicitTop = 117
  end
  inherited btOpen: TButton
    Top = 69
    ExplicitTop = 69
  end
  object edHost: TEdit
    Left = 16
    Top = 31
    Width = 171
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 7
    Text = '192.168.43.5'
  end
  object edPort: TEdit
    Left = 208
    Top = 31
    Width = 75
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 8
    Text = '5000'
  end
end
