﻿unit FIToolkit.Reports.Builder.Consts;

interface

uses
  System.SysUtils,
  FIToolkit.Reports.Parser.Types,
  FIToolkit.Localization;

const

  { Common consts }

  ARR_MSGTYPE_TO_MSGKEYWORD_MAPPING : array [TFixInsightMessageType] of String =
    (String.Empty, 'Warning', 'Optimization', 'CodingConvention', 'Fatal', 'Trial'); // Do not localize!

  { XML consts for an HTML report template format. Do not localize! }

  // <HTMLReportTemplate>\<%REPORT_ELEMENT%>\<%REPORT_ELEMENT'S_CHILD_ELEMENT%>\...\<Element>
  STR_RPTXML_ROOT_NODE                 = 'HTMLReportTemplate';
  STR_RPTXML_CSS_NODE                  = 'CSS';
  STR_RPTXML_JAVASCRIPT_NODE           = 'JavaScript';
  STR_RPTXML_HEADER_NODE               = 'Header';
  STR_RPTXML_TOTAL_SUMMARY_NODE        = 'TotalSummary';
  STR_RPTXML_TOTAL_SUMMARY_ITEM_NODE   = 'TotalSummaryItem';
  STR_RPTXML_PROJECT_SECTION_NODE      = 'ProjectSection';
  STR_RPTXML_PROJECT_SUMMARY_NODE      = 'ProjectSummary';
  STR_RPTXML_PROJECT_SUMMARY_ITEM_NODE = 'ProjectSummaryItem';
  STR_RPTXML_PROJECT_MESSAGES_NODE     = 'ProjectMessages';
  STR_RPTXML_MESSAGE_NODE              = 'Message';
  STR_RPTXML_FOOTER_NODE               = 'Footer';
  STR_RPTXML_ELEMENT_NODE              = 'Element';

  { HTML report builder consts. Do not localize! }

  // IDs & classes:
  STR_HTML_REPORT_ROOT_ID = 'root';

  // Macros:
  STR_HTML_COLUMN                       = '%COLUMN%';
  STR_HTML_FILE_NAME                    = '%FILE_NAME%';
  STR_HTML_FINISH_TIME                  = '%FINISH_TIME%';
  STR_HTML_LINE                         = '%LINE%';
  STR_HTML_MESSAGE_TEXT                 = '%MESSAGE_TEXT%';
  STR_HTML_MESSAGE_TYPE_KEYWORD         = '%MESSAGE_TYPE_KEYWORD%';
  STR_HTML_MESSAGE_TYPE_NAME            = '%MESSAGE_TYPE_NAME%';
  STR_HTML_PROJECT_SUMMARY              = '{PROJECT_SUMMARY}';
  STR_HTML_PROJECT_SUMMARY_ITEMS        = '{PROJECT_SUMMARY_ITEMS}';
  STR_HTML_PROJECT_TITLE                = '%PROJECT_TITLE%';
  STR_HTML_REPORT_TITLE                 = '%REPORT_TITLE%';
  STR_HTML_SNIPPET                      = '%SNIPPET%';
  STR_HTML_START_TIME                   = '%START_TIME%';
  STR_HTML_SUMMARY_MESSAGE_COUNT        = '%SUMMARY_MESSAGE_COUNT%';
  STR_HTML_SUMMARY_MESSAGE_TYPE_KEYWORD = '%SUMMARY_MESSAGE_TYPE_KEYWORD%';
  STR_HTML_SUMMARY_MESSAGE_TYPE_NAME    = '%SUMMARY_MESSAGE_TYPE_NAME%';
  STR_HTML_TOTAL_SUMMARY_ITEMS          = '{TOTAL_SUMMARY_ITEMS}';

  // Code snippet output:
  FMT_CSO_LINE_NUMBER = '{%s}'; // Do not localize!
  STR_CSO_TARGET_LINE_NUMBER_PREFIX = '→ ';

  { Resources. Do not localize! }

  STR_RES_HTML_REPORT_DEFAULT_TEMPLATE = 'HTMLReportDefaultTemplate';

resourcestring

  {$IF LANGUAGE = LANG_EN_US}
    {$INCLUDE 'Locales\en-US.inc'}
  {$ELSEIF LANGUAGE = LANG_RU_RU}
    {$INCLUDE 'Locales\ru-RU.inc'}
  {$ELSE}
    {$MESSAGE FATAL 'No language defined!'}
  {$ENDIF}

const

  ARR_MSGTYPE_TO_MSGNAME_MAPPING : array [TFixInsightMessageType] of String =
    (String.Empty, RSWarning, RSOptimization, RSCodingConvention, RSFatal, RSTrial);

implementation

end.
