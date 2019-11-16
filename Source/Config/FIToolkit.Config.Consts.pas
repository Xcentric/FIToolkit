unit FIToolkit.Config.Consts;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Config.Types,
  FIToolkit.Localization;

const

  { Common consts }

  STR_CFG_VALUE_ARR_DELIM_DEFAULT = ',';
  STR_CFG_VALUE_ARR_DELIM_REGEX   = '<|>';

  { FixInsight options consts }

  // <none>

  { Config data consts }

  CD_INT_SNIPPET_SIZE_MIN = 1;
  CD_INT_SNIPPET_SIZE_MAX = 101;

  { Default config values. Do not localize! }

  DEF_FIO_ARR_COMPILER_DEFINES : TStringDynArray = ['RELEASE', 'MSWINDOWS'];
  DEF_FIO_BOOL_SILENT = False;
  DEF_FIO_ENUM_OUTPUT_FORMAT = TFixInsightOutputFormat(fiofXML);
  DEF_FIO_STR_OUTPUT_FILENAME = 'FixInsightReport.xml';
  DEF_FIO_STR_SETTINGS_FILENAME = String.Empty;

  DEF_CD_ARR_EXCLUDE_PROJECT_PATTERNS : TStringDynArray = ['Project[0-9]+\.dpr', '\\JCL\\', '\\JVCL\\'];
  DEF_CD_ARR_EXCLUDE_UNIT_PATTERNS : TStringDynArray = ['Unit[0-9]+\.pas', '\\JWA\\', '\\RegExpr.pas'];
  DEF_CD_BOOL_DEDUPLICATE = False;
  DEF_CD_BOOL_MAKE_ARCHIVE = False;
  DEF_CD_INT_NONZERO_EXIT_CODE_MSG_COUNT = 0;
  DEF_CD_INT_SNIPPET_SIZE = 21;
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

  {$IF LANGUAGE = LANG_EN_US}
    {$INCLUDE 'Locales\en-US.inc'}
  {$ELSEIF LANGUAGE = LANG_RU_RU}
    {$INCLUDE 'Locales\ru-RU.inc'}
  {$ELSE}
    {$MESSAGE FATAL 'No language defined!'}
  {$ENDIF}

implementation

end.
