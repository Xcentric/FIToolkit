unit FIToolkit.Config.Data;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Commons.Types, FIToolkit.Config.FixInsight, FIToolkit.Config.Types, FIToolkit.Config.TypedDefaults,
  FIToolkit.Config.Consts;

type

  DefaultExcludeProjectPatterns = class (TDefaultStringArrayValue); //FI:C104
  DefaultExcludeUnitPatterns = class (TDefaultStringArrayValue);    //FI:C104
  DefaultFixInsightExe = class (TDefaultFileNameValue);             //FI:C104
  DefaultMakeArchive = class (TDefaultBooleanValue);                //FI:C104
  DefaultOutputDirectory = class (TDefaultStringValue);             //FI:C104
  DefaultOutputFileName = class (TDefaultStringValue);              //FI:C104
  DefaultTempDirectory = class (TDefaultStringValue);               //FI:C104
  DefaultUseBadExitCode = class (TDefaultBooleanValue);             //FI:C104

  TConfigData = class sealed
    strict private
      FCustomTemplateFileName : TAssignableFileName;
      FExcludeProjectPatterns : TStringDynArray;
      FExcludeUnitPatterns : TStringDynArray;
      FFixInsightExe : TAssignableFileName;
      FInputFileName : TAssignableFileName;
      FMakeArchive : Boolean;
      FOutputDirectory : TAssignableString;
      FOutputFileName : TAssignableString;
      FTempDirectory : TAssignableString;
      FUseBadExitCode : Boolean;
      FValidate : Boolean;

      FFixInsightOptions : TFixInsightOptions;
    private
      procedure ValidateCustomTemplateFileName(const Value : TFileName);
      procedure ValidateExcludeProjectPatterns(const Value : TStringDynArray);
      procedure ValidateExcludeUnitPatterns(const Value : TStringDynArray);
      procedure ValidateFixInsightExe(const Value : TFileName);
      procedure ValidateInputFileName(const Value : TFileName);
      procedure ValidateOutputDirectory(const Value : String);
      procedure ValidateOutputFileName(const Value : String);
      procedure ValidateTempDirectory(const Value : String);

      function  GetCustomTemplateFileName : TFileName;
      function  GetFixInsightExe : TFileName;
      function  GetInputFileName : TFileName;
      function  GetOutputDirectory : String;
      function  GetOutputFileName : String;
      function  GetTempDirectory : String;
      procedure SetCustomTemplateFileName(Value : TFileName);
      procedure SetExcludeProjectPatterns(const Value : TStringDynArray);
      procedure SetExcludeUnitPatterns(const Value : TStringDynArray);
      procedure SetFixInsightExe(Value : TFileName);
      procedure SetInputFileName(Value : TFileName);
      procedure SetOutputDirectory(Value : String);
      procedure SetOutputFileName(const Value : String);
      procedure SetTempDirectory(Value : String);
    public
      constructor Create;
      destructor Destroy; override;

      [FIToolkitParam]
      property CustomTemplateFileName : TFileName read GetCustomTemplateFileName write SetCustomTemplateFileName;
      [FIToolkitParam(STR_CFG_VALUE_ARR_DELIM_REGEX), DefaultExcludeProjectPatterns]
      property ExcludeProjectPatterns : TStringDynArray read FExcludeProjectPatterns write SetExcludeProjectPatterns;
      [FIToolkitParam(STR_CFG_VALUE_ARR_DELIM_REGEX), DefaultExcludeUnitPatterns]
      property ExcludeUnitPatterns : TStringDynArray read FExcludeUnitPatterns write SetExcludeUnitPatterns;
      [FIToolkitParam, DefaultFixInsightExe]
      property FixInsightExe : TFileName read GetFixInsightExe write SetFixInsightExe;
      [FIToolkitParam]
      property FixInsightOptions : TFixInsightOptions read FFixInsightOptions;
      [FIToolkitParam]
      property InputFileName : TFileName read GetInputFileName write SetInputFileName;
      [FIToolkitParam, DefaultMakeArchive(DEF_CD_BOOL_MAKE_ARCHIVE)]
      property MakeArchive : Boolean read FMakeArchive write FMakeArchive;
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
  System.IOUtils, System.Rtti, System.RegularExpressions,
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

function TConfigData.GetCustomTemplateFileName : TFileName;
begin
  Result := FCustomTemplateFileName;
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

procedure TConfigData.SetCustomTemplateFileName(Value : TFileName);
begin
  Value := TPath.ExpandIfNotExists(Value);

  if not FCustomTemplateFileName.Assigned or (FCustomTemplateFileName <> Value) then
  begin
    if FValidate then
      ValidateCustomTemplateFileName(Value);

    FCustomTemplateFileName := Value;
  end;
end;

procedure TConfigData.SetExcludeProjectPatterns(const Value : TStringDynArray);
begin
  if FValidate then
    ValidateExcludeProjectPatterns(Value);

  FExcludeProjectPatterns := Value;
end;

procedure TConfigData.SetExcludeUnitPatterns(const Value : TStringDynArray);
begin
  if FValidate then
    ValidateExcludeUnitPatterns(Value);

  FExcludeUnitPatterns := Value;
end;

procedure TConfigData.SetFixInsightExe(Value : TFileName);
begin
  Value := TPath.ExpandIfNotExists(Value);

  if not FFixInsightExe.Assigned or (FFixInsightExe <> Value) then
  begin
    if FValidate then
      ValidateFixInsightExe(Value);

    FFixInsightExe := Value;
  end;
end;

procedure TConfigData.SetInputFileName(Value : TFileName);
begin
  Value := TPath.ExpandIfNotExists(Value);

  if not FInputFileName.Assigned or (FInputFileName <> Value) then
  begin
    if FValidate then
      ValidateInputFileName(Value);

    FInputFileName := Value;
  end;
end;

procedure TConfigData.SetOutputDirectory(Value : String);
begin
  Value := TPath.ExpandIfNotExists(Value);

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

procedure TConfigData.SetTempDirectory(Value : String);
begin
  Value := TPath.ExpandIfNotExists(Value);

  if not FTempDirectory.Assigned or (TempDirectory <> Value) then
  begin
    if FValidate then
      ValidateTempDirectory(Value);

    FTempDirectory := Value;
  end;
end;

procedure TConfigData.ValidateCustomTemplateFileName(const Value : TFileName);
begin
  if not (Value.IsEmpty or TFile.Exists(Value)) then
    raise ECDCustomTemplateFileNotFound.Create;
end;

procedure TConfigData.ValidateExcludeProjectPatterns(const Value : TStringDynArray);
var
  S : String;
begin
  for S in Value do
    try
      TRegEx.Create(S, [roNotEmpty, roCompiled]);
    except
      Exception.RaiseOuterException(ECDInvalidExcludeProjectPattern.CreateFmt([S]));
    end;
end;

procedure TConfigData.ValidateExcludeUnitPatterns(const Value : TStringDynArray);
var
  S : String;
begin
  for S in Value do
    try
      TRegEx.Create(S, [roNotEmpty, roCompiled]);
    except
      Exception.RaiseOuterException(ECDInvalidExcludeUnitPattern.CreateFmt([S]));
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
  RegisterDefaultValue(DefaultExcludeProjectPatterns, TValue.From<TStringDynArray>(DEF_CD_ARR_EXCLUDE_PROJECT_PATTERNS));
  RegisterDefaultValue(DefaultExcludeUnitPatterns, TValue.From<TStringDynArray>(DEF_CD_ARR_EXCLUDE_UNIT_PATTERNS));
  RegisterDefaultValue(DefaultFixInsightExe, GetFixInsightExePath);
  RegisterDefaultValue(DefaultOutputDirectory, TPath.GetDocumentsPath);
  RegisterDefaultValue(DefaultTempDirectory, TPath.GetTempPath);

end.
