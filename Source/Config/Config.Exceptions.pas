unit Config.Exceptions;

interface

uses
  Base.Exceptions;

type

  EConfigException = class abstract (ECustomException);

  { FixInsight Options Exceptions }

  EFixInsightOptionsException = class abstract (EConfigException);

  EFIOEmptyOutputFileName = class (EFixInsightOptionsException);
  EFIOOutputDirectoryNotFound = class (EFixInsightOptionsException);
  EFIOProjectFileNotFound = class (EFixInsightOptionsException);
  EFIOSettingsFileNotFound = class (EFixInsightOptionsException);

implementation

uses
  Config.Consts;

initialization
  RegisterExceptionMessage(EFIOEmptyOutputFileName, SFIOEmptyOutputFileName);
  RegisterExceptionMessage(EFIOOutputDirectoryNotFound, SFIOOutputDirectoryNotFound);
  RegisterExceptionMessage(EFIOProjectFileNotFound, SFIOProjectFileNotFound);
  RegisterExceptionMessage(EFIOSettingsFileNotFound, SFIOSettingsFileNotFound);

end.
