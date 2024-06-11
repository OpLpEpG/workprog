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
      Caption = 'Path'
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
              Text = 'Path'
              Width = 325
            end>
        end
      end
    end
    object tshSelParam: TTabSheet
      Caption = 'Parameters'
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
          Caption = 'Select Y'
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
              Text = 'Name'
              Width = 277
            end>
        end
      end
    end
    object tshData: TTabSheet
      Caption = 'View data'
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
    Caption = 'Close'
    TabOrder = 3
    OnClick = btCancelClick
  end
  object btOK: TButton
    Left = 475
    Top = 380
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Add'
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
      Caption = 'Object fields'
      Checked = True
    end
  end
end
