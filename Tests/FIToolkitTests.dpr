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
  DUnitTestRunner,
  Test_Base.Exceptions in 'Test_Base.Exceptions.pas',
  Base.Exceptions in '..\Source\Base\Base.Exceptions.pas',
  Test_Config.FixInsight in 'Test_Config.FixInsight.pas',
  Config.FixInsight in '..\Source\Config\Config.FixInsight.pas',
  Base.Consts in '..\Source\Base\Base.Consts.pas',
  Config.Exceptions in '..\Source\Config\Config.Exceptions.pas',
  Config.Consts in '..\Source\Config\Config.Consts.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.
