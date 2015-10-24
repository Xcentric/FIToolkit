unit FIToolkit.Exceptions;

interface

uses
  FIToolkit.Base.Exceptions;

type

  EApplicationException = class abstract (ECustomException);

  { Config exceptions }

  EConfigException = class abstract (EApplicationException);

  ENoConfigSpecified = class (EConfigException);

implementation

uses
  FIToolkit.Consts;

initialization
  RegisterExceptionMessage(ENoConfigSpecified, SNoConfigSpecified);

end.
