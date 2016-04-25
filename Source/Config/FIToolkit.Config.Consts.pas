unit FIToolkit.Config.Consts;

interface

uses
  System.Types,
  FIToolkit.Config.Types;

const

  { FixInsight command line parameters. Do not localize! }

  STR_FIPARAM_PREFIX       = '--';
  STR_FIPARAM_VALUE_DELIM  = '=';
  STR_FIPARAM_VALUES_DELIM = ';';

  STR_FIPARAM_DEFINES  = STR_FIPARAM_PREFIX + 'defines'  + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_OUTPUT   = STR_FIPARAM_PREFIX + 'output'   + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_PROJECT  = STR_FIPARAM_PREFIX + 'project'  + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_SETTINGS = STR_FIPARAM_PREFIX + 'settings' + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_SILENT   = STR_FIPARAM_PREFIX + 'silent';
  STR_FIPARAM_XML      = STR_FIPARAM_PREFIX + 'xml';

  { Default config values. Do not localize! }

  DEF_FIO_ARR_COMPILER_DEFINES : TStringDynArray = ['_FIXINSIGHT_'];
  DEF_FIO_ENUM_OUTPUT_FORMAT = fiofXML;
  DEF_FIO_STR_OUTPUT_FILENAME = 'FixInsightReport.xml';
  DEF_FIO_STR_SETTINGS_FILENAME = 'FixInsightConfig.ficfg';

  DEF_CD_STR_OUTPUT_FILENAME = 'FIToolkitReport.html';

resourcestring

  { Exceptions }

  RSFIOEmptyOutputFileName = 'Пустое имя выходного файла.';
  RSFIOInvalidOutputFileName = 'Имя выходного файла содержит недопустимые символы.';
  RSFIOOutputDirectoryNotFound = 'Директории выходного файла не существует.';
  RSFIOProjectFileNotFound = 'Файл проекта не найден.';
  RSFIOSettingsFileNotFound = 'Файл настроек FixInsight не найден.';

  RSCDFixInsightExeNotFound = 'Исполняемый файл FixInsight не найден.';
  RSCDInputFileNotFound = 'Входной файл не найден.';
  RSCDInvalidOutputFileName = 'Неверное имя выходного файла.';
  RSCDOutputDirectoryNotFound = 'Выходная директория не найдена.';
  RSCDTempDirectoryNotFound = 'Директория для временных файлов не найдена.';

implementation

end.
