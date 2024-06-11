object DlgSetupDev: TDlgSetupDev
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Device setup'
  ClientHeight = 106
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 80
    Height = 13
    Caption = 'Device name'
  end
  object lbPeriod: TLabel
    Left = 154
    Top = 8
    Width = 106
    Height = 13
    Caption = 'Cyclo polling period'
    Visible = False
  end
  object btApply: TButton
    Left = 200
    Top = 63
    Width = 75
    Height = 25
    Caption = 'Apply'
    TabOrder = 0
    OnClick = btApplyClick
  end
  object Button1: TButton
    Left = 104
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object ButtonOK: TButton
    Left = 8
    Top = 63
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
    OnClick = ButtonOKClick
  end
  object edName: TEdit
    Left = 8
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object edPeriod: TEdit
    Left = 154
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 4
    Visible = False
  end
end
