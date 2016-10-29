unit FIToolkit.Reports.Builder.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EReportsBuilderCommonException = class abstract (ECustomException);

  { Report builder exceptions }

  EReportBuilderException = class abstract (EReportsBuilderCommonException);

  { Report template exceptions }

  EReportTemplateException = class abstract (EReportsBuilderCommonException);

  EReportTemplateLoadError = class (EReportTemplateException);
  EReportTemplateParseError = class (EReportTemplateException);

implementation

uses
  FIToolkit.Reports.Builder.Consts;

initialization
  RegisterExceptionMessage(EReportTemplateLoadError, RSReportTemplateLoadError);
  RegisterExceptionMessage(EReportTemplateParseError, RSReportTemplateParseError);

end.
