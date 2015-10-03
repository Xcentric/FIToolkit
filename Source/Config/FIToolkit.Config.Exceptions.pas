unit FIToolkit.Config.Exceptions;

interface

uses
  FIToolkit.Base.Exceptions;

type

  EConfigException = class abstract (ECustomException);

  { FixInsight options exceptions }

  EFixInsightOptionsException = class abstract (EConfigException);

  EFIOEmptyOutputFileName = class (EFixInsightOptionsException);
  EFIOInvalidOutputFileName = class (EFixInsightOptionsException);
  EFIOOutputDirectoryNotFound = class (EFixInsightOptionsException);
  EFIOProjectFileNotFound = class (EFixInsightOptionsException);
  EFIOSettingsFileNotFound = class (EFixInsightOptionsException);

  { Config data exceptions }

  EConfigDataException = class abstract (EConfigException);

  ECDFixInsightExeNotFound = class (EConfigDataException);
  ECDInputFileNotFound = class (EConfigDataException);
  ECDInvalidOutputFileName = class (EConfigDataException);
  ECDOutputDirectoryNotFound = class (EConfigDataException);
  ECDTempDirectoryNotFound = class (EConfigDataException);

implementation

uses
  FIToolkit.Config.Consts;

initialization
  RegisterExceptionMessage(EFIOEmptyOutputFileName, SFIOEmptyOutputFileName);
  RegisterExceptionMessage(EFIOInvalidOutputFileName, SFIOInvalidOutputFileName);
  RegisterExceptionMessage(EFIOOutputDirectoryNotFound, SFIOOutputDirectoryNotFound);
  RegisterExceptionMessage(EFIOProjectFileNotFound, SFIOProjectFileNotFound);
  RegisterExceptionMessage(EFIOSettingsFileNotFound, SFIOSettingsFileNotFound);

  RegisterExceptionMessage(ECDFixInsightExeNotFound, SCDFixInsightExeNotFound);
  RegisterExceptionMessage(ECDInputFileNotFound, SCDInputFileNotFound);
  RegisterExceptionMessage(ECDInvalidOutputFileName, SCDInvalidOutputFileName);
  RegisterExceptionMessage(ECDOutputDirectoryNotFound, SCDOutputDirectoryNotFound);
  RegisterExceptionMessage(ECDTempDirectoryNotFound, SCDTempDirectoryNotFound);

end.
