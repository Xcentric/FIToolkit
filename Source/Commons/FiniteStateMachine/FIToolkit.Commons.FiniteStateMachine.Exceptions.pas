unit FIToolkit.Commons.FiniteStateMachine.Exceptions;

interface

uses
  System.SysUtils;

type

  EFiniteStateMachineError = class abstract (Exception);

  ETransitionNotFound = class (EFiniteStateMachineError);

implementation

end.
