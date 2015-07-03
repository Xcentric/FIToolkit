unit Config.Manager;

interface

uses
  System.SysUtils,
  Config.Data, Config.ConfigFile;

type

  TConfigManager = class
    strict private
      FConfigData : TConfigData;
      FConfigFile : TConfigFile;
    protected
      procedure FillDataFromFile;
    public
      constructor Create(const ConfigFileName : TFileName);
      destructor Destroy; override;

      property ConfigData : TConfigData read FConfigData;
  end;

implementation

{ TConfigManager }

constructor TConfigManager.Create(const ConfigFileName : TFileName);
begin
  inherited Create;

  FConfigData := TConfigData.Create;
  FConfigData.Validate := True;
  FConfigData.FixInsightOptions.Validate := True;

  FConfigFile := TConfigFile.Create(ConfigFileName);
end;

destructor TConfigManager.Destroy;
begin
  FreeAndNil(FConfigData);
  FreeAndNil(FConfigFile);

  inherited Destroy;
end;

procedure TConfigManager.FillDataFromFile;
begin
  //TODO: fill FConfigData with appropriate values from FConfigFile.Config
end;

end.
