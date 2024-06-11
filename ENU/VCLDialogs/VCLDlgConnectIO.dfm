object FormSetupConnect: TFormSetupConnect
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'COM port settings'
  ClientHeight = 174
  ClientWidth = 300
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    300
    174)
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 52
    Width = 145
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Response timeout (ms)'
    ExplicitTop = 125
  end
  object sb: TStatusBar
    Left = 0
    Top = 155
    Width = 300
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitTop = 173
    ExplicitWidth = 305
  end
  object ButtonOK: TButton
    Left = 16
    Top = 115
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = ButtonOKClick
    ExplicitTop = 136
  end
  object btTest: TButton
    Left = 208
    Top = 114
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Apply'
    TabOrder = 2
    OnClick = btTestClick
    ExplicitTop = 135
  end
  object EdWait: TEdit
    Left = 16
    Top = 71
    Width = 171
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 3
    Text = '1000'
    ExplicitTop = 144
  end
  object Button1: TButton
    Left = 112
    Top = 115
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    ExplicitTop = 136
  end
  object btClose: TButton
    Left = 208
    Top = 65
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Close'
    TabOrder = 5
    OnClick = btCloseClick
    ExplicitTop = 161
  end
  object btOpen: TButton
    Left = 208
    Top = 17
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Open'
    TabOrder = 6
    OnClick = btOpenClick
    ExplicitTop = 113
  end
end
