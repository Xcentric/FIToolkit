unit FIToolkit.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  EApplicationException = class abstract (ECustomException);

  ENoValidConfigSpecified = class (EApplicationException);

implementation

uses
  FIToolkit.Consts;

initialization
  RegisterExceptionMessage(ENoValidConfigSpecified, RSNoValidConfigSpecified);

end.
