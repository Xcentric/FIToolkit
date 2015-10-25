unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);

implementation

uses
  System.IOUtils,
  FIToolkit.Exceptions, FIToolkit.Consts,
  FIToolkit.Base.Utils,
  FIToolkit.CommandLine.Options, FIToolkit.CommandLine.Consts,
  FIToolkit.Config.Manager;

type

  TFIToolkit = class sealed
    strict private
      FConfig : TConfigManager;
      FOptions : TCLIOptions;
    private
      procedure InitConfig;
      procedure InitOptions(const CmdLineOptions : TStringDynArray);
    public
      class procedure PrintAbout;

      constructor Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
      destructor Destroy; override;

      procedure Run;
  end;

{ Utils }

procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
begin
  TFIToolkit.PrintAbout;

  with TFIToolkit.Create(FullExePath, CmdLineOptions) do
    try
      Run;
    finally
      Free;
    end;
end;

{ TFIToolkit }

constructor TFIToolkit.Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
begin
  inherited Create;

  InitOptions(CmdLineOptions);
  InitConfig;
end;

destructor TFIToolkit.Destroy;
begin
  FreeAndNil(FConfig);
  FreeAndNil(FOptions);

  inherited Destroy;
end;

procedure TFIToolkit.InitConfig;
  var
    bHasGenerateConfigOption : Boolean;
    SetConfigOption : TCLIOption;
begin
  bHasGenerateConfigOption := FOptions.Contains(STR_CLI_OPTION_GENERATE_CONFIG);

  if FOptions.Find(STR_CLI_OPTION_SET_CONFIG, SetConfigOption) and
     TPath.IsApplicableFileName(SetConfigOption.Value) and
     (TFile.Exists(SetConfigOption.Value) or bHasGenerateConfigOption)
  then
    FConfig := TConfigManager.Create(SetConfigOption.Value, bHasGenerateConfigOption, True)
  else
    raise ENoConfigSpecified.Create;
end;

procedure TFIToolkit.InitOptions(const CmdLineOptions : TStringDynArray);
  var
    S : String;
begin
  FOptions := TCLIOptions.Create;

  for S in CmdLineOptions do
    FOptions.Add(S);
end;

class procedure TFIToolkit.PrintAbout;
begin
  Writeln(SApplicationAbout);
end;

procedure TFIToolkit.Run;
begin
  if FOptions.Contains(STR_CLI_OPTION_GENERATE_CONFIG) and TFile.Exists(FConfig.ConfigFileName) then
  begin
    Writeln(SConfigWasGenerated);
    Writeln(FConfig.ConfigFileName);
    Writeln(SEditConfigManually);
    Exit;
  end;
end;

end.
