﻿unit Test_FIToolkit.Config.Data;
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
  FIToolkit.Config.Data;

type
  // Test methods for class TConfigData

  TestTConfigData = class(TGenericTestCase)
  strict private
    FConfigData: TConfigData;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEmptyData;
    procedure TestInvalidData;
    procedure TestValidData;
  end;

implementation

uses
  System.SysUtils, System.IOUtils,
  TestUtils, TestConsts,
  FIToolkit.Config.Exceptions;

procedure TestTConfigData.SetUp;
begin
  FConfigData := TConfigData.Create;
end;

procedure TestTConfigData.TearDown;
begin
  FreeAndNil(FConfigData);
end;

procedure TestTConfigData.TestEmptyData;
begin
  FConfigData.Validate := True;

  { Check validation - empty custom template file name }

  CheckException(
    procedure
    begin
      FConfigData.CustomTemplateFileName := String.Empty;
    end,
    nil,
    'CheckException::<nil>'
  );

  { Check validation - empty exclude project regex }

  CheckException(
    procedure
    begin
      FConfigData.ExcludeProjectPatterns := [String.Empty];
    end,
    ECDInvalidExcludeProjectPattern,
    'CheckException::ECDInvalidExcludeProjectPattern'
  );

  { Check validation - empty FixInsight executable path }

  CheckException(
    procedure
    begin
      FConfigData.FixInsightExe := String.Empty;
    end,
    ECDFixInsightExeNotFound,
    'CheckException::ECDFixInsightExeNotFound'
  );

  { Check validation - empty input file name }

  CheckException(
    procedure
    begin
      FConfigData.InputFileName := String.Empty;
    end,
    ECDInputFileNotFound,
    'CheckException::ECDInputFileNotFound'
  );

  { Check validation - empty output directory }

  CheckException(
    procedure
    begin
      FConfigData.OutputDirectory := String.Empty;
    end,
    ECDOutputDirectoryNotFound,
    'CheckException::ECDOutputDirectoryNotFound'
  );

  { Check validation - empty output file name }

  CheckException(
    procedure
    begin
      FConfigData.OutputFileName := String.Empty;
    end,
    ECDInvalidOutputFileName,
    'CheckException::ECDInvalidOutputFileName'
  );

  { Check validation - empty temp directory }

  CheckException(
    procedure
    begin
      FConfigData.TempDirectory := String.Empty;
    end,
    ECDTempDirectoryNotFound,
    'CheckException::ECDTempDirectoryNotFound'
  );
end;

procedure TestTConfigData.TestInvalidData;
const
  REGEX_VALID = '^[0-9]+';
  REGEX_INVALID = '[0-|9)';
begin
  FConfigData.Validate := True;

  { Check validation - invalid custom template file name }

  CheckException(
    procedure
    begin
      FConfigData.CustomTemplateFileName := STR_NON_EXISTENT_FILE;
    end,
    ECDCustomTemplateFileNotFound,
    'CheckException::ECDCustomTemplateFileNotFound'
  );

  { Check validation - invalid exclude project regex }

  CheckException(
    procedure
    begin
      FConfigData.ExcludeProjectPatterns := [REGEX_VALID, REGEX_INVALID];
    end,
    ECDInvalidExcludeProjectPattern,
    'CheckException::ECDInvalidExcludeProjectPattern'
  );

  { Check validation - invalid FixInsight executable path }

  CheckException(
    procedure
    begin
      FConfigData.FixInsightExe := STR_NON_EXISTENT_FILE;
    end,
    ECDFixInsightExeNotFound,
    'CheckException::ECDFixInsightExeNotFound'
  );

  { Check validation - invalid input file name }

  CheckException(
    procedure
    begin
      FConfigData.InputFileName := STR_NON_EXISTENT_FILE;
    end,
    ECDInputFileNotFound,
    'CheckException::ECDInputFileNotFound'
  );

  { Check validation - invalid output directory }

  CheckException(
    procedure
    begin
      FConfigData.OutputDirectory := STR_NON_EXISTENT_DIR;
    end,
    ECDOutputDirectoryNotFound,
    'CheckException::ECDOutputDirectoryNotFound'
  );

  { Check validation - invalid output file name }

  CheckException(
    procedure
    begin
      FConfigData.OutputFileName := STR_INVALID_FILENAME;
    end,
    ECDInvalidOutputFileName,
    'CheckException::ECDInvalidOutputFileName'
  );

  { Check validation - invalid temp directory }

  CheckException(
    procedure
    begin
      FConfigData.TempDirectory := STR_NON_EXISTENT_DIR;
    end,
    ECDTempDirectoryNotFound,
    'CheckException::ECDTempDirectoryNotFound'
  );
end;

procedure TestTConfigData.TestValidData;
const
  REGEX_VALID1 = '^interface$';
  REGEX_VALID2 = '[0-9]+[A-F]{2}';
begin
  CheckException(
    procedure
    begin
      with FConfigData do
      begin
        Validate := True;
        CustomTemplateFileName := ParamStr(0);
        ExcludeProjectPatterns := [REGEX_VALID1, REGEX_VALID2];
        FixInsightExe := ParamStr(0);
        InputFileName := ParamStr(0);
        OutputDirectory := ExtractFileDir(ParamStr(0));
        OutputFileName := ExtractFileName(ParamStr(0));
        TempDirectory := ExtractFileDir(ParamStr(0));
      end;
    end,
    nil,
    'CheckException::nil'
  );
  CheckTrue(FConfigData.OutputDirectory.EndsWith(TPath.DirectorySeparatorChar),
    'CheckTrue::OutputDirectory.EndsWith(TPath.DirectorySeparatorChar)');
  CheckTrue(FConfigData.TempDirectory.EndsWith(TPath.DirectorySeparatorChar),
    'CheckTrue::TempDirectory.EndsWith(TPath.DirectorySeparatorChar)');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTConfigData.Suite);
end.
