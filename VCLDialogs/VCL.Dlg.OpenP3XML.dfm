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
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    647
    411)
  PixelsPerInch = 96
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
    Directory = 'C:\Gorizont'
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
    Mask = '*.XML'
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
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
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
          ExplicitTop = 0
          ExplicitWidth = 325
          ExplicitHeight = 338
          Columns = <
            item
              Position = 0
              Style = vsOwnerDraw
              Width = 325
              WideText = #1055#1091#1090#1100
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
          Width = 325
          Height = 314
          ExplicitWidth = 325
          ExplicitHeight = 314
          Columns = <
            item
              MaxWidth = 24
              MinWidth = 24
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
              Position = 0
              Width = 24
              WideText = 'D'
            end
            item
              MaxWidth = 24
              MinWidth = 24
              Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
              Position = 1
              Width = 24
              WideText = 'C'
            end
            item
              Position = 2
              Width = 277
              WideText = #1048#1084#1103
            end>
        end
      end
    end
    object tshData: TTabSheet
      Caption = #1057#1084#1086#1090#1088#1077#1090#1100' '#1076#1072#1085#1085#1099#1077
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
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
