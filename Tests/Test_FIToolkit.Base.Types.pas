﻿unit Test_FIToolkit.Base.Types;
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
  FIToolkit.Base.Types;

type
  // Test methods for TAssignable

  TestTAssignable = class (TTestCase)
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
  CheckEquals(INT_TEST, AI2, 'AI2 = INT_TEST');
end;

procedure TestTAssignable.TestOnChange;
  const
    INT_OLD_VALUE = INT_TEST;
    INT_NEW_VALUE = INT_OLD_VALUE + 1;
  var
    AI : TAssignableInteger;
begin
  CheckFalse(Assigned(AI.OnChange), 'CheckFalse::(OnChange <> nil)');

  AI.OnChange :=
    procedure (WasAssigned : Boolean; const CurrentValue, OldValue : Integer)
    begin
      CheckFalse(WasAssigned, 'CheckFalse::WasAssigned');
    end;
  AI := INT_OLD_VALUE;

  AI.OnChange :=
    procedure (WasAssigned : Boolean; const CurrentValue, OldValue : Integer)
    begin
      CheckTrue(WasAssigned, 'CheckTrue::WasAssigned');
      CheckEquals(INT_OLD_VALUE, OldValue, 'OldValue = INT_OLD_VALUE');
      CheckEquals(INT_NEW_VALUE, CurrentValue, 'CurrentValue = INT_NEW_VALUE');
    end;
  AI := INT_NEW_VALUE;
end;

procedure TestTAssignable.TestOnChanging;
  const
    INT_OLD_VALUE = INT_TEST;
    INT_NEW_VALUE = INT_OLD_VALUE + 1;
  var
    AI : TAssignableInteger;
begin
  CheckFalse(Assigned(AI.OnChanging), 'CheckFalse::(OnChanging <> nil)');

  AI.OnChanging :=
    procedure (WasAssigned : Boolean; const CurrentValue, OldValue : Integer; var AllowChange : Boolean)
    begin
      CheckFalse(WasAssigned, 'CheckFalse::WasAssigned');
    end;
  AI := INT_OLD_VALUE;

  AI.OnChanging :=
    procedure (WasAssigned : Boolean; const CurrentValue, NewValue : Integer; var AllowChange : Boolean)
    begin
      CheckTrue(WasAssigned, 'CheckTrue::WasAssigned');
      CheckEquals(INT_OLD_VALUE, CurrentValue, 'CurrentValue = INT_OLD_VALUE');
      CheckEquals(INT_NEW_VALUE, NewValue, 'NewValue = INT_NEW_VALUE');
    end;
  AI := INT_NEW_VALUE;

  AI.OnChanging := nil;
  AI := INT_OLD_VALUE;
  AI.OnChanging :=
    procedure (WasAssigned : Boolean; const CurrentValue, NewValue : Integer; var AllowChange : Boolean)
    begin
      CheckTrue(AllowChange, 'CheckTrue::AllowChange');
      AllowChange := False;
    end;
  AI := INT_NEW_VALUE;
  CheckEquals(INT_OLD_VALUE, AI.Value, 'AI.Value = INT_OLD_VALUE');
end;

procedure TestTAssignable.TestOnUnassign;
  var
    AI : TAssignableInteger;
begin
  CheckFalse(Assigned(AI.OnUnassign), 'CheckFalse::(OnUnassign <> nil)');

  AI.OnUnassign :=
    procedure (WasAssigned : Boolean; const OldValue : Integer)
    begin
      CheckFalse(WasAssigned, 'CheckFalse::WasAssigned');
    end;
  AI.Unassign;

  AI := INT_TEST;
  AI.OnUnassign :=
    procedure (WasAssigned : Boolean; const OldValue : Integer)
    begin
      CheckTrue(WasAssigned, 'CheckTrue::WasAssigned');
    end;
  AI.Unassign;
end;

procedure TestTAssignable.TestUnassign;
  var
    AI : TAssignableInteger;
begin
  AI := INT_TEST;
  AI.Unassign;

  CheckFalse(AI.Assigned, 'CheckFalse::Assigned');
  CheckEquals(Default(Integer), AI, 'AI = 0');
end;

procedure TestTAssignable.TestValue;
  var
    AI : TAssignableInteger;
begin
  CheckEquals(Default(Integer), AI, 'AI = 0');
  AI := INT_TEST;
  CheckEquals(INT_TEST, AI.Value, 'AI.Value = INT_TEST');
  CheckEquals(INT_TEST, AI, 'AI = INT_TEST');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTAssignable.Suite);
end.
