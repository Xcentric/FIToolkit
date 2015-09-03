unit Test_FIToolkit.Config.FixInsight;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework,
  FIToolkit.Config.FixInsight;

type
  // Test methods for class TFixInsightOptions

  TestTFixInsightOptions = class(TTestCase)
  strict private
    FFixInsightOptions: TFixInsightOptions;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestToString;
    procedure TestValidationWithInvalidProps;
    procedure TestValidationWithValidProps;
  end;

implementation

uses
  System.SysUtils, System.Types,
  TestConsts,
  FIToolkit.Config.Exceptions, FIToolkit.Config.Types, FIToolkit.Config.Consts;

procedure TestTFixInsightOptions.SetUp;
begin
  FFixInsightOptions := TFixInsightOptions.Create;
end;

procedure TestTFixInsightOptions.TearDown;
begin
  FreeAndNil(FFixInsightOptions);
end;

procedure TestTFixInsightOptions.TestToString;
  const
    STR_DEFINE1 = 'DEFINE1';
    STR_DEFINE2 = 'DEFINE2';
    STR_EXPECTED_RESULT =
      STR_FIPARAM_PROJECT + STR_NON_EXISTENT_FILE + ' ' +
      STR_FIPARAM_DEFINES + STR_DEFINE1 + STR_FIPARAM_VALUES_DELIM + STR_DEFINE2 + ' ' +
      STR_FIPARAM_OUTPUT + STR_NON_EXISTENT_FILE + ' ' +
      STR_FIPARAM_SETTINGS + STR_NON_EXISTENT_FILE + ' ' +
      STR_FIPARAM_XML;
  var
    Defines : TStringDynArray;
    ReturnValue : String;
    bWasException : Boolean;
begin
  SetLength(Defines, 2);
  Defines[0] := STR_DEFINE1;
  Defines[1] := STR_DEFINE2;

  with FFixInsightOptions do
  begin
    Validate := False;
    ProjectFileName := STR_NON_EXISTENT_FILE;
    CompilerDefines := Defines;
    OutputFileName := STR_NON_EXISTENT_FILE;
    SettingsFileName := STR_NON_EXISTENT_FILE;
    OutputFormat := fiofXML;
  end;

  { Check string format }

  ReturnValue := FFixInsightOptions.ToString;
  CheckEquals(STR_EXPECTED_RESULT, ReturnValue, 'ReturnValue = STR_EXPECTED_RESULT');

  { Check validation within method call }

  FFixInsightOptions.Validate := True;
  bWasException := False;
  try
    ReturnValue := FFixInsightOptions.ToString;
  except
    on E:Exception do
    begin
      bWasException := True;
      CheckTrue(E.InheritsFrom(EFixInsightOptionsException), 'E.InheritsFrom(EFixInsightOptionsException)');
    end;
  end;
  CheckTrue(bWasException, 'ToString::bWasException');
end;

procedure TestTFixInsightOptions.TestValidationWithInvalidProps;
  var
    bWasException : Boolean;
begin
  FFixInsightOptions.Validate := True;

  { Check validation - invalid project file name }

  bWasException := False;
  try
    FFixInsightOptions.ProjectFileName := STR_NON_EXISTENT_FILE;
  except
    on E:Exception do
    begin
      bWasException := True;
      CheckTrue(E.InheritsFrom(EFIOProjectFileNotFound), 'E.InheritsFrom(EFIOProjectFileNotFound)');
    end;
  end;
  CheckTrue(bWasException, 'ProjectFileName::bWasException');

  { Check validation - empty output file name }

  bWasException := False;
  try
    FFixInsightOptions.OutputFileName := ParamStr(0);
    FFixInsightOptions.OutputFileName := String.Empty;
  except
    on E:Exception do
    begin
      bWasException := True;
      CheckTrue(E.InheritsFrom(EFIOEmptyOutputFileName), 'E.InheritsFrom(EFIOEmptyOutputFileName)');
    end;
  end;
  CheckTrue(bWasException, 'OutputFileName::bWasException');

  { Check validation - nonexistent output directory }

  bWasException := False;
  try
    FFixInsightOptions.OutputFileName := STR_NON_EXISTENT_DIR + ExtractFileName(ParamStr(0));
  except
    on E:Exception do
    begin
      bWasException := True;
      CheckTrue(E.InheritsFrom(EFIOOutputDirectoryNotFound), 'E.InheritsFrom(EFIOOutputDirectoryNotFound)');
    end;
  end;
  CheckTrue(bWasException, 'OutputFileName::bWasException');

  { Check validation - invalid output file name }

  bWasException := False;
  try
    FFixInsightOptions.OutputFileName := ExtractFilePath(ParamStr(0)) + STR_INVALID_FILENAME;
  except
    on E:Exception do
    begin
      bWasException := True;
      CheckTrue(E.InheritsFrom(EFIOInvalidOutputFileName), 'E.InheritsFrom(EFIOInvalidOutputFileName)');
    end;
  end;
  CheckTrue(bWasException, 'OutputFileName::bWasException');

  { Check validation - invalid settings file name }

  bWasException := False;
  try
    FFixInsightOptions.SettingsFileName := STR_NON_EXISTENT_FILE;
  except
    on E:Exception do
    begin
      bWasException := True;
      CheckTrue(E.InheritsFrom(EFIOSettingsFileNotFound), 'E.InheritsFrom(EFIOSettingsFileNotFound)');
    end;
  end;
  CheckTrue(bWasException, 'SettingsFileName::bWasException');
end;

procedure TestTFixInsightOptions.TestValidationWithValidProps;
  var
    bWasException : Boolean;
begin
  bWasException := False;
  try
    with FFixInsightOptions do
    begin
      Validate := True;
      CompilerDefines := nil;
      OutputFileName := ParamStr(0);
      OutputFormat := fiofPlainText;
      ProjectFileName := ParamStr(0);
      SettingsFileName := ParamStr(0);
      SettingsFileName := String.Empty;
    end;
  except
    bWasException := True;
  end;
  CheckFalse(bWasException, 'TestValidationWithValidProps::bWasException');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFixInsightOptions.Suite);
end.
