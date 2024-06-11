object FormPluginSetup: TFormPluginSetup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Setup modules'
  ClientHeight = 383
  ClientWidth = 594
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
    594
    383)
  PixelsPerInch = 96
  TextHeight = 13
  object btClose: TButton
    Left = 8
    Top = 350
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1050
    TabOrder = 0
    OnClick = btCloseClick
  end
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 594
    Height = 338
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderWidth = 1
    Header.AutoSizeIndex = -1
    Header.Options = [hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible]
    Header.ParentFont = True
    TabOrder = 1
    TabStop = False
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    OnGetText = TreeGetText
    OnInitNode = TreeInitNode
    Columns = <
      item
        MaxWidth = 1000
        Position = 0
        Width = 150
        WideText = 'load,Name'
      end
      item
        MaxWidth = 100
        Position = 1
        Width = 60
        WideText = 'Version'
      end
      item
        Margin = 0
        MaxWidth = 300
        MinWidth = 40
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coAllowFocus]
        Position = 2
        Width = 40
        WideText = 'ID'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAutoSpring, coSmartResize, coAllowFocus, coDisableAnimatedResize, coWrapCaption]
        Position = 3
        Width = 250
        WideText = 'File'
      end>
    WideDefaultText = ''
  end
  object btSave: TButton
    Left = 104
    Top = 350
    Width = 129
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save'
    TabOrder = 2
    OnClick = btSaveClick
  end
  object btUpdate: TButton
    Left = 256
    Top = 350
    Width = 137
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Reload'
    TabOrder = 3
    OnClick = btUpdateClick
  end
end
