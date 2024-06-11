inherited FormSetupCom: TFormSetupCom
  Caption = 'COM settings'
  ClientHeight = 228
  ExplicitHeight = 267
  TextHeight = 13
  inherited Label2: TLabel
    Top = 106
    ExplicitTop = 74
  end
  object Label1: TLabel [1]
    Left = 16
    Top = 20
    Width = 97
    Height = 13
    Caption = 'Select COM port'
  end
  inherited sb: TStatusBar
    Top = 209
    ExplicitTop = 209
  end
  inherited ButtonOK: TButton
    Top = 169
    ExplicitTop = 169
  end
  inherited btTest: TButton
    Top = 168
    ExplicitTop = 168
  end
  inherited EdWait: TEdit
    Top = 125
    ExplicitTop = 125
  end
  inherited Button1: TButton
    Top = 169
    ExplicitTop = 169
  end
  inherited btClose: TButton
    Top = 119
    ExplicitTop = 119
  end
  inherited btOpen: TButton
    Top = 71
    ExplicitTop = 71
  end
  object cbCom: TComComboBox
    Left = 16
    Top = 39
    Width = 171
    Height = 21
    ComProperty = cpPort
    Text = 'COM1'
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 7
  end
  object cb9600: TCheckBox
    Left = 203
    Top = 41
    Width = 89
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = '9600 bod'
    TabOrder = 8
  end
end
