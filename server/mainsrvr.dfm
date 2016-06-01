object MainForm: TMainForm
  Left = 771
  Top = 310
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Server Info'
  ClientHeight = 347
  ClientWidth = 362
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 362
    Height = 306
    ActivePage = tsLog
    Align = alClient
    TabOrder = 1
    object tsLog: TTabSheet
      Caption = 'Statistic'
      ImageIndex = 1
      object mLog: TMemo
        Left = 3
        Top = 63
        Width = 345
        Height = 209
        Anchors = [akLeft, akTop, akBottom]
        ScrollBars = ssBoth
        TabOrder = 1
        WordWrap = False
      end
      object pnlStatistic: TPanel
        Left = 3
        Top = 3
        Width = 345
        Height = 54
        BevelInner = bvLowered
        TabOrder = 0
        object lblMaxConnects: TLabel
          Left = 128
          Top = 27
          Width = 18
          Height = 13
          Caption = '000'
        end
        object lblCurrConnects: TLabel
          Left = 128
          Top = 8
          Width = 18
          Height = 13
          Caption = '000'
        end
        object Label1: TLabel
          Left = 11
          Top = 8
          Width = 99
          Height = 13
          Caption = 'Current Connections'
        end
        object Label2: TLabel
          Left = 11
          Top = 27
          Width = 106
          Height = 13
          Caption = 'Maximum Connections'
        end
        object btnStatClear: TButton
          Left = 256
          Top = 8
          Width = 75
          Height = 33
          Caption = 'Clear'
          TabOrder = 0
          OnClick = btnStatClearClick
        end
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 306
    Width = 362
    Height = 41
    Align = alBottom
    TabOrder = 0
    object btnHide: TButton
      Left = 277
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Hide'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnHideClick
    end
  end
  object pmTrayMenu: TPopupMenu
    OnPopup = pmTrayMenuPopup
    Left = 108
    Top = 146
    object pmiShutdown: TMenuItem
      Caption = 'Shutdown'
      OnClick = pmiShutdownClick
    end
    object pmiProperties: TMenuItem
      Caption = 'Properties'
      OnClick = pmiPropertiesClick
    end
    object pmiViewLog: TMenuItem
      Caption = 'View Log'
      Default = True
      OnClick = pmiViewLogClick
    end
  end
end
