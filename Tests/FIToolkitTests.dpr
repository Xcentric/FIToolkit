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
  FIToolkit.Consts in '..\Source\FIToolkit.Consts.pas',
  FIToolkit.Localization in '..\Source\FIToolkit.Localization.pas',
  FIToolkit.Types in '..\Source\FIToolkit.Types.pas',
  FIToolkit.Utils in '..\Source\FIToolkit.Utils.pas',
  FIToolkit.CommandLine.Consts in '..\Source\CommandLine\FIToolkit.CommandLine.Consts.pas',
  FIToolkit.CommandLine.Exceptions in '..\Source\CommandLine\FIToolkit.CommandLine.Exceptions.pas',
  FIToolkit.CommandLine.Options in '..\Source\CommandLine\FIToolkit.CommandLine.Options.pas',
  FIToolkit.CommandLine.Types in '..\Source\CommandLine\FIToolkit.CommandLine.Types.pas',
  FIToolkit.Commons.Consts in '..\Source\Commons\FIToolkit.Commons.Consts.pas',
  FIToolkit.Commons.Exceptions in '..\Source\Commons\FIToolkit.Commons.Exceptions.pas',
  FIToolkit.Commons.FiniteStateMachine.Consts in '..\Source\Commons\FiniteStateMachine\FIToolkit.Commons.FiniteStateMachine.Consts.pas',
  FIToolkit.Commons.FiniteStateMachine.Exceptions in '..\Source\Commons\FiniteStateMachine\FIToolkit.Commons.FiniteStateMachine.Exceptions.pas',
  FIToolkit.Commons.FiniteStateMachine.FSM in '..\Source\Commons\FiniteStateMachine\FIToolkit.Commons.FiniteStateMachine.FSM.pas',
  FIToolkit.Commons.Types in '..\Source\Commons\FIToolkit.Commons.Types.pas',
  FIToolkit.Commons.Utils in '..\Source\Commons\FIToolkit.Commons.Utils.pas',
  FIToolkit.Config.Consts in '..\Source\Config\FIToolkit.Config.Consts.pas',
  FIToolkit.Config.Data in '..\Source\Config\FIToolkit.Config.Data.pas',
  FIToolkit.Config.Defaults in '..\Source\Config\FIToolkit.Config.Defaults.pas',
  FIToolkit.Config.Exceptions in '..\Source\Config\FIToolkit.Config.Exceptions.pas',
  FIToolkit.Config.FixInsight in '..\Source\Config\FIToolkit.Config.FixInsight.pas',
  FIToolkit.Config.Manager in '..\Source\Config\FIToolkit.Config.Manager.pas',
  FIToolkit.Config.Storage in '..\Source\Config\FIToolkit.Config.Storage.pas',
  FIToolkit.Config.TypedDefaults in '..\Source\Config\FIToolkit.Config.TypedDefaults.pas',
  FIToolkit.Config.Types in '..\Source\Config\FIToolkit.Config.Types.pas',
  FIToolkit.Logger.Consts in '..\Source\Logger\FIToolkit.Logger.Consts.pas',
  FIToolkit.Logger.Default in '..\Source\Logger\FIToolkit.Logger.Default.pas',
  FIToolkit.Logger.Impl in '..\Source\Logger\FIToolkit.Logger.Impl.pas',
  FIToolkit.Logger.Intf in '..\Source\Logger\FIToolkit.Logger.Intf.pas',
  FIToolkit.Logger.Types in '..\Source\Logger\FIToolkit.Logger.Types.pas',
  FIToolkit.Logger.Utils in '..\Source\Logger\FIToolkit.Logger.Utils.pas',
  FIToolkit.ProjectGroupParser.Consts in '..\Source\ProjectGroupParser\FIToolkit.ProjectGroupParser.Consts.pas',
  FIToolkit.ProjectGroupParser.Exceptions in '..\Source\ProjectGroupParser\FIToolkit.ProjectGroupParser.Exceptions.pas',
  FIToolkit.ProjectGroupParser.Parser in '..\Source\ProjectGroupParser\FIToolkit.ProjectGroupParser.Parser.pas',
  FIToolkit.Reports.Builder.Consts in '..\Source\Reports\Builder\FIToolkit.Reports.Builder.Consts.pas',
  FIToolkit.Reports.Builder.Exceptions in '..\Source\Reports\Builder\FIToolkit.Reports.Builder.Exceptions.pas',
  FIToolkit.Reports.Builder.HTML in '..\Source\Reports\Builder\FIToolkit.Reports.Builder.HTML.pas',
  FIToolkit.Reports.Builder.Intf in '..\Source\Reports\Builder\FIToolkit.Reports.Builder.Intf.pas',
  FIToolkit.Reports.Builder.Types in '..\Source\Reports\Builder\FIToolkit.Reports.Builder.Types.pas',
  FIToolkit.Reports.Parser.Consts in '..\Source\Reports\Parser\FIToolkit.Reports.Parser.Consts.pas',
  FIToolkit.Reports.Parser.Exceptions in '..\Source\Reports\Parser\FIToolkit.Reports.Parser.Exceptions.pas',
  FIToolkit.Reports.Parser.Messages in '..\Source\Reports\Parser\FIToolkit.Reports.Parser.Messages.pas',
  FIToolkit.Reports.Parser.Types in '..\Source\Reports\Parser\FIToolkit.Reports.Parser.Types.pas',
  FIToolkit.Reports.Parser.XMLOutputParser in '..\Source\Reports\Parser\FIToolkit.Reports.Parser.XMLOutputParser.pas',
  FIToolkit.Runner.Consts in '..\Source\Runner\FIToolkit.Runner.Consts.pas',
  FIToolkit.Runner.Exceptions in '..\Source\Runner\FIToolkit.Runner.Exceptions.pas',
  FIToolkit.Runner.Tasks in '..\Source\Runner\FIToolkit.Runner.Tasks.pas',
  Test_FIToolkit.CommandLine.Options in 'Test_FIToolkit.CommandLine.Options.pas',
  Test_FIToolkit.Commons.Exceptions in 'Test_FIToolkit.Commons.Exceptions.pas',
  Test_FIToolkit.Commons.FiniteStateMachine.FSM in 'Test_FIToolkit.Commons.FiniteStateMachine.FSM.pas',
  Test_FIToolkit.Commons.Types in 'Test_FIToolkit.Commons.Types.pas',
  Test_FIToolkit.Commons.Utils in 'Test_FIToolkit.Commons.Utils.pas',
  Test_FIToolkit.Config.Data in 'Test_FIToolkit.Config.Data.pas',
  Test_FIToolkit.Config.Defaults in 'Test_FIToolkit.Config.Defaults.pas',
  Test_FIToolkit.Config.FixInsight in 'Test_FIToolkit.Config.FixInsight.pas',
  Test_FIToolkit.Config.Manager in 'Test_FIToolkit.Config.Manager.pas',
  Test_FIToolkit.Config.Storage in 'Test_FIToolkit.Config.Storage.pas',
  Test_FIToolkit.Logger.Default in 'Test_FIToolkit.Logger.Default.pas',
  Test_FIToolkit.Logger.Impl in 'Test_FIToolkit.Logger.Impl.pas',
  Test_FIToolkit.Logger.Types in 'Test_FIToolkit.Logger.Types.pas',
  Test_FIToolkit.Logger.Utils in 'Test_FIToolkit.Logger.Utils.pas',
  Test_FIToolkit.ProjectGroupParser.Parser in 'Test_FIToolkit.ProjectGroupParser.Parser.pas',
  Test_FIToolkit.Reports.Builder.HTML in 'Test_FIToolkit.Reports.Builder.HTML.pas',
  Test_FIToolkit.Reports.Parser.Messages in 'Test_FIToolkit.Reports.Parser.Messages.pas',
  Test_FIToolkit.Reports.Parser.Types in 'Test_FIToolkit.Reports.Parser.Types.pas',
  Test_FIToolkit.Reports.Parser.XMLOutputParser in 'Test_FIToolkit.Reports.Parser.XMLOutputParser.pas',
  Test_FIToolkit.Runner.Tasks in 'Test_FIToolkit.Runner.Tasks.pas',
  Test_FIToolkit.Utils in 'Test_FIToolkit.Utils.pas',
  Test_UTF8Sources in 'Test_UTF8Sources.pas',
  TestConsts in 'TestConsts.pas',
  TestTypes in 'TestTypes.pas',
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
  System.ReportMemoryLeaksOnShutdown := True;

  {$IFDEF TESTINSIGHT}
  if IsTestInsightRunning then
    TestInsight.DUnit.RunRegisteredTests
  else
    DUnitTestRunner.RunRegisteredTests;
  {$ELSE}
  DUnitTestRunner.RunRegisteredTests;
  {$ENDIF}
end.
