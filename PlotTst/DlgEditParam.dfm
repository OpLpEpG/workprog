object FormEditParam: TFormEditParam
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1080#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088
  ClientHeight = 317
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    323
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object btExit: TButton
    Left = 8
    Top = 284
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 0
    OnClick = btExitClick
  end
  object insp: TJvInspector
    Left = 8
    Top = 8
    Width = 307
    Height = 270
    Style = isItemPainter
    Anchors = [akLeft, akTop, akRight, akBottom]
    Divider = 200
    ItemHeight = 16
    Painter = InspectorBorlandPainter
    TabStop = True
    TabOrder = 1
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
