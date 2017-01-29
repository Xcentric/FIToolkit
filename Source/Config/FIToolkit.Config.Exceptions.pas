unit FIToolkit.Config.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

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

  ECDCustomTemplateFileNotFound = class (EConfigDataException);
  ECDFixInsightExeNotFound = class (EConfigDataException);
  ECDInputFileNotFound = class (EConfigDataException);
  ECDInvalidExcludeProjectPattern = class (EConfigDataException);
  ECDInvalidOutputFileName = class (EConfigDataException);
  ECDOutputDirectoryNotFound = class (EConfigDataException);
  ECDSnippetSizeOutOfRange = class (EConfigDataException);
  ECDTempDirectoryNotFound = class (EConfigDataException);

implementation

uses
  FIToolkit.Config.Consts;

initialization
  RegisterExceptionMessage(EFIOEmptyOutputFileName, RSFIOEmptyOutputFileName);
  RegisterExceptionMessage(EFIOInvalidOutputFileName, RSFIOInvalidOutputFileName);
  RegisterExceptionMessage(EFIOOutputDirectoryNotFound, RSFIOOutputDirectoryNotFound);
  RegisterExceptionMessage(EFIOProjectFileNotFound, RSFIOProjectFileNotFound);
  RegisterExceptionMessage(EFIOSettingsFileNotFound, RSFIOSettingsFileNotFound);

  RegisterExceptionMessage(ECDCustomTemplateFileNotFound, RSCDCustomTemplateFileNotFound);
  RegisterExceptionMessage(ECDFixInsightExeNotFound, RSCDFixInsightExeNotFound);
  RegisterExceptionMessage(ECDInputFileNotFound, RSCDInputFileNotFound);
  RegisterExceptionMessage(ECDInvalidExcludeProjectPattern, RSCDInvalidExcludeProjectPattern);
  RegisterExceptionMessage(ECDInvalidOutputFileName, RSCDInvalidOutputFileName);
  RegisterExceptionMessage(ECDOutputDirectoryNotFound, RSCDOutputDirectoryNotFound);
  RegisterExceptionMessage(ECDSnippetSizeOutOfRange, RSCDSnippetSizeOutOfRange);
  RegisterExceptionMessage(ECDTempDirectoryNotFound, RSCDTempDirectoryNotFound);

end.
