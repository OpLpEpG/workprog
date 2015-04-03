object FormRunCodes: TFormRunCodes
  Tag = 305419896
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 310
  ClientWidth = 535
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 378
    Top = 0
    Height = 310
    Align = alRight
    ExplicitLeft = 288
    ExplicitTop = 40
    ExplicitHeight = 100
  end
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 378
    Height = 310
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel'
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 129
      Width = 378
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 105
      ExplicitWidth = 281
    end
    object Chart: TChart
      Left = 0
      Top = 0
      Width = 378
      Height = 129
      AllowPanning = pmNone
      BottomWall.Visible = False
      LeftWall.Visible = False
      Legend.Visible = False
      MarginBottom = 1
      MarginLeft = 0
      MarginRight = 1
      MarginTop = 1
      MarginUnits = muPixels
      Title.Text.Strings = (
        'TChart')
      Title.Visible = False
      BottomAxis.Axis.Width = 0
      LeftAxis.Axis.Width = 0
      LeftAxis.AxisValuesFormat = '#0.#'
      LeftAxis.LabelsFormat.Font.Shadow.Smooth = False
      LeftAxis.LabelsFormat.Font.Shadow.Visible = False
      LeftAxis.LabelsFormat.Shadow.Visible = False
      LeftAxis.LabelsSeparation = 20
      LeftAxis.LabelStyle = talValue
      RightAxis.Visible = False
      Shadow.Visible = False
      TopAxis.Visible = False
      View3D = False
      View3DWalls = False
      Zoom.Allow = False
      Zoom.Pen.Visible = False
      Align = alTop
      BevelOuter = bvNone
      PopupMenu = PopupMenu
      TabOrder = 0
      DefaultCanvas = 'TTeeCanvas3D'
      PrintMargins = (
        15
        23
        15
        23)
      ColorPaletteIndex = 19
      object SeriesSP: TBarSeries
        BarBrush.BackColor = clDefault
        BarPen.Width = 4
        BarPen.Visible = False
        Marks.Visible = False
        Marks.Callout.Length = 8
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Bar'
        YValues.Order = loNone
      end
    end
    object ChartCode: TChart
      Left = 0
      Top = 132
      Width = 378
      Height = 178
      AllowPanning = pmNone
      BottomWall.Visible = False
      LeftWall.Visible = False
      Legend.CheckBoxes = True
      MarginBottom = 1
      MarginLeft = 0
      MarginRight = 1
      MarginTop = 1
      MarginUnits = muPixels
      Title.Text.Strings = (
        'TChart')
      Title.Visible = False
      BottomAxis.Axis.Width = 0
      LeftAxis.Axis.Width = 0
      LeftAxis.AxisValuesFormat = '#0.#'
      LeftAxis.LabelsFormat.Font.Shadow.Smooth = False
      LeftAxis.LabelsFormat.Font.Shadow.Visible = False
      LeftAxis.LabelsFormat.Shadow.Visible = False
      LeftAxis.LabelsSeparation = 20
      LeftAxis.LabelStyle = talValue
      RightAxis.Visible = False
      Shadow.Visible = False
      TopAxis.Visible = False
      View3D = False
      View3DWalls = False
      Zoom.Allow = False
      Zoom.Pen.Visible = False
      OnAfterDraw = ChartAfterDraw
      Align = alClient
      BevelOuter = bvNone
      PopupMenu = PopupMenu
      TabOrder = 1
      DefaultCanvas = 'TTeeCanvas3D'
      PrintMargins = (
        15
        23
        15
        23)
      ColorPaletteIndex = 19
      object SeriesCode: TBarSeries
        BarBrush.BackColor = clDefault
        BarPen.Width = 4
        BarPen.Visible = False
        Marks.Visible = False
        Marks.AutoPosition = False
        Marks.Callout.Length = 8
        Title = #1050#1086#1088#1088
        Transparency = 71
        BarWidthPercent = 100
        MultiBar = mbNone
        OffsetPercent = 50
        Shadow.Visible = False
        SideMargins = False
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Bar'
        YValues.Order = loNone
      end
      object SeriesPorog: TFastLineSeries
        Title = #1055#1086#1088#1086#1075
        LinePen.Color = 13395626
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object srSignal: TFastLineSeries
        SeriesColor = 64
        Title = #1057#1080#1075#1085#1072#1083
        LinePen.Color = 64
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object srNoise: TFastLineSeries
        SeriesColor = 8388863
        Title = #1064#1091#1084
        LinePen.Color = 8388863
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object srData: TFastLineSeries
        SeriesColor = 10485760
        Title = #1057'+'#1064
        LinePen.Color = 10485760
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object srMul: TFastLineSeries
        SeriesColor = 8421631
        Title = 'Mul'
        LinePen.Color = 8421631
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object srBit: TFastLineSeries
        SeriesColor = clTeal
        Title = 'bit'
        LinePen.Color = clTeal
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
      object srZerro: TFastLineSeries
        SeriesColor = 16711808
        Title = 'zerro'
        LinePen.Color = 16711808
        LinePen.Width = 3
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
  object Memo: TMemo
    Left = 381
    Top = 0
    Width = 154
    Height = 310
    Align = alRight
    BorderStyle = bsNone
    PopupMenu = PopupMenu
    TabOrder = 1
  end
  object PopupMenu: TPopupMenu
    Left = 152
    Top = 64
    object N1: TMenuItem
      Caption = #1087#1088#1080#1085#1091#1076#1080#1090#1077#1083#1100#1085#1086' '#1087#1086#1080#1089#1082' '#1057#1055
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #1057#1073#1088#1086#1089#1080#1090#1100' '#1089#1090#1072#1090#1080#1089#1090#1080#1082#1091
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object NPause: TMenuItem
      AutoCheck = True
      Caption = #1055#1072#1091#1079#1072
      Checked = True
      OnClick = NPauseClick
    end
    object N4: TMenuItem
      Caption = #1087#1077#1088#1082#1081#1090#1080' '#1082' '#1076#1072#1085#1085#1099#1084
      object N11: TMenuItem
        Tag = 1
        AutoCheck = True
        Caption = '1'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N21: TMenuItem
        Tag = 2
        AutoCheck = True
        Caption = '2'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N31: TMenuItem
        Tag = 3
        AutoCheck = True
        Caption = '3'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N41: TMenuItem
        Tag = 4
        AutoCheck = True
        Caption = '4'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N51: TMenuItem
        Tag = 5
        AutoCheck = True
        Caption = '5'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N61: TMenuItem
        Tag = 6
        AutoCheck = True
        Caption = '6'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N71: TMenuItem
        Tag = 7
        AutoCheck = True
        Caption = '7'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N81: TMenuItem
        Tag = 8
        AutoCheck = True
        Caption = '8'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N91: TMenuItem
        Tag = 9
        AutoCheck = True
        Caption = '9'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N101: TMenuItem
        Tag = 10
        AutoCheck = True
        Caption = '10'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N111: TMenuItem
        Tag = 11
        AutoCheck = True
        Caption = '11'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N121: TMenuItem
        Tag = 12
        AutoCheck = True
        Caption = '12'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N131: TMenuItem
        Tag = 13
        AutoCheck = True
        Caption = '13'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N141: TMenuItem
        Tag = 14
        AutoCheck = True
        Caption = '14'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N151: TMenuItem
        Tag = 15
        AutoCheck = True
        Caption = '15'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
      object N161: TMenuItem
        Tag = 16
        AutoCheck = True
        Caption = '16'
        GroupIndex = 1
        RadioItem = True
        OnClick = NDataClick
      end
    end
  end
end
