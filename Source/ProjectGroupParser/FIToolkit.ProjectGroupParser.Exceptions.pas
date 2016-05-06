unit FIToolkit.ProjectGroupParser.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EProjectsParserException = class abstract (ECustomException);

  EProjectGroupParseError = class (EProjectsParserException);

  EProjectParseError = class (EProjectsParserException);

implementation

uses
  FIToolkit.ProjectGroupParser.Consts;

initialization
  RegisterExceptionMessage(EProjectGroupParseError, RSProjectGroupParseError);
  RegisterExceptionMessage(EProjectParseError, RSProjectParseError);

end.
