object FormCreateDev: TFormCreateDev
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = #1053#1086#1074#1086#1077' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1086
  ClientHeight = 399
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    297
    399)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 116
    Height = 13
    Caption = #1044#1086#1089#1090#1091#1087#1085#1099#1077' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072
  end
  object Label2: TLabel
    Left = 144
    Top = 315
    Width = 125
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1072#1076#1088#1077#1089#1072' '#1095#1077#1088#1077#1079' '#39';'#39
    ExplicitTop = 337
  end
  object Label3: TLabel
    Left = 8
    Top = 315
    Width = 93
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1042#1074#1077#1076#1080#1090#1077' '#1085#1072#1079#1074#1072#1085#1080#1077
  end
  object ButtonOK: TButton
    Left = 8
    Top = 366
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
    OnClick = ButtonOKClick
  end
  object Button1: TButton
    Left = 104
    Top = 366
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object Tree: TVirtualStringTree
    Left = 8
    Top = 24
    Width = 279
    Height = 276
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderWidth = 1
    Color = clBtnHighlight
    Ctl3D = True
    DragMode = dmAutomatic
    DragType = dtVCL
    Header.AutoSizeIndex = 1
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    Header.ParentFont = True
    ParentCtl3D = False
    PopupMenu = ppM
    RootNodeCount = 10
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnGetText = TreeGetText
    Columns = <
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Width = 116
        WideText = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coDisableAnimatedResize]
        Position = 1
        Width = 112
        WideText = #1054#1087#1080#1089#1072#1085#1080#1077
      end
      item
        Position = 2
        Width = 45
        WideText = #1040#1076#1088#1077#1089
      end>
  end
  object edAdr: TEdit
    Left = 144
    Top = 334
    Width = 145
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
  end
  object edCaption: TEdit
    Left = 8
    Top = 334
    Width = 130
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  object ppM: TPopupActionBar
    Left = 104
    Top = 88
    object NAdd: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      OnClick = NAddClick
    end
  end
end
