unit FIToolkit.CommandLine.Consts;

interface

const

  { Command-line option }

  STR_CLI_OPTION_PREFIX = '--';
  STR_CLI_OPTION_DELIMITER = '=';

resourcestring

  { Exceptions }

  SCLIOptionIsEmpty = 'Передан пустой параметр командной строки.';
  SCLIOptionHasNoName = 'Параметр командной строки не имеет имени.';

implementation

end.
