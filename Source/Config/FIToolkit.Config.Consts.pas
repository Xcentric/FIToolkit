unit FIToolkit.Config.Consts;

interface

uses
  FIToolkit.Config.Types;

const

  { FixInsight command line parameters. Do not localize! }

  STR_FIPARAM_PREFIX = '--';
  STR_FIPARAM_VALUE_DELIM = '=';
  STR_FIPARAM_VALUES_DELIM = ';';

  STR_FIPARAM_DEFINES  = STR_FIPARAM_PREFIX + 'defines'  + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_OUTPUT   = STR_FIPARAM_PREFIX + 'output'   + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_PROJECT  = STR_FIPARAM_PREFIX + 'project'  + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_SETTINGS = STR_FIPARAM_PREFIX + 'settings' + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_SILENT   = STR_FIPARAM_PREFIX + 'silent';
  STR_FIPARAM_XML      = STR_FIPARAM_PREFIX + 'xml';

  { Default config values. Do not localize! }

  DEF_FIO_ARR_COMPILER_DEFINES : array [0..0] of String = ('_FIXINSIGHT_');
  DEF_FIO_ENUM_OUTPUT_FORMAT = fiofXML;
  DEF_FIO_STR_OUTPUT_FILENAME = 'FixInsightReport.xml';
  DEF_FIO_STR_SETTINGS_FILENAME = 'FixInsightConfig.ficfg';

  DEF_CD_STR_OUTPUT_FILENAME = 'FIToolkitReport.html';

resourcestring

  { Exceptions }

  SFIOEmptyOutputFileName = 'Пустое имя выходного файла.';
  SFIOInvalidOutputFileName = 'Имя выходного файла содержит недопустимые символы.';
  SFIOOutputDirectoryNotFound = 'Директории выходного файла не существует.';
  SFIOProjectFileNotFound = 'Файл проекта не найден.';
  SFIOSettingsFileNotFound = 'Файл настроек FixInsight не найден.';

  SCDFixInsightExeNotFound = 'Исполняемый файл FixInsight не найден.';
  SCDInputFileNotFound = 'Входной файл не найден.';
  SCDInvalidOutputFileName = 'Неверное имя выходного файла.';
  SCDOutputDirectoryNotFound = 'Выходная директория не найдена.';
  SCDTempDirectoryNotFound = 'Директория для временных файлов не найдена.';

implementation

end.
