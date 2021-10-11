object Progressform: TProgressform
  Left = 391
  Top = 496
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Message : '
  ClientHeight = 92
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 14
    Top = 16
    Width = 299
    Height = 13
    Caption = 'Traitement en cours veuillez patientez quelques instants SVP ...'
  end
  object ProgressBar1: TProgressBar
    Left = 14
    Top = 48
    Width = 289
    Height = 25
    TabOrder = 0
  end
end
