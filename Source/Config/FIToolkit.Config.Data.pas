unit FIToolkit.Config.Data;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Commons.Types, FIToolkit.Config.FixInsight, FIToolkit.Config.Types, FIToolkit.Config.TypedDefaults,
  FIToolkit.Config.Consts;

type

  DefaultDeduplicate = class (TDefaultBooleanValue);                //FI:C104
  DefaultExcludeProjectPatterns = class (TDefaultStringArrayValue); //FI:C104
  DefaultExcludeUnitPatterns = class (TDefaultStringArrayValue);    //FI:C104
  DefaultFixInsightExe = class (TDefaultFileNameValue);             //FI:C104
  DefaultMakeArchive = class (TDefaultBooleanValue);                //FI:C104
  DefaultNonZeroExitCodeMsgCount = class (TDefaultIntegerValue);    //FI:C104
  DefaultOutputDirectory = class (TDefaultStringValue);             //FI:C104
  DefaultOutputFileName = class (TDefaultStringValue);              //FI:C104
  DefaultSnippetSize = class (TDefaultIntegerValue);                //FI:C104
  DefaultTempDirectory = class (TDefaultStringValue);               //FI:C104

  TConfigData = class sealed
    strict private
      FCustomTemplateFileName : TAssignableFileName;
      FDeduplicate : Boolean;
      FExcludeProjectPatterns : TStringDynArray;
      FExcludeUnitPatterns : TStringDynArray;
      FFixInsightExe : TAssignableFileName;
      FInputFileName : TAssignableFileName;
      FMakeArchive : Boolean;
      FNonZeroExitCodeMsgCount : Integer;
      FOutputDirectory : TAssignableString;
      FOutputFileName : TAssignableString;
      FSnippetSize : Integer;
      FTempDirectory : TAssignableString;
      FValidate : Boolean;

      FFixInsightOptions : TFixInsightOptions;
    private
      procedure ValidateCustomTemplateFileName(const Value : TFileName);
      procedure ValidateExcludeProjectPatterns(const Value : TStringDynArray);
      procedure ValidateExcludeUnitPatterns(const Value : TStringDynArray);
      procedure ValidateFixInsightExe(const Value : TFileName);
      procedure ValidateInputFileName(const Value : TFileName);
      procedure ValidateNonZeroExitCodeMsgCount(Value : Integer);
      procedure ValidateOutputDirectory(const Value : String);
      procedure ValidateOutputFileName(const Value : String);
      procedure ValidateSnippetSize(Value : Integer);
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
      procedure SetNonZeroExitCodeMsgCount(Value : Integer);
      procedure SetOutputDirectory(Value : String);
      procedure SetOutputFileName(const Value : String);
      procedure SetSnippetSize(Value : Integer);
      procedure SetTempDirectory(Value : String);
    public
      constructor Create;
      destructor Destroy; override;

      [FIToolkitParam]
      property CustomTemplateFileName : TFileName read GetCustomTemplateFileName write SetCustomTemplateFileName;
      [FIToolkitParam, DefaultDeduplicate(DEF_CD_BOOL_DEDUPLICATE)]
      property Deduplicate : Boolean read FDeduplicate write FDeduplicate;
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
      [FIToolkitParam, DefaultNonZeroExitCodeMsgCount(DEF_CD_INT_NONZERO_EXIT_CODE_MSG_COUNT)]
      property NonZeroExitCodeMsgCount : Integer read FNonZeroExitCodeMsgCount write SetNonZeroExitCodeMsgCount;
      [FIToolkitParam, DefaultOutputDirectory]
      property OutputDirectory : String read GetOutputDirectory write SetOutputDirectory;
      [FIToolkitParam, DefaultOutputFileName(DEF_CD_STR_OUTPUT_FILENAME)]
      property OutputFileName : String read GetOutputFileName write SetOutputFileName;
      [FIToolkitParam, DefaultSnippetSize(DEF_CD_INT_SNIPPET_SIZE)]
      property SnippetSize : Integer read FSnippetSize write SetSnippetSize;
      [FIToolkitParam, DefaultTempDirectory]
      property TempDirectory : String read GetTempDirectory write SetTempDirectory;

      property Validate : Boolean read FValidate write FValidate;
  end;

implementation

uses
  System.IOUtils, System.Rtti, System.RegularExpressions, System.Math,
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

procedure TConfigData.SetNonZeroExitCodeMsgCount(Value : Integer);
begin
  if FValidate then
    ValidateNonZeroExitCodeMsgCount(Value);

  FNonZeroExitCodeMsgCount := Value;
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

procedure TConfigData.SetSnippetSize(Value : Integer);
begin
  if FValidate then
    ValidateSnippetSize(Value);

  FSnippetSize := Value;
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

procedure TConfigData.ValidateNonZeroExitCodeMsgCount(Value : Integer);
begin
  if Value < 0 then
    raise ECDInvalidNonZeroExitCodeMsgCount.Create;
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

procedure TConfigData.ValidateSnippetSize(Value : Integer);
begin
  if (Value <> 0) and not InRange(Value, CD_INT_SNIPPET_SIZE_MIN, CD_INT_SNIPPET_SIZE_MAX) then
    raise ECDSnippetSizeOutOfRange.CreateFmt([CD_INT_SNIPPET_SIZE_MIN, CD_INT_SNIPPET_SIZE_MAX]);
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
