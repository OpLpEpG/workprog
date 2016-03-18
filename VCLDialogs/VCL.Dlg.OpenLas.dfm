object DlgOpenLASDataSet: TDlgOpenLASDataSet
  Left = 0
  Top = 0
  ClientHeight = 377
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    664
    377)
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
    Height = 334
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
    Height = 334
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Mask = '*.las'
    TabOrder = 2
    OnChange = FileListChange
    ForceFileExtensions = True
  end
  object pc: TPageControl
    Left = 310
    Top = 8
    Width = 350
    Height = 345
    ActivePage = tshLAS
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    TabPosition = tpBottom
    object tshLAS: TTabSheet
      Caption = 'LAS'
      object Inspector: TJvInspector
        Left = 0
        Top = 24
        Width = 342
        Height = 295
        Style = isItemPainter
        Align = alClient
        BevelOuter = bvNone
        Divider = 254
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier'
        Font.Style = []
        ItemHeight = 16
        Painter = BorlandPainter
        PopupMenu = PopupMenu
        TabStop = True
        TabOrder = 0
      end
      object Panel: TPanel
        Left = 0
        Top = 0
        Width = 342
        Height = 24
        Align = alTop
        Caption = 'Panel'
        ShowCaption = False
        TabOrder = 1
        DesignSize = (
          342
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
          Width = 270
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
      end
    end
    object tshData: TTabSheet
      Caption = #1044#1072#1085#1085#1099#1077
      ImageIndex = 1
      object DBGrid1: TDBGrid
        Left = 0
        Top = 0
        Width = 342
        Height = 319
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
    Left = 581
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 3
    OnClick = btCancelClick
  end
  object btOK: TButton
    Left = 492
    Top = 344
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = btOKClick
  end
  object BorlandPainter: TJvInspectorBorlandPainter
    CategoryFont.Charset = DEFAULT_CHARSET
    CategoryFont.Color = clBtnText
    CategoryFont.Height = -11
    CategoryFont.Name = 'Tahoma'
    CategoryFont.Style = []
    NameFont.Charset = DEFAULT_CHARSET
    NameFont.Color = clWindowText
    NameFont.Height = -11
    NameFont.Name = 'Courier'
    NameFont.Style = []
    ValueFont.Charset = DEFAULT_CHARSET
    ValueFont.Color = clNavy
    ValueFont.Height = -11
    ValueFont.Name = 'Courier'
    ValueFont.Style = []
    DrawNameEndEllipsis = False
    Left = 80
    Top = 192
  end
  object ds: TDataSource
    Left = 74
    Top = 260
  end
  object PopupMenu: TPopupMenu
    Left = 466
    Top = 140
    object NDOS: TMenuItem
      AutoCheck = True
      Caption = #1050#1086#1076#1080#1088#1086#1074#1082#1072' DOS'
      OnClick = NDOSClick
    end
  end
end
