object FormDlgRam: TFormDlgRam
  Left = 0
  Top = 0
  Caption = 'Memory reading settings'
  ClientHeight = 349
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poMainFormCenter
  DesignSize = (
    386
    349)
  TextHeight = 13
  object lbFile: TLabel
    Left = 18
    Top = 8
    Width = 125
    Height = 13
    Caption = 'Create binary file'
  end
  object lbLen: TLabel
    Left = 224
    Top = 88
    Width = 86
    Height = 13
    Caption = 'Packet length 0x'
  end
  object lbSD: TLabel
    Left = 224
    Top = 58
    Width = 44
    Height = 13
    Caption = 'Disc  SD'
    Enabled = False
  end
  object btStart: TButton
    Left = 16
    Top = 294
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btStartClick
  end
  object btExit: TButton
    Left = 291
    Top = 294
    Width = 75
    Height = 25
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
    OnClick = btExitClick
  end
  object cbToFF: TCheckBox
    Left = 18
    Top = 114
    Width = 151
    Height = 17
    Caption = 'Read to empty memory'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object Progress: TProgressBar
    Left = 17
    Top = 271
    Width = 350
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
  end
  object btTerminate: TButton
    Left = 178
    Top = 294
    Width = 75
    Height = 25
    Caption = 'Abort'
    TabOrder = 4
    OnClick = btTerminateClick
  end
  object sb: TStatusBar
    Left = 0
    Top = 330
    Width = 386
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
  object rg: TRadioGroup
    Left = 18
    Top = 48
    Width = 201
    Height = 63
    Caption = 'High speed'
    Columns = 4
    ItemIndex = 0
    Items.Strings = (
      '125'#1050
      '0.5M'
      '1M'
      '2M'
      '3M'
      '8M'
      '12M'
      '100'#1052)
    TabOrder = 6
    OnClick = rgClick
  end
  object od: TJvFilenameEdit
    Left = 18
    Top = 21
    Width = 350
    Height = 21
    OnBeforeDialog = odBeforeDialog
    DialogKind = dkSave
    DefaultExt = 'bin'
    Filter = 'binary file (*.bin)|*.bin'
    DialogOptions = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist]
    DirectInput = False
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = ''
  end
  object edLen: TEdit
    Left = 310
    Top = 85
    Width = 57
    Height = 21
    TabOrder = 8
    Text = '3FF0'
  end
  object cbSD: TComboBox
    Left = 270
    Top = 55
    Width = 97
    Height = 21
    Style = csDropDownList
    Enabled = False
    TabOrder = 9
    OnChange = cbSDChange
    OnDropDown = cbSDDropDown
  end
  object cbClcCreate: TCheckBox
    Left = 171
    Top = 114
    Width = 196
    Height = 17
    Caption = 'Create calculation data file'
    TabOrder = 10
  end
  inline RangeSelect: TFrameRangeSelect
    Left = 18
    Top = 144
    Width = 348
    Height = 122
    Anchors = [akLeft, akTop, akRight]
    AutoSize = True
    TabOrder = 11
    ExplicitLeft = 18
    ExplicitTop = 144
    ExplicitWidth = 348
    inherited lbBegin: TLabel
      Width = 37
      Height = 13
      ExplicitWidth = 37
      ExplicitHeight = 13
    end
    inherited lbEnd: TLabel
      Width = 31
      Height = 13
      ExplicitWidth = 31
      ExplicitHeight = 13
    end
    inherited lbCnt: TLabel
      Width = 35
      Height = 13
      ExplicitWidth = 35
      ExplicitHeight = 13
    end
    inherited lbKaBegin: TLabel
      Height = 13
      ExplicitHeight = 13
    end
    inherited lbKaCnt: TLabel
      Height = 13
      ExplicitHeight = 13
    end
    inherited lbKaEnd: TLabel
      Height = 13
      ExplicitHeight = 13
    end
    inherited Label1: TLabel
      Width = 70
      Height = 13
      ExplicitWidth = 70
      ExplicitHeight = 13
    end
    inherited Label2: TLabel
      Width = 58
      Height = 13
      ExplicitWidth = 58
      ExplicitHeight = 13
    end
    inherited Label3: TLabel
      Width = 33
      Height = 13
      ExplicitWidth = 33
      ExplicitHeight = 13
    end
    inherited Range: TRangeSelector
      Width = 348
      SelStart = 20
      SelEnd = 80
      ExplicitWidth = 348
    end
  end
  object btContinue: TButton
    Left = 97
    Top = 294
    Width = 75
    Height = 25
    Caption = 'Continue'
    Enabled = False
    TabOrder = 12
    OnClick = btContinueClick
  end
end
