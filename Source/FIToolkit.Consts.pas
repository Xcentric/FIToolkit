unit FIToolkit.Consts;

interface

uses
  FIToolkit.Base.Consts;

const

  { About }

  STR_APP_ABOUT_STRIP = '----------------------------------------------------------------------';
  STR_APP_COPYRIGHT_HOLDER = 'Xcentric <true.xcentric@gmail.com>';
  STR_APP_COPYRIGHT_TEXT = ' Copyright (c) ' + STR_APP_COPYRIGHT_HOLDER + ', 2015';
  STR_APP_DESCRIPTION = ' A set of tools for SourceOddity(R) FixInsight(TM).';
  STR_APP_TITLE = '                           FIToolkit';

  { Resources }

  STR_RES_HELP = 'HelpOutput';

resourcestring

  { About }

  SApplicationAbout =
    STR_APP_ABOUT_STRIP + sLineBreak +
    STR_APP_TITLE + sDualBreak + STR_APP_DESCRIPTION + sDualBreak + STR_APP_COPYRIGHT_TEXT + sLineBreak +
    STR_APP_ABOUT_STRIP + sLineBreak;

  { Common strings }

  SConfigWasGenerated = 'Файл конфигурации был сгенерирован.';
  SEditConfigManually = 'Рекомендуется вручную отредактировать файл конфигурации.';

  { Exceptions }

  SNoConfigSpecified = 'Не был указан существующий или генерируемый файл конфигурации.';

implementation

end.
