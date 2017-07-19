unit FIToolkit.CommandLine.Consts;

interface

const

  { Command-line option }

  STR_CLI_OPTION_PREFIX = '--';
  STR_CLI_OPTION_DELIMITER = '=';

  { Supported command-line options }

  STR_CLI_OPTION_GENERATE_CONFIG = 'generate-config';
  STR_CLI_OPTION_HELP = 'help';
  STR_CLI_OPTION_LOG_FILE = 'log-file';
  STR_CLI_OPTION_NO_EXIT = 'no-exit';
  STR_CLI_OPTION_SET_CONFIG = 'set-config';
  STR_CLI_OPTION_VERSION = 'version';

resourcestring

  { Exceptions }

  RSCLIOptionIsEmpty = 'Передан пустой параметр командной строки.';
  RSCLIOptionHasNoName = 'Параметр командной строки не имеет имени.';

implementation

end.
