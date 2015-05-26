object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Form4'
  ClientHeight = 351
  ClientWidth = 807
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    807
    351)
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
    Top = 8
    Width = 632
    Height = 335
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    TabOrder = 9
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object DataSource1: TDataSource
    DataSet = ms
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
    Left = 336
    Top = 240
  end
end
