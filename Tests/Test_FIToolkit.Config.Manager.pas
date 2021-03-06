﻿unit Test_FIToolkit.Config.Manager;
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
  FIToolkit.Config.Manager;

type

  // Test methods for class TConfigManager
  TestTConfigManager = class(TGenericTestCase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreate;
  end;

implementation

uses
  System.SysUtils, System.IniFiles,
  TestUtils, TestConsts,
  FIToolkit.Config.Consts, FIToolkit.Config.Types;

procedure TestTConfigManager.SetUp;
begin
  DeleteFile(GetTestIniFileName)
end;

procedure TestTConfigManager.TearDown;
begin
  DeleteFile(GetTestIniFileName)
end;

procedure TestTConfigManager.TestCreate;
var
  sFileName : TFileName;
  CfgMgr : TConfigManager;
begin
  sFileName := GetTestIniFileName;

  { File name specified }

  CfgMgr := TConfigManager.Create(sFileName, False, False);
  try
    CheckFalse(FileExists(sFileName), 'CheckFalse::FileExists<NonEmptyFileName,DoNotGenerateConfig>');
    CheckTrue(String.IsNullOrEmpty(CfgMgr.ConfigFileName),
      'CheckTrue::ConfigFileName.IsEmpty<NonEmptyFileName,DoNotGenerateConfig>');
    CheckEquals<TFixInsightOutputFormat>(DEF_FIO_ENUM_OUTPUT_FORMAT, CfgMgr.ConfigData.FixInsightOptions.OutputFormat,
      '(ConfigData.FixInsightOptions.OutputFormat = DEF_FIO_ENUM_OUTPUT_FORMAT)::<NonEmptyFileName,DoNotGenerateConfig>');
  finally
    CfgMgr.Free;
  end;

  CfgMgr := TConfigManager.Create(sFileName, True, False);
  try
    CheckTrue(FileExists(sFileName), 'CheckTrue::FileExists<NonEmptyFileName,GenerateConfig>');
    CheckEquals(sFileName, CfgMgr.ConfigFileName, '(CfgMgr.ConfigFileName = sFileName)::<NonEmptyFileName,GenerateConfig>');

    with TMemIniFile.Create(CloneFile(sFileName), TEncoding.UTF8) do
      try
        CheckEquals(
          DEF_CD_STR_OUTPUT_FILENAME,
          ReadString(CfgMgr.ConfigData.QualifiedClassName, 'OutputFileName', STR_INVALID_FILENAME),
          '(ReadString = DEF_CD_STR_OUTPUT_FILENAME)::<NonEmptyFileName,GenerateConfig>'
        );
      finally
        Free;
      end;
  finally
    CfgMgr.Free;
  end;

  Assert(FileExists(sFileName));
  CfgMgr := TConfigManager.Create(sFileName, False, False);
  try
    CheckFalse(String.IsNullOrEmpty(CfgMgr.ConfigFileName),
      'CheckFalse::ConfigFileName.IsEmpty<NonEmptyFileName,DoNotGenerateConfig,FileExists>');
    CheckEquals<TFixInsightOutputFormat>(DEF_FIO_ENUM_OUTPUT_FORMAT, CfgMgr.ConfigData.FixInsightOptions.OutputFormat,
      '(ConfigData.FixInsightOptions.OutputFormat = DEF_FIO_ENUM_OUTPUT_FORMAT)::<NonEmptyFileName,DoNotGenerateConfig,FileExists>');
  finally
    CfgMgr.Free;
  end;

  { File name NOT specified }

  CfgMgr := TConfigManager.Create(String.Empty, False, False);
  try
    CheckTrue(String.IsNullOrEmpty(CfgMgr.ConfigFileName),
      'CheckTrue::ConfigFileName.IsEmpty<EmptyFileName,DoNotGenerateConfig>');
    CheckEquals<TFixInsightOutputFormat>(DEF_FIO_ENUM_OUTPUT_FORMAT, CfgMgr.ConfigData.FixInsightOptions.OutputFormat,
      '(ConfigData.FixInsightOptions.OutputFormat = DEF_FIO_ENUM_OUTPUT_FORMAT)::<EmptyFileName,DoNotGenerateConfig>');
  finally
    CfgMgr.Free;
  end;

  CheckException(
    procedure
    begin
      TConfigManager.Create(String.Empty, True, False);
    end,
    EArgumentException,
    'CheckException::EArgumentException<EmptyFileName,GenerateConfig>'
  );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTConfigManager.Suite);

end.
