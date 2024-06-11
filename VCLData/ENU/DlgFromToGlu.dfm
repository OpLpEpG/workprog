object FormDlgGluFilter: TFormDlgGluFilter
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Filter by Depth'
  ClientHeight = 144
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbWork: TLabel
    Left = 26
    Top = 17
    Width = 189
    Height = 26
    AutoSize = False
    Caption = 'From frame'#13#10'(0-not set)'
    WordWrap = True
  end
  object Label1: TLabel
    Left = 266
    Top = 17
    Width = 189
    Height = 26
    AutoSize = False
    Caption = 'By frame'#13#10'(0-not set)'
    WordWrap = True
  end
  object medFrom: TMaskEdit
    Left = 26
    Top = 49
    Width = 187
    Height = 24
    EditMask = '!99999;1;_'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlue
    Font.Height = -16
    Font.Name = 'Courier'
    Font.Style = []
    MaxLength = 5
    ParentFont = False
    TabOrder = 0
    Text = '     '
  end
  object medTo: TMaskEdit
    Left = 266
    Top = 49
    Width = 187
    Height = 24
    EditMask = '!99999;1;_'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clBlue
    Font.Height = -16
    Font.Name = 'Courier'
    Font.Style = []
    MaxLength = 5
    ParentFont = False
    TabOrder = 1
    Text = '     '
  end
  object btApply: TButton
    Left = 26
    Top = 96
    Width = 111
    Height = 25
    Caption = 'Apply'
    TabOrder = 2
    OnClick = btApplyClick
  end
  object btClose: TButton
    Left = 266
    Top = 96
    Width = 111
    Height = 25
    Caption = 'Exit'
    ModalResult = 8
    TabOrder = 3
  end
end
