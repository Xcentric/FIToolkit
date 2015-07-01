program FIToolkit;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Main in 'Main.pas',
  Exceptions in 'Exceptions.pas',
  Config.Manager in 'Config\Config.Manager.pas',
  Config.Consts in 'Config\Config.Consts.pas',
  Config.FixInsight in 'Config\Config.FixInsight.pas',
  Config.Exceptions in 'Config\Config.Exceptions.pas',
  LaunchParams.Consts in 'LaunchParams\LaunchParams.Consts.pas',
  Logger.Consts in 'Logger\Logger.Consts.pas',
  Reports.Builder.Consts in 'Reports\Builder\Reports.Builder.Consts.pas',
  Reports.Parser.Consts in 'Reports\Parser\Reports.Parser.Consts.pas',
  Runner.Consts in 'Runner\Runner.Consts.pas';

{$R *.res}

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
