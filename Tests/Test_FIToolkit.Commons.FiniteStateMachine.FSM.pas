﻿unit Test_FIToolkit.Commons.FiniteStateMachine.FSM;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework,
  System.Generics.Defaults,
  FIToolkit.Commons.FiniteStateMachine.FSM, FIToolkit.Commons.Exceptions;

type
  // Test methods for class TFiniteStateMachine

  TestTFiniteStateMachine = class(TGenericTestCase)
  private
    type
      TStateType = (stStart, stState1, stState2, stState3, stFinish);
      TCommandType = (ctBegin, ctSwitchState_1to2, ctSwitchState_2to3, ctEnd);
      ETestException = class (ECustomException);

      TOnEnterStateMethod = TOnEnterStateMethod<TStateType, TCommandType>;
      TOnEnterStateProc   = TOnEnterStateProc<TStateType, TCommandType>;
      TOnExitStateMethod  = TOnExitStateMethod<TStateType, TCommandType>;
      TOnExitStateProc    = TOnExitStateProc<TStateType, TCommandType>;

      IFiniteStateMachine = IFiniteStateMachine<TStateType, TCommandType, ETestException>;
      TFiniteStateMachine = class (TFiniteStateMachine<TStateType, TCommandType, ETestException>);

      TStateRec = record
        ID : Integer;
        Flag : Boolean;
      end;

      TCommandRec = record
        ID : Integer;
        Flag : Boolean;
      end;

      TStateRecComparer = class (TEqualityComparer<TStateRec>)
        public
          function Equals(const Left, Right : TStateRec) : Boolean; override;
          function GetHashCode(const Value : TStateRec) : Integer; override;
      end;

      TCommandRecComparer = class (TEqualityComparer<TCommandRec>)
        public
          function Equals(const Left, Right : TCommandRec) : Boolean; override;
          function GetHashCode(const Value : TCommandRec) : Integer; override;
      end;

    const
      START_STATE  = stStart;
      FINISH_STATE = stFinish;

      STATE_RECS : array [0..2] of TStateRec =
        (
          (ID: 1; Flag: True),
          (ID: 2; Flag: False),
          (ID: 3; Flag: False)
        );

      COMMAND_RECS : array [0..1] of TCommandRec =
        (
          (ID: 1; Flag: False),
          (ID: 2; Flag: True)
        );
  private
    FEnterStateCalled,
    FExitStateCalled : Boolean;

    procedure OnEnterState(const PreviousState, CurrentState : TStateType; const UsedCommand : TCommandType);
    procedure OnExitState(const CurrentState, NewState : TStateType; const UsedCommand : TCommandType);
  strict protected
    FFiniteStateMachine: IFiniteStateMachine;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddTransition_NoEvents;
    procedure TestAddTransition_MethodEvents;
    procedure TestAddTransition_ProcEvents;
    procedure TestCreate;
    procedure TestExecute;
    procedure TestGetReachableState_FromSpecifiedState;
    procedure TestGetReachableState_FromCurrentState;
    procedure TestHasTransition_FromSpecifiedState;
    procedure TestHasTransition_FromCurrentState;
    procedure TestRemoveAllTransitions;
    procedure TestRemoveTransition;
  end;

  TestTThreadFiniteStateMachine = class(TestTFiniteStateMachine)
  public
    procedure SetUp; override;
  published
    procedure TestThreadSafety;
  end;

implementation

uses
  TestUtils,
  System.Hash, System.Threading, System.Classes, System.SysUtils,
  FIToolkit.Commons.FiniteStateMachine.Exceptions;

procedure TestTFiniteStateMachine.OnEnterState(const PreviousState, CurrentState : TStateType;
  const UsedCommand : TCommandType);
begin
  FEnterStateCalled := True;

  CheckEquals<TStateType>(CurrentState, FFiniteStateMachine.GetReachableState(PreviousState, UsedCommand));
end;

procedure TestTFiniteStateMachine.OnExitState(const CurrentState, NewState : TStateType;
  const UsedCommand : TCommandType);
begin
  FExitStateCalled := True;

  CheckEquals<TStateType>(NewState, FFiniteStateMachine.GetReachableState(CurrentState, UsedCommand));
end;

procedure TestTFiniteStateMachine.SetUp;
begin
  FFiniteStateMachine := TFiniteStateMachine.Create(START_STATE);
  FEnterStateCalled := False;
  FExitStateCalled := False;
end;

procedure TestTFiniteStateMachine.TearDown;
begin
  FFiniteStateMachine := nil;
end;

procedure TestTFiniteStateMachine.TestAddTransition_NoEvents;
var
  ReturnValue: IFiniteStateMachine;
  OnCommand: TCommandType;
  ToState: TStateType;
  FromState: TStateType;
begin
  FromState := stStart;
  ToState := stFinish;
  OnCommand := ctEnd;

  ReturnValue := FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand);

  CheckEquals(TObject(FFiniteStateMachine), TObject(ReturnValue), 'ReturnValue = FFiniteStateMachine');
  CheckTrue(ReturnValue.HasTransition(FromState, OnCommand), 'CheckTrue::HasTransition');
  CheckEquals<TStateType>(ToState, ReturnValue.GetReachableState(FromState, OnCommand), 'GetReachableState = ToState');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand);
    end,
    ETestException,
    'CheckException::ETestException'
  );
end;

procedure TestTFiniteStateMachine.TestAddTransition_MethodEvents;
var
  ReturnValue: IFiniteStateMachine;
  OnExit: TOnExitStateMethod;
  OnEnter: TOnEnterStateMethod;
  OnCommand: TCommandType;
  ToState: TStateType;
  FromState: TStateType;
begin
  FromState := stState1;
  ToState := stState2;
  OnCommand := ctSwitchState_1to2;
  OnEnter := OnEnterState;
  OnExit := OnExitState;

  ReturnValue := FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand,
      OnEnter, OnExit);

  CheckEquals(TObject(FFiniteStateMachine), TObject(ReturnValue), 'ReturnValue = FFiniteStateMachine');
  CheckTrue(ReturnValue.HasTransition(FromState, OnCommand), 'CheckTrue::HasTransition');
  CheckEquals<TStateType>(ToState, ReturnValue.GetReachableState(FromState, OnCommand), 'GetReachableState = ToState');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand);
    end,
    ETestException,
    'CheckException::ETestException'
  );
end;

procedure TestTFiniteStateMachine.TestAddTransition_ProcEvents;
var
  ReturnValue: IFiniteStateMachine;
  OnExit: TOnExitStateProc;
  OnEnter: TOnEnterStateProc;
  OnCommand: TCommandType;
  ToState: TStateType;
  FromState: TStateType;
begin
  FromState := stState3;
  ToState := stFinish;
  OnCommand := ctEnd;
  OnEnter :=
    procedure (const PreviousState, CurrentState : TStateType; const UsedCommand : TCommandType)
    begin
      //
    end;
  OnExit :=
    procedure (const CurrentState, NewState : TStateType; const UsedCommand : TCommandType)
    begin
      //
    end;

  ReturnValue := FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand,
      OnEnter, OnExit);

  CheckEquals(TObject(FFiniteStateMachine), TObject(ReturnValue), 'ReturnValue = FFiniteStateMachine');
  CheckTrue(ReturnValue.HasTransition(FromState, OnCommand), 'CheckTrue::HasTransition');
  CheckEquals<TStateType>(ToState, ReturnValue.GetReachableState(FromState, OnCommand), 'GetReachableState = ToState');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.AddTransition(FromState, ToState, OnCommand);
    end,
    ETestException,
    'CheckException::ETestException'
  );
end;

procedure TestTFiniteStateMachine.TestCreate;
var
  FSM : IFiniteStateMachine;
  CustomFSM : IFiniteStateMachine<TStateRec, TCommandRec, ETestException>;
  StateComparer : IEqualityComparer<TStateRec>;
  CommandComparer : IEqualityComparer<TCommandRec>;
begin
  { Default test FSM }

  FSM := TFiniteStateMachine.Create;
  CheckEquals<TStateType>(START_STATE, FSM.CurrentState, 'CurrentState = START_STATE');
  CheckEquals<TStateType>(FSM.PreviousState, FSM.CurrentState, 'CurrentState = PreviousState');
  FSM := nil;

  FSM := TFiniteStateMachine.Create(FINISH_STATE);
  CheckEquals<TStateType>(FINISH_STATE, FSM.CurrentState, 'CurrentState = FINISH_STATE');
  CheckEquals<TStateType>(FSM.PreviousState, FSM.CurrentState, 'CurrentState = PreviousState');
  FSM := nil;

  { FSM with complex state/command types & custom comparers }

  StateComparer := TStateRecComparer.Create;
  CommandComparer := TCommandRecComparer.Create;
  CustomFSM := TFiniteStateMachine<TStateRec, TCommandRec, ETestException>.Create(
    STATE_RECS[0], StateComparer, CommandComparer);
  CustomFSM
    .AddTransition(STATE_RECS[0], STATE_RECS[1], COMMAND_RECS[0])
    .AddTransition(STATE_RECS[1], STATE_RECS[2], COMMAND_RECS[1]);

  CheckTrue(CustomFSM.HasTransition(STATE_RECS[0], COMMAND_RECS[0]), 'CheckTrue::HasTransition');
  CheckTrue(StateComparer.Equals(STATE_RECS[2], CustomFSM.GetReachableState(STATE_RECS[1], COMMAND_RECS[1])),
    'CheckTrue::(GetReachableState = STATE_RECS[2])');
end;

procedure TestTFiniteStateMachine.TestExecute;
var
  ReturnValue: IFiniteStateMachine;
  bEnterStateCalled, bExitStateCalled : Boolean;
begin
  bEnterStateCalled := False;
  bExitStateCalled := False;
  FFiniteStateMachine
    .AddTransition(START_STATE, stState1, ctBegin)
    .AddTransition(stState1, stState2, ctSwitchState_1to2, OnEnterState, OnExitState)
    .AddTransition(stState2, stState3, ctSwitchState_2to3,
      procedure (const PreviousState, CurrentState : TStateType; const UsedCommand : TCommandType)
      begin
        bEnterStateCalled := True;

        CheckEquals<TStateType>(stState2, PreviousState, 'PreviousState = stState2');
        CheckEquals<TStateType>(stState3, CurrentState, 'CurrentState = stState3');
        CheckEquals<TCommandType>(ctSwitchState_2to3, UsedCommand, 'UsedCommand = ctSwitchState_2to3');
      end,
      procedure (const CurrentState, NewState : TStateType; const UsedCommand : TCommandType)
      begin
        bExitStateCalled := True;

        CheckEquals<TStateType>(stState2, CurrentState, 'CurrentState = stState2');
        CheckEquals<TStateType>(stState3, NewState, 'NewState = stState3');
        CheckEquals<TCommandType>(ctSwitchState_2to3, UsedCommand, 'UsedCommand = ctSwitchState_2to3');
      end)
    .AddTransition(stState3, FINISH_STATE, ctEnd);

  ReturnValue := FFiniteStateMachine
    .Execute(ctBegin)
    .Execute(ctSwitchState_1to2)
    .Execute(ctSwitchState_2to3)
    .Execute(ctEnd);

  CheckEquals(TObject(FFiniteStateMachine), TObject(ReturnValue), 'ReturnValue = FFiniteStateMachine');
  CheckEquals<TStateType>(FINISH_STATE, ReturnValue.CurrentState, 'CurrentState = FINISH_STATE');
  CheckNotEquals<TStateType>(START_STATE, ReturnValue.CurrentState, 'CurrentState <> START_STATE');
  CheckNotEquals<TStateType>(ReturnValue.PreviousState, ReturnValue.CurrentState, 'CurrentState <> PreviousState');
  CheckTrue(FEnterStateCalled, 'CheckTrue::FEnterStateCalled');
  CheckTrue(FExitStateCalled, 'CheckTrue::FExitStateCalled');
  CheckTrue(bEnterStateCalled, 'CheckTrue::bEnterStateCalled');
  CheckTrue(bExitStateCalled, 'CheckTrue::bExitStateCalled');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.Execute(ctBegin);
    end,
    ETestException,
    'CheckException::ETestException'
  );
  CheckInnerException(
    procedure
    begin
      FFiniteStateMachine.Execute(ctBegin);
    end,
    ETransitionNotFound,
    'CheckException::ETransitionNotFound'
  );
end;

procedure TestTFiniteStateMachine.TestGetReachableState_FromSpecifiedState;
const
  TARGET_STATE = stState2;
var
  ReturnValue: TStateType;
  OnCommand: TCommandType;
  FromState: TStateType;
begin
  FromState := stState1;
  OnCommand := ctSwitchState_1to2;
  FFiniteStateMachine.AddTransition(FromState, TARGET_STATE, OnCommand);

  ReturnValue := FFiniteStateMachine.GetReachableState(FromState, OnCommand);

  CheckEquals<TStateType>(TARGET_STATE, ReturnValue, 'ReturnValue = TARGET_STATE');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.GetReachableState(FINISH_STATE, ctEnd);
    end,
    ETestException,
    'CheckException::ETestException'
  );
  CheckInnerException(
    procedure
    begin
      FFiniteStateMachine.GetReachableState(FINISH_STATE, ctEnd);
    end,
    ETransitionNotFound,
    'CheckException::ETransitionNotFound'
  );
end;

procedure TestTFiniteStateMachine.TestGetReachableState_FromCurrentState;
const
  TARGET_STATE = stState1;
var
  ReturnValue: TStateType;
  OnCommand: TCommandType;
begin
  OnCommand := ctBegin;
  FFiniteStateMachine.AddTransition(START_STATE, TARGET_STATE, OnCommand);

  ReturnValue := FFiniteStateMachine.GetReachableState(OnCommand);

  CheckEquals<TStateType>(TARGET_STATE, ReturnValue, 'ReturnValue = TARGET_STATE');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.GetReachableState(FINISH_STATE, ctEnd);
    end,
    ETestException,
    'CheckException::ETestException'
  );
  CheckInnerException(
    procedure
    begin
      FFiniteStateMachine.GetReachableState(FINISH_STATE, ctEnd);
    end,
    ETransitionNotFound,
    'CheckException::ETransitionNotFound'
  );
end;

procedure TestTFiniteStateMachine.TestHasTransition_FromSpecifiedState;
const
  TARGET_STATE = stState2;
var
  ReturnValue: Boolean;
  OnCommand: TCommandType;
  FromState: TStateType;
begin
  FromState := stState1;
  OnCommand := ctSwitchState_1to2;
  FFiniteStateMachine.AddTransition(FromState, TARGET_STATE, OnCommand);

  ReturnValue := FFiniteStateMachine.HasTransition(FromState, OnCommand);
  CheckTrue(ReturnValue, 'CheckTrue::ReturnValue');

  FromState := FINISH_STATE;
  OnCommand := ctEnd;

  ReturnValue := FFiniteStateMachine.HasTransition(FromState, OnCommand);
  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue');
end;

procedure TestTFiniteStateMachine.TestHasTransition_FromCurrentState;
const
  TARGET_STATE = stState1;
var
  ReturnValue: Boolean;
  OnCommand: TCommandType;
begin
  OnCommand := ctBegin;
  FFiniteStateMachine.AddTransition(START_STATE, TARGET_STATE, OnCommand);

  ReturnValue := FFiniteStateMachine.HasTransition(OnCommand);
  CheckTrue(ReturnValue, 'CheckTrue::ReturnValue');

  OnCommand := ctEnd;

  ReturnValue := FFiniteStateMachine.HasTransition(OnCommand);
  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue');
end;

procedure TestTFiniteStateMachine.TestRemoveAllTransitions;
var
  ReturnValue: IFiniteStateMachine;
begin
  FFiniteStateMachine
    .AddTransition(stStart,  stState1, ctBegin)
    .AddTransition(stState1, stState2, ctSwitchState_1to2)
    .AddTransition(stState2, stState3, ctSwitchState_2to3);

  ReturnValue := FFiniteStateMachine.RemoveAllTransitions;

  CheckEquals(TObject(FFiniteStateMachine), TObject(ReturnValue), 'ReturnValue = FFiniteStateMachine');
  CheckFalse(
    ReturnValue.HasTransition(stStart,  ctBegin) or
    ReturnValue.HasTransition(stState1, ctSwitchState_1to2) or
    ReturnValue.HasTransition(stState2, ctSwitchState_2to3),
    'CheckFalse::HasTransition'
  );
end;

procedure TestTFiniteStateMachine.TestRemoveTransition;
var
  ReturnValue: IFiniteStateMachine;
  OnCommand: TCommandType;
  FromState: TStateType;
begin
  FromState := START_STATE;
  OnCommand := ctEnd;
  FFiniteStateMachine.AddTransition(FromState, FINISH_STATE, OnCommand);

  ReturnValue := FFiniteStateMachine.RemoveTransition(FromState, OnCommand);

  CheckEquals(TObject(FFiniteStateMachine), TObject(ReturnValue), 'ReturnValue = FFiniteStateMachine');
  CheckFalse(ReturnValue.HasTransition(FromState, OnCommand), 'CheckFalse::HasTransition');
  CheckException(
    procedure
    begin
      FFiniteStateMachine.RemoveTransition(FromState, OnCommand);
    end,
    nil,
    'CheckException::nil'
  );
end;

{ TestTFiniteStateMachine.TStateRecComparer }

function TestTFiniteStateMachine.TStateRecComparer.Equals(const Left, Right : TStateRec) : Boolean;
begin
  Result := (Left.ID = Right.ID) and (Left.Flag = Right.Flag);
end;

function TestTFiniteStateMachine.TStateRecComparer.GetHashCode(const Value : TStateRec) : Integer;
begin
  Result := THashBobJenkins.GetHashValue(Value, SizeOf(Value));
end;

{ TestTFiniteStateMachine.TCommandRecComparer }

function TestTFiniteStateMachine.TCommandRecComparer.Equals(const Left, Right : TCommandRec) : Boolean;
begin
  Result := (Left.ID = Right.ID) and (Left.Flag = Right.Flag);
end;

function TestTFiniteStateMachine.TCommandRecComparer.GetHashCode(const Value : TCommandRec) : Integer;
begin
  Result := THashBobJenkins.GetHashValue(Value, SizeOf(Value));
end;

{ TestTThreadFiniteStateMachine }

procedure TestTThreadFiniteStateMachine.SetUp;
begin
  FFiniteStateMachine := TThreadFiniteStateMachine<
    TestTFiniteStateMachine.TStateType,
    TestTFiniteStateMachine.TCommandType,
    TestTFiniteStateMachine.ETestException
  >.Create;
end;

procedure TestTThreadFiniteStateMachine.TestThreadSafety;
type
  IThreadFiniteStateMachine = IThreadFiniteStateMachine<TStateType, TCommandType, ETestException>;
var
  ThreadFSM : IThreadFiniteStateMachine;
  LoadThread : TThread;
  TestTask : ITask;
  bLoadThreadFaulted,
  bCheck1, bCheck2, bCheck3 : Boolean;
begin
  ThreadFSM := IThreadFiniteStateMachine(FFiniteStateMachine);
  ThreadFSM
    .AddTransition(stStart, stFinish, ctEnd)
    .AddTransition(stFinish, stStart, ctBegin);

  bLoadThreadFaulted := False;
  LoadThread := TThread.CreateAnonymousThread(
    procedure
    var
      FSM : IFiniteStateMachine;
    begin
      try
        while not TThread.CheckTerminated do
        begin
          FSM := ThreadFSM.Lock;
          try
            case FSM.CurrentState of
              stStart:
                FSM.Execute(ctEnd);
              stFinish:
                FSM.Execute(ctBegin);
            end;
          finally
            ThreadFSM.Unlock;
          end;
        end;
      except
        bLoadThreadFaulted := True;
      end;
    end
  );
  LoadThread.Start;

  bCheck1 := False;
  bCheck2 := False;
  bCheck3 := False;
  TestTask := TTask.Run(
    procedure
    var
      i : Integer;
      FSM : IFiniteStateMachine;
    begin
      ThreadFSM
        .AddTransition(stState1, stState2, ctSwitchState_1to2)
        .AddTransition(stState2, stState3, ctSwitchState_2to3);

      for i := 1 to 1000 do
      begin
        FSM := ThreadFSM.Lock;
        try
          case FSM.CurrentState of
            stStart:
              FSM.Execute(ctEnd);
            stFinish:
              FSM.Execute(ctBegin);
          end;
        finally
          ThreadFSM.Unlock;
        end;
      end;

      bCheck1 := ThreadFSM.HasTransition(stState1, ctSwitchState_1to2);
      ThreadFSM.RemoveTransition(stState1, ctSwitchState_1to2);
      bCheck2 := not ThreadFSM.HasTransition(stState1, ctSwitchState_1to2);

      with ThreadFSM do
        try
          Lock
            .RemoveAllTransitions
            .AddTransition(stStart, stFinish, ctEnd)
            .AddTransition(stFinish, stStart, ctBegin);

          bCheck3 := not HasTransition(stState2, ctSwitchState_2to3);
        finally
          Unlock;
        end;
    end
  );

  CheckException(
    procedure
    begin
      TestTask.Wait;
    end,
    nil,
    'CheckException::nil'
  );
  CheckFalse(bLoadThreadFaulted, 'CheckFalse::bLoadThreadFaulted');
  CheckTrue(bCheck1, 'CheckTrue::bCheck1');
  CheckTrue(bCheck2, 'CheckTrue::bCheck2');
  CheckTrue(bCheck3, 'CheckTrue::bCheck3');

  TestTask := nil;
  LoadThread.Terminate;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFiniteStateMachine.Suite);
  RegisterTest(TestTThreadFiniteStateMachine.Suite);
end.