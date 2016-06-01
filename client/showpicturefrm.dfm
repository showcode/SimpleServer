object PictureForm: TPictureForm
  Left = 528
  Top = 321
  Width = 457
  Height = 440
  Caption = 'Viewer (Double click to fullscreen)'
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imgPicture: TImage
    Left = 0
    Top = 0
    Width = 449
    Height = 406
    Align = alClient
    Center = True
    Stretch = True
    OnDblClick = imgPictureDblClick
  end
  object pnlButtons: TPanel
    Left = 192
    Top = 72
    Width = 169
    Height = 41
    TabOrder = 0
    object btnRestore: TButton
      Left = 8
      Top = 8
      Width = 73
      Height = 25
      Caption = 'Restore'
      TabOrder = 0
      OnClick = btnRestoreClick
    end
    object btnShot: TButton
      Left = 87
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Shot'
      TabOrder = 1
      OnClick = btnShotClick
    end
  end
end
