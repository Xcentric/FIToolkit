unit FIToolkit.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EApplicationException = class abstract (ECustomException);

  EApplicationExecutionFailed = class (EApplicationException);
  ECLIOptionsProcessingFailed = class (EApplicationException);
  ENoValidConfigSpecified = class (EApplicationException);
  EUnknownInputFileType = class (EApplicationException);

implementation

uses
  FIToolkit.Consts;

initialization
  RegisterExceptionMessage(EApplicationExecutionFailed, RSApplicationExecutionFailed);
  RegisterExceptionMessage(ECLIOptionsProcessingFailed, RSCLIOptionsProcessingFailed);
  RegisterExceptionMessage(ENoValidConfigSpecified, RSNoValidConfigSpecified);
  RegisterExceptionMessage(EUnknownInputFileType, RSUnknownInputFileType);

end.
