unit FIToolkit.Reports.Builder.Consts;

interface

const

  { XML consts for an HTML report template format. Do not localize! }

  // <HTMLReportTemplate>\<%REPORT_ELEMENT%>\<%REPORT_ELEMENT'S_CHILD_ELEMENT%>\...\<Element>
  STR_RPTXML_ROOT_NODE                 = 'HTMLReportTemplate';
  STR_RPTXML_CSS_NODE                  = 'CSS';
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

  { Resources }

  STR_RES_HTML_REPORT_DEFAULT_TEMPLATE = 'HTMLReportDefaultTemplate';

resourcestring

  { Exceptions }

  RSInvalidReportTemplate = 'Неверный шаблон отчёта.';
  RSReportTemplateLoadError = 'Ошибка загрузки шаблона отчёта.';
  RSReportTemplateParseError = 'Ошибка разбора шаблона отчёта.';

implementation

end.
