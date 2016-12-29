unit FIToolkit.Consts;

interface

uses
  System.SysUtils,
  FIToolkit.Types,
  FIToolkit.Commons.Consts, FIToolkit.CommandLine.Consts;

const

  { About }

  STR_APP_ABOUT_STRIP = '----------------------------------------------------------------------';
  STR_APP_COPYRIGHT_HOLDER = 'Xcentric <true.xcentric@gmail.com>';
  STR_APP_COPYRIGHT_TEXT = ' Copyright (c) ' + STR_APP_COPYRIGHT_HOLDER + ', 2016';
  STR_APP_DESCRIPTION = ' A set of tools for TMS Software(R) FixInsight(TM).';
  STR_APP_TITLE = 'FIToolkit';
  STR_APP_TITLE_ALIGNED = '                           ' + STR_APP_TITLE;

  { Common consts }

  ARR_APPCOMMAND_TO_CLIOPTION_MAPPING : array [Low(TApplicationCommand)..High(TApplicationCommand)] of String = (
    String.Empty,
    //
    STR_CLI_OPTION_HELP, STR_CLI_OPTION_VERSION, STR_CLI_OPTION_GENERATE_CONFIG, STR_CLI_OPTION_SET_CONFIG,
    STR_CLI_OPTION_NO_EXIT,
    //
    String.Empty, String.Empty, String.Empty, String.Empty,
    //
    String.Empty
  );

  ARR_CASE_SENSITIVE_CLI_OPTIONS : TArray<String> = [];

  ARR_CLIOPTION_PROCESSING_ORDER : TArray<String> = [
    STR_CLI_OPTION_NO_EXIT,
    STR_CLI_OPTION_HELP,
    STR_CLI_OPTION_VERSION,
    STR_CLI_OPTION_GENERATE_CONFIG,
    STR_CLI_OPTION_SET_CONFIG
  ];

  SET_FINAL_APPSTATES : set of TApplicationState =
    [asFinal, asHelpPrinted, asVersionPrinted, asConfigGenerated];

  { Resources }

  STR_RES_HELP = 'HelpOutput';

resourcestring

  { About }

  RSApplicationAbout =
    STR_APP_ABOUT_STRIP + sLineBreak +
    STR_APP_TITLE_ALIGNED + sDualBreak + STR_APP_DESCRIPTION + sDualBreak + STR_APP_COPYRIGHT_TEXT + sLineBreak +
    STR_APP_ABOUT_STRIP + sLineBreak;

  { Common strings }

  RSConfigWasGenerated = 'Файл конфигурации был сгенерирован.';
  RSEditConfigManually = 'Рекомендуется вручную отредактировать файл конфигурации.';
  RSNoVersionInfoAvailable = '<информация о версии недоступна>';
  RSTotalDuration = 'Время работы: %s';

  { Exceptions }

  RSApplicationExecutionFailed = 'Ошибка при выполнении программы.';
  RSCLIOptionsProcessingFailed = 'Ошибка при обработке параметров командной строки.';
  RSNoValidConfigSpecified = 'Не был указан существующий или генерируемый файл конфигурации.';

implementation

end.
