unit FIToolkit.Runner.Exceptions;

interface

uses
  FIToolkit.Commons.Exceptions;

type

  ECommonTaskException = class abstract (ECustomException);

  { Task manager exceptions }

  ETaskManagerException = class abstract (ECustomException);

  ESomeTasksFailed = class (ETaskManagerException);

  { Task runner exceptions }

  ETaskRunnerException = class abstract (ECommonTaskException);

  ECreateProcessError = class (ETaskRunnerException);

implementation

uses
  FIToolkit.Runner.Consts;

initialization
  RegisterExceptionMessage(ESomeTasksFailed, RSSomeTasksFailed);
  RegisterExceptionMessage(ECreateProcessError, RSCreateProcessError);

end.
