unit FIToolkit.Config.FixInsight;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Commons.Types, FIToolkit.Config.Types, FIToolkit.Config.TypedDefaults, FIToolkit.Config.Consts;

type

  DefaultCompilerDefines = class (TDefaultStringArrayValue);  //FI:C104
  DefaultOutputFileName = class (TDefaultFileNameValue);      //FI:C104
  DefaultOutputFormat = class (TDefaultOutputFormatValue);    //FI:C104
  DefaultSettingsFileName = class (TDefaultFileNameValue);    //FI:C104
  DefaultSilent = class (TDefaultBooleanValue);               //FI:C104

  TFixInsightOptions = class sealed
    strict private
      FCompilerDefines : TStringDynArray;
      FOutputFileName : TAssignableFileName;
      FOutputFormat : TFixInsightOutputFormat;
      FProjectFileName : TAssignableFileName;
      FSettingsFileName : TAssignableFileName;
      FSilent : Boolean;
      FValidate : Boolean;
    private
      function  FormatCompilerDefines : String;
      function  FormatOutputFileName : String;
      function  FormatOutputFormat : String;
      function  FormatProjectFileName : String;
      function  FormatSettingsFileName : String;
      function  FormatSilent : String;

      procedure ValidateOutputFileName(const Value : TFileName);
      procedure ValidateProjectFileName(const Value : TFileName);
      procedure ValidateSettingsFileName(const Value : TFileName);

      function  GetOutputFileName : TFileName;
      function  GetProjectFileName : TFileName;
      function  GetSettingsFileName : TFileName;
      procedure SetOutputFileName(const Value : TFileName);
      procedure SetProjectFileName(const Value : TFileName);
      procedure SetSettingsFileName(const Value : TFileName);
    public
      procedure Assign(Source : TFixInsightOptions; CheckValid : Boolean);
      function  ToString : String; override; final;

      [FixInsightParam, DefaultCompilerDefines]
      property CompilerDefines : TStringDynArray read FCompilerDefines write FCompilerDefines;
      [FixInsightParam(False), DefaultOutputFileName(DEF_FIO_STR_OUTPUT_FILENAME)]
      property OutputFileName : TFileName read GetOutputFileName write SetOutputFileName;
      [FixInsightParam(False), DefaultOutputFormat(DEF_FIO_ENUM_OUTPUT_FORMAT)]
      property OutputFormat : TFixInsightOutputFormat read FOutputFormat write FOutputFormat;
      [FixInsightParam(False)]
      property ProjectFileName : TFileName read GetProjectFileName write SetProjectFileName;
      [FixInsightParam, DefaultSettingsFileName]
      property SettingsFileName : TFileName read GetSettingsFileName write SetSettingsFileName;
      [FixInsightParam(False), DefaultSilent(DEF_FIO_BOOL_SILENT)]
      property Silent : Boolean read FSilent write FSilent;

      property Validate : Boolean read FValidate write FValidate;
  end;

implementation

uses
  System.IOUtils, System.Rtti,
  FIToolkit.Config.Exceptions, FIToolkit.Config.Defaults, FIToolkit.Commons.Utils, FIToolkit.CommandLine.Types;

{ TFixInsightOptions }

procedure TFixInsightOptions.Assign(Source : TFixInsightOptions; CheckValid : Boolean);
var
  bValidate : Boolean;
begin
  if Assigned(Source) then
  begin
    bValidate := FValidate;
    FValidate := CheckValid;
    try
      TObjectProperties<TFixInsightOptions>.Copy(Source, Self,
        function (Instance : TObject; Prop : TRttiProperty) : Boolean
        var
          Attr : TCustomAttribute;
        begin
          Result := False;

          for Attr in Prop.GetAttributes do
            if Attr is FixInsightParam then
              Exit(True);
        end
      );
    finally
      FValidate := bValidate;
    end;
  end;
end;

function TFixInsightOptions.FormatCompilerDefines : String;
begin
  Result := String.Join(STR_FIPARAM_VALUES_DELIM, FCompilerDefines);

  if not Result.IsEmpty then
    Result := STR_FIPARAM_DEFINES + Result;
end;

function TFixInsightOptions.FormatOutputFileName : String;
begin
  Result := STR_FIPARAM_OUTPUT + TPath.GetQuotedPath(FOutputFileName, TCLIOptionString.CHR_QUOTE);
end;

function TFixInsightOptions.FormatOutputFormat : String;
begin
  Result := String.Empty;

  case FOutputFormat of
    fiofPlainText:
      Result := String.Empty;
    fiofXML:
      Result := STR_FIPARAM_XML;
  else
    Assert(False, 'Unhandled FixInsight output format type while converting to string.');
  end;
end;

function TFixInsightOptions.FormatProjectFileName : String;
begin
  Result := STR_FIPARAM_PROJECT + TPath.GetQuotedPath(FProjectFileName, TCLIOptionString.CHR_QUOTE);
end;

function TFixInsightOptions.FormatSettingsFileName : String;
begin
  if String(FSettingsFileName).IsEmpty then
    Result := String.Empty
  else
    Result := STR_FIPARAM_SETTINGS + TPath.GetQuotedPath(FSettingsFileName, TCLIOptionString.CHR_QUOTE);
end;

function TFixInsightOptions.FormatSilent : String;
begin
  Result := Iff.Get<String>(FSilent, STR_FIPARAM_SILENT, String.Empty);
end;

function TFixInsightOptions.GetOutputFileName : TFileName;
begin
  Result := FOutputFileName;
end;

function TFixInsightOptions.GetProjectFileName : TFileName;
begin
  Result := FProjectFileName;
end;

function TFixInsightOptions.GetSettingsFileName : TFileName;
begin
  Result := FSettingsFileName;
end;

procedure TFixInsightOptions.SetOutputFileName(const Value : TFileName);
begin
  if not FOutputFileName.Assigned or (FOutputFileName <> Value) then
  begin
    if FValidate then
      ValidateOutputFileName(Value);

    FOutputFileName := Value;
  end;
end;

procedure TFixInsightOptions.SetProjectFileName(const Value : TFileName);
begin
  if not FProjectFileName.Assigned or (FProjectFileName <> Value) then
  begin
    if FValidate then
      ValidateProjectFileName(Value);

    FProjectFileName := Value;
  end;
end;

procedure TFixInsightOptions.SetSettingsFileName(const Value : TFileName);
begin
  if not FSettingsFileName.Assigned or (FSettingsFileName <> Value) then
  begin
    if FValidate then
      ValidateSettingsFileName(Value);

    FSettingsFileName := Value;
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

  Result := Trim(Format('%s %s %s %s %s %s',
    [FormatProjectFileName, FormatCompilerDefines, FormatSettingsFileName,
     FormatOutputFileName, FormatOutputFormat, FormatSilent]));
end;

procedure TFixInsightOptions.ValidateOutputFileName(const Value : TFileName);
begin
  if String.IsNullOrWhiteSpace(Value) then
    raise EFIOEmptyOutputFileName.Create;

  if not TDirectory.Exists(ExtractFilePath(Value)) then
    raise EFIOOutputDirectoryNotFound.Create;

  if not TPath.IsApplicableFileName(ExtractFileName(Value)) then
    raise EFIOInvalidOutputFileName.Create;
end;

procedure TFixInsightOptions.ValidateProjectFileName(const Value : TFileName);
begin
  if not TFile.Exists(Value) then
    raise EFIOProjectFileNotFound.Create;
end;

procedure TFixInsightOptions.ValidateSettingsFileName(const Value : TFileName);
begin
  if not (Value.IsEmpty or TFile.Exists(Value)) then
    raise EFIOSettingsFileNotFound.Create;
end;

initialization
  RegisterDefaultValue(DefaultCompilerDefines, TValue.From<TStringDynArray>(DEF_FIO_ARR_COMPILER_DEFINES));
  RegisterDefaultValue(DefaultSettingsFileName, TPath.GetExePath + DEF_FIO_STR_SETTINGS_FILENAME);

end.
