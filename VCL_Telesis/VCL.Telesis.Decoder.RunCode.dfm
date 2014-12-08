object FormRunCodes: TFormRunCodes
  Tag = 305419896
  Left = 0
  Top = 0
  Align = alClient
  BorderStyle = bsNone
  ClientHeight = 292
  ClientWidth = 528
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
    Left = 371
    Top = 0
    Height = 292
    Align = alRight
    ExplicitLeft = 288
    ExplicitTop = 40
    ExplicitHeight = 100
  end
  object Panel: TPanel
    Left = 0
    Top = 0
    Width = 371
    Height = 292
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel'
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 161
      Width = 371
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 105
      ExplicitWidth = 281
    end
    object Chart: TChart
      Left = 0
      Top = 0
      Width = 371
      Height = 161
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
      Top = 164
      Width = 371
      Height = 128
      AllowPanning = pmNone
      BottomWall.Visible = False
      LeftWall.Visible = False
      Legend.CheckBoxes = True
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
        Marks.Callout.Length = 8
        Title = #1050#1086#1088#1088
        Transparency = 71
        BarWidthPercent = 100
        MultiBar = mbNone
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
        SeriesColor = 8453888
        Title = #1057#1080#1075#1085#1072#1083
        LinePen.Color = 8453888
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
    end
  end
  object Memo: TMemo
    Left = 374
    Top = 0
    Width = 154
    Height = 292
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
  end
end
