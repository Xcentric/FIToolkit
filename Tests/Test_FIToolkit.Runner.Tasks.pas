﻿unit Test_FIToolkit.Runner.Tasks;
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
  System.SysUtils,
  FIToolkit.Runner.Tasks;

type

  // Test methods for class TTaskRunner
  TestTTaskRunner = class (TGenericTestCase)
  private
    const
      STR_OUTPUT_FILENAME_NO_EXT = 'test_output';
      STR_OUTPUT_FILENAME_EXT = '.ext';
      STR_OUTPUT_FILENAME = STR_OUTPUT_FILENAME_NO_EXT + STR_OUTPUT_FILENAME_EXT;

      STR_PROJECT_FILENAME_NO_EXT = 'test_input';
      STR_PROJECT_FILENAME = STR_PROJECT_FILENAME_NO_EXT + '.ext';
  strict private
    FTaskRunner : TTaskRunner;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExecute;
  end;

  // Test methods for class TTaskManager
  TestTTaskManager = class (TGenericTestCase)
  private
    const
      ARR_FILE_NAMES : array of TFileName = [String.Empty, String.Empty];
  strict private
    FTaskManager : TTaskManager;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRunAndGetOutput;
  end;

implementation

uses
  System.Threading, System.IOUtils, System.Generics.Collections,
  TestUtils,
  FIToolkit.Config.FixInsight, FIToolkit.Commons.Utils, FIToolkit.Runner.Exceptions;

procedure TestTTaskRunner.SetUp;
var
  FIO : TFixInsightOptions;
begin
  FIO := TFixInsightOptions.Create;
  try
    FIO.OutputFileName  := STR_OUTPUT_FILENAME;
    FIO.ProjectFileName := STR_PROJECT_FILENAME;
    FTaskRunner := TTaskRunner.Create(String.Empty, FIO);
  finally
    FIO.Free;
  end;
end;

procedure TestTTaskRunner.TearDown;
begin
  FreeAndNil(FTaskRunner);
end;

procedure TestTTaskRunner.TestExecute;
var
  ReturnValue : ITask;
  S : String;
begin
  ReturnValue := FTaskRunner.Execute;

  CheckAggregateException(
    procedure
    begin
      ReturnValue.Wait;
    end,
    ECreateProcessError,
    'CheckAggregateException::ECreateProcessError'
  );

  S := FTaskRunner.OutputFileName;

  CheckTrue(TPath.IsApplicableFileName(S), 'IsApplicableFileName(%s)', [S]);
  CheckEquals(TestDataDir, TPath.GetDirectoryName(S, True), 'GetDirectoryName(S) = TestDataDir');
  CheckTrue(TPath.GetFileName(S).StartsWith(STR_OUTPUT_FILENAME_NO_EXT),
    'GetFileName(S).StartsWith(%s)', [STR_OUTPUT_FILENAME_NO_EXT]);
  CheckTrue(S.EndsWith(STR_OUTPUT_FILENAME_EXT), 'S.EndsWith(%s)', [STR_OUTPUT_FILENAME_EXT]);
  CheckTrue(S.Contains(STR_PROJECT_FILENAME_NO_EXT), 'S.Contains(%s)', [STR_PROJECT_FILENAME_NO_EXT]);
  CheckFalse(S.Contains(STR_PROJECT_FILENAME), 'S.Contains(%s)', [STR_PROJECT_FILENAME]);

  S := FTaskRunner.InputFileName;

  CheckEquals(STR_PROJECT_FILENAME, S, 'InputFileName = STR_PROJECT_FILENAME');
end;

procedure TestTTaskManager.SetUp;
var
  FIO : TFixInsightOptions;
begin
  FIO := TFixInsightOptions.Create;
  try
    FTaskManager := TTaskManager.Create(String.Empty, FIO, ARR_FILE_NAMES, TestDataDir);
  finally
    FIO.Free;
  end;
end;

procedure TestTTaskManager.TearDown;
begin
  FreeAndNil(FTaskManager);
end;

procedure TestTTaskManager.TestRunAndGetOutput;
var
  ReturnValue: TArray<TPair<TFileName, TFileName>>;
begin
  CheckException(
    procedure
    begin
      ReturnValue := FTaskManager.RunAndGetOutput;
    end,
    ESomeTasksFailed,
    'CheckException::ESomeTasksFailed'
  );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTTaskRunner.Suite);
  RegisterTest(TestTTaskManager.Suite);

end.
