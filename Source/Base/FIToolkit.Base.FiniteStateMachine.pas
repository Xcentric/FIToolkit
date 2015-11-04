﻿unit FIToolkit.Base.FiniteStateMachine;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type

  TOnEnterStateMethod<TState, TCommand> =
    procedure (const PreviousState, CurrentState : TState; const UsedCommand : TCommand) of object;

  TOnEnterStateProc<TState, TCommand> =
    reference to procedure (const PreviousState, CurrentState : TState; const UsedCommand : TCommand);

  TOnExitStateMethod<TState, TCommand> =
    procedure (const CurrentState, NewState : TState; const UsedCommand : TCommand) of object;

  TOnExitStateProc<TState, TCommand> =
    reference to procedure (const CurrentState, NewState : TState; const UsedCommand : TCommand);

  IFiniteStateMachine<TState, TCommand; ErrorClass:Exception, constructor> = interface
    function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
      const OnEnter : TOnEnterStateMethod<TState, TCommand>; const OnExit : TOnExitStateMethod<TState, TCommand> = nil
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
      const OnEnter : TOnEnterStateProc<TState, TCommand>; const OnExit : TOnExitStateProc<TState, TCommand> = nil
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function Execute(const Command : TCommand) : IFiniteStateMachine<TState, TCommand, ErrorClass>;
    function GetCurrentState : TState;
    function GetPreviousState : TState;
    function GetReachableState(const FromState : TState; const OnCommand : TCommand) : TState; overload;
    function GetReachableState(const OnCommand : TCommand) : TState; overload;
    function HasTransition(const FromState : TState; const OnCommand : TCommand) : Boolean;
    function RemoveTransition(const FromState : TState; const OnCommand : TCommand
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>;

    property CurrentState : TState read GetCurrentState;
    property PreviousState : TState read GetPreviousState;
  end;

  TFiniteStateMachine<TState, TCommand; ErrorClass:Exception, constructor> = class abstract
    (TInterfacedObject, IFiniteStateMachine<TState, TCommand, ErrorClass>)
    private
      type
        ICommandComparer = IEqualityComparer<TCommand>;
        IFiniteStateMachine = IFiniteStateMachine<TState, TCommand, ErrorClass>;
        IStateComparer = IEqualityComparer<TState>;

        TOnEnterStateMethod = TOnEnterStateMethod<TState, TCommand>;
        TOnEnterStateProc = TOnEnterStateProc<TState, TCommand>;
        TOnExitStateMethod = TOnExitStateMethod<TState, TCommand>;
        TOnExitStateProc = TOnExitStateProc<TState, TCommand>;

        TTransition = class sealed
          strict private
            FFromState : TState;
            FOnCommand : TCommand;

            FCommandComparer : ICommandComparer;
            FStateComparer : IStateComparer;

            FOnEnterMethod : TOnEnterStateMethod;
            FOnEnterProc : TOnEnterStateProc;
            FOnExitMethod : TOnExitStateMethod;
            FOnExitProc : TOnExitStateProc;
          private
            function GetCombinedHashCode(const HashCodes : array of Integer) : Integer;
          public
            constructor Create(const AFromState : TState; const AOnCommand : TCommand;
              const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
              const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod); overload;
            constructor Create(const AFromState : TState; const AOnCommand : TCommand;
              const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
              const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc); overload;

            function  Equals(Obj : TObject) : Boolean; override; final;
            function  GetHashCode : Integer; override; final;
            procedure PerformEnterStateAction(const CurrentState : TState);
            procedure PerformExitStateAction(const NewState : TState);

            property FromState : TState read FFromState;
            property OnCommand : TCommand read FOnCommand;
        end;

        TTransitionTable = class (TDictionary<TTransition, TState>);
    strict private
      FCurrentState,
      FPreviousState : TState;
      FTransitionTable : TTransitionTable;
    private
      function GetCurrentState : TState;
      function GetPreviousState : TState;
    protected
      procedure AfterExecute(const Command : TCommand); virtual;
      procedure BeforeExecute(const Command : TCommand); virtual;
    public
      constructor Create; overload; virtual; abstract;
      constructor Create(const InitialState : TState); overload; virtual;
      constructor Create(const InitialState : TState; const StateComparer : IStateComparer;
        const CommandComparer : ICommandComparer); overload; virtual;
      destructor Destroy; override;

      function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand
        ) : IFiniteStateMachine; overload;
      function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod = nil
        ) : IFiniteStateMachine; overload;
      function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc = nil
        ) : IFiniteStateMachine; overload;
      function Execute(const Command : TCommand) : IFiniteStateMachine;
      function GetReachableState(const FromState : TState; const OnCommand : TCommand) : TState; overload;
      function GetReachableState(const OnCommand : TCommand) : TState; overload;
      function HasTransition(const FromState : TState; const OnCommand : TCommand) : Boolean;
      function RemoveTransition(const FromState : TState; const OnCommand : TCommand) : IFiniteStateMachine;

      property CurrentState : TState read GetCurrentState;
      property PreviousState : TState read GetPreviousState;
  end;

implementation

{ TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition }

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Create(const AFromState : TState;
  const AOnCommand : TCommand; const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
  const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod);
begin

end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Create(const AFromState : TState;
  const AOnCommand : TCommand; const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
  const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc);
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Equals(Obj : TObject) : Boolean;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.GetCombinedHashCode(
  const HashCodes : array of Integer) : Integer;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.GetHashCode : Integer;
begin

end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.PerformEnterStateAction(
  const CurrentState : TState);
begin

end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.PerformExitStateAction(const NewState : TState);
begin

end;

{ TFiniteStateMachine<TState, TCommand, ErrorClass> }

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand; const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod) : IFiniteStateMachine;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand; const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc) : IFiniteStateMachine;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand) : IFiniteStateMachine;
begin

end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.AfterExecute(const Command : TCommand);
begin

end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.BeforeExecute(const Command : TCommand);
begin

end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Create(const InitialState : TState);
begin

end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Create(const InitialState : TState;
  const StateComparer : IStateComparer; const CommandComparer : ICommandComparer);
begin

end;

destructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Destroy;
begin

  inherited Destroy;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.Execute(const Command : TCommand) : IFiniteStateMachine;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetCurrentState : TState;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetPreviousState : TState;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const FromState : TState;
  const OnCommand : TCommand) : TState;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const OnCommand : TCommand) : TState;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.HasTransition(const FromState : TState;
  const OnCommand : TCommand) : Boolean;
begin

end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.RemoveTransition(const FromState : TState;
  const OnCommand : TCommand) : IFiniteStateMachine;
begin

end;

end.
