﻿unit Test_FIToolkit.Logger.Utils;
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
  FIToolkit.Logger.Utils;

type

  TestFIToolkitLoggerUtils = class (TGenericTestCase)
  published
    procedure TestInferLogMsgType;
  end;

implementation

uses
  FIToolkit.Logger.Types, FIToolkit.Logger.Consts;

{ TestFIToolkitLoggerUtils }

procedure TestFIToolkitLoggerUtils.TestInferLogMsgType;
begin
  CheckEquals<TLogMsgType>(Low(TLogMsgType), InferLogMsgType(SEVERITY_NONE), 'SEVERITY_NONE -> Low(TLogMsgType)');
  CheckEquals<TLogMsgType>(High(TLogMsgType), InferLogMsgType(SEVERITY_MAX), 'SEVERITY_MAX -> High(TLogMsgType)');

  CheckEquals<TLogMsgType>(lmNone, InferLogMsgType(SEVERITY_NONE), 'SEVERITY_NONE -> lmNone');
  CheckEquals<TLogMsgType>(lmDebug, InferLogMsgType(SEVERITY_DEBUG), 'SEVERITY_DEBUG -> lmDebug');
  CheckEquals<TLogMsgType>(lmInfo, InferLogMsgType(SEVERITY_INFO), 'SEVERITY_INFO -> lmInfo');
  CheckEquals<TLogMsgType>(lmWarning, InferLogMsgType(SEVERITY_WARNING), 'SEVERITY_WARNING -> lmWarning');
  CheckEquals<TLogMsgType>(lmError, InferLogMsgType(SEVERITY_ERROR), 'SEVERITY_ERROR -> lmError');
  CheckEquals<TLogMsgType>(lmFatal, InferLogMsgType(SEVERITY_FATAL), 'SEVERITY_FATAL -> lmFatal');

  CheckEquals<TLogMsgType>(lmDebug, InferLogMsgType(SEVERITY_DEBUG + 1), 'SEVERITY_DEBUG + 1 -> lmDebug');
  CheckEquals<TLogMsgType>(Pred(lmFatal), InferLogMsgType(SEVERITY_FATAL - 1), 'SEVERITY_FATAL - 1 -> Pred(lmFatal)');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestFIToolkitLoggerUtils.Suite);

end.
