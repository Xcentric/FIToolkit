unit FIToolkit.Config.Data;

interface

uses
  System.SysUtils,
  FIToolkit.Commons.Types, FIToolkit.Config.FixInsight, FIToolkit.Config.Types, FIToolkit.Config.TypedDefaults,
  FIToolkit.Config.Consts;

type

  DefaultFixInsightExe = class (TDefaultFileNameValue); //FI:C104
  DefaultOutputDirectory = class (TDefaultStringValue); //FI:C104
  DefaultOutputFileName = class (TDefaultStringValue);  //FI:C104
  DefaultTempDirectory = class (TDefaultStringValue);   //FI:C104
  DefaultUseBadExitCode = class (TDefaultBooleanValue); //FI:C104

  TConfigData = class sealed
    strict private
      FFixInsightExe : TAssignableFileName;
      FInputFileName : TAssignableFileName;
      FOutputDirectory : TAssignableString;
      FOutputFileName : TAssignableString;
      FTempDirectory : TAssignableString;
      FUseBadExitCode : Boolean;
      FValidate : Boolean;

      FFixInsightOptions : TFixInsightOptions;
    private
      procedure ValidateFixInsightExe(const Value : TFileName);
      procedure ValidateInputFileName(const Value : TFileName);
      procedure ValidateOutputDirectory(const Value : String);
      procedure ValidateOutputFileName(const Value : String);
      procedure ValidateTempDirectory(const Value : String);

      function  GetFixInsightExe : TFileName;
      function  GetInputFileName : TFileName;
      function  GetOutputDirectory : String;
      function  GetOutputFileName : String;
      function  GetTempDirectory : String;
      procedure SetFixInsightExe(const Value : TFileName);
      procedure SetInputFileName(const Value : TFileName);
      procedure SetOutputDirectory(const Value : String);
      procedure SetOutputFileName(const Value : String);
      procedure SetTempDirectory(const Value : String);
    public
      constructor Create;
      destructor Destroy; override;

      [FIToolkitParam, DefaultFixInsightExe]
      property FixInsightExe : TFileName read GetFixInsightExe write SetFixInsightExe;
      [FIToolkitParam]
      property FixInsightOptions : TFixInsightOptions read FFixInsightOptions;
      [FIToolkitParam]
      property InputFileName : TFileName read GetInputFileName write SetInputFileName;
      [FIToolkitParam, DefaultOutputDirectory]
      property OutputDirectory : String read GetOutputDirectory write SetOutputDirectory;
      [FIToolkitParam, DefaultOutputFileName(DEF_CD_STR_OUTPUT_FILENAME)]
      property OutputFileName : String read GetOutputFileName write SetOutputFileName;
      [FIToolkitParam, DefaultTempDirectory]
      property TempDirectory : String read GetTempDirectory write SetTempDirectory;
      [FIToolkitParam, DefaultUseBadExitCode(DEF_CD_BOOL_USE_BAD_EXIT_CODE)]
      property UseBadExitCode : Boolean read FUseBadExitCode write FUseBadExitCode;

      property Validate : Boolean read FValidate write FValidate;
  end;

implementation

uses
  System.IOUtils, System.Rtti,
  FIToolkit.Config.Exceptions, FIToolkit.Config.Defaults, FIToolkit.Commons.Utils;

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

function TConfigData.GetFixInsightExe : TFileName;
begin
  Result := FFixInsightExe;
end;

function TConfigData.GetInputFileName : TFileName;
begin
  Result := FInputFileName;
end;

function TConfigData.GetOutputDirectory : String;
begin
  Result := TPath.IncludeTrailingPathDelimiter(FOutputDirectory);
end;

function TConfigData.GetOutputFileName : String;
begin
  Result := FOutputFileName;
end;

function TConfigData.GetTempDirectory : String;
begin
  Result := TPath.IncludeTrailingPathDelimiter(FTempDirectory);
end;

procedure TConfigData.SetFixInsightExe(const Value : TFileName);
begin
  if not FFixInsightExe.Assigned or (FFixInsightExe <> Value) then
  begin
    if FValidate then
      ValidateFixInsightExe(Value);

    FFixInsightExe := Value;
  end;
end;

procedure TConfigData.SetInputFileName(const Value : TFileName);
begin
  if not FInputFileName.Assigned or (FInputFileName <> Value) then
  begin
    if FValidate then
      ValidateInputFileName(Value);

    FInputFileName := Value;
  end;
end;

procedure TConfigData.SetOutputDirectory(const Value : String);
begin
  if not FOutputDirectory.Assigned or (FOutputDirectory <> Value) then
  begin
    if FValidate then
      ValidateOutputDirectory(Value);

    FOutputDirectory := Value;
  end;
end;

procedure TConfigData.SetOutputFileName(const Value : String);
begin
  if not FOutputFileName.Assigned or (FOutputFileName <> Value) then
  begin
    if FValidate then
      ValidateOutputFileName(Value);

    FOutputFileName := Value;
  end;
end;

procedure TConfigData.SetTempDirectory(const Value : String);
begin
  if not FTempDirectory.Assigned or (TempDirectory <> Value) then
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
  if not TPath.IsApplicableFileName(Value) then
    raise ECDInvalidOutputFileName.Create;
end;

procedure TConfigData.ValidateTempDirectory(const Value : String);
begin
  if not TDirectory.Exists(Value) then
    raise ECDTempDirectoryNotFound.Create;
end;

initialization
  RegisterDefaultValue(DefaultFixInsightExe, GetFixInsightExePath);
  RegisterDefaultValue(DefaultOutputDirectory, TPath.GetDocumentsPath);
  RegisterDefaultValue(DefaultTempDirectory, TPath.GetTempPath);

end.
