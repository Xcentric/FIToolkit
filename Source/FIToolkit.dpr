program FIToolkit;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Types,
  FIToolkit.Base.Consts in 'Base\FIToolkit.Base.Consts.pas',
  FIToolkit.Base.Exceptions in 'Base\FIToolkit.Base.Exceptions.pas',
  FIToolkit.CommandLine.Consts in 'CommandLine\FIToolkit.CommandLine.Consts.pas',
  FIToolkit.CommandLine.Exceptions in 'CommandLine\FIToolkit.CommandLine.Exceptions.pas',
  FIToolkit.CommandLine.Options in 'CommandLine\FIToolkit.CommandLine.Options.pas',
  FIToolkit.CommandLine.Types in 'CommandLine\FIToolkit.CommandLine.Types.pas',
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
  FIToolkit.Main in 'FIToolkit.Main.pas',
  FIToolkit.Reports.Builder.Consts in 'Reports\Builder\FIToolkit.Reports.Builder.Consts.pas',
  FIToolkit.Reports.Parser.Consts in 'Reports\Parser\FIToolkit.Reports.Parser.Consts.pas',
  FIToolkit.Runner.Consts in 'Runner\FIToolkit.Runner.Consts.pas',
  FIToolkit.Utils in 'FIToolkit.Utils.pas';

{$R *.res}

var
  sFullExePath : TFileName;
  aLaunchParams : TStringDynArray;
  i : Integer;
begin
  try
    sFullExePath := ParamStr(0);
    SetLength(aLaunchParams, ParamCount);
    for i := 0 to High(aLaunchParams) do
      aLaunchParams[i] := ParamStr(i + 1);

    RunApplication(sFullExePath, aLaunchParams);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
