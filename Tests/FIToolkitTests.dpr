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
  FIToolkit.Base.Consts in '..\Source\Base\FIToolkit.Base.Consts.pas',
  FIToolkit.Base.Exceptions in '..\Source\Base\FIToolkit.Base.Exceptions.pas',
  FIToolkit.Config.Consts in '..\Source\Config\FIToolkit.Config.Consts.pas',
  FIToolkit.Config.Data in '..\Source\Config\FIToolkit.Config.Data.pas',
  FIToolkit.Config.Exceptions in '..\Source\Config\FIToolkit.Config.Exceptions.pas',
  FIToolkit.Config.FixInsight in '..\Source\Config\FIToolkit.Config.FixInsight.pas',
  FIToolkit.Config.Types in '..\Source\Config\FIToolkit.Config.Types.pas',
  Test_FIToolkit.Base.Exceptions in 'Test_FIToolkit.Base.Exceptions.pas',
  Test_FIToolkit.Config.Data in 'Test_FIToolkit.Config.Data.pas',
  Test_FIToolkit.Config.FixInsight in 'Test_FIToolkit.Config.FixInsight.pas',
  TestConsts in 'TestConsts.pas';

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

{$R *.RES}

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
