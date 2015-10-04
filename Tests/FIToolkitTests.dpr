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

{$R *.RES}

uses
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnit,
  TestInsight.Client,
  {$ENDIF}
  DUnitTestRunner,
  FIToolkit.Base.Consts in '..\Source\Base\FIToolkit.Base.Consts.pas',
  FIToolkit.Base.Exceptions in '..\Source\Base\FIToolkit.Base.Exceptions.pas',
  FIToolkit.CommandLine.Consts in '..\Source\CommandLine\FIToolkit.CommandLine.Consts.pas',
  FIToolkit.CommandLine.Exceptions in '..\Source\CommandLine\FIToolkit.CommandLine.Exceptions.pas',
  FIToolkit.CommandLine.Options in '..\Source\CommandLine\FIToolkit.CommandLine.Options.pas',
  FIToolkit.CommandLine.Types in '..\Source\CommandLine\FIToolkit.CommandLine.Types.pas',
  FIToolkit.Config.Consts in '..\Source\Config\FIToolkit.Config.Consts.pas',
  FIToolkit.Config.Data in '..\Source\Config\FIToolkit.Config.Data.pas',
  FIToolkit.Config.Defaults in '..\Source\Config\FIToolkit.Config.Defaults.pas',
  FIToolkit.Config.Exceptions in '..\Source\Config\FIToolkit.Config.Exceptions.pas',
  FIToolkit.Config.FixInsight in '..\Source\Config\FIToolkit.Config.FixInsight.pas',
  FIToolkit.Config.Manager in '..\Source\Config\FIToolkit.Config.Manager.pas',
  FIToolkit.Config.Storage in '..\Source\Config\FIToolkit.Config.Storage.pas',
  FIToolkit.Config.TypedDefaults in '..\Source\Config\FIToolkit.Config.TypedDefaults.pas',
  FIToolkit.Config.Types in '..\Source\Config\FIToolkit.Config.Types.pas',
  FIToolkit.Utils in '..\Source\FIToolkit.Utils.pas',
  Test_FIToolkit.Base.Exceptions in 'Test_FIToolkit.Base.Exceptions.pas',
  Test_FIToolkit.CommandLine.Options in 'Test_FIToolkit.CommandLine.Options.pas',
  Test_FIToolkit.Config.Data in 'Test_FIToolkit.Config.Data.pas',
  Test_FIToolkit.Config.Defaults in 'Test_FIToolkit.Config.Defaults.pas',
  Test_FIToolkit.Config.FixInsight in 'Test_FIToolkit.Config.FixInsight.pas',
  Test_FIToolkit.Config.Manager in 'Test_FIToolkit.Config.Manager.pas',
  Test_FIToolkit.Config.Storage in 'Test_FIToolkit.Config.Storage.pas',
  Test_FIToolkit.Utils in 'Test_FIToolkit.Utils.pas',
  TestConsts in 'TestConsts.pas',
  TestUtils in 'TestUtils.pas';

  {$IFDEF TESTINSIGHT}
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
  {$IFDEF TESTINSIGHT}
  if IsTestInsightRunning then
    TestInsight.DUnit.RunRegisteredTests
  else
    DUnitTestRunner.RunRegisteredTests;
  {$ELSE}
  DUnitTestRunner.RunRegisteredTests;
  {$ENDIF}
end.
