unit FIToolkit.CommandLine.Exceptions;

interface

uses
  FIToolkit.Base.Exceptions;

type

  ECommandLineException = class abstract (ECustomException);

  { Command-line option exceptions }

  ECLIOptionException = class abstract (ECommandLineException);

  ECLIOptionParseError = class abstract (ECLIOptionException);

  ECLIOptionIsEmpty = class (ECLIOptionParseError);
  ECLIOptionHasNoName = class (ECLIOptionParseError);

implementation

uses
  FIToolkit.CommandLine.Consts;

initialization
  RegisterExceptionMessage(ECLIOptionIsEmpty, SCLIOptionIsEmpty);
  RegisterExceptionMessage(ECLIOptionHasNoName, SCLIOptionHasNoName);

end.
