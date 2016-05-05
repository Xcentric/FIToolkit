unit FIToolkit.ProjectGroupParser.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EProjectGroupParserException = class abstract (ECustomException);

  EProjectGroupParseError = class (EProjectGroupParserException);

implementation

uses
  FIToolkit.ProjectGroupParser.Consts;

initialization
  RegisterExceptionMessage(EProjectGroupParseError, RSProjectGroupParseError);

end.
