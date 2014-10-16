object FormSetupRootDevice: TFormSetupRootDevice
  Left = 0
  Top = 0
  ClientHeight = 435
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 169
    Top = 0
    Height = 435
    ExplicitLeft = 152
    ExplicitTop = 136
    ExplicitHeight = 100
  end
  object PanelRoot: TPanel
    Left = 172
    Top = 0
    Width = 442
    Height = 435
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    object PanelBoot: TPanel
      Left = 0
      Top = 394
      Width = 442
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object btClose: TButton
        Left = 9
        Top = 6
        Width = 89
        Height = 27
        HelpContext = 20
        Cancel = True
        Caption = #1047#1072#1082#1088#1099#1090#1100' '#1086#1082#1085#1086
        TabOrder = 0
        OnClick = btCloseClick
      end
    end
  end
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 169
    Height = 435
    Align = alLeft
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoAutoSpring]
    PopupMenu = ppM
    TabOrder = 1
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    OnGetText = TreeGetText
    Columns = <
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Width = 165
        WideText = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 224
    Top = 80
    object NConnect: TMenuItem
      Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100' ('#1044#1086#1073#1072#1074#1080#1090#1100') '
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NRemove: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = NRemoveClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object NUp: TMenuItem
      Caption = #1042#1074#1077#1088#1093
      OnClick = NUpClick
    end
    object NDown: TMenuItem
      Caption = #1042#1085#1080#1079
      OnClick = NDownClick
    end
  end
end
