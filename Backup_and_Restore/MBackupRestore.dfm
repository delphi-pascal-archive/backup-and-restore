object FBackupRestore: TFBackupRestore
  Left = 235
  Top = 127
  ActiveControl = RGChoixBase
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Backup and Restore'
  ClientHeight = 361
  ClientWidth = 298
  Color = 13565951
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 176
    Top = 64
    Width = 83
    Height = 16
    Caption = 'User_Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 176
    Top = 120
    Width = 69
    Height = 16
    Caption = 'Password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 176
    Top = 8
    Width = 47
    Height = 16
    Caption = 'Server'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BBRecupLOG: TBitBtn
    Left = 8
    Top = 240
    Width = 57
    Height = 49
    Hint = 'Sauvegarder les fichiers LOG'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = BBRecupLOGClick
    Glyph.Data = {
      76020000424D7602000000000000760000002800000020000000200000000100
      0400000000000002000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777777777777777777777777777777777777777777777777777777788888888
      888888888888877777777700000F7FFF77777000000087777777770CCCCF7CCC
      F7777CCCCCC087777777770CCCCF7CCCF7777CCCCCC087777777770CCCCF7CCC
      F7777CCCCCC087777777770CCCCF7CCCF7777CCCCCC087777777770CCCCF7CCC
      F7777CCCCCC087777777770CCCCF7CCCF7777CCCCCC087777777770CCCCF7777
      77777CCCCCC087777777770CCCCCFFFFFFFFCCCCCCC087777777770CCCCCCCCC
      CCCCCCCCCCC087777777770CCCCCCCCCCCCCCCCCCCC087777777770CCCCCCCCC
      CCCCCCCCCCC087777777770CCCCCCCCCCCCCCCCCCCC087777777770CCC000000
      00000000CCC087777777770CCC0FFFFFFFFFFFF0CCC087777777770CCC0FFFFF
      FFFFFFF0CCC087777777770CCC0F8888888888F0CCC087777777770CCC0FFFFF
      FFFFFFF0CCC087777777770CCC0F8888888888F0CCC087777777770C0C0FFFFF
      FFFFFFF0CCC087777777770C0C0F8888888888F0CCC077777777770CCC0FFFFF
      FFFFFFF0CCC07777777777000000000000000000000077777777777777777777
      7777777777777777777777777777777777777777777777777777777777777777
      7777777777777777777777777777777777777777777777777777777777777777
      7777777777777777777777777777777777777777777777777777}
  end
  object BBBackupRestore: TBitBtn
    Left = 8
    Top = 183
    Width = 57
    Height = 50
    Hint = 'Lancer Backup Restore'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = BBBackupRestoreClick
    Glyph.Data = {
      EE010000424DEE01000000000000860000002800000014000000120000000100
      08000000000068010000120B0000120B00001400000014000000C6C3C6008486
      8400393C39006361630000000000000052009C9E9C00006194000092DE00FFFF
      FF008CD7FF004ABAFF0000AAFF00D6F3FF006BC7FF008CD7DE000079BD004A49
      4A00B5E3FF0021AAFF0000000000000102020202020201000000000000000001
      0302040404050505050402010000000000000604040407080508090A0B070403
      000000000000010407080B08050C0D0A0A0804030000000000000104070E0B08
      05070F1010070411000000000000030408120A13080505050505050201000000
      0000030408120B080508090B0A0B0704030000000000030407070808050B0D0A
      0A0A0804110303030100030407080B0805070F10101007040404040402010304
      080E121308050505050505070C0C0C0704110304080E120B0B0C0C0C0C0C0C0C
      0A0A0A0804110304070B0A12120B0B0B0A0B0A0A0B0A0A0704110104070C0B0A
      0B08050404040404040404040201010404070C0C0B1212120804021111111111
      01000603020404070E0E0B12090804030000000000000000010302041007070B
      0B08040300000000000000000000010204040404040402010000000000000000
      000000010303030303030100000000000000}
  end
  object RGProtocol: TRadioGroup
    Left = 8
    Top = 96
    Width = 153
    Height = 73
    Caption = ' Protocol '
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Items.Strings = (
      'Local'
      'TCP')
    ParentColor = False
    ParentFont = False
    TabOrder = 2
    OnClick = RGProtocolClick
  end
  object EUserName: TEdit
    Left = 176
    Top = 88
    Width = 113
    Height = 24
    TabOrder = 3
    Text = 'SYSDBA'
    OnChange = EUserNameChange
  end
  object EPassword: TEdit
    Left = 176
    Top = 144
    Width = 113
    Height = 24
    TabOrder = 4
    Text = 'masterkey'
    OnChange = EPasswordChange
  end
  object EServer: TEdit
    Left = 176
    Top = 32
    Width = 113
    Height = 24
    TabOrder = 5
    Text = 'LocaHost'
    OnChange = EUserNameChange
  end
  object RGChoixBase: TRadioGroup
    Left = 8
    Top = 8
    Width = 153
    Height = 73
    Caption = ' Choose database '
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Items.Strings = (
      'Firebird'
      'Interbase')
    ParentColor = False
    ParentFont = False
    TabOrder = 6
    OnClick = RGChoixBaseClick
  end
  object TMAfficheLOG: TMemo
    Left = 72
    Top = 184
    Width = 220
    Height = 169
    Color = 16777204
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object IBBackupService1: TIBBackupService
    TraceFlags = []
    BlockingFactor = 0
    Options = []
    Left = 80
    Top = 176
  end
  object IBRestoreService1: TIBRestoreService
    TraceFlags = []
    PageBuffers = 0
    Left = 112
    Top = 176
  end
  object SDChoixBase: TSaveDialog
    Left = 146
    Top = 176
  end
end
