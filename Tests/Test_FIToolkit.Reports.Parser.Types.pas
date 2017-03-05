﻿unit Test_FIToolkit.Reports.Parser.Types;
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
  FIToolkit.Reports.Parser.Types;

type

  TestTFixInsightMessage = class (TGenericTestCase)
    published
      procedure TestCreate;
      procedure TestGetComparer;
  end;

implementation

uses
  System.SysUtils, System.Types;

{ TestTFixInsightMessage }

procedure TestTFixInsightMessage.TestCreate;
const
  MSGID_WARNING = 'W123';
  MSGID_OPTIMIZATION = 'O123';
  MSGID_CODING_CONVENTION = 'C123';
  MSGID_FATAL = 'FATAL';
  MSGID_TRIAL = 'Tria';
var
  FIM : TFixInsightMessage;
begin
  FIM := TFixInsightMessage.Create(String.Empty, 0, 0, String.Empty, String.Empty);
  CheckEquals<TFixInsightMessageType>(fimtUnknown, FIM.MsgType, 'MsgType = fimtUnknown');

  FIM := TFixInsightMessage.Create(String.Empty, 0, 0, MSGID_WARNING, String.Empty);
  CheckEquals<TFixInsightMessageType>(fimtWarning, FIM.MsgType, 'MsgType = fimtWarning');

  FIM := TFixInsightMessage.Create(String.Empty, 0, 0, MSGID_OPTIMIZATION, String.Empty);
  CheckEquals<TFixInsightMessageType>(fimtOptimization, FIM.MsgType, 'MsgType = fimtOptimization');

  FIM := TFixInsightMessage.Create(String.Empty, 0, 0, MSGID_CODING_CONVENTION, String.Empty);
  CheckEquals<TFixInsightMessageType>(fimtCodingConvention, FIM.MsgType, 'MsgType = fimtCodingConvention');

  FIM := TFixInsightMessage.Create(String.Empty, 0, 0, MSGID_FATAL, String.Empty);
  CheckEquals<TFixInsightMessageType>(fimtFatal, FIM.MsgType, 'MsgType = fimtFatal');

  FIM := TFixInsightMessage.Create(String.Empty, 0, 0, MSGID_TRIAL, String.Empty);
  CheckEquals<TFixInsightMessageType>(fimtTrial, FIM.MsgType, 'MsgType = fimtTrial');
end;

procedure TestTFixInsightMessage.TestGetComparer;
var
  // case #1
  OrigMsg, EqualMsg, GreaterMsg1, GreaterMsg2, GreaterMsg3 : TFixInsightMessage;
  // case #2
  OrigMsg2, EqualMsg2, EqualMsg3, GreaterMsg4 : TFixInsightMessage;
begin
  { Case #1 - constructor with NO full file name }

  OrigMsg := TFixInsightMessage.Create('C:\abc.pas', 100, 32, String.Empty, String.Empty);
  EqualMsg := TFixInsightMessage.Create('C:\ABC.pas', 100, 32, 'W505', 'text');
  GreaterMsg1 := TFixInsightMessage.Create('C:\bcd.pas', 100, 32, String.Empty, String.Empty);
  GreaterMsg2 := TFixInsightMessage.Create('C:\abc.pas', 101, 32, String.Empty, String.Empty);
  GreaterMsg3 := TFixInsightMessage.Create('C:\abc.pas', 100, 33, String.Empty, String.Empty);

  with TFixInsightMessage.GetComparer do
  begin
    CheckEquals(EqualsValue, Compare(OrigMsg, OrigMsg), 'OrigMsg = OrigMsg');
    CheckEquals(EqualsValue, Compare(OrigMsg, EqualMsg), 'OrigMsg = EqualMsg');
    CheckEquals(LessThanValue, Compare(OrigMsg, GreaterMsg1), 'OrigMsg < GreaterMsg1');
    CheckEquals(LessThanValue, Compare(OrigMsg, GreaterMsg2), 'OrigMsg < GreaterMsg2');
    CheckEquals(LessThanValue, Compare(OrigMsg, GreaterMsg3), 'OrigMsg < GreaterMsg3');
  end;

  { Case #2 - constructor WITH full file name }

  OrigMsg2 := TFixInsightMessage.Create('..\TestUnit.pas', 'C:\TestUnit.pas', 100, 32, String.Empty, String.Empty);
  EqualMsg2 := TFixInsightMessage.Create('..\TestUnit.pas', 100, 32, String.Empty, String.Empty);
  EqualMsg3 := TFixInsightMessage.Create('..\TestUnit.pas', 'c:\testunit.pas', 100, 32, String.Empty, String.Empty);
  GreaterMsg4 := TFixInsightMessage.Create('..\TestUnit.pas', 'X:\TestUnit.pas', 100, 32, String.Empty, String.Empty);

  with TFixInsightMessage.GetComparer do
  begin
    CheckEquals(EqualsValue, Compare(OrigMsg2, EqualMsg2), 'OrigMsg2 = EqualMsg2');
    CheckEquals(EqualsValue, Compare(OrigMsg2, EqualMsg3), 'OrigMsg2 = EqualMsg3');
    CheckEquals(LessThanValue, Compare(OrigMsg2, GreaterMsg4), 'OrigMsg2 < GreaterMsg4');
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFixInsightMessage.Suite);

end.
