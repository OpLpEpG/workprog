object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 498
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    794
    498)
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 26
    Top = 49
    Width = 57
    Height = 25
    Caption = 'Create'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 26
    Top = 80
    Width = 57
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 26
    Top = 111
    Width = 57
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = Button4Click
  end
  object CheckBox1: TCheckBox
    Left = 104
    Top = 24
    Width = 57
    Height = 17
    Caption = 'legend'
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckBox1Click
  end
  object CheckBox2: TCheckBox
    Left = 104
    Top = 47
    Width = 41
    Height = 17
    Caption = 'info'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CheckBox2Click
  end
  object Button1: TButton
    Left = 26
    Top = 18
    Width = 57
    Height = 25
    Caption = 'AddColl'
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button5: TButton
    Left = 26
    Top = 142
    Width = 57
    Height = 25
    Caption = 'Dialog'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 26
    Top = 173
    Width = 57
    Height = 25
    Caption = 'Dialog'
    TabOrder = 7
    OnClick = Button6Click
  end
  object CheckBox3: TCheckBox
    Left = 104
    Top = 70
    Width = 47
    Height = 17
    Caption = 'mirror'
    TabOrder = 8
    OnClick = CheckBox3Click
  end
  object DBGrid1: TDBGrid
    Left = 167
    Top = 0
    Width = 619
    Height = 490
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    ReadOnly = True
    TabOrder = 9
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button7: TButton
    Left = 26
    Top = 204
    Width = 57
    Height = 25
    Caption = 'AddRow'
    TabOrder = 10
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 26
    Top = 235
    Width = 57
    Height = 25
    Caption = 'DElRow'
    TabOrder = 11
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 26
    Top = 266
    Width = 57
    Height = 25
    Caption = 'DelColl'
    TabOrder = 12
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 26
    Top = 352
    Width = 57
    Height = 25
    Caption = 'Load'
    TabOrder = 13
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 26
    Top = 383
    Width = 57
    Height = 25
    Caption = 'Save'
    TabOrder = 14
    OnClick = Button11Click
  end
  object DataSource1: TDataSource
    Left = 120
    Top = 200
  end
  object ms: TJvMemoryData
    Active = True
    FieldDefs = <
      item
        Name = 'JvMemoryData1Field1'
        ChildDefs = <
          item
            Name = 'JvMemoryData1Field1Field1'
            DataType = ftSingle
          end
          item
            Name = 'JvMemoryData1Field1Field2'
            DataType = ftSingle
          end
          item
            Name = 'JvMemoryData1Field1Field3'
            DataType = ftSingle
          end>
        Size = 3
      end
      item
        Name = 'JvMemoryData1Field2'
        DataType = ftString
        Size = 20
      end>
    ObjectView = True
    Left = 112
    Top = 264
  end
  object FDTable1: TFDTable
    Left = 656
    Top = 152
  end
  object FDLocalSQL1: TFDLocalSQL
    Connection = FDConnection1
    Active = True
    Left = 120
    Top = 152
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    Connected = True
    LoginPrompt = False
    Left = 120
    Top = 104
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from x ;# where l.ID = x.ID')
    Left = 192
    Top = 152
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 344
    Top = 152
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 544
    Top = 152
  end
  object xini: TJvAppXMLFileStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    StorageOptions.InvalidCharReplacement = '_'
    FileName = 'xini.xml'
    RootNodeName = 'Project3'
    SubStorages = <>
    Left = 312
    Top = 280
  end
  object rini: TJvAppRegistryStorage
    StorageOptions.BooleanStringTrueValues = 'TRUE, YES, Y'
    StorageOptions.BooleanStringFalseValues = 'FALSE, NO, N'
    Root = '%NONE%'
    SubStorages = <>
    Left = 272
    Top = 280
  end
end
