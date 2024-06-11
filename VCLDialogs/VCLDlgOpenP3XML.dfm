object DlgOpenP3DataSet: TDlgOpenP3DataSet
  Left = 0
  Top = 0
  ClientHeight = 411
  ClientWidth = 647
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  DesignSize = (
    647
    411)
  TextHeight = 13
  object DriveCombo: TJvDriveCombo
    Left = 8
    Top = 8
    Width = 296
    Height = 22
    DriveTypes = [dtFixed, dtRemote, dtCDROM]
    Offset = 4
    TabOrder = 0
  end
  object DirectoryList: TJvDirectoryListBox
    Left = 8
    Top = 36
    Width = 145
    Height = 368
    Directory = 'C:\Program Files (x86)\Embarcadero\Studio\22.0\bin'
    FileList = FileList
    DriveCombo = DriveCombo
    ItemHeight = 17
    ScrollBars = ssVertical
    TabOrder = 1
    Anchors = [akLeft, akTop, akBottom]
  end
  object FileList: TJvFileListBox
    Left = 159
    Top = 36
    Width = 145
    Height = 368
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Mask = '*.XML;*.XMLPrj'
    TabOrder = 2
    OnChange = FileListChange
    ForceFileExtensions = True
  end
  object pc: TPageControl
    Left = 310
    Top = 8
    Width = 333
    Height = 364
    ActivePage = tshSelDir
    Anchors = [akLeft, akTop, akRight, akBottom]
    PopupMenu = PopupMenu
    TabOrder = 5
    TabPosition = tpBottom
    object tshSelDir: TTabSheet
      Caption = #1055#1091#1090#1100
      ImageIndex = 1
      inline FrameSelectPath: TFrameSelectPath
        Left = 0
        Top = 0
        Width = 325
        Height = 338
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 325
        ExplicitHeight = 338
        inherited Tree: TVirtualStringTree
          Width = 325
          Height = 338
          ExplicitWidth = 325
          ExplicitHeight = 338
          Columns = <
            item
              Position = 0
              Style = vsOwnerDraw
              Text = #1055#1091#1090#1100
              Width = 319
            end>
        end
      end
    end
    object tshSelParam: TTabSheet
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      object Panel: TPanel
        Left = 0
        Top = 0
        Width = 325
        Height = 24
        Align = alTop
        Caption = 'Panel'
        ShowCaption = False
        TabOrder = 0
        DesignSize = (
          325
          24)
        object Label1: TLabel
          Left = 2
          Top = 3
          Width = 62
          Height = 13
          Caption = #1042#1099#1073#1088#1072#1090#1100' Y'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object cbY: TComboBox
          Left = 67
          Top = 0
          Width = 253
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
      end
      inline FrameSelectParam1: TFrameSelectParam
        Left = 0
        Top = 24
        Width = 325
        Height = 314
        Align = alClient
        TabOrder = 1
        ExplicitTop = 24
        ExplicitWidth = 325
        ExplicitHeight = 314
        inherited Tree: TVirtualStringTree
          Left = 0
          Top = 0
          Width = 325
          Height = 314
          Align = alClient
          Background.Data = {00}
          BorderWidth = 1
          ClipboardFormats.Strings = ()
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
          Header.AutoSizeIndex = 2
          Header.MainColumn = 2
          Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible, hoAutoSpring]
          PopupMenu = FrameSelectParam1.ppM
          TabOrder = 0
          TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSpanColumns, toAutoTristateTracking, toAutoHideButtons, toAutoDeleteMovedNodes]
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
          TreeOptions.PaintOptions = [toHideFocusRect, toHideSelection, toHotTrack, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
          TreeOptions.SelectionOptions = [toDisableDrawSelection, toExtendedFocus, toMultiSelect, toSimpleDrawSelection]
          ExplicitWidth = 325
          ExplicitHeight = 314
          Columns = <
            item
              MaxWidth = 24
              MinWidth = 24
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
              Position = 0
              Text = 'D'
              Width = 24
            end
            item
              MaxWidth = 24
              MinWidth = 24
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
              Position = 1
              Text = 'C'
              Width = 24
            end
            item
              Position = 2
              Text = #1048#1084#1103
              Width = 271
            end>
        end
        inherited ppM: TPopupActionBar
          inherited NSet: TMenuItem
            Bitmap.Data = {00000000}
            Caption = #1042#1099#1073#1088#1072#1090#1100' '
            inherited NSetAll: TMenuItem
              Tag = 2
              Bitmap.Data = {00000000}
              Caption = #1042#1089#1077
            end
            inherited NSetRow: TMenuItem
              Bitmap.Data = {00000000}
              Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
            end
            inherited NSetTrr: TMenuItem
              Tag = 1
              Bitmap.Data = {00000000}
              Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
            end
          end
          inherited NDel: TMenuItem
            Bitmap.Data = {00000000}
            Caption = #1057#1085#1103#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1080#1077
            inherited NClrAll: TMenuItem
              Tag = 2
              Bitmap.Data = {00000000}
              Caption = #1042#1089#1077
            end
            inherited NClrRow: TMenuItem
              Bitmap.Data = {00000000}
              Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
            end
            inherited NClrTrr: TMenuItem
              Tag = 1
              Bitmap.Data = {00000000}
              Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
            end
          end
          inherited N1: TMenuItem
            Bitmap.Data = {00000000}
            Caption = '-'
          end
          inherited NSetChild: TMenuItem
            Bitmap.Data = {00000000}
            Caption = #1042#1099#1073#1088#1072#1090#1100' '#1076#1086#1095#1077#1088#1085#1080#1077
            inherited NSetChildALL: TMenuItem
              Tag = 2
              Bitmap.Data = {00000000}
              Caption = #1042#1089#1077
            end
            inherited NSetChildRow: TMenuItem
              Bitmap.Data = {00000000}
              Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
            end
            inherited NSetChildTRR: TMenuItem
              Tag = 1
              Bitmap.Data = {00000000}
              Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
            end
          end
          inherited NClrChild: TMenuItem
            Bitmap.Data = {00000000}
            Caption = #1057#1085#1103#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1080#1077' '#1076#1086#1095#1077#1088#1085#1080#1093
            inherited NClrChildALL: TMenuItem
              Tag = 2
              Bitmap.Data = {00000000}
              Caption = #1042#1089#1077
            end
            inherited NClrChildRow: TMenuItem
              Bitmap.Data = {00000000}
              Caption = '[D] "'#1057#1099#1088#1099#1077'" '#1076#1072#1085#1085#1099#1077
            end
            inherited NClrChildTrr: TMenuItem
              Tag = 1
              Bitmap.Data = {00000000}
              Caption = '[C] '#1056#1072#1089#1095#1077#1090#1085#1099#1077
            end
          end
        end
      end
    end
    object tshData: TTabSheet
      Caption = #1057#1084#1086#1090#1088#1077#1090#1100' '#1076#1072#1085#1085#1099#1077
      ImageIndex = 1
      object DBGrid1: TDBGrid
        Left = 0
        Top = 0
        Width = 325
        Height = 338
        Align = alClient
        DataSource = ds
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object btCancel: TButton
    Left = 564
    Top = 380
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 3
    OnClick = btCancelClick
  end
  object btOK: TButton
    Left = 475
    Top = 380
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = btOKClick
  end
  object ds: TDataSource
    Left = 34
    Top = 228
  end
  object PopupMenu: TPopupMenu
    Left = 466
    Top = 140
    object NObjectView: TMenuItem
      AutoCheck = True
      Caption = #1054#1073#1098#1077#1082#1090#1085#1099#1077' '#1087#1086#1083#1103
      Checked = True
    end
  end
end
