object RP45FormDlgMetrol: TRP45FormDlgMetrol
  Left = 0
  Top = 0
  Caption = #1056#1055'-45'
  ClientHeight = 213
  ClientWidth = 408
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    408
    213)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 156
    Height = 26
    Alignment = taCenter
    AutoSize = False
    Caption = #1087#1088#1080#1074#1103#1079#1082#1072' 1'#13#10#1050#1072#1076#1088'           '#1043#1083#1091#1073#1080#1085#1072
  end
  object Label2: TLabel
    Left = 8
    Top = 67
    Width = 156
    Height = 26
    Alignment = taCenter
    AutoSize = False
    Caption = #1087#1088#1080#1074#1103#1079#1082#1072' 2'#13#10#1050#1072#1076#1088'           '#1043#1083#1091#1073#1080#1085#1072
  end
  object Label3: TLabel
    Left = 8
    Top = 126
    Width = 82
    Height = 13
    Caption = #1055#1086#1088#1086#1075'  '#1085#1072#1075#1088#1091#1079#1082#1080
  end
  object Memo: TMemo
    Left = 197
    Top = 8
    Width = 203
    Height = 197
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object btRUN: TButton
    Left = 8
    Top = 180
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'RUN'
    TabOrder = 1
    OnClick = btRUNClick
  end
  object edGlu1: TEdit
    Left = 89
    Top = 40
    Width = 75
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object edGlu2: TEdit
    Left = 89
    Top = 99
    Width = 75
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object btClose: TButton
    Left = 102
    Top = 180
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100' '#1086#1082#1085#1086
    TabOrder = 4
    OnClick = btCloseClick
  end
end
