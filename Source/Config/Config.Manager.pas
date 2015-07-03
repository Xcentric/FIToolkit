unit Config.Manager;

interface

uses
  System.SysUtils,
  Config.Data;

type

  TConfigManager = class
    strict private
      FConfigData : TConfigData;
    public
      constructor Create;
      destructor Destroy; override;

      property ConfigData : TConfigData read FConfigData;
  end;

implementation

{ TConfigManager }

constructor TConfigManager.Create;
begin
  inherited Create;

  FConfigData := TConfigData.Create;
  FConfigData.Validate := True;
  FConfigData.FixInsightOptions.Validate := True;
end;

destructor TConfigManager.Destroy;
begin
  FreeAndNil(FConfigData);

  inherited Destroy;
end;

end.
