object FormDACNNk_abst: TFormDACNNk_abst
  Left = 0
  Top = 0
  Caption = #1059#1089#1090#1072#1085#1086#1074#1082#1072' '#1062#1040#1055' '#1053#1053#1050
  ClientHeight = 201
  ClientWidth = 342
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    342
    201)
  PixelsPerInch = 96
  TextHeight = 13
  object btRead: TButton
    Left = 13
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1063#1080#1090#1072#1090#1100
    TabOrder = 0
    OnClick = btReadClick
  end
  object btWrite: TButton
    Left = 109
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1080#1089#1072#1090#1100
    TabOrder = 1
    OnClick = btWriteClick
  end
  object btExit: TButton
    Left = 208
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1093#1086#1076
    ModalResult = 1
    TabOrder = 2
    OnClick = btExitClick
  end
  object st: TStatusBar
    Left = 0
    Top = 182
    Width = 342
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object insp: TJvInspector
    Left = 8
    Top = 8
    Width = 326
    Height = 130
    Style = isItemPainter
    Anchors = [akLeft, akTop, akRight, akBottom]
    Divider = 200
    ItemHeight = 16
    Painter = InspectorBorlandPainter
    TabStop = True
    TabOrder = 4
  end
  object InspectorBorlandPainter: TJvInspectorBorlandPainter
    CategoryFont.Charset = DEFAULT_CHARSET
    CategoryFont.Color = clBlack
    CategoryFont.Height = -11
    CategoryFont.Name = 'Tahoma'
    CategoryFont.Style = []
    NameFont.Charset = DEFAULT_CHARSET
    NameFont.Color = clWindowText
    NameFont.Height = -11
    NameFont.Name = 'Tahoma'
    NameFont.Style = []
    ValueFont.Charset = DEFAULT_CHARSET
    ValueFont.Color = clNavy
    ValueFont.Height = -11
    ValueFont.Name = 'Tahoma'
    ValueFont.Style = [fsBold]
    DrawNameEndEllipsis = True
    Left = 272
    Top = 32
  end
end
