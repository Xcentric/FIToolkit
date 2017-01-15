unit FIToolkit.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EApplicationException = class abstract (ECustomException);

  EApplicationExecutionFailed = class (EApplicationException);
  ECLIOptionsProcessingFailed = class (EApplicationException);
  EErroneousConfigSpecified = class (EApplicationException);
  ENoValidConfigSpecified = class (EApplicationException);
  EUnableToGenerateConfig = class (EApplicationException);
  EUnknownInputFileType = class (EApplicationException);

implementation

uses
  FIToolkit.Consts;

initialization
  RegisterExceptionMessage(EApplicationExecutionFailed, RSApplicationExecutionFailed);
  RegisterExceptionMessage(ECLIOptionsProcessingFailed, RSCLIOptionsProcessingFailed);
  RegisterExceptionMessage(EErroneousConfigSpecified, RSErroneousConfigSpecified);
  RegisterExceptionMessage(ENoValidConfigSpecified, RSNoValidConfigSpecified);
  RegisterExceptionMessage(EUnableToGenerateConfig, RSUnableToGenerateConfig);
  RegisterExceptionMessage(EUnknownInputFileType, RSUnknownInputFileType);

end.
