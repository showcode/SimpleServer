object MainForm: TMainForm
  Left = 510
  Top = 311
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Simple Server Manager'
  ClientHeight = 346
  ClientWidth = 362
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 362
    Height = 305
    ActivePage = tsProperties
    Align = alClient
    TabOrder = 0
    object tsProperties: TTabSheet
      Caption = 'Properties'
      object lblStatus: TLabel
        Left = 56
        Top = 8
        Width = 177
        Height = 33
        AutoSize = False
        Caption = 'Server is stopped.'
      end
      object Image1: TImage
        Left = 11
        Top = 8
        Width = 32
        Height = 32
        AutoSize = True
        Picture.Data = {
          055449636F6E0000010002001010000001000800680500002600000020200000
          01000800A80800008E0500002800000010000000200000000100080000000000
          0000000000000000000000000000000000000000000000000000800000800000
          00808000800000008000800080800000C0C0C000C0DCC000F0CAA60004040400
          080808000C0C0C0011111100161616001C1C1C00222222002929290055555500
          4D4D4D004242420039393900807CFF005050FF009300D600FFECCC00C6D6EF00
          D6E7E70090A9AD000000330000006600000099000000CC000033000000333300
          00336600003399000033CC000033FF0000660000006633000066660000669900
          0066CC000066FF00009900000099330000996600009999000099CC000099FF00
          00CC000000CC330000CC660000CC990000CCCC0000CCFF0000FF660000FF9900
          00FFCC00330000003300330033006600330099003300CC003300FF0033330000
          3333330033336600333399003333CC003333FF00336600003366330033666600
          336699003366CC003366FF00339900003399330033996600339999003399CC00
          3399FF0033CC000033CC330033CC660033CC990033CCCC0033CCFF0033FF3300
          33FF660033FF990033FFCC0033FFFF0066000000660033006600660066009900
          6600CC006600FF00663300006633330066336600663399006633CC006633FF00
          666600006666330066666600666699006666CC00669900006699330066996600
          669999006699CC006699FF0066CC000066CC330066CC990066CCCC0066CCFF00
          66FF000066FF330066FF990066FFCC00CC00FF00FF00CC009999000099339900
          990099009900CC009900000099333300990066009933CC009900FF0099660000
          9966330099336600996699009966CC009933FF00999933009999660099999900
          9999CC009999FF0099CC000099CC330066CC660099CC990099CCCC0099CCFF00
          99FF000099FF330099CC660099FF990099FFCC0099FFFF00CC00000099003300
          CC006600CC009900CC00CC0099330000CC333300CC336600CC339900CC33CC00
          CC33FF00CC660000CC66330099666600CC669900CC66CC009966FF00CC990000
          CC993300CC996600CC999900CC99CC00CC99FF00CCCC0000CCCC3300CCCC6600
          CCCC9900CCCCCC00CCCCFF00CCFF0000CCFF330099FF6600CCFF9900CCFFCC00
          CCFFFF00CC003300FF006600FF009900CC330000FF333300FF336600FF339900
          FF33CC00FF33FF00FF660000FF663300CC666600FF669900FF66CC00CC66FF00
          FF990000FF993300FF996600FF999900FF99CC00FF99FF00FFCC0000FFCC3300
          FFCC6600FFCC9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF9900FFFFCC00
          6666FF0066FF660066FFFF00FF666600FF66FF00FFFF66002100A5005F5F5F00
          777777008686860096969600CBCBCB00B2B2B200D7D7D700DDDDDD00E3E3E300
          EAEAEA00F1F1F100F8F8F800F0FBFF00A4A0A000808080000000FF0000FF0000
          00FFFF00FF000000FF00FF00FFFF0000FFFFFF000A0A0A0A0A0A0A0A0A0A0A0A
          0A0A0A0A0A0A0A0A0AAE65656565130A0A0A0A0A0A0A0AEEAEEC919191AE6D6D
          6D0A0A0A0A0AB48AACACACAC8A8A8A6565650A0A0A0A07F3F6F3F31909EEF7F7
          6D6D6D0A0AD4D3D3D3D3D3D3D3D3ACAC8A65650AF0F0F4FFFFFFFFFFFFFFF6F0
          F7EC6DECD4D3D3D4D4D4D4D4D3D3D3D3AC8A6565FFF6F6FFFFFFFFFFFFFFFFF6
          EEF76D6DD4D3D4D4D4D4D4D4D4D3D3D3AC8A6565FFF3FFFFFFFFFFFFFFFFF6F3
          EEF76DEC0AD3D3D4D4D4D4D4D4D3D3D3AC8A650A0A0AF6F6FFFFFFFFFFFFF6F1
          07EC6D0A0A0A09D4D4D4D4D4D4D3D3D38A650A0A0A0A0A0AF3F6FFFFF6F3EEF7
          6D0A0A0A0A0A0A0A0AB4D3ACACAC8A0A0A0A0A0AFFFF0000F81F0000E0070000
          C0030000C0010000800100000000000000000000000000000000000000000000
          80010000C0010000C0030000F0070000F81F0000280000002000000040000000
          0100080000000000000000000000000000000000000000000000000000000000
          000080000080000000808000800000008000800080800000C0C0C000C0DCC000
          F0CAA60004040400080808000C0C0C0011111100161616001C1C1C0022222200
          29292900555555004D4D4D004242420039393900807CFF005050FF009300D600
          FFECCC00C6D6EF00D6E7E70090A9AD000000330000006600000099000000CC00
          003300000033330000336600003399000033CC000033FF000066000000663300
          00666600006699000066CC000066FF0000990000009933000099660000999900
          0099CC000099FF0000CC000000CC330000CC660000CC990000CCCC0000CCFF00
          00FF660000FF990000FFCC00330000003300330033006600330099003300CC00
          3300FF00333300003333330033336600333399003333CC003333FF0033660000
          3366330033666600336699003366CC003366FF00339900003399330033996600
          339999003399CC003399FF0033CC000033CC330033CC660033CC990033CCCC00
          33CCFF0033FF330033FF660033FF990033FFCC0033FFFF006600000066003300
          66006600660099006600CC006600FF0066330000663333006633660066339900
          6633CC006633FF00666600006666330066666600666699006666CC0066990000
          6699330066996600669999006699CC006699FF0066CC000066CC330066CC9900
          66CCCC0066CCFF0066FF000066FF330066FF990066FFCC00CC00FF00FF00CC00
          9999000099339900990099009900CC009900000099333300990066009933CC00
          9900FF00996600009966330099336600996699009966CC009933FF0099993300
          99996600999999009999CC009999FF0099CC000099CC330066CC660099CC9900
          99CCCC0099CCFF0099FF000099FF330099CC660099FF990099FFCC0099FFFF00
          CC00000099003300CC006600CC009900CC00CC0099330000CC333300CC336600
          CC339900CC33CC00CC33FF00CC660000CC66330099666600CC669900CC66CC00
          9966FF00CC990000CC993300CC996600CC999900CC99CC00CC99FF00CCCC0000
          CCCC3300CCCC6600CCCC9900CCCCCC00CCCCFF00CCFF0000CCFF330099FF6600
          CCFF9900CCFFCC00CCFFFF00CC003300FF006600FF009900CC330000FF333300
          FF336600FF339900FF33CC00FF33FF00FF660000FF663300CC666600FF669900
          FF66CC00CC66FF00FF990000FF993300FF996600FF999900FF99CC00FF99FF00
          FFCC0000FFCC3300FFCC6600FFCC9900FFCCCC00FFCCFF00FFFF3300CCFF6600
          FFFF9900FFFFCC006666FF0066FF660066FFFF00FF666600FF66FF00FFFF6600
          2100A5005F5F5F00777777008686860096969600CBCBCB00B2B2B200D7D7D700
          DDDDDD00E3E3E300EAEAEA00F1F1F100F8F8F800F0FBFF00A4A0A00080808000
          0000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000F791919191F70000000000000000000000000000000000
          000000000000AE65656565656565656513AE0000000000000000000000000000
          00000000AE1313AE6DAEAE6DAEAE6D6D131313AE000000000000000000000000
          0000EE6DAEECEC919191919191ECAEAE6DAE6D6D6D0000000000000000000000
          00B4658A8AACACACACAC8AAC8AAC8A8A8A658A656513EC000000000000000000
          B4658AACACACACACACACACAC8A8A8A8A8A8A65656565659100000000000000DD
          AEB3B3B4B4B4B4B4B4B4B4B4B4B4B4919191AEAE1313131300000000000000F7
          07F0F3F6F6F6F3F3F3F219DD09EEEE07F7F7F7EC6D6D6D6D6D0000000000B4AC
          B3D4D4D4D4D4D4D4D3D3D3D3D3D3ACD3ACAC8A8A8A8A656565EC00000000ACD3
          D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3ACACAC8A8A656565651300000000B3B4
          B409091919F3F3F31919DD090909B4B4B4B3B3B3AEAE8A656513000000F0F0F6
          F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F2F0BCF7F7EC6D6D6DEC0000B3B4B4
          090909DDDDDDDD09DD0909090909B4B4D4D4D3ACAC8A8A656565130000D3D3D3
          D3D4D4D4D4D4D4D4D4D4D4D4D3D3D3D3D3D3D3ACAC8A8A656565650000B409DD
          19F3F4F5F5F5F5F5F5F5F5F4F3DD0909B4B4D4B3B3AE8A136565650000F0F6F6
          F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F6F2BC07F7EC6D6D6D0000B4DD19
          F3F4F5F5F5FFF5FFFFF5FFF5F5F319DD09B4B4B3B3AC8A8A6565650000D3D3D4
          D4D4D4D4D4D4D4D4D4D4D4D4D4D3D3D3D3D3D3D3ACAC8A8A6565650000B409DD
          DDDD19191919191919191919DD0909B4B4D4D4D3D3AC8A8A656513000000F3F6
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F6F3F0EE07F7EC6D6DEC0000000919
          F3F3F4F4F5F5F5F5F5F4F5F4F4F4F3190909B4B4B4B3AE8A656500000000D3D3
          D3D4D4D4D4D4D4D4D4D4D4D4D4D3D3D3D3D3D3D3ACAC8A8A6565000000000909
          0909DDDDDDDDDDDDDD09DD0909090909B4D4D4D3ACAC8A6565910000000000F3
          F6F6F6FFFFFFFFFFFFFFFFFFFFFFFFFFF6F6F2EE07F7EC6D6D00000000000000
          DDF3F3F4F6F6FFFFFFFFF6F5F5F4190909B4B4B4B3AE8A650000000000000000
          09D3D4D4D4D4D4D4D4D4D4D4D4D3D3D3D3D3D3AC8A8A65910000000000000000
          0009B4B409090909090909B4B4D4D4D3D3D3ACAC8A6591000000000000000000
          000000F2F3F6F6F6FFFFFFFFF6F6F3F0EE07F7EC6D0000000000000000000000
          00000000F009EEF0F0DD090909B4B4B491AEAE91000000000000000000000000
          000000000000B4D3D3ACACACACACAC8A8AB30000000000000000000000000000
          000000000000000000B4B4B4B4B4B400000000000000000000000000FFFFFFFF
          FFF81FFFFFC003FFFF0000FFFC00007FF800001FF000000FE000000FE0000007
          C0000003C0000003C00000038000000180000001800000018000000180000001
          800000018000000180000001C0000001C0000003C0000003C0000003E0000007
          F000000FF000000FF800001FFE00007FFF0000FFFFC003FFFFF81FFF}
      end
      object lblInfo: TLabel
        Left = 8
        Top = 48
        Width = 225
        Height = 17
        AutoSize = False
        Caption = 'The Simple Server 1.0'
      end
      object pnlSettings: TPanel
        Left = 3
        Top = 75
        Width = 345
        Height = 78
        BevelInner = bvLowered
        TabOrder = 1
        object lblListenPort: TLabel
          Left = 24
          Top = 16
          Width = 51
          Height = 13
          Caption = 'Listen Port'
        end
        object edtPort: TEdit
          Left = 93
          Top = 13
          Width = 44
          Height = 21
          TabOrder = 0
          Text = '22'
          OnChange = PropertyModified
        end
        object cbxShowTray: TCheckBox
          Left = 24
          Top = 48
          Width = 97
          Height = 17
          Caption = 'Show TrayIcon'
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = PropertyModified
        end
        object btnSetDefault: TButton
          Left = 152
          Top = 11
          Width = 75
          Height = 25
          Caption = 'Default'
          TabOrder = 1
          OnClick = btnSetDefaultClick
        end
      end
      object btnStartStop: TButton
        Left = 257
        Top = 11
        Width = 75
        Height = 50
        Caption = 'Start'
        TabOrder = 0
        OnClick = btnStartStopClick
      end
      object rgRunMode: TRadioGroup
        Left = 3
        Top = 199
        Width = 166
        Height = 65
        Anchors = [akLeft, akBottom]
        Caption = ' Run '
        ItemIndex = 0
        Items.Strings = (
          'as a Service'
          'as an Application')
        TabOrder = 4
        OnClick = PropertyModified
      end
      object rgStartMode: TRadioGroup
        Left = 176
        Top = 199
        Width = 169
        Height = 65
        Anchors = [akLeft, akBottom]
        Caption = ' Start '
        ItemIndex = 0
        Items.Strings = (
          'Automatically'
          'Manually')
        TabOrder = 5
        OnClick = PropertyModified
      end
      object cbxUseGuardian: TCheckBox
        Left = 11
        Top = 175
        Width = 126
        Height = 17
        Anchors = [akLeft, akBottom]
        Caption = 'Use the Guardian'
        TabOrder = 2
        OnClick = PropertyModified
      end
      object cbxCtrlApplet: TCheckBox
        Left = 192
        Top = 176
        Width = 153
        Height = 17
        Caption = 'Install Control Panel Applet'
        TabOrder = 3
        OnClick = PropertyModified
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 305
    Width = 362
    Height = 41
    Align = alBottom
    TabOrder = 1
    object btnOk: TButton
      Left = 117
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 197
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnApply: TButton
      Left = 277
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 2
      OnClick = btnApplyClick
    end
  end
  object tmrCheckStatus: TTimer
    OnTimer = tmrCheckStatusTimer
    Left = 167
    Top = 27
  end
end
