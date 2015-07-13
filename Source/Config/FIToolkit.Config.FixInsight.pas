unit FIToolkit.Config.FixInsight;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Config.Types, FIToolkit.Config.Defaults;

type

  TFixInsightOptions = class sealed
    strict private
      FCompilerDefines : TStringDynArray;
      FOutputFileName : TFileName;
      FOutputFormat : TFixInsightOutputFormat;
      FProjectFileName : TFileName;
      FSettingsFileName : TFileName;
      FValidate : Boolean;
    private
      function  FormatCompilerDefines : String;
      function  FormatOutputFileName : String;
      function  FormatOutputFormat : String;
      function  FormatProjectFileName : String;
      function  FormatSettingsFileName : String;

      procedure SetOutputFileName(const Value : TFileName);
      procedure SetProjectFileName(const Value : TFileName);
      procedure SetSettingsFileName(const Value : TFileName);

      procedure ValidateOutputFileName(const Value : TFileName);
      procedure ValidateProjectFileName(const Value : TFileName);
      procedure ValidateSettingsFileName(const Value : TFileName);
    public
      function  ToString : String; override;

      [FixInsightParam]
      property CompilerDefines : TStringDynArray read FCompilerDefines write FCompilerDefines;
      [FixInsightParam]
      property OutputFileName : TFileName read FOutputFileName write SetOutputFileName;
      [FixInsightParam]
      property OutputFormat : TFixInsightOutputFormat read FOutputFormat write FOutputFormat;
      [FixInsightParam]
      property ProjectFileName : TFileName read FProjectFileName write SetProjectFileName;
      [FixInsightParam]
      property SettingsFileName : TFileName read FSettingsFileName write SetSettingsFileName;

      property Validate : Boolean read FValidate write FValidate;
  end;

implementation

uses
  System.IOUtils,
  FIToolkit.Config.Exceptions, FIToolkit.Config.Consts;

{ TFixInsightOptions }

function TFixInsightOptions.FormatCompilerDefines : String;
  var
    S : String;
begin
  Result := String.Empty;

  if Length(FCompilerDefines) > 0 then
  begin
    for S in FCompilerDefines do
      if String.IsNullOrEmpty(Result) then
        Result := S
      else
        Result := Concat(Result, STR_FIPARAM_VALUES_DELIM, S);

    Result := STR_FIPARAM_DEFINES + Result;
  end;
end;

function TFixInsightOptions.FormatOutputFileName : String;
begin
  Result := STR_FIPARAM_OUTPUT + FOutputFileName;
end;

function TFixInsightOptions.FormatOutputFormat : String;
begin
  case FOutputFormat of
    fiofPlainText:
      Result := String.Empty;
    fiofXML:
      Result := STR_FIPARAM_XML;
  else
    Result := String.Empty;
  end;
end;

function TFixInsightOptions.ToString : String;
begin
  if FValidate then
  begin
    ValidateOutputFileName(FOutputFileName);
    ValidateProjectFileName(FProjectFileName);
    ValidateSettingsFileName(FSettingsFileName);
  end;

  Result := Trim(Format('%s %s %s %s %s',
    [FormatProjectFileName, FormatCompilerDefines, FormatOutputFileName, FormatSettingsFileName, FormatOutputFormat]));
end;

function TFixInsightOptions.FormatProjectFileName : String;
begin
  Result := STR_FIPARAM_PROJECT + FProjectFileName;
end;

function TFixInsightOptions.FormatSettingsFileName : String;
begin
  Result := STR_FIPARAM_SETTINGS + FSettingsFileName;
end;

procedure TFixInsightOptions.SetOutputFileName(const Value : TFileName);
begin
  if FOutputFileName <> Value then
  begin
    if FValidate then
      ValidateOutputFileName(Value);

    FOutputFileName := Value;
  end;
end;

procedure TFixInsightOptions.SetProjectFileName(const Value : TFileName);
begin
  if FProjectFileName <> Value then
  begin
    if FValidate then
      ValidateProjectFileName(Value);

    FProjectFileName := Value;
  end;
end;

procedure TFixInsightOptions.SetSettingsFileName(const Value : TFileName);
begin
  if FSettingsFileName <> Value then
  begin
    if FValidate then
      ValidateSettingsFileName(Value);

    FSettingsFileName := Value;
  end;
end;

procedure TFixInsightOptions.ValidateOutputFileName(const Value : TFileName);
begin
  if String.IsNullOrWhiteSpace(Value) then
    raise EFIOEmptyOutputFileName.Create;

  if not TDirectory.Exists(ExtractFilePath(Value)) then
    raise EFIOOutputDirectoryNotFound.Create;

  if not TPath.HasValidFileNameChars(ExtractFileName(Value), False) then
    raise EFIOInvalidOutputFileName.Create;
end;

procedure TFixInsightOptions.ValidateProjectFileName(const Value : TFileName);
begin
  if not TFile.Exists(Value) then
    raise EFIOProjectFileNotFound.Create;
end;

procedure TFixInsightOptions.ValidateSettingsFileName(const Value : TFileName);
begin
  if not String.IsNullOrEmpty(Value) and not TFile.Exists(Value) then
    raise EFIOSettingsFileNotFound.Create;
end;

end.
