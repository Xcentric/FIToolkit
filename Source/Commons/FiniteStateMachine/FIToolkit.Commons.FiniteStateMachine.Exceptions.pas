unit FIToolkit.Commons.FiniteStateMachine.Exceptions;

interface

uses
  System.SysUtils;

type

  EFiniteStateMachineError = class abstract (Exception);

  EExecutionInProgress = class (EFiniteStateMachineError);

  ETransitionNotFound = class (EFiniteStateMachineError);

implementation

end.
