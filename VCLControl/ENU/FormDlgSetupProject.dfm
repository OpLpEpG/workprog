object FormSetupProject: TFormSetupProject
  Left = 0
  Top = 0
  Caption = 'Project properties'
  ClientHeight = 411
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  DesignSize = (
    630
    411)
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 632
    Height = 369
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object TabSheet1: TTabSheet
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Caption = 'Project properties'
      object Insp: TJvInspector
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 624
        Height = 341
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Style = isItemPainter
        Align = alClient
        BevelEdges = []
        BevelKind = bkNone
        Divider = 350
        ItemHeight = 16
        Painter = InspectorBorlandPainter
        TabStop = True
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Depth Offset'
      ImageIndex = 1
      object InspZ: TJvInspector
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 624
        Height = 341
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Style = isItemPainter
        Align = alClient
        BevelEdges = []
        BevelKind = bkNone
        Divider = 350
        ItemHeight = 16
        Painter = JvInspectorBorlandPainterZ
        PopupMenu = ppM
        TabStop = True
        TabOrder = 0
      end
    end
  end
  object btExit: TButton
    Left = 15
    Top = 378
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 0
    OnClick = btExitClick
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
    Left = 200
    Top = 40
  end
  object JvInspectorBorlandPainterZ: TJvInspectorBorlandPainter
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
    Left = 200
    Top = 104
  end
  object ppM: TPopupActionBar
    Left = 208
    Top = 144
    object NReadOnly: TMenuItem
      AutoCheck = True
      Caption = 'Read only'
      Checked = True
      OnClick = UpdateGlu
    end
  end
end
