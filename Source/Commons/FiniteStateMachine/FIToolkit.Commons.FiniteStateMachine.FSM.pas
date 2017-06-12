unit FIToolkit.Commons.FiniteStateMachine.FSM;

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

  IFiniteStateMachine<TState, TCommand; ErrorClass : Exception, constructor> = interface
    function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
      const OnEnter : TOnEnterStateMethod<TState, TCommand>; const OnExit : TOnExitStateMethod<TState, TCommand> = nil
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
      const OnEnter : TOnEnterStateProc<TState, TCommand>; const OnExit : TOnExitStateProc<TState, TCommand> = nil
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand;
      const OnEnter : TOnEnterStateMethod<TState, TCommand>; const OnExit : TOnExitStateMethod<TState, TCommand> = nil
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand;
      const OnEnter : TOnEnterStateProc<TState, TCommand>; const OnExit : TOnExitStateProc<TState, TCommand> = nil
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>; overload;
    function Execute(const Command : TCommand) : IFiniteStateMachine<TState, TCommand, ErrorClass>;
    function GetCurrentState : TState;
    function GetPreviousState : TState;
    function GetReachableState(const FromState : TState; const OnCommand : TCommand) : TState; overload;
    function GetReachableState(const OnCommand : TCommand) : TState; overload;
    function HasTransition(const FromState : TState; const OnCommand : TCommand) : Boolean; overload;
    function HasTransition(const OnCommand : TCommand) : Boolean; overload;
    function RemoveAllTransitions : IFiniteStateMachine<TState, TCommand, ErrorClass>;
    function RemoveTransition(const FromState : TState; const OnCommand : TCommand
      ) : IFiniteStateMachine<TState, TCommand, ErrorClass>;

    property CurrentState : TState read GetCurrentState;
    property PreviousState : TState read GetPreviousState;
  end;

  TFiniteStateMachine<TState, TCommand; ErrorClass : Exception, constructor> = class abstract
    (TInterfacedObject, IFiniteStateMachine<TState, TCommand, ErrorClass>)
    private
      type
        ICommandComparer    = IEqualityComparer<TCommand>;
        IFiniteStateMachine = IFiniteStateMachine<TState, TCommand, ErrorClass>;
        IStateComparer      = IEqualityComparer<TState>;

        TOnEnterStateMethod = TOnEnterStateMethod<TState, TCommand>;
        TOnEnterStateProc   = TOnEnterStateProc<TState, TCommand>;
        TOnExitStateMethod  = TOnExitStateMethod<TState, TCommand>;
        TOnExitStateProc    = TOnExitStateProc<TState, TCommand>;

        TTransition = class sealed
          strict private
            FFromState : TState;
            FOnCommand : TCommand;

            FCommandComparer : ICommandComparer;
            FStateComparer : IStateComparer;

            FOnEnterStateMethod : TOnEnterStateMethod;
            FOnEnterStateProc : TOnEnterStateProc;
            FOnExitStateMethod : TOnExitStateMethod;
            FOnExitStateProc : TOnExitStateProc;
          private
            function GetCombinedHashCode(const HashCodes : array of Integer) : Integer;
          public
            constructor Create(const AFromState : TState; const AOnCommand : TCommand;
              const StateComparer : IStateComparer; const CommandComparer : ICommandComparer); overload;
            constructor Create(const AFromState : TState; const AOnCommand : TCommand;
              const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
              const OnEnterState : TOnEnterStateMethod; const OnExitState : TOnExitStateMethod); overload;
            constructor Create(const AFromState : TState; const AOnCommand : TCommand;
              const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
              const OnEnterState : TOnEnterStateProc; const OnExitState : TOnExitStateProc); overload;

            function  Equals(Obj : TObject) : Boolean; override; final;
            function  GetHashCode : Integer; override; final;

            procedure PerformEnterStateAction(const CurrentState : TState);
            procedure PerformExitStateAction(const NewState : TState);

            property FromState : TState read FFromState;
            property OnCommand : TCommand read FOnCommand;
        end;

        TTransitionTable = class (TObjectDictionary<TTransition, TState>);
    strict private
      FCommandComparer : ICommandComparer;
      FCurrentState : TState;
      FExecuting : Boolean;
      FPreviousState : TState;
      FStateComparer : IStateComparer;
      FTransitionTable : TTransitionTable;
    private
      function AddTransition(var Transition : TTransition; const ToState : TState) : IFiniteStateMachine; overload;
      function FindTransition(const FromState : TState; const OnCommand : TCommand) : TTransition;
      function GetReachableState(const FromState : TState; const OnCommand : TCommand;
        out Transition : TTransition) : TState; overload;
      function HasTransition(const FromState : TState; const OnCommand : TCommand;
        out Transition : TTransition) : Boolean; overload;

      function GetCurrentState : TState;
      function GetPreviousState : TState;
    strict protected
      procedure AfterExecute(const Command : TCommand); virtual;
      procedure BeforeExecute(const Command : TCommand); virtual;
      procedure RaiseOuterException(E : Exception); virtual;
    protected
      class function GetDefaultInitialState : TState; virtual;

      function CommandToStr(const Command : TCommand) : String; virtual;
      function StateToStr(const State : TState) : String; virtual;
    public
      constructor Create; overload;
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
      function AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand
        ) : IFiniteStateMachine; overload;
      function AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod = nil
        ) : IFiniteStateMachine; overload;
      function AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc = nil
        ) : IFiniteStateMachine; overload;
      function Execute(const Command : TCommand) : IFiniteStateMachine;
      function GetReachableState(const FromState : TState; const OnCommand : TCommand) : TState; overload;
      function GetReachableState(const OnCommand : TCommand) : TState; overload;
      function HasTransition(const FromState : TState; const OnCommand : TCommand) : Boolean; overload;
      function HasTransition(const OnCommand : TCommand) : Boolean; overload;
      function RemoveAllTransitions : IFiniteStateMachine;
      function RemoveTransition(const FromState : TState; const OnCommand : TCommand) : IFiniteStateMachine;

      property CurrentState : TState read GetCurrentState;
      property PreviousState : TState read GetPreviousState;
  end;

  IThreadFiniteStateMachine<TState, TCommand; ErrorClass : Exception, constructor> = interface
    (IFiniteStateMachine<TState, TCommand, ErrorClass>)
    function  Lock : IFiniteStateMachine<TState, TCommand, ErrorClass>;
    procedure Unlock;
  end;

  TThreadFiniteStateMachine<TState, TCommand; ErrorClass : Exception, constructor> = class (TInterfacedObject,
    IFiniteStateMachine<TState, TCommand, ErrorClass>, IThreadFiniteStateMachine<TState, TCommand, ErrorClass>)
    private
      type
        ICommandComparer    = IEqualityComparer<TCommand>;
        IFiniteStateMachine = IFiniteStateMachine<TState, TCommand, ErrorClass>;
        IStateComparer      = IEqualityComparer<TState>;

        TOnEnterStateMethod = TOnEnterStateMethod<TState, TCommand>;
        TOnEnterStateProc   = TOnEnterStateProc<TState, TCommand>;
        TOnExitStateMethod  = TOnExitStateMethod<TState, TCommand>;
        TOnExitStateProc    = TOnExitStateProc<TState, TCommand>;
    strict private
      FFiniteStateMachine : IFiniteStateMachine;
      FLock : TObject;
    private
      procedure InternalLock; inline;
      procedure InternalUnlock; inline;

      function  GetCurrentState : TState;
      function  GetPreviousState : TState;
    public
      constructor Create; overload;
      constructor Create(const StateMachine : IFiniteStateMachine); overload;
      destructor Destroy; override;

      function  AddTransition(const FromState, ToState : TState; const OnCommand : TCommand
        ) : IFiniteStateMachine; overload;
      function  AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod = nil
        ) : IFiniteStateMachine; overload;
      function  AddTransition(const FromState, ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc = nil
        ) : IFiniteStateMachine; overload;
      function  AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand
        ) : IFiniteStateMachine; overload;
      function  AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod = nil
        ) : IFiniteStateMachine; overload;
      function  AddTransitions(const FromStates : array of TState; const ToState : TState; const OnCommand : TCommand;
        const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc = nil
        ) : IFiniteStateMachine; overload;
      function  Execute(const Command : TCommand) : IFiniteStateMachine;
      function  GetReachableState(const FromState : TState; const OnCommand : TCommand) : TState; overload;
      function  GetReachableState(const OnCommand : TCommand) : TState; overload;
      function  HasTransition(const FromState : TState; const OnCommand : TCommand) : Boolean; overload;
      function  HasTransition(const OnCommand : TCommand) : Boolean; overload;
      function  Lock : IFiniteStateMachine;
      function  RemoveAllTransitions : IFiniteStateMachine;
      function  RemoveTransition(const FromState : TState; const OnCommand : TCommand) : IFiniteStateMachine;
      procedure Unlock;

      property CurrentState : TState read GetCurrentState;
      property PreviousState : TState read GetPreviousState;
  end;

implementation

uses
  System.Rtti,
  FIToolkit.Commons.FiniteStateMachine.Exceptions, FIToolkit.Commons.FiniteStateMachine.Consts;

{ TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition }

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Create(const AFromState : TState;
  const AOnCommand : TCommand; const StateComparer : IStateComparer; const CommandComparer : ICommandComparer);
begin
  inherited Create;

  FFromState := AFromState;
  FOnCommand := AOnCommand;

  if Assigned(StateComparer) then
    FStateComparer := StateComparer
  else
    FStateComparer := TEqualityComparer<TState>.Default;

  if Assigned(CommandComparer) then
    FCommandComparer := CommandComparer
  else
    FCommandComparer := TEqualityComparer<TCommand>.Default;
end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Create(const AFromState : TState;
  const AOnCommand : TCommand; const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
  const OnEnterState : TOnEnterStateMethod; const OnExitState : TOnExitStateMethod);
begin
  Create(AFromState, AOnCommand, StateComparer, CommandComparer);

  FOnEnterStateMethod := OnEnterState;
  FOnExitStateMethod  := OnExitState;
end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Create(const AFromState : TState;
  const AOnCommand : TCommand; const StateComparer : IStateComparer; const CommandComparer : ICommandComparer;
  const OnEnterState : TOnEnterStateProc; const OnExitState : TOnExitStateProc);
begin
  Create(AFromState, AOnCommand, StateComparer, CommandComparer);

  FOnEnterStateProc := OnEnterState;
  FOnExitStateProc  := OnExitState;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.Equals(Obj : TObject) : Boolean;
begin
  Result := False;

  if Obj is TTransition then
    Result := FStateComparer.Equals(FFromState, TTransition(Obj).FromState) and
              FCommandComparer.Equals(FOnCommand, TTransition(Obj).OnCommand);
end;

{$IFOPT Q+}
  {$DEFINE OVERFLOW_CHECKS_ENABLED}
  {$Q-}
{$ENDIF}
function TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.GetCombinedHashCode(
  const HashCodes : array of Integer) : Integer;
var
  HashCode : Integer;
begin
  Result := 17;

  for HashCode in HashCodes do
    Result := Result * 37 + HashCode;
end;
{$IFDEF OVERFLOW_CHECKS_ENABLED}
  {$Q+}
  {$UNDEF OVERFLOW_CHECKS_ENABLED}
{$ENDIF}

function TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.GetHashCode : Integer;
begin
  Result := GetCombinedHashCode([FStateComparer.GetHashCode(FFromState), FCommandComparer.GetHashCode(FOnCommand)]);
end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.PerformEnterStateAction(
  const CurrentState : TState);
begin
  if Assigned(FOnEnterStateMethod) then
    FOnEnterStateMethod(FFromState, CurrentState, FOnCommand);

  if Assigned(FOnEnterStateProc) then
    FOnEnterStateProc(FFromState, CurrentState, FOnCommand);
end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.TTransition.PerformExitStateAction(const NewState : TState);
begin
  if Assigned(FOnExitStateMethod) then
    FOnExitStateMethod(FFromState, NewState, FOnCommand);

  if Assigned(FOnExitStateProc) then
    FOnExitStateProc(FFromState, NewState, FOnCommand);
end;

{ TFiniteStateMachine<TState, TCommand, ErrorClass> }

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand) : IFiniteStateMachine;
var
  T : TTransition;
begin
  T := TTransition.Create(FromState, OnCommand, FStateComparer, FCommandComparer);
  Result := AddTransition(T, ToState);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand; const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod) : IFiniteStateMachine;
var
  T : TTransition;
begin
  T := TTransition.Create(FromState, OnCommand, FStateComparer, FCommandComparer, OnEnter, OnExit);
  Result := AddTransition(T, ToState);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand; const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc) : IFiniteStateMachine;
var
  T : TTransition;
begin
  T := TTransition.Create(FromState, OnCommand, FStateComparer, FCommandComparer, OnEnter, OnExit);
  Result := AddTransition(T, ToState);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransitions(const FromStates : array of TState;
  const ToState : TState; const OnCommand : TCommand) : IFiniteStateMachine;
var
  State : TState;
begin
  for State in FromStates do
    AddTransition(State, ToState, OnCommand);

  Result := Self;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransitions(const FromStates : array of TState;
  const ToState : TState; const OnCommand : TCommand; const OnEnter : TOnEnterStateMethod;
  const OnExit : TOnExitStateMethod) : IFiniteStateMachine;
var
  State : TState;
begin
  for State in FromStates do
    AddTransition(State, ToState, OnCommand, OnEnter, OnExit);

  Result := Self;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransitions(const FromStates : array of TState;
  const ToState : TState; const OnCommand : TCommand; const OnEnter : TOnEnterStateProc;
  const OnExit : TOnExitStateProc) : IFiniteStateMachine;
var
  State : TState;
begin
  for State in FromStates do
    AddTransition(State, ToState, OnCommand, OnEnter, OnExit);

  Result := Self;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(var Transition : TTransition;
  const ToState : TState) : IFiniteStateMachine;
begin
  try
    FTransitionTable.Add(Transition, ToState);
  except
    FreeAndNil(Transition);
    RaiseOuterException(nil);
  end;

  Result := Self;
end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.AfterExecute(const Command : TCommand);
begin
  // for descendants
end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.BeforeExecute(const Command : TCommand);
begin
  // for descendants
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.CommandToStr(const Command : TCommand) : String;
begin
  with TValue.From<TCommand>(Command) do
    if TypeInfo.Kind = tkClass then
      Result := AsObject.ToString
    else
      Result := ToString;
end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Create;
begin
  Create(GetDefaultInitialState);
end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Create(const InitialState : TState);
begin
  Create(InitialState, nil, nil);
end;

constructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Create(const InitialState : TState;
  const StateComparer : IStateComparer; const CommandComparer : ICommandComparer);
begin
  inherited Create;

  FCurrentState  := InitialState;
  FPreviousState := InitialState;

  FCommandComparer := CommandComparer;
  FStateComparer   := StateComparer;

  FTransitionTable := TTransitionTable.Create([doOwnsKeys]);
end;

destructor TFiniteStateMachine<TState, TCommand, ErrorClass>.Destroy;
begin
  FreeAndNil(FTransitionTable);

  inherited Destroy;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.Execute(const Command : TCommand) : IFiniteStateMachine;
var
  NewState : TState;
  Transition : TTransition;
begin
  if FExecuting then
    RaiseOuterException(EExecutionInProgress.Create(RSExecutionInProgress));

  NewState := GetReachableState(FCurrentState, Command, Transition);

  try
    FExecuting := True;
    try
      BeforeExecute(Command);
      Transition.PerformExitStateAction(NewState);
      FPreviousState := FCurrentState;
      FCurrentState  := NewState;
      Transition.PerformEnterStateAction(NewState);
      AfterExecute(Command);
    finally
      FExecuting := False;
    end;
  except
    RaiseOuterException(nil);
  end;

  Result := Self;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.FindTransition(const FromState : TState;
  const OnCommand : TCommand) : TTransition;
var
  SearchKey, Key : TTransition;
begin
  Result := nil;

  SearchKey := TTransition.Create(FromState, OnCommand, FStateComparer, FCommandComparer);
  try
    if FTransitionTable.ContainsKey(SearchKey) then
      for Key in FTransitionTable.Keys do
        if Key.Equals(SearchKey) then
        begin
          Result := Key;
          Break;
        end;
  finally
    SearchKey.Free;
  end;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetCurrentState : TState;
begin
  Result := FCurrentState;
end;

class function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetDefaultInitialState : TState;
begin
  Result := Default(TState);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetPreviousState : TState;
begin
  Result := FPreviousState;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const FromState : TState;
  const OnCommand : TCommand) : TState;
var
  T : TTransition;
begin
  Result := GetReachableState(FromState, OnCommand, T);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const FromState : TState;
  const OnCommand : TCommand; out Transition : TTransition) : TState;
begin
  Result := Default(TState);

  if HasTransition(FromState, OnCommand, Transition) then
    Result := FTransitionTable[Transition]
  else
    RaiseOuterException(ETransitionNotFound.CreateFmt(
      RSTransitionNotFound, [StateToStr(FromState), CommandToStr(OnCommand)]));
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const OnCommand : TCommand) : TState;
begin
  Result := GetReachableState(FCurrentState, OnCommand);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.HasTransition(const FromState : TState;
  const OnCommand : TCommand) : Boolean;
var
  T : TTransition;
begin
  Result := HasTransition(FromState, OnCommand, T);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.HasTransition(const FromState : TState;
  const OnCommand : TCommand; out Transition : TTransition) : Boolean;
begin
  Transition := FindTransition(FromState, OnCommand);
  Result := Assigned(Transition);
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.HasTransition(const OnCommand : TCommand) : Boolean;
begin
  Result := HasTransition(FCurrentState, OnCommand);
end;

procedure TFiniteStateMachine<TState, TCommand, ErrorClass>.RaiseOuterException(E : Exception);
begin
  if not Assigned(E) then
    Exception.RaiseOuterException(ErrorClass.Create)
  else
    try
      raise E;
    except
      RaiseOuterException(nil);
    end;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.RemoveAllTransitions : IFiniteStateMachine;
begin
  FTransitionTable.Clear;

  Result := Self;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.RemoveTransition(const FromState : TState;
  const OnCommand : TCommand) : IFiniteStateMachine;
var
  T : TTransition;
begin
  if HasTransition(FromState, OnCommand, T) then
    FTransitionTable.Remove(T);

  Result := Self;
end;

function TFiniteStateMachine<TState, TCommand, ErrorClass>.StateToStr(const State : TState) : String;
begin
  with TValue.From<TState>(State) do
    if TypeInfo.Kind = tkClass then
      Result := AsObject.ToString
    else
      Result := ToString;
end;

{ TThreadFiniteStateMachine<TState, TCommand, ErrorClass> }

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand; const OnEnter : TOnEnterStateProc; const OnExit : TOnExitStateProc) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand, OnEnter, OnExit);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransitions(const FromStates : array of TState;
  const ToState : TState; const OnCommand : TCommand) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.AddTransitions(FromStates, ToState, OnCommand);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransitions(const FromStates : array of TState;
  const ToState : TState; const OnCommand : TCommand; const OnEnter : TOnEnterStateMethod;
  const OnExit : TOnExitStateMethod) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.AddTransitions(FromStates, ToState, OnCommand, OnEnter, OnExit);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransitions(const FromStates : array of TState;
  const ToState : TState; const OnCommand : TCommand; const OnEnter : TOnEnterStateProc;
  const OnExit : TOnExitStateProc) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.AddTransitions(FromStates, ToState, OnCommand, OnEnter, OnExit);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand; const OnEnter : TOnEnterStateMethod; const OnExit : TOnExitStateMethod) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand, OnEnter, OnExit);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.AddTransition(const FromState, ToState : TState;
  const OnCommand : TCommand) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

constructor TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.Create;
begin
  inherited Create;

  FLock := TObject.Create;
  FFiniteStateMachine := TFiniteStateMachine<TState, TCommand, ErrorClass>.Create;
end;

constructor TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.Create(const StateMachine : IFiniteStateMachine);
begin
  inherited Create;

  FLock := TObject.Create;
  FFiniteStateMachine := StateMachine;
end;

destructor TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.Destroy;
begin
  InternalLock;
  try
    FFiniteStateMachine := nil;

    inherited Destroy;
  finally
    InternalUnlock;
    FreeAndNil(FLock);
  end;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.Execute(const Command : TCommand) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.Execute(Command);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.GetCurrentState : TState;
begin
  InternalLock;
  try
    Result := FFiniteStateMachine.CurrentState;
  finally
    InternalUnlock;
  end;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.GetPreviousState : TState;
begin
  InternalLock;
  try
    Result := FFiniteStateMachine.PreviousState;
  finally
    InternalUnlock;
  end;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const FromState : TState;
  const OnCommand : TCommand) : TState;
begin
  InternalLock;
  try
    Result := FFiniteStateMachine.GetReachableState(FromState, OnCommand);
  finally
    InternalUnlock;
  end;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.GetReachableState(const OnCommand : TCommand) : TState;
begin
  InternalLock;
  try
    Result := FFiniteStateMachine.GetReachableState(OnCommand);
  finally
    InternalUnlock;
  end;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.HasTransition(const OnCommand : TCommand) : Boolean;
begin
  InternalLock;
  try
    Result := FFiniteStateMachine.HasTransition(OnCommand);
  finally
    InternalUnlock;
  end;
end;

procedure TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.InternalLock;
begin
  TMonitor.Enter(FLock);
end;

procedure TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.InternalUnlock;
begin
  TMonitor.Exit(FLock);
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.Lock : IFiniteStateMachine;
begin
  InternalLock;
  Result := FFiniteStateMachine;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.HasTransition(const FromState : TState;
  const OnCommand : TCommand) : Boolean;
begin
  InternalLock;
  try
    Result := FFiniteStateMachine.HasTransition(FromState, OnCommand);
  finally
    InternalUnlock;
  end;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.RemoveAllTransitions : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.RemoveAllTransitions;
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

function TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.RemoveTransition(const FromState : TState;
  const OnCommand : TCommand) : IFiniteStateMachine;
begin
  InternalLock;
  try
    FFiniteStateMachine.RemoveTransition(FromState, OnCommand);
  finally
    InternalUnlock;
  end;

  Result := Self;
end;

procedure TThreadFiniteStateMachine<TState, TCommand, ErrorClass>.Unlock;
begin
  InternalUnlock;
end;

end.
