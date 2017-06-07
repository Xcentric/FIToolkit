﻿unit Test_FIToolkit.Logger.Impl;
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
  System.Rtti, System.TypInfo,
  FIToolkit.Logger.Intf, FIToolkit.Logger.Impl, FIToolkit.Logger.Types,
  TestUtils;

type

  { Testing helpers }

  TTestTextOutput = class (TPlainTextOutput)
    strict private
      FLastWrittenLine : String;
      FWrittenLinesCount : Integer;
    strict protected
      procedure WriteLine(const S : String); override;
    public
      property LastWrittenLine : String read FLastWrittenLine;
      property WrittenLinesCount : Integer read FWrittenLinesCount;
  end;

  { SUT }

  // Test methods for class TLogger

  TestTLogger = class (TInterfaceTestCase<ILogger>)
  strict private
    FOutput : TTestTextOutput;
  protected
    procedure DoSetUp; override;
    procedure DoTearDown; override;
    function  MakeSUT : ILogger; override;
  published
    procedure TestAddOutput;
    procedure TestEnterSection;
    procedure TestEnterSection1;
    procedure TestEnterSectionFmt;
    procedure TestEnterSectionVal;
    procedure TestLeaveSection;
    procedure TestLeaveSection1;
    procedure TestLeaveSectionFmt;
    procedure TestLeaveSectionVal;
    procedure TestEnterMethod;
    procedure TestEnterMethod1;
    procedure TestLeaveMethod;
    procedure TestLeaveMethod1;
    procedure TestLog;
    procedure TestLog1;
    procedure TestLogFmt;
    procedure TestLogVal;
    procedure TestDebug;
    procedure TestDebug1;
    procedure TestDebugFmt;
    procedure TestDebugVal;
    procedure TestInfo;
    procedure TestInfo1;
    procedure TestInfoFmt;
    procedure TestInfoVal;
    procedure TestWarning;
    procedure TestWarning1;
    procedure TestWarningFmt;
    procedure TestWarningVal;
    procedure TestError;
    procedure TestError1;
    procedure TestErrorFmt;
    procedure TestErrorVal;
    procedure TestFatal;
    procedure TestFatal1;
    procedure TestFatalFmt;
    procedure TestFatalVal;
  end;

  // Test methods for class TPlainTextOutput

  TestTPlainTextOutput = class (TInterfaceTestCase<ILogOutput>)
  protected
    function  MakeSUT : ILogOutput; override;
  published
    procedure TestBeginSection;
    procedure TestEndSection;
    procedure TestWriteMessage;
  end;

implementation

uses
  System.SysUtils,
  FIToolkit.Logger.Utils, FIToolkit.Logger.Consts;

{ TTestTextOutput }

procedure TTestTextOutput.WriteLine(const S : String);
begin
  FLastWrittenLine := S;
  Inc(FWrittenLinesCount);
end;

{ TestTLogger }

procedure TestTLogger.DoSetUp;
begin
  FOutput := TTestTextOutput.Create;
end;

procedure TestTLogger.DoTearDown;
begin
  FreeAndNil(FOutput);
end;

function TestTLogger.MakeSUT : ILogger;
begin
  Result := TLogger.Create;
end;

procedure TestTLogger.TestAddOutput;
var
  LogOutput: ILogOutput;
begin
  // TODO: Setup method call parameters
  SUT.AddOutput(LogOutput);
  // TODO: Validate method results
end;

procedure TestTLogger.TestEnterSection;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.EnterSection(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestEnterSection1;
//var
//  Vals: $1;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.EnterSection(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestEnterSectionFmt;
//var
//  Args: $3;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.EnterSectionFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestEnterSectionVal;
//var
//  Vals: $5;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.EnterSectionVal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLeaveSection;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.LeaveSection(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLeaveSection1;
//var
//  Vals: $7;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.LeaveSection(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLeaveSectionFmt;
//var
//  Args: $9;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.LeaveSectionFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLeaveSectionVal;
//var
//  Vals: $11;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.LeaveSectionVal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestEnterMethod;
//var
//  Params: $13;
//  MethodAddress: Pointer;
//  AClass: TClass;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.EnterMethod(AClass, MethodAddress, Params);
  // TODO: Validate method results
end;

procedure TestTLogger.TestEnterMethod1;
//var
//  Params: $15;
//  MethodAddress: Pointer;
//  ARecord: PTypeInfo;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.EnterMethod(ARecord, MethodAddress, Params);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLeaveMethod;
var
  AResult: TValue;
  MethodAddress: Pointer;
  AClass: TClass;
begin
  // TODO: Setup method call parameters
  MethodAddress := nil;
  AClass := nil;
  SUT.LeaveMethod(AClass, MethodAddress, AResult);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLeaveMethod1;
var
  AResult: TValue;
  MethodAddress: Pointer;
  ARecord: PTypeInfo;
begin
  // TODO: Setup method call parameters
  MethodAddress := nil;
  ARecord := nil;
  SUT.LeaveMethod(ARecord, MethodAddress, AResult);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLog;
var
  Msg: string;
  Severity: TLogMsgSeverity;
begin
  // TODO: Setup method call parameters
  Severity := Default(TLogMsgSeverity);
  SUT.Log(Severity, Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLog1;
//var
//  Vals: $17;
//  Severity: TLogMsgSeverity;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.Log(Severity, Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLogFmt;
//var
//  Args: $19;
//  Msg: string;
//  Severity: TLogMsgSeverity;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.LogFmt(Severity, Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestLogVal;
//var
//  Vals: $21;
//  Severity: TLogMsgSeverity;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.LogVal(Severity, Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestDebug;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.Debug(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestDebug1;
//var
//  Vals: $23;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.Debug(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestDebugFmt;
//var
//  Args: $25;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.DebugFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestDebugVal;
//var
//  Vals: $27;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.DebugVal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestInfo;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.Info(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestInfo1;
//var
//  Vals: $29;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.Info(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestInfoFmt;
//var
//  Args: $31;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.InfoFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestInfoVal;
//var
//  Vals: $33;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.InfoVal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestWarning;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.Warning(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestWarning1;
//var
//  Vals: $35;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.Warning(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestWarningFmt;
//var
//  Args: $37;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.WarningFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestWarningVal;
//var
//  Vals: $39;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.WarningVal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestError;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.Error(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestError1;
//var
//  Vals: $41;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.Error(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestErrorFmt;
//var
//  Args: $43;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.ErrorFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestErrorVal;
//var
//  Vals: $45;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.ErrorVal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestFatal;
var
  Msg: string;
begin
  // TODO: Setup method call parameters
  SUT.Fatal(Msg);
  // TODO: Validate method results
end;

procedure TestTLogger.TestFatal1;
//var
//  Vals: $47;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.Fatal(Vals);
  // TODO: Validate method results
end;

procedure TestTLogger.TestFatalFmt;
//var
//  Args: $49;
//  Msg: string;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.FatalFmt(Msg, Args);
  // TODO: Validate method results
end;

procedure TestTLogger.TestFatalVal;
//var
//  Vals: $51;
begin
  // TODO: Setup method call parameters
  //FAbstractLogger.FatalVal(Vals);
  // TODO: Validate method results
end;

{ TestTPlainTextOutput }

function TestTPlainTextOutput.MakeSUT : ILogOutput;
begin
  Result := TTestTextOutput.Create;
end;

procedure TestTPlainTextOutput.TestBeginSection;
var
  Msg : String;
  Instant : TLogTimestamp;

  procedure RunLocalChecks;
  begin
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMainThreadName),
      'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMainThreadName]);
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOSectionBeginningPrefix),
      'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOSectionBeginningPrefix]);

    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(Msg),
      'CheckTrue::LastWrittenLine.Contains(%s)', [Msg]);
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(DateTimeToStr(Instant)),
      'CheckTrue::LastWrittenLine.Contains(%s)', [DateTimeToStr(Instant)]);
  end;

begin
  CheckEquals(0, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 0');
  CheckEquals(0, SUTAsClass<TTestTextOutput>.WrittenLinesCount, 'WrittenLinesCount = 0');
  CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.IsEmpty, 'CheckTrue::LastWrittenLine.IsEmpty');

  Msg := 'BeginSection1';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_NONE;
  SUT.BeginSection(Instant, Msg);

  CheckEquals(1, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 1');
  RunLocalChecks;

  Msg := 'BeginSection2';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.BeginSection(Instant, Msg);

  CheckEquals(2, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 2');
  RunLocalChecks;

  Msg := 'BeginSection3';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_MAX;
  SUT.BeginSection(Instant, Msg);

  CheckEquals(3, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 3');
  RunLocalChecks;

  CheckEquals(3, SUTAsClass<TTestTextOutput>.WrittenLinesCount, 'WrittenLinesCount = 3');
end;

procedure TestTPlainTextOutput.TestEndSection;
var
  Msg : String;
  Instant : TLogTimestamp;

  procedure RunLocalChecks;
  begin
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMainThreadName),
      'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMainThreadName]);
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOSectionEndingPrefix),
      'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOSectionEndingPrefix]);

    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(Msg),
      'CheckTrue::LastWrittenLine.Contains(%s)', [Msg]);
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(DateTimeToStr(Instant)),
      'CheckTrue::LastWrittenLine.Contains(%s)', [DateTimeToStr(Instant)]);
  end;

begin
  SUT.BeginSection(Now, 'BeginSection1');
  SUT.BeginSection(Now, 'BeginSection2');
  SUT.BeginSection(Now, 'BeginSection3');

  Assert(SUTAsClass<TTestTextOutput>.SectionLevel = 3, 'SectionLevel <> 3');
  Assert(SUTAsClass<TTestTextOutput>.WrittenLinesCount = 3, 'WrittenLinesCount <> 3');

  Msg := 'EndSection3';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_MAX;
  SUT.EndSection(Instant, Msg);

  CheckEquals(2, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 2');
  RunLocalChecks;

  Msg := 'EndSection2';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.EndSection(Instant, Msg);

  CheckEquals(1, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 1');
  RunLocalChecks;

  Msg := 'EndSection1';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_NONE;
  SUT.EndSection(Instant, Msg);

  CheckEquals(0, SUTAsClass<TTestTextOutput>.SectionLevel, 'SectionLevel = 0');
  RunLocalChecks;

  CheckEquals(6, SUTAsClass<TTestTextOutput>.WrittenLinesCount, 'WrittenLinesCount = 6');
end;

procedure TestTPlainTextOutput.TestWriteMessage;
var
  Msg : String;
  Severity : TLogMsgSeverity;
  Instant : TLogTimestamp;

  procedure RunLocalChecks;
  begin
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMainThreadName),
      'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMainThreadName]);

    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(Msg),
      'CheckTrue::LastWrittenLine.Contains(%s)', [Msg]);
    CheckTrue((Severity in [SEVERITY_NONE, SEVERITY_MIN]) or
      SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(
      SUTAsClass<TTestTextOutput>.GetSeverityDescriptions[InferLogMsgType(Severity)]),
      'CheckTrue::LastWrittenLine.Contains(<SeverityDesc>)');
    CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(DateTimeToStr(Instant)),
      'CheckTrue::LastWrittenLine.Contains(%s)', [DateTimeToStr(Instant)]);

    case InferLogMsgType(Severity) of
      lmNone:
        begin {NOP} end;
      lmDebug:
        CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMsgTypeDescDebug),
          'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMsgTypeDescDebug]);
      lmInfo:
        CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMsgTypeDescInfo),
          'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMsgTypeDescInfo]);
      lmWarning:
        CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMsgTypeDescWarning),
          'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMsgTypeDescWarning]);
      lmError:
        CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMsgTypeDescError),
          'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMsgTypeDescError]);
      lmFatal:
        CheckTrue(SUTAsClass<TTestTextOutput>.LastWrittenLine.Contains(RSPTOMsgTypeDescFatal),
          'CheckTrue::LastWrittenLine.Contains(%s)', [RSPTOMsgTypeDescFatal]);
    else
      Fail('Unhandled log message type.');
    end;
  end;

begin
  { Case #1 }

  Msg := 'Message1';
  Instant := Now;
  Severity := SUT.SeverityThreshold;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(1, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 1)::<Case #1>');
  RunLocalChecks;

  { Case #2 }

  Msg := 'Message2';
  Instant := Now;
  Severity := SEVERITY_NONE;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(1, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 1)::<Case #2>');

  { Case #3 }

  Msg := 'Message3';
  Instant := Now;
  Severity := SEVERITY_MAX;
  SUT.SeverityThreshold := SEVERITY_NONE;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(1, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 1)::<Case #3>');

  { Case #4 }

  Msg := 'Message4';
  Instant := Now;
  SUT.SeverityThreshold := SEVERITY_MAX;
  Severity := Pred(SUT.SeverityThreshold);
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(1, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 1)::<Case #4>');

  { Case #5 }

  Msg := 'Message5';
  Instant := Now;
  Severity := SEVERITY_DEBUG;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(2, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 2)::<Case #5>');
  RunLocalChecks;

  { Case #6 }

  Msg := 'Message6';
  Instant := Now;
  Severity := SEVERITY_INFO;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(3, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 3)::<Case #6>');
  RunLocalChecks;

  { Case #7 }

  Msg := 'Message7';
  Instant := Now;
  Severity := SEVERITY_WARNING;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(4, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 4)::<Case #7>');
  RunLocalChecks;

  { Case #8 }

  Msg := 'Message8';
  Instant := Now;
  Severity := SEVERITY_ERROR;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(5, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 5)::<Case #8>');
  RunLocalChecks;

  { Case #9 }

  Msg := 'Message9';
  Instant := Now;
  Severity := SEVERITY_FATAL;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(6, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 6)::<Case #9>');
  RunLocalChecks;

  { Case #10 }

  Msg := 'Message10';
  Instant := Now;
  Severity := SEVERITY_MAX;
  SUT.SeverityThreshold := SEVERITY_MIN;
  SUT.WriteMessage(Instant, Severity, Msg);

  CheckEquals(7, SUTAsClass<TTestTextOutput>.WrittenLinesCount, '(WrittenLinesCount = 7)::<Case #10>');
  RunLocalChecks;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTLogger.Suite);
  RegisterTest(TestTPlainTextOutput.Suite);
end.
