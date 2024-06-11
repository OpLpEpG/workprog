object FormControl: TFormControl
  Left = 0
  Top = 0
  Caption = 'Device Management'
  ClientHeight = 251
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object Tree: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 354
    Height = 251
    Align = alClient
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
    DragMode = dmAutomatic
    DragType = dtVCL
    EditDelay = 100
    Header.AutoSizeIndex = 2
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible, hoAutoSpring, hoHeaderClickAutoSort]
    PopupMenu = ppM
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick]
    TreeOptions.PaintOptions = [toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toExtendedFocus]
    TreeOptions.StringOptions = []
    OnCreateEditor = TreeCreateEditor
    OnEditing = TreeEditing
    OnGetText = TreeGetText
    OnPaintText = TreePaintText
    OnGetImageIndex = TreeGetImageIndex
    Columns = <
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coAllowFocus]
        Position = 0
        Text = 'Device'
        Width = 78
      end
      item
        Position = 1
        Text = 'Status'
        Width = 100
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
        Position = 2
        Text = 'Time'
        Width = 170
      end>
  end
  object ppM: TPopupActionBar
    OnPopup = ppMPopup
    Left = 104
    Top = 88
    object NSetup: TMenuItem
      Caption = 'Properties...'
      OnClick = NSetupClick
    end
    object NSepConn: TMenuItem
      Caption = '-'
    end
    object NAddDev: TMenuItem
      Caption = 'New Device'
      OnClick = NAddDevClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object NRemove: TMenuItem
      Caption = 'Delete'
      OnClick = NRemoveClick
    end
    object NConnect: TMenuItem
      Caption = 'Connect'
    end
    object NControl: TMenuItem
      Caption = 'Controll'
    end
    object NSetupDev: TMenuItem
      Caption = 'Properties...'
      OnClick = NSetupDevClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object NReadRam: TMenuItem
      Caption = 'Reading module memory...'
      OnClick = NReadRamClick
    end
    object NClc: TMenuItem
      Caption = 'Module metrology recalculation...'
      OnClick = NClcClick
    end
    object NInfo: TMenuItem
      Caption = 'Information mode'
    end
    object NRamSize: TMenuItem
      Caption = 'Set maximum operating time manually (Days)...'
      OnClick = NRamSizeClick
    end
    object NGlu: TMenuItem
      Caption = 'Depth-referenced data'
    end
    object NeepEdit: TMenuItem
      Caption = 'EEPROM Edit...'
      OnClick = NeepEditClick
    end
    object NeepCmp: TMenuItem
      Caption = 'EEPROM Compare with Metrology...'
      OnClick = NeepCmpClick
    end
    object NMetrolExport: TMenuItem
      Caption = 'Metrology Test...'
      OnClick = NMetrolTestClick
    end
    object NMetrolImport: TMenuItem
      Caption = 'Metrology Import...'
      OnClick = NMetrolImportClick
    end
    object NSepDEv: TMenuItem
      Caption = '-'
    end
    object NUpdate: TMenuItem
      Caption = 'Update'
      OnClick = NUpdateClick
    end
  end
end
