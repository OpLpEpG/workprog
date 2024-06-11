object FormCreateDev: TFormCreateDev
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'New Device'
  ClientHeight = 420
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  DesignSize = (
    392
    420)
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 118
    Height = 13
    Caption = 'Available Devices'
  end
  object Label3: TLabel
    Left = 8
    Top = 328
    Width = 93
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Enter the title'
    ExplicitTop = 307
  end
  object ButtonOK: TButton
    Left = 8
    Top = 387
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
    Top = 387
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object Tree: TVirtualStringTree
    Left = 8
    Top = 24
    Width = 374
    Height = 297
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderWidth = 1
    Color = clBtnHighlight
    Colors.BorderColor = 15987699
    Colors.DisabledColor = clGray
    Colors.DropMarkColor = 15385233
    Colors.DropTargetColor = 15385233
    Colors.DropTargetBorderColor = 15385233
    Colors.FocusedSelectionColor = 15385233
    Colors.FocusedSelectionBorderColor = 15385233
    Colors.GridLineColor = 15987699
    Colors.HeaderHotColor = clBlack
    Colors.HotColor = clBlack
    Colors.SelectionRectangleBlendColor = 15385233
    Colors.SelectionRectangleBorderColor = 15385233
    Colors.SelectionTextColor = clBlack
    Colors.TreeLineColor = 9471874
    Colors.UnfocusedColor = clGray
    Colors.UnfocusedSelectionColor = 13421772
    Colors.UnfocusedSelectionBorderColor = 13421772
    Ctl3D = True
    DragMode = dmAutomatic
    DragType = dtVCL
    Header.AutoSizeIndex = 1
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    ParentCtl3D = False
    RootNodeCount = 10
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnChecked = TreeChecked
    OnChecking = TreeChecking
    OnGetText = TreeGetText
    Columns = <
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus]
        Position = 0
        Text = 'Device'
        Width = 116
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coDisableAnimatedResize]
        Position = 1
        Text = 'Description'
        Width = 207
      end
      item
        Position = 2
        Text = 'Address'
        Width = 45
      end>
  end
  object edCaption: TEdit
    Left = 8
    Top = 347
    Width = 130
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  object cbTree: TCheckBox
    Left = 191
    Top = 391
    Width = 89
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Data window'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object btConnection: TButton
    Left = 144
    Top = 345
    Width = 238
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Connect'
    TabOrder = 5
    OnClick = btConnectionClick
  end
  object ppConnection: TPopupMenu
    Left = 144
    Top = 208
  end
end
