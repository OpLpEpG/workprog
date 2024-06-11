object FormOptionSetup: TFormOptionSetup
  Left = 0
  Top = 0
  Caption = 'Verification parameters'
  ClientHeight = 344
  ClientWidth = 593
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  DesignSize = (
    593
    344)
  TextHeight = 13
  object insp: TJvInspector
    Left = 8
    Top = 8
    Width = 577
    Height = 289
    Style = isItemPainter
    Anchors = [akLeft, akTop, akRight, akBottom]
    Divider = 300
    ItemHeight = 16
    Painter = InspectorBorlandPainter
    TabStop = True
    TabOrder = 0
  end
  object btOK: TButton
    Left = 160
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = btOKClick
  end
  object btCancel: TButton
    Left = 241
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = btCancelClick
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
