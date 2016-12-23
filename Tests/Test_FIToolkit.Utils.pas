﻿unit Test_FIToolkit.Utils;
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
  FIToolkit.Utils;

type

  TestFIToolkitUtils = class (TGenericTestCase)
    published
      procedure TestGetAppVersionInfo;
      procedure TestGetCLIOptionProcessingOrder;
      procedure TestIsCaseSensitiveCLIOption;
      procedure TestTryCLIOptionToAppCommand;
  end;

implementation

uses
  System.SysUtils,
  FIToolkit.Types, FIToolkit.Consts,
  TestUtils;

{ TestFIToolkitUtils }

procedure TestFIToolkitUtils.TestGetAppVersionInfo;
var
  ReturnValue : String;
begin
  ReturnValue := GetAppVersionInfo;

  CheckFalse(ReturnValue.IsEmpty, 'CheckFalse::IsEmpty');
  CheckTrue(ReturnValue.Contains(STR_APP_TITLE), 'CheckTrue::Contains(%s)', [STR_APP_TITLE]);
end;

procedure TestFIToolkitUtils.TestGetCLIOptionProcessingOrder;
var
  ReturnValue : Integer;
  S : String;
begin
  ReturnValue := GetCLIOptionProcessingOrder(String.Empty, False);
  CheckEquals(-1, ReturnValue, '(ReturnValue = -1)::<empty>');

  ReturnValue := GetCLIOptionProcessingOrder(' ', True);
  CheckEquals(-1, ReturnValue, '(ReturnValue = -1)::<space>');

  for S in ARR_CLIOPTION_PROCESSING_ORDER do
  begin
    ReturnValue := GetCLIOptionProcessingOrder(S, True);
    CheckTrue(ReturnValue >= 0, 'CheckTrue::(%d >= 0)<case insensitive>', [ReturnValue]);

    ReturnValue := GetCLIOptionProcessingOrder(S, False);
    CheckTrue(ReturnValue >= 0, 'CheckTrue::(%d >= 0)<case sensitive>', [ReturnValue]);
  end;
end;

procedure TestFIToolkitUtils.TestIsCaseSensitiveCLIOption;
var
  ReturnValue : Boolean;
begin
  ReturnValue := IsCaseSensitiveCLIOption(String.Empty);
  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue<empty>');

  ReturnValue := IsCaseSensitiveCLIOption(' ');
  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue<space>');
end;

procedure TestFIToolkitUtils.TestTryCLIOptionToAppCommand;
var
  Cmd, C : TApplicationCommand;
  ReturnValue : Boolean;
begin
  ReturnValue := TryCLIOptionToAppCommand(String.Empty, False, Cmd);
  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue<empty>');

  ReturnValue := TryCLIOptionToAppCommand(' ', True, Cmd);
  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue<space>');

  for C := Low(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING) to High(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING) do
    if not ARR_APPCOMMAND_TO_CLIOPTION_MAPPING[C].IsEmpty then
    begin
      ReturnValue := TryCLIOptionToAppCommand(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING[C], True, Cmd);
      CheckTrue(ReturnValue, 'CheckTrue::ReturnValue<case insensitive>');

      ReturnValue := TryCLIOptionToAppCommand(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING[C], False, Cmd);
      CheckTrue(ReturnValue, 'CheckTrue::ReturnValue<case sensitive>');
    end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestFIToolkitUtils.Suite);

end.