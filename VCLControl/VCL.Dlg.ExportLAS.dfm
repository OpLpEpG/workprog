object FormExportLASP3: TFormExportLASP3
  Left = 0
  Top = 0
  ClientHeight = 441
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    340
    441)
  PixelsPerInch = 96
  TextHeight = 13
  object pc: TPageControl
    Left = 8
    Top = 8
    Width = 324
    Height = 369
    ActivePage = tshSelDir
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    TabPosition = tpBottom
    object tshSelDir: TTabSheet
      Caption = #1055#1091#1090#1100
      ImageIndex = 1
      inline FrameSelectPath: TFrameSelectPath
        Left = 0
        Top = 0
        Width = 316
        Height = 343
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 316
        ExplicitHeight = 343
        inherited Tree: TVirtualStringTree
          Width = 316
          Height = 343
          ExplicitWidth = 316
          ExplicitHeight = 343
          Columns = <
            item
              Position = 0
              Style = vsOwnerDraw
              Width = 310
              WideText = #1055#1091#1090#1100
            end>
        end
      end
    end
    object tshSelParam: TTabSheet
      Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
      inline FrameSelectParam1: TFrameSelectParam
        Left = 0
        Top = 0
        Width = 316
        Height = 343
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 316
        ExplicitHeight = 343
        inherited Tree: TVirtualStringTree
          Width = 316
          Height = 343
          ExplicitWidth = 316
          ExplicitHeight = 343
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
              Width = 262
              WideText = #1048#1084#1103
            end>
        end
      end
    end
    object tshData: TTabSheet
      Caption = #1057#1084#1086#1090#1088#1077#1090#1100' '#1076#1072#1085#1085#1099#1077
      ImageIndex = 1
      object DBGrid1: TDBGrid
        Left = 0
        Top = 0
        Width = 316
        Height = 343
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
    object tshLas: TTabSheet
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '
      ImageIndex = 3
      OnShow = tshLasShow
      DesignSize = (
        316
        343)
      object Label4: TLabel
        Left = 7
        Top = 56
        Width = 56
        Height = 13
        Caption = #1050#1086#1076#1080#1088#1086#1074#1082#1072
      end
      object Label1: TLabel
        Left = 3
        Top = 7
        Width = 26
        Height = 13
        Caption = #1060#1072#1081#1083
      end
      object Label2: TLabel
        Left = 134
        Top = 56
        Width = 122
        Height = 13
        Caption = #1058#1086#1095#1085#1086#1089#1090#1100' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
      end
      object cb: TComboBox
        Left = 7
        Top = 75
        Width = 121
        Height = 22
        Style = csOwnerDrawFixed
        ItemIndex = 0
        TabOrder = 0
        Text = 'ANSI'
        Items.Strings = (
          'ANSI'
          'DOS'
          'UTF8')
      end
      object od: TJvFilenameEdit
        Left = 7
        Top = 26
        Width = 296
        Height = 21
        OnBeforeDialog = odBeforeDialog
        DialogKind = dkSave
        DefaultExt = 'bin'
        Filter = 'LAS '#1092#1072#1081#1083' (*.LAS)|*.LAS'
        DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
        DirectInput = False
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        Text = ''
      end
      object Memo: TMemo
        Left = 7
        Top = 229
        Width = 296
        Height = 113
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 2
      end
      inline RangeSelect: TFrameRangeSelect
        Left = 7
        Top = 103
        Width = 292
        Height = 122
        Anchors = [akLeft, akTop, akRight]
        AutoSize = True
        TabOrder = 3
        ExplicitLeft = 7
        ExplicitTop = 103
        ExplicitWidth = 292
        inherited Range: TRangeSelector
          Width = 292
          ExplicitWidth = 292
        end
      end
      object lbAq: TEdit
        Left = 134
        Top = 75
        Width = 121
        Height = 21
        TabOrder = 4
        Text = '2'
      end
    end
  end
  object btCancel: TButton
    Left = 257
    Top = 390
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 1
    OnClick = btCancelClick
  end
  object btOK: TButton
    Left = 152
    Top = 390
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 2
    OnClick = btOKClick
  end
  object sb: TStatusBar
    Left = 0
    Top = 422
    Width = 340
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object ds: TDataSource
    Left = 266
    Top = 492
  end
end
