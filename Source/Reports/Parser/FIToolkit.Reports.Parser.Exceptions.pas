unit FIToolkit.Reports.Parser.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EReportsParserException = class abstract (ECustomException);

  { FixInsight XML output parser exceptions }

  EFixInsightXMLParseError = class (EReportsParserException);

implementation

uses
  FIToolkit.Reports.Parser.Consts;

initialization
  RegisterExceptionMessage(EFixInsightXMLParseError, RSFixInsightXMLParseError);

end.
