﻿unit Test_FIToolkit.Commons.Exceptions;
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
  FIToolkit.Commons.Exceptions;

type
  // Test methods for class ECustomException

  TestECustomException = class(TGenericTestCase)
  private
    type
      ETestException = class (ECustomException);
    const
      STR_TEST_ERR_MSG = 'TestExceptionMessage';
  strict private
    FCustomException: ECustomException;
    FTestException : ETestException;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRegisterExceptionMessage;
  end;

implementation

uses
  System.SysUtils,
  FIToolkit.Commons.Consts;

procedure TestECustomException.SetUp;
begin
  FCustomException := ECustomException.Create;
  RegisterExceptionMessage(ETestException, STR_TEST_ERR_MSG);
  FTestException := ETestException.Create;
end;

procedure TestECustomException.TearDown;
begin
  FreeAndNil(FCustomException);
  FreeAndNil(FTestException);
end;

procedure TestECustomException.TestRegisterExceptionMessage;
begin
  CheckEquals(RSDefaultErrMsg, FCustomException.Message, 'FCustomException.Message = RSDefaultErrMsg');
  CheckEquals(STR_TEST_ERR_MSG, FTestException.Message, 'FTestException.Message = STR_TEST_ERR_MSG');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestECustomException.Suite);
end.