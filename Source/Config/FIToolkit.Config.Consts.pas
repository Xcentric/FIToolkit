unit FIToolkit.Config.Consts;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Config.Types;

const

  { Common consts }

  STR_CFG_VALUE_ARR_DELIM_DEFAULT = ',';
  STR_CFG_VALUE_ARR_DELIM_REGEX   = '<|>';

  { FixInsight options consts }

  // <none>

  { Config data consts }

  // <none>

  { Default config values. Do not localize! }

  DEF_FIO_ARR_COMPILER_DEFINES : TStringDynArray = ['DEBUG', 'RELEASE'];
  DEF_FIO_BOOL_SILENT = False;
  DEF_FIO_ENUM_OUTPUT_FORMAT = TFixInsightOutputFormat(fiofXML);
  DEF_FIO_STR_OUTPUT_FILENAME = 'FixInsightReport.xml';
  DEF_FIO_STR_SETTINGS_FILENAME = String.Empty;

  DEF_CD_ARR_EXCLUDE_PROJECT_PATTERNS : TStringDynArray = ['Project[0-9]+\.dpr', '\\JCL\\', '\\JVCL\\'];
  DEF_CD_ARR_EXCLUDE_UNIT_PATTERNS : TStringDynArray = ['Unit[0-9]+\.pas', '\\JWA\\', '\\RegExpr.pas'];
  DEF_CD_BOOL_MAKE_ARCHIVE = False;
  DEF_CD_BOOL_USE_BAD_EXIT_CODE = False;
  DEF_CD_STR_OUTPUT_FILENAME = 'FIToolkitReport.html';

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

resourcestring

  { Exceptions }

  RSFIOEmptyOutputFileName = 'Пустое имя выходного файла.';
  RSFIOInvalidOutputFileName = 'Имя выходного файла содержит недопустимые символы.';
  RSFIOOutputDirectoryNotFound = 'Директории выходного файла не существует.';
  RSFIOProjectFileNotFound = 'Файл проекта не найден.';
  RSFIOSettingsFileNotFound = 'Файл настроек FixInsight не найден.';

  RSCDCustomTemplateFileNotFound = 'Файл пользовательского шаблона не найден.';
  RSCDFixInsightExeNotFound = 'Исполняемый файл FixInsight не найден.';
  RSCDInputFileNotFound = 'Входной файл не найден.';
  RSCDInvalidExcludeProjectPattern = 'Ошибка в регулярном выражении для исключения проектов: %s';
  RSCDInvalidExcludeUnitPattern = 'Ошибка в регулярном выражении для исключения модулей: %s';
  RSCDInvalidOutputFileName = 'Неверное имя выходного файла.';
  RSCDOutputDirectoryNotFound = 'Выходная директория не найдена.';
  RSCDTempDirectoryNotFound = 'Директория для временных файлов не найдена.';

implementation

end.
