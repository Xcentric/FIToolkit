program FIToolkitTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  {$IFDEF USE_TESTINSIGHT}
  TestInsight.DUnit,
  TestInsight.Client,
  {$ENDIF}
  DUnitTestRunner,
  Base.Consts in '..\Source\Base\Base.Consts.pas',
  Base.Exceptions in '..\Source\Base\Base.Exceptions.pas',
  Config.Consts in '..\Source\Config\Config.Consts.pas',
  Config.Exceptions in '..\Source\Config\Config.Exceptions.pas',
  Config.FixInsight in '..\Source\Config\Config.FixInsight.pas',
  Test_Base.Exceptions in 'Test_Base.Exceptions.pas',
  Test_Config.FixInsight in 'Test_Config.FixInsight.pas';

{$R *.RES}

  {$IFDEF USE_TESTINSIGHT}
  function IsTestInsightRunning : Boolean;
    var
      TIClient : ITestInsightClient;
  begin
    TIClient := TTestInsightRestClient.Create;
    TIClient.StartedTesting(0);
    Result := not TIClient.HasError;
  end;
  {$ENDIF}

begin
  {$IFDEF USE_TESTINSIGHT}
  if IsTestInsightRunning then
    TestInsight.DUnit.RunRegisteredTests
  else
    DUnitTestRunner.RunRegisteredTests;
  {$ELSE}
  DUnitTestRunner.RunRegisteredTests;
  {$ENDIF}
end.
