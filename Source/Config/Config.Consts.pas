unit Config.Consts;

interface

const

  { FixInsight command line parameters. Do not localize! }

  STR_FIPARAM_PREFIX = '--';
  STR_FIPARAM_VALUE_DELIM = '=';
  STR_FIPARAM_VALUES_DELIM = ';';

  STR_FIPARAM_DEFINES  = STR_FIPARAM_PREFIX + 'defines'  + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_OUTPUT   = STR_FIPARAM_PREFIX + 'output'   + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_PROJECT  = STR_FIPARAM_PREFIX + 'project'  + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_SETTINGS = STR_FIPARAM_PREFIX + 'settings' + STR_FIPARAM_VALUE_DELIM;
  STR_FIPARAM_XML      = STR_FIPARAM_PREFIX + 'xml';

resourcestring

  { Exceptions }

  SFIOEmptyOutputFileName = 'Пустое имя выходного файла';
  SFIOInvalidOutputFileName = 'Имя выходного файла содержит недопустимые символы';
  SFIOOutputDirectoryNotFound = 'Директории выходного файла не существует';
  SFIOProjectFileNotFound = 'Файл проекта не найден';
  SFIOSettingsFileNotFound = 'Файл настроек FixInsight не найден';

implementation

end.
