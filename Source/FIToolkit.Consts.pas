unit FIToolkit.Consts;

interface

uses
  FIToolkit.Commons.Consts;

const

  { About }

  STR_APP_ABOUT_STRIP = '----------------------------------------------------------------------';
  STR_APP_COPYRIGHT_HOLDER = 'Xcentric <true.xcentric@gmail.com>';
  STR_APP_COPYRIGHT_TEXT = ' Copyright (c) ' + STR_APP_COPYRIGHT_HOLDER + ', 2016';
  STR_APP_DESCRIPTION = ' A set of tools for SourceOddity(R) FixInsight(TM).';
  STR_APP_TITLE = '                           FIToolkit';

  { Resources }

  STR_RES_HELP = 'HelpOutput';

resourcestring

  { About }

  RSApplicationAbout =
    STR_APP_ABOUT_STRIP + sLineBreak +
    STR_APP_TITLE + sDualBreak + STR_APP_DESCRIPTION + sDualBreak + STR_APP_COPYRIGHT_TEXT + sLineBreak +
    STR_APP_ABOUT_STRIP + sLineBreak;

  { Common strings }

  RSConfigWasGenerated = 'Файл конфигурации был сгенерирован.';
  RSEditConfigManually = 'Рекомендуется вручную отредактировать файл конфигурации.';

  { Exceptions }

  RSNoValidConfigSpecified = 'Не был указан существующий или генерируемый файл конфигурации.';

implementation

end.
