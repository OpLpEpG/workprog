object DlgOpenLAS: TDlgOpenLAS
  Left = 0
  Top = 0
  ClientHeight = 396
  ClientWidth = 623
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    623
    396)
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
    Height = 353
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
    Height = 353
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Mask = '*.las'
    TabOrder = 2
    OnChange = FileListChange
    ForceFileExtensions = True
  end
  object Inspector: TJvInspector
    Left = 310
    Top = 8
    Width = 305
    Height = 341
    Style = isItemPainter
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Divider = 254
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ItemHeight = 16
    Painter = BorlandPainter
    TabStop = True
    TabOrder = 3
  end
  object btCancel: TButton
    Left = 540
    Top = 363
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 4
  end
  object btOK: TButton
    Left = 451
    Top = 363
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1042#1099#1073#1088#1072#1090#1100
    ModalResult = 1
    TabOrder = 5
  end
  object BorlandPainter: TJvInspectorBorlandPainter
    CategoryFont.Charset = RUSSIAN_CHARSET
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
    Left = 424
    Top = 136
  end
end
