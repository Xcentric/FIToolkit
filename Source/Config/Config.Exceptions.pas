unit Config.Exceptions;

interface

uses
  Base.Exceptions;

type

  EConfigException = class abstract (ECustomException);

  EEmptyOutputFileName = class (EConfigException);

  ENonExistentOutputDirectory = class (EConfigException);

implementation

uses
  Config.Consts;

initialization
  RegisterExceptionMessage(EEmptyOutputFileName, SEmptyOutputFileName);
  RegisterExceptionMessage(ENonExistentOutputDirectory, SNonExistentOutputDirectory);

end.
