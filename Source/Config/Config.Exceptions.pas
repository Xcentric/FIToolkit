unit Config.Exceptions;

interface

uses
  Exceptions;

type

  EConfigException = class abstract (ECustomException);

  EEmptyOutputFileName = class (EConfigException);

  ENonExistentOutputDirectory = class (EConfigException);

implementation

uses
  Config.Consts;

initialization
  GlobalExceptionsMap.Add(EEmptyOutputFileName, SEmptyOutputFileName);
  GlobalExceptionsMap.Add(ENonExistentOutputDirectory, SNonExistentOutputDirectory);

end.
