object GG: TGG
  Left = 192
  Top = 116
  Width = 397
  Height = 472
  BorderIcons = [biSystemMenu]
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 345
    Width = 389
    Height = 4
    Cursor = crHandPoint
    Align = alBottom
    Color = cl3DDkShadow
    ParentColor = False
  end
  object InputBox: TRichEdit
    Left = 0
    Top = 0
    Width = 389
    Height = 345
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clGrayText
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    WordWrap = False
    OnKeyDown = InputBoxKeyDown
  end
  object OutputBox: TRichEdit
    Left = 0
    Top = 349
    Width = 389
    Height = 89
    Align = alBottom
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clGrayText
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    WordWrap = False
  end
end
