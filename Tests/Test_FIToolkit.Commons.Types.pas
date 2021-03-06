﻿unit Test_FIToolkit.Commons.Types;
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
  FIToolkit.Commons.Types;

type
  // Test methods for TAssignable

  TestTAssignable = class (TGenericTestCase)
  private
    const
      INT_TEST = 777;
    type
      TAssignableInteger = TAssignable<Integer>;
  published
    procedure TestAssigned;
    procedure TestCreate;
    procedure TestOnChange;
    procedure TestOnChanging;
    procedure TestOnUnassign;
    procedure TestUnassign;
    procedure TestValue;
  end;

implementation

{ TestTAssignable }

procedure TestTAssignable.TestAssigned;
var
  AI : TAssignableInteger;
begin
  CheckFalse(AI.Assigned, 'CheckFalse::Assigned');
  AI := INT_TEST;
  CheckTrue(AI.Assigned, 'CheckTrue::Assigned');
end;

procedure TestTAssignable.TestCreate;
var
  AI1, AI2 : TAssignableInteger;
begin
  AI1 := TAssignableInteger.Create(INT_TEST);
  CheckTrue(AI1.Assigned, 'CheckTrue::AI1.Assigned');
  CheckEquals(INT_TEST, AI1.Value, 'AI1.Value = INT_TEST');

  AI2 := INT_TEST;
  CheckTrue(AI2.Assigned, 'CheckTrue::AI2.Assigned');
  CheckEquals(INT_TEST, Integer(AI2), 'AI2 = INT_TEST');
end;

procedure TestTAssignable.TestOnChange;
const
  INT_OLD_VALUE = INT_TEST;
  INT_NEW_VALUE = INT_OLD_VALUE + 1;
var
  AI : TAssignableInteger;
  bCalled : Boolean;
begin
  CheckFalse(Assigned(AI.OnChange), 'CheckFalse::Assigned(AI.OnChange)');

  bCalled := False;
  AI.OnChange :=
    procedure (WasAssigned : Boolean; const CurrentValue, OldValue : Integer)
    begin
      bCalled := True;
      CheckFalse(WasAssigned, 'CheckFalse::WasAssigned');
    end;
  AI := INT_OLD_VALUE;
  CheckTrue(bCalled, 'CheckTrue::bCalled');

  bCalled := False;
  AI.OnChange :=
    procedure (WasAssigned : Boolean; const CurrentValue, OldValue : Integer)
    begin
      bCalled := True;
      CheckTrue(WasAssigned, 'CheckTrue::WasAssigned');
      CheckEquals(INT_OLD_VALUE, OldValue, 'OldValue = INT_OLD_VALUE');
      CheckEquals(INT_NEW_VALUE, CurrentValue, 'CurrentValue = INT_NEW_VALUE');
    end;
  AI := INT_NEW_VALUE;
  CheckTrue(bCalled, 'CheckTrue::bCalled');
end;

procedure TestTAssignable.TestOnChanging;
const
  INT_OLD_VALUE = INT_TEST;
  INT_NEW_VALUE = INT_OLD_VALUE + 1;
var
  AI : TAssignableInteger;
  bCalled : Boolean;
begin
  CheckFalse(Assigned(AI.OnChanging), 'CheckFalse::Assigned(AI.OnChanging)');

  bCalled := False;
  AI.OnChanging :=
    procedure (WasAssigned : Boolean; const CurrentValue, OldValue : Integer; var AllowChange : Boolean)
    begin
      bCalled := True;
      CheckFalse(WasAssigned, 'CheckFalse::WasAssigned');
    end;
  AI := INT_OLD_VALUE;
  CheckTrue(bCalled, 'CheckTrue::bCalled');

  bCalled := False;
  AI.OnChanging :=
    procedure (WasAssigned : Boolean; const CurrentValue, NewValue : Integer; var AllowChange : Boolean)
    begin
      bCalled := True;
      CheckTrue(WasAssigned, 'CheckTrue::WasAssigned');
      CheckEquals(INT_OLD_VALUE, CurrentValue, 'CurrentValue = INT_OLD_VALUE');
      CheckEquals(INT_NEW_VALUE, NewValue, 'NewValue = INT_NEW_VALUE');
    end;
  AI := INT_NEW_VALUE;
  CheckTrue(bCalled, 'CheckTrue::bCalled');

  AI.OnChanging := nil;
  AI := INT_OLD_VALUE;
  bCalled := False;
  AI.OnChanging :=
    procedure (WasAssigned : Boolean; const CurrentValue, NewValue : Integer; var AllowChange : Boolean)
    begin
      bCalled := True;
      CheckTrue(AllowChange, 'CheckTrue::AllowChange');
      AllowChange := False;
    end;
  AI := INT_NEW_VALUE;
  CheckTrue(bCalled, 'CheckTrue::bCalled');
  CheckEquals(INT_OLD_VALUE, AI.Value, 'AI.Value = INT_OLD_VALUE');
end;

procedure TestTAssignable.TestOnUnassign;
var
  AI : TAssignableInteger;
  bCalled : Boolean;
begin
  CheckFalse(Assigned(AI.OnUnassign), 'CheckFalse::Assigned(AI.OnUnassign)');

  bCalled := False;
  AI.OnUnassign :=
    procedure (WasAssigned : Boolean; const OldValue : Integer)
    begin
      bCalled := True;
      CheckFalse(WasAssigned, 'CheckFalse::WasAssigned');
    end;
  AI.Unassign;
  CheckTrue(bCalled, 'CheckTrue::bCalled');

  bCalled := False;
  AI := INT_TEST;
  AI.OnUnassign :=
    procedure (WasAssigned : Boolean; const OldValue : Integer)
    begin
      bCalled := True;
      CheckTrue(WasAssigned, 'CheckTrue::WasAssigned');
      CheckEquals(INT_TEST, OldValue, 'OldValue = INT_TEST');
    end;
  AI.Unassign;
  CheckTrue(bCalled, 'CheckTrue::bCalled');
end;

procedure TestTAssignable.TestUnassign;
var
  AI : TAssignableInteger;
begin
  AI := INT_TEST;
  AI.Unassign;

  CheckFalse(AI.Assigned, 'CheckFalse::Assigned');
  CheckNotEquals(INT_TEST, AI.Value, 'AI.Value <> INT_TEST');
  CheckEquals(Default(Integer), Integer(AI), 'AI = 0');
end;

procedure TestTAssignable.TestValue;
var
  AI : TAssignableInteger;
begin
  CheckEquals(Default(Integer), AI.Value, 'AI.Value = 0');
  CheckEquals(Default(Integer), Integer(AI), 'AI = 0');
  AI := INT_TEST;
  CheckEquals(INT_TEST, AI.Value, 'AI.Value = INT_TEST');
  CheckEquals(INT_TEST, Integer(AI), 'AI = INT_TEST');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTAssignable.Suite);
end.
