object FormTest: TFormTest
  Left = 0
  Top = 0
  Caption = 'FormTest'
  ClientHeight = 289
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 554
    Height = 289
    Align = alClient
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Button1: TButton
    Left = 496
    Top = 8
    Width = 33
    Height = 25
    Caption = 'CR'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 496
    Top = 39
    Width = 33
    Height = 25
    Caption = 'CR2'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 496
    Top = 70
    Width = 33
    Height = 25
    Caption = 'CR2'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 496
    Top = 101
    Width = 33
    Height = 25
    Caption = 'CR2'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 496
    Top = 132
    Width = 33
    Height = 25
    Caption = 'v'
    TabOrder = 5
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 496
    Top = 163
    Width = 33
    Height = 25
    Caption = 'v'
    TabOrder = 6
    OnClick = Button6Click
  end
  object vld: TFDSQLiteValidate
    DriverLink = FDPhysSQLiteDriverLink1
    Database = 'c:\XE\Projects\Device2\_exe\Debug\Projects\Telesis1.db'
    OnProgress = vldProgress
    Left = 176
    Top = 64
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 248
    Top = 72
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 104
    Top = 16
  end
end
