object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 598
  ClientWidth = 805
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 26
    Top = 49
    Width = 57
    Height = 25
    Caption = 'Create'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 26
    Top = 80
    Width = 57
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 26
    Top = 111
    Width = 57
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 104
    Top = 24
    Width = 57
    Height = 17
    Caption = 'legend'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 104
    Top = 47
    Width = 41
    Height = 17
    Caption = 'info'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CheckBox2Click
  end
  object Button1: TButton
    Left = 26
    Top = 18
    Width = 57
    Height = 25
    Caption = 'AddColl'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button5: TButton
    Left = 26
    Top = 142
    Width = 57
    Height = 25
    Caption = 'Dialog'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 26
    Top = 173
    Width = 57
    Height = 25
    Caption = 'Dialog'
    TabOrder = 7
    OnClick = Button6Click
  end
end
