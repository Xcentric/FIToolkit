unit FIToolkit.Commons.StateMachine;

interface

uses
  FIToolkit.Commons.Exceptions, FIToolkit.Commons.FiniteStateMachine.FSM;

type

  EStateMachineError = class (ECustomException);

  //TODO: implement {F2084 Internal Error: URW1175}
//  IStateMachine<TState, TCommand> = interface (IFiniteStateMachine<TState, TCommand, EStateMachineError>)
//  end;
//
//  TStateMachine<TState, TCommand> = class (TFiniteStateMachine<TState, TCommand, EStateMachineError>,
//    IStateMachine<TState, TCommand>);

implementation

uses
  FIToolkit.Commons.Consts;

initialization
  RegisterExceptionMessage(EStateMachineError, RSStateMachineError);

end.
