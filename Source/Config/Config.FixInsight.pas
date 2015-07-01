unit Config.FixInsight;

interface

uses
  System.SysUtils, System.Types;

type

  TFixInsightOutputFormat = (fiofPlainText, fiofXML);

  TFixInsightOptions = class sealed
    strict private
      FCompilerDefines : TStringDynArray;
      FOutputFileName : TFileName;
      FOutputFormat : TFixInsightOutputFormat;
      FProjectFileName : TFileName;
      FSettingsFileName : TFileName;
    private
      procedure SetOutputFileName(const Value : TFileName);
      procedure SetProjectFileName(const Value : TFileName);
      procedure SetSettingsFileName(const Value : TFileName);

      procedure ValidateOutputFileName(const Value : TFileName);
      procedure ValidateProjectFileName(const Value : TFileName);
      procedure ValidateSettingsFileName(const Value : TFileName);
    public
      property CompilerDefines : TStringDynArray read FCompilerDefines write FCompilerDefines;
      property OutputFileName : TFileName read FOutputFileName write SetOutputFileName;
      property OutputFormat : TFixInsightOutputFormat read FOutputFormat write FOutputFormat;
      property ProjectFileName : TFileName read FProjectFileName write SetProjectFileName;
      property SettingsFileName : TFileName read FSettingsFileName write SetSettingsFileName;
  end;

{
  --project=XXX.dpr (a project to analyze)
  --defines=XXX;YYY;ZZZ (compiler defines separated by semicolon)
  --output=XXX (write output to a file)
  --settings=XXX.ficfg (override project settings)
  --xml (format output as xml)
}

implementation

uses
  System.IOUtils,
  Config.Exceptions;

{ TFixInsightOptions }

procedure TFixInsightOptions.SetOutputFileName(const Value : TFileName);
begin
  if FOutputFileName <> Value then
  begin
    ValidateOutputFileName(Value);
    FOutputFileName := Value;
  end;
end;

procedure TFixInsightOptions.SetProjectFileName(const Value : TFileName);
begin
  if FProjectFileName <> Value then
  begin
    ValidateProjectFileName(Value);
    FProjectFileName := Value;
  end;
end;

procedure TFixInsightOptions.SetSettingsFileName(const Value : TFileName);
begin
  if FSettingsFileName <> Value then
  begin
    ValidateSettingsFileName(Value);
    FSettingsFileName := Value;
  end;
end;

procedure TFixInsightOptions.ValidateOutputFileName(const Value : TFileName);
begin
  if Value = EmptyStr then
    raise EEmptyOutputFileName.Create;

  if not TDirectory.Exists(ExtractFilePath(Value)) then
    raise ENonExistentOutputDirectory.Create;
end;

procedure TFixInsightOptions.ValidateProjectFileName(const Value : TFileName);
begin

end;

procedure TFixInsightOptions.ValidateSettingsFileName(const Value : TFileName);
begin

end;

end.
