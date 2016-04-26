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
  TestTConfigManager = class(TTestCase)
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
  FIToolkit.Config.Consts;

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

  CfgMgr := TConfigManager.Create(sFileName, False, False);
  try
    CheckFalse(FileExists(sFileName), 'Create(NonEmptyFileName,DoNotGenerateConfig)::FileExists');
    CheckTrue(String.IsNullOrEmpty(CfgMgr.ConfigFileName),
      'Create(NonEmptyFileName,DoNotGenerateConfig)::ConfigFileName.IsEmpty');
    CheckTrue(CfgMgr.ConfigData.OutputFileName = DEF_CD_STR_OUTPUT_FILENAME,
              'Create(NonEmptyFileName,DoNotGenerateConfig)::PropertiesHaveDefaultValues');
  finally
    CfgMgr.Free;
  end;

  CfgMgr := TConfigManager.Create(sFileName, True, False);
  try
    CheckTrue(FileExists(sFileName), 'Create(NonEmptyFileName,GenerateConfig)::FileExists');
    CheckEquals(sFileName, CfgMgr.ConfigFileName, 'Create(NonEmptyFileName,GenerateConfig)::ConfigFileName.IsEqual');

    with TMemIniFile.Create(CloneFile(sFileName), TEncoding.UTF8) do
      try
        CheckEquals(
          DEF_CD_STR_OUTPUT_FILENAME,
          ReadString(CfgMgr.ConfigData.QualifiedClassName, 'OutputFileName', STR_INVALID_FILENAME),
          'Create(NonEmptyFileName,GenerateConfig)::ConfigFileContainsDefaultValues'
        );
      finally
        Free;
      end;
  finally
    CfgMgr.Free;
  end;

  CfgMgr := TConfigManager.Create(String.Empty, False, False);
  try
    CheckTrue(String.IsNullOrEmpty(CfgMgr.ConfigFileName),
      'Create(EmptyFileName,DoNotGenerateConfig)::ConfigFileName.IsEmpty');
    CheckTrue(CfgMgr.ConfigData.OutputFileName = DEF_CD_STR_OUTPUT_FILENAME,
              'Create(EmptyFileName,DoNotGenerateConfig)::PropertiesHaveDefaultValues');
  finally
    CfgMgr.Free;
  end;

  CheckException(
    procedure
    begin
      TConfigManager.Create(String.Empty, True, False);
    end,
    EArgumentException,
    'Create(EmptyFileName,GenerateConfig)::EArgumentException'
  );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTConfigManager.Suite);

end.
