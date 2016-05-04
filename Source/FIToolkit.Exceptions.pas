unit FIToolkit.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EApplicationException = class abstract (ECustomException);

  { Config exceptions }

  EConfigException = class abstract (EApplicationException);

  ENoValidConfigSpecified = class (EConfigException);

implementation

uses
  FIToolkit.Consts;

initialization
  RegisterExceptionMessage(ENoValidConfigSpecified, RSNoValidConfigSpecified);

end.
