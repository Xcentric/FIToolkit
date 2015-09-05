unit FIToolkit.Config.Data;

interface

uses
  System.SysUtils,
  FIToolkit.Config.FixInsight, FIToolkit.Config.Types, FIToolkit.Config.TypedDefaults, FIToolkit.Config.Consts;

type

  DefaultOutputDirectory = class (TDefaultStringValue);
  DefaultOutputFileName = class (TDefaultStringValue);
  DefaultTempDirectory = class (TDefaultStringValue);

  TConfigData = class
    strict private
      FFixInsightExe : TFileName;
      FInputFileName : TFileName;
      FOutputDirectory : String;
      FOutputFileName : String;
      FTempDirectory : String;
      FValidate : Boolean;

      FFixInsightOptions : TFixInsightOptions;
    private
      procedure SetFixInsightExe(const Value : TFileName);
      procedure SetInputFileName(const Value : TFileName);
      procedure SetOutputDirectory(const Value : String);
      procedure SetOutputFileName(const Value : String);
      procedure SetTempDirectory(const Value : String);

      procedure ValidateFixInsightExe(const Value : TFileName);
      procedure ValidateInputFileName(const Value : TFileName);
      procedure ValidateOutputDirectory(const Value : String);
      procedure ValidateOutputFileName(const Value : String);
      procedure ValidateTempDirectory(const Value : String);
    public
      constructor Create;
      destructor Destroy; override;

      [FIToolkitParam]
      property FixInsightExe : TFileName read FFixInsightExe write SetFixInsightExe;
      [FIToolkitParam]
      property FixInsightOptions : TFixInsightOptions read FFixInsightOptions;
      [FIToolkitParam]
      property InputFileName : TFileName read FInputFileName write SetInputFileName;
      [FIToolkitParam, DefaultOutputDirectory]
      property OutputDirectory : String read FOutputDirectory write SetOutputDirectory;
      [FIToolkitParam, DefaultOutputFileName(DEF_CD_STR_OUTPUT_FILENAME)]
      property OutputFileName : String read FOutputFileName write SetOutputFileName;
      [FIToolkitParam, DefaultTempDirectory]
      property TempDirectory : String read FTempDirectory write SetTempDirectory;

      property Validate : Boolean read FValidate write FValidate;
  end;

implementation

uses
  System.IOUtils, System.Rtti,
  FIToolkit.Config.Exceptions, FIToolkit.Config.Defaults;

{ TConfigData }

constructor TConfigData.Create;
begin
  inherited Create;

  FFixInsightOptions := TFixInsightOptions.Create;
end;

destructor TConfigData.Destroy;
begin
  FreeAndNil(FFixInsightOptions);

  inherited Destroy;
end;

procedure TConfigData.SetFixInsightExe(const Value : TFileName);
begin
  if FFixInsightExe <> Value then
  begin
    if FValidate then
      ValidateFixInsightExe(Value);

    FFixInsightExe := Value;
  end;
end;

procedure TConfigData.SetInputFileName(const Value : TFileName);
begin
  if FInputFileName <> Value then
  begin
    if FValidate then
      ValidateInputFileName(Value);

    FInputFileName := Value;
  end;
end;

procedure TConfigData.SetOutputDirectory(const Value : String);
begin
  if FOutputDirectory <> Value then
  begin
    if FValidate then
      ValidateOutputDirectory(Value);

    FOutputDirectory := Value;
  end;
end;

procedure TConfigData.SetOutputFileName(const Value : String);
begin
  if FOutputFileName <> Value then
  begin
    if FValidate then
      ValidateOutputFileName(Value);

    FOutputFileName := Value;
  end;
end;

procedure TConfigData.SetTempDirectory(const Value : String);
begin
  if FTempDirectory <> Value then
  begin
    if FValidate then
      ValidateTempDirectory(Value);

    FTempDirectory := Value;
  end;
end;

procedure TConfigData.ValidateFixInsightExe(const Value : TFileName);
begin
  if not TFile.Exists(Value) then
    raise ECDFixInsightExeNotFound.Create;
end;

procedure TConfigData.ValidateInputFileName(const Value : TFileName);
begin
  if not TFile.Exists(Value) then
    raise ECDInputFileNotFound.Create;
end;

procedure TConfigData.ValidateOutputDirectory(const Value : String);
begin
  if not TDirectory.Exists(Value) then
    raise ECDOutputDirectoryNotFound.Create;
end;

procedure TConfigData.ValidateOutputFileName(const Value : String);
begin
  if not TPath.HasValidFileNameChars(Value, False) then
    raise ECDInvalidOutputFileName.Create;
end;

procedure TConfigData.ValidateTempDirectory(const Value : String);
begin
  if not TDirectory.Exists(Value) then
    raise ECDTempDirectoryNotFound.Create;
end;

initialization
  RegisterDefaultValue(DefaultOutputDirectory,
    function : TValue
    begin
      Result := TPath.GetTempPath;
    end
  );
  RegisterDefaultValue(DefaultTempDirectory,
    function : TValue
    begin
      Result := TPath.GetTempPath;
    end
  );

end.
