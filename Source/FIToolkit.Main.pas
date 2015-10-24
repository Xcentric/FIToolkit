unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);

implementation

uses
  System.IOUtils,
  FIToolkit.Exceptions,
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
      constructor Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
      destructor Destroy; override;

      procedure Run;
  end;

{ Utils }

procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
  var
    FIToolkit : TFIToolkit;
begin
  FIToolkit := TFIToolkit.Create(FullExePath, CmdLineOptions);
  try
    FIToolkit.Run;
  finally
    FIToolkit.Free;
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
    SetConfigOption : TCLIOption;
begin
  if FOptions.Find(STR_CLI_OPTION_SET_CONFIG, SetConfigOption) and
     TPath.IsApplicableFileName(SetConfigOption.Value)
  then
    FConfig := TConfigManager.Create(SetConfigOption.Value, FOptions.Contains(STR_CLI_OPTION_GENERATE_CONFIG), True)
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

procedure TFIToolkit.Run;
begin
  //
end;

end.
