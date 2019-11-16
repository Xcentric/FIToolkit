unit FIToolkit.CommandLine.Consts;

interface

uses
  FIToolkit.Localization;

const

  { Command-line option }

  STR_CLI_OPTION_PREFIX = '--';
  STR_CLI_OPTION_DELIMITER = '=';
  STR_CLI_OPTIONS_DELIMITER = ' ';

  { Supported command-line options }

  STR_CLI_OPTION_GENERATE_CONFIG = 'generate-config';
  STR_CLI_OPTION_HELP = 'help';
  STR_CLI_OPTION_LOG_FILE = 'log-file';
  STR_CLI_OPTION_NO_EXIT = 'no-exit';
  STR_CLI_OPTION_SET_CONFIG = 'set-config';
  STR_CLI_OPTION_VERSION = 'version';

resourcestring

  {$IF LANGUAGE = LANG_EN_US}
    {$INCLUDE 'Locales\en-US.inc'}
  {$ELSEIF LANGUAGE = LANG_RU_RU}
    {$INCLUDE 'Locales\ru-RU.inc'}
  {$ELSE}
    {$MESSAGE FATAL 'No language defined!'}
  {$ENDIF}

implementation

end.
