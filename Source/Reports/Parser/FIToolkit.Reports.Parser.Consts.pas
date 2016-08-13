unit FIToolkit.Reports.Parser.Consts;

interface

uses
  System.SysUtils,
  FIToolkit.Reports.Parser.Types;

const

  { FixInsight message types. Do not localize! }

  REGEX_FIMSG_CODING_CONVENTION = '^C[0-9]+$';
  REGEX_FIMSG_OPTIMIZATION      = '^O[0-9]+$';
  REGEX_FIMSG_TRIAL             = '^Tria$';
  REGEX_FIMSG_WARNING           = '^W[0-9]+$';

  { Common consts }

  ARR_MSGTYPE_TO_MSGID_REGEX_MAPPING : array [Low(TFixInsightMessageType)..High(TFixInsightMessageType)] of String =
    (String.Empty, REGEX_FIMSG_WARNING, REGEX_FIMSG_OPTIMIZATION, REGEX_FIMSG_CODING_CONVENTION, REGEX_FIMSG_TRIAL);

  { XML consts for a FixInsight report format. Do not localize! }

  // <FixInsightReport>\<file>\<message>
  STR_FIXML_ROOT_NODE    = 'FixInsightReport';
  STR_FIXML_FILE_NODE    = 'file';
  STR_FIXML_MESSAGE_NODE = 'message';

  STR_FIXML_COL_ATTRIBUTE  = 'col';
  STR_FIXML_ID_ATTRIBUTE   = 'id';
  STR_FIXML_LINE_ATTRIBUTE = 'line';
  STR_FIXML_NAME_ATTRIBUTE = 'name';

resourcestring

  { Exceptions }

  RSFixInsightXMLParseError = 'Ошибка при разборе файла отчёта FixInsight.';

implementation

end.
