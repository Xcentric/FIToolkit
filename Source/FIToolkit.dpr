program FIToolkit;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Types,
  Main in 'Main.pas',
  Base.Consts in 'Base\Base.Consts.pas',
  Base.Exceptions in 'Base\Base.Exceptions.pas',
  Config.Consts in 'Config\Config.Consts.pas',
  Config.Data in 'Config\Config.Data.pas',
  Config.Exceptions in 'Config\Config.Exceptions.pas',
  Config.FixInsight in 'Config\Config.FixInsight.pas',
  Config.Manager in 'Config\Config.Manager.pas',
  Config.Types in 'Config\Config.Types.pas',
  LaunchParams.Consts in 'LaunchParams\LaunchParams.Consts.pas',
  Logger.Consts in 'Logger\Logger.Consts.pas',
  Reports.Builder.Consts in 'Reports\Builder\Reports.Builder.Consts.pas',
  Reports.Parser.Consts in 'Reports\Parser\Reports.Parser.Consts.pas',
  Runner.Consts in 'Runner\Runner.Consts.pas';

{$R *.res}

var
  sFullExePath : TFileName;
  aLaunchParams : TStringDynArray;
  i : Integer;
begin
  try
    sFullExePath := ParamStr(0);
    SetLength(aLaunchParams, ParamCount - 1);
    for i := 0 to High(aLaunchParams) do
      aLaunchParams[i] := ParamStr(i + 1);

    RunApplication(sFullExePath, aLaunchParams);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
