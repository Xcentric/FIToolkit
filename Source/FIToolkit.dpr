program FIToolkit;

{$APPTYPE CONSOLE}

{$R 'Help.res' 'ResourceScripts\Help\Help.rc'}

{$R *.res}

uses
  System.SysUtils,
  System.Types,
  FIToolkit.Consts in 'FIToolkit.Consts.pas',
  FIToolkit.Exceptions in 'FIToolkit.Exceptions.pas',
  FIToolkit.Main in 'FIToolkit.Main.pas',
  FIToolkit.Types in 'FIToolkit.Types.pas',
  FIToolkit.CommandLine.Consts in 'CommandLine\FIToolkit.CommandLine.Consts.pas',
  FIToolkit.CommandLine.Exceptions in 'CommandLine\FIToolkit.CommandLine.Exceptions.pas',
  FIToolkit.CommandLine.Options in 'CommandLine\FIToolkit.CommandLine.Options.pas',
  FIToolkit.CommandLine.Types in 'CommandLine\FIToolkit.CommandLine.Types.pas',
  FIToolkit.Commons.Consts in 'Commons\FIToolkit.Commons.Consts.pas',
  FIToolkit.Commons.Exceptions in 'Commons\FIToolkit.Commons.Exceptions.pas',
  FIToolkit.Commons.FiniteStateMachine.Consts in 'Commons\FiniteStateMachine\FIToolkit.Commons.FiniteStateMachine.Consts.pas',
  FIToolkit.Commons.FiniteStateMachine.Exceptions in 'Commons\FiniteStateMachine\FIToolkit.Commons.FiniteStateMachine.Exceptions.pas',
  FIToolkit.Commons.FiniteStateMachine.FSM in 'Commons\FiniteStateMachine\FIToolkit.Commons.FiniteStateMachine.FSM.pas',
  FIToolkit.Commons.StateMachine in 'Commons\FIToolkit.Commons.StateMachine.pas',
  FIToolkit.Commons.Types in 'Commons\FIToolkit.Commons.Types.pas',
  FIToolkit.Commons.Utils in 'Commons\FIToolkit.Commons.Utils.pas',
  FIToolkit.Config.Consts in 'Config\FIToolkit.Config.Consts.pas',
  FIToolkit.Config.Data in 'Config\FIToolkit.Config.Data.pas',
  FIToolkit.Config.Defaults in 'Config\FIToolkit.Config.Defaults.pas',
  FIToolkit.Config.Exceptions in 'Config\FIToolkit.Config.Exceptions.pas',
  FIToolkit.Config.FixInsight in 'Config\FIToolkit.Config.FixInsight.pas',
  FIToolkit.Config.Manager in 'Config\FIToolkit.Config.Manager.pas',
  FIToolkit.Config.Storage in 'Config\FIToolkit.Config.Storage.pas',
  FIToolkit.Config.TypedDefaults in 'Config\FIToolkit.Config.TypedDefaults.pas',
  FIToolkit.Config.Types in 'Config\FIToolkit.Config.Types.pas',
  FIToolkit.Logger.Consts in 'Logger\FIToolkit.Logger.Consts.pas',
  FIToolkit.ProjectGroupParser.Consts in 'ProjectGroupParser\FIToolkit.ProjectGroupParser.Consts.pas',
  FIToolkit.ProjectGroupParser.Exceptions in 'ProjectGroupParser\FIToolkit.ProjectGroupParser.Exceptions.pas',
  FIToolkit.ProjectGroupParser.Parser in 'ProjectGroupParser\FIToolkit.ProjectGroupParser.Parser.pas',
  FIToolkit.Reports.Builder.Consts in 'Reports\Builder\FIToolkit.Reports.Builder.Consts.pas',
  FIToolkit.Reports.Parser.Consts in 'Reports\Parser\FIToolkit.Reports.Parser.Consts.pas',
  FIToolkit.Runner.Consts in 'Runner\FIToolkit.Runner.Consts.pas',
  FIToolkit.Runner.Exceptions in 'Runner\FIToolkit.Runner.Exceptions.pas',
  FIToolkit.Runner.Tasks in 'Runner\FIToolkit.Runner.Tasks.pas';

var
  sFullExePath : TFileName;
  arrCmdLineOptions : TStringDynArray;
  i : Integer;
begin
  {$IFDEF DEBUG}
  System.ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  try
    sFullExePath := ParamStr(0);
    SetLength(arrCmdLineOptions, ParamCount);
    for i := 0 to High(arrCmdLineOptions) do
      arrCmdLineOptions[i] := ParamStr(i + 1);

    RunApplication(sFullExePath, arrCmdLineOptions);
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.ToString, sLineBreak);
      {$IFNDEF DEBUG}
      Halt(1);
      {$ENDIF}
    end;
  end;

  {$IFDEF DEBUG}
  PressAnyKey;
  {$ENDIF}
end.
