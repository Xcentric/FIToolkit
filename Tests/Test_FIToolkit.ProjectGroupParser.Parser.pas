﻿unit Test_FIToolkit.ProjectGroupParser.Parser;
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
  FIToolkit.ProjectGroupParser.Parser;

type
  // Test methods for class TProjectGroupParser

  TestTProjectGroupParser = class(TGenericTestCase)
  strict private
    FProjectGroupParser : TProjectGroupParser;
  private
    function  FindProjectGroup : String;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetIncludedProjectsFiles;
    procedure TestInvalidFile;
  end;

implementation

uses
  TestUtils,
  System.SysUtils, System.Types, System.IOUtils,
  FIToolkit.ProjectGroupParser.Exceptions;

{ TestTProjectGroupParser }

function TestTProjectGroupParser.FindProjectGroup : String;
begin
  Result := TDirectory.GetFiles(GetProjectGroupDir, '*.groupproj', TSearchOption.soAllDirectories)[0];
end;

procedure TestTProjectGroupParser.SetUp;
begin
  if GetCurrTestMethodAddr = @TestTProjectGroupParser.TestInvalidFile then
    FProjectGroupParser := TProjectGroupParser.Create(String.Empty)
  else
    FProjectGroupParser := TProjectGroupParser.Create(FindProjectGroup);
end;

procedure TestTProjectGroupParser.TearDown;
begin
  FreeAndNil(FProjectGroupParser);
end;

procedure TestTProjectGroupParser.TestGetIncludedProjectsFiles;
var
  sRootDir, S : String;
  ReturnValue : TArray<TFileName>;
begin
  sRootDir := GetProjectGroupDir;

  ReturnValue := FProjectGroupParser.GetIncludedProjectsFiles;

  CheckTrue(Length(ReturnValue) > 0, 'CheckTrue::(Length(ReturnValue) > 0)');
  for S in ReturnValue do
  begin
    CheckTrue(S.StartsWith(sRootDir, True), 'CheckTrue::ReturnValue[i].StartsWith(sRootDir)<%s>', [S]);
    CheckTrue(TPath.GetExtension(S).Equals('.dpr') or TPath.GetExtension(S).Equals('.dpk'),
      'CheckTrue::<"%s" in [".dpr", ".dpk"]>', [TPath.GetExtension(S)]);
    CheckTrue(TFile.Exists(S), 'CheckTrue::TFile.Exists("%s")', [S]);
  end;
end;

procedure TestTProjectGroupParser.TestInvalidFile;
begin
  CheckException(
    procedure
    begin
      FProjectGroupParser.GetIncludedProjectsFiles;
    end,
    EProjectGroupParseError,
    'CheckException::EProjectGroupParseError'
  );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTProjectGroupParser.Suite);

end.
