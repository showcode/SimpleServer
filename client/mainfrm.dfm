object MainForm: TMainForm
  Left = 504
  Top = 264
  Width = 401
  Height = 500
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Client'
  Color = clBtnFace
  Constraints.MaxWidth = 401
  Constraints.MinHeight = 420
  Constraints.MinWidth = 401
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 377
    Height = 81
  end
  object Bevel3: TBevel
    Left = 8
    Top = 272
    Width = 377
    Height = 168
    Anchors = [akLeft, akTop, akBottom]
  end
  object Bevel2: TBevel
    Left = 8
    Top = 96
    Width = 377
    Height = 169
  end
  object lblTextLen: TLabel
    Left = 16
    Top = 405
    Width = 62
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Text Length:'
  end
  object lblImageProperty: TLabel
    Left = 18
    Top = 244
    Width = 46
    Height = 13
    Caption = 'No Image'
  end
  object cbxServers: TComboBox
    Left = 16
    Top = 21
    Width = 257
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
  end
  object mText: TMemo
    Left = 16
    Top = 281
    Width = 361
    Height = 105
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 10
    OnChange = mTextChange
  end
  object btnConnect: TButton
    Left = 302
    Top = 35
    Width = 75
    Height = 41
    Action = acConnect
    TabOrder = 5
  end
  object btnGetLength: TButton
    Left = 304
    Top = 391
    Width = 75
    Height = 41
    Action = acSendText
    Anchors = [akLeft, akBottom]
    TabOrder = 11
  end
  object btnGetScreenshot: TButton
    Left = 302
    Top = 216
    Width = 75
    Height = 41
    Action = acReqScreenshot
    TabOrder = 7
  end
  object pnlPreview: TPanel
    Left = 16
    Top = 105
    Width = 172
    Height = 128
    BevelOuter = bvLowered
    BevelWidth = 2
    Caption = '<No Image>'
    Color = clActiveBorder
    TabOrder = 9
    object imgScreenshot: TImage
      Left = 2
      Top = 2
      Width = 168
      Height = 124
      Hint = 'Click image for show'
      Align = alClient
      Center = True
      Stretch = True
      OnClick = acShowViewerExecute
    end
  end
  object gbxCompression: TGroupBox
    Left = 194
    Top = 112
    Width = 183
    Height = 97
    Caption = '   '
    TabOrder = 6
    object lblQuality: TLabel
      Left = 11
      Top = 20
      Width = 102
      Height = 13
      Caption = 'Compression Quality:'
    end
    object cbxUseJpeg: TCheckBox
      Left = 13
      Top = 0
      Width = 67
      Height = 17
      Caption = 'Use JPEG'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = cbxUseJpegClick
    end
    object trbCompression: TTrackBar
      Left = 6
      Top = 36
      Width = 171
      Height = 30
      Max = 100
      Orientation = trHorizontal
      PageSize = 10
      Frequency = 2
      Position = 100
      SelEnd = 0
      SelStart = 0
      TabOrder = 1
      TickMarks = tmBottomRight
      TickStyle = tsAuto
    end
    object cbxGrayScale: TCheckBox
      Left = 14
      Top = 70
      Width = 72
      Height = 17
      Caption = 'GrayScale'
      Enabled = False
      TabOrder = 2
    end
    object cbxProgressive: TCheckBox
      Left = 92
      Top = 70
      Width = 75
      Height = 17
      Caption = 'Progressive'
      TabOrder = 3
    end
  end
  object btnAdd: TButton
    Left = 16
    Top = 51
    Width = 65
    Height = 25
    Action = acServersAdd
    TabOrder = 1
  end
  object btnDel: TButton
    Left = 80
    Top = 51
    Width = 65
    Height = 25
    Action = acServersDel
    TabOrder = 2
  end
  object btnSave: TButton
    Left = 144
    Top = 51
    Width = 65
    Height = 25
    Action = acServersSave
    TabOrder = 3
  end
  object btnLoad: TButton
    Left = 208
    Top = 51
    Width = 65
    Height = 25
    Action = acServersLoad
    Caption = 'Reload'
    TabOrder = 4
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 447
    Width = 393
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object btnShowViewer: TButton
    Left = 204
    Top = 216
    Width = 75
    Height = 41
    Action = acShowViewer
    TabOrder = 8
  end
  object ActionList: TActionList
    Left = 216
    Top = 304
    object acServersAdd: TAction
      Category = 'ServersList'
      Caption = 'Add'
      OnExecute = acServersAddExecute
    end
    object acServersDel: TAction
      Category = 'ServersList'
      Caption = 'Delete'
      OnExecute = acServersDelExecute
    end
    object acServersLoad: TAction
      Category = 'ServersList'
      Caption = 'Load'
      OnExecute = acServersLoadExecute
    end
    object acServersSave: TAction
      Category = 'ServersList'
      Caption = 'Save'
      OnExecute = acServersSaveExecute
    end
    object acConnect: TAction
      Category = 'Server'
      Caption = 'Connect'
      OnExecute = acConnectExecute
    end
    object acDisconnect: TAction
      Category = 'Server'
      Caption = 'Disconnect'
      OnExecute = acDisconnectExecute
    end
    object acSendText: TAction
      Category = 'Server'
      Caption = 'Send Text'
      OnExecute = acSendTextExecute
    end
    object acReqScreenshot: TAction
      Category = 'Server'
      Caption = 'Screenshot'
      OnExecute = acReqScreenshotExecute
    end
    object acShowViewer: TAction
      Category = 'Control'
      Caption = 'Viewer'
      OnExecute = acShowViewerExecute
    end
  end
end
