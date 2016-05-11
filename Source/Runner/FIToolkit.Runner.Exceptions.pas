unit FIToolkit.Runner.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  ECommonTaskException = class abstract (ECustomException);

  { Task runner exceptions }

  ETaskRunnerException = class abstract (ECommonTaskException);

  ECreateProcessError = class (ETaskRunnerException);

implementation

uses
  FIToolkit.Runner.Consts;

initialization
  RegisterExceptionMessage(ECreateProcessError, RSCreateProcessError);

end.
