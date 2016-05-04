﻿unit Test_FIToolkit.Commons.Utils;
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
  FIToolkit.Commons.Utils;

type

  TestFIToolkitUtils = class (TGenericTestCase)
    published
      procedure TestGetFixInsightExePath;
      procedure TestIff;
  end;

  TestTFileNameHelper = class (TGenericTestCase)
    published
      procedure TestIsApplicable;
      procedure TestIsEmpty;
  end;

  TestTPathHelper = class (TGenericTestCase)
    published
      procedure TestGetExePath;
      procedure TestGetQuotedPath;
      procedure TestIsApplicableFileName;
  end;

  TestTRttiTypeHelper = class (TGenericTestCase)
    private
      type
        TTestAttribute = class abstract (TCustomAttribute);
        IsArrayPropAttribute = class (TTestAttribute);
        IsStringPropAttribute = class (TTestAttribute);

        TTestStaticArray = array [0..9] of Byte;
        TTestDynamicArray = TArray<Byte>;
    strict private
      FDynamicArray : TTestDynamicArray;
      FStaticArray : TTestStaticArray;

      FAnsiString : AnsiString;
      FRawByteString : RawByteString;
      FShortString : ShortString;
      FString : String;
      FUnicodeString : UnicodeString;
      FUTF8String : UTF8String;
      FWideString : WideString;
    public
      [IsArrayProp]
      property PropDynamicArray : TTestDynamicArray read FDynamicArray;
      [IsArrayProp]
      property PropStaticArray : TTestStaticArray read FStaticArray;

      [IsStringProp]
      property PropAnsiString : AnsiString read FAnsiString;
      [IsStringProp]
      property PropRawByteString : RawByteString read FRawByteString;
      [IsStringProp]
      property PropShortString : ShortString read FShortString;
      [IsStringProp]
      property PropString : String read FString;
      [IsStringProp]
      property PropUnicodeString : UnicodeString read FUnicodeString;
      [IsStringProp]
      property PropUTF8String : UTF8String read FUTF8String;
      [IsStringProp]
      property PropWideString : WideString read FWideString;
    published
      procedure TestIsArray;
      procedure TestIsString;
  end;

  TestTTypeInfoHelper = class (TGenericTestCase)
    published
      procedure TestIsArray;
      procedure TestIsString;
  end;

  TestTTypeKindHelper = class (TGenericTestCase)
    published
      procedure TestIsArray;
      procedure TestIsString;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.TypInfo, System.Rtti,
  TestUtils, TestConsts;

procedure TestFIToolkitUtils.TestGetFixInsightExePath;
var
  ReturnValue : TFileName;
begin
  ReturnValue := GetFixInsightExePath;

  CheckTrue(TPath.HasValidPathChars(ReturnValue, False), 'CheckTrue::HasValidPathChars');
  CheckTrue(TPath.HasValidFileNameChars(TPath.GetFileName(ReturnValue), False), 'CheckTrue::HasValidFileNameChars');
  CheckTrue(TFile.Exists(ReturnValue) or (ReturnValue = String.Empty), 'CheckTrue::(Exists or Empty)');
end;

procedure TestFIToolkitUtils.TestIff;
type
  TTestEnum = (teFirst, teSecond, teThird);
var
  iReturnValue, iTruePart, iFalsePart : Integer;
  sReturnValue, sTruePart, sFalsePart : String;
  eReturnValue, eTruePart, eFalsePart : TTestEnum;
begin
  iTruePart  := 1;
  iFalsePart := 0;
  sTruePart  := '1';
  sFalsePart := '0';
  eTruePart  := teFirst;
  eFalsePart := teThird;

  iReturnValue := Iff.Get<Integer>(True, iTruePart, iFalsePart);
  CheckEquals(iTruePart, iReturnValue, 'iReturnValue = iTruePart');
  iReturnValue := Iff.Get<Integer>(False, iTruePart, iFalsePart);
  CheckEquals(iFalsePart, iReturnValue, 'iReturnValue = iFalsePart');

  sReturnValue := Iff.Get<String>(True, sTruePart, sFalsePart);
  CheckEquals(sTruePart, sReturnValue, 'sReturnValue = sTruePart');
  sReturnValue := Iff.Get<String>(False, sTruePart, sFalsePart);
  CheckEquals(sFalsePart, sReturnValue, 'sReturnValue = sFalsePart');

  eReturnValue := Iff.Get<TTestEnum>(True, eTruePart, eFalsePart);
  CheckTrue(eReturnValue = eTruePart, 'eReturnValue = eTruePart');
  eReturnValue := Iff.Get<TTestEnum>(False, eTruePart, eFalsePart);
  CheckTrue(eReturnValue = eFalsePart, 'eReturnValue = eFalsePart');
end;

{ TestTFileNameHelper }

procedure TestTFileNameHelper.TestIsApplicable;
var
  FileName : TFileName;
begin
  FileName := TPath.GetDirectoryName(ParamStr(0));
  CheckFalse(FileName.IsApplicable, 'CheckFalse::(%s)', [FileName]);

  FileName := TPath.GetFileName(ParamStr(0));
  CheckTrue(FileName.IsApplicable, 'CheckTrue::(%s)', [FileName]);

  FileName := ParamStr(0);
  CheckTrue(FileName.IsApplicable, 'CheckTrue::(%s)', [FileName]);

  FileName := STR_NON_EXISTENT_DIR;
  CheckFalse(FileName.IsApplicable, 'CheckFalse::(%s)', [STR_NON_EXISTENT_DIR]);

  FileName := STR_INVALID_FILENAME;
  CheckFalse(FileName.IsApplicable, 'CheckFalse::(%s)', [STR_INVALID_FILENAME]);
end;

procedure TestTFileNameHelper.TestIsEmpty;
var
  FileName : TFileName;
begin
  FileName := String.Empty;
  CheckTrue(FileName.IsEmpty, 'CheckTrue::(<empty>)');

  FileName := '  ';
  CheckFalse(FileName.IsEmpty, 'CheckFalse::(<whitespace>)');

  FileName := STR_NON_EXISTENT_FILE;
  CheckFalse(FileName.IsEmpty, 'CheckFalse::(<filename>)');
end;

{ TestTPathHelper }

procedure TestTPathHelper.TestGetExePath;
var
  ReturnValue, sExpected : String;
begin
  ReturnValue := TPath.GetExePath;

  sExpected := ExtractFilePath(ParamStr(0));
  CheckEquals(sExpected, ReturnValue, 'ReturnValue = sExpected');
  CheckTrue(ReturnValue.EndsWith(TPath.DirectorySeparatorChar), 'CheckTrue::EndsWith(TPath.DirectorySeparatorChar)');
  CheckTrue(TDirectory.Exists(ReturnValue), 'CheckTrue::TDirectory.Exists(ReturnValue)');
end;

procedure TestTPathHelper.TestGetQuotedPath;
const
  STR_PATH_QUOTED_NONE = 'C:\test\file.ext';
  STR_PATH_QUOTED_LEFT = '"' + STR_PATH_QUOTED_NONE;
  STR_PATH_QUOTED_RIGHT = STR_PATH_QUOTED_NONE + '"';
  STR_PATH_QUOTED_BOTH = '"' + STR_PATH_QUOTED_NONE + '"';
  STR_PATH_EXPECTED = '"' + STR_PATH_QUOTED_NONE + '"';
var
  ReturnValue : String;
begin
  ReturnValue := TPath.GetQuotedPath(String.Empty);
  CheckTrue(ReturnValue.StartsWith('"') and ReturnValue.EndsWith('"'), 'CheckTrue::(ReturnValue(<empty>) = "")');

  ReturnValue := TPath.GetQuotedPath(STR_PATH_QUOTED_NONE);
  CheckEquals(STR_PATH_EXPECTED, ReturnValue, 'ReturnValue(STR_PATH_QUOTED_NONE) = STR_EXPECTED');

  ReturnValue := TPath.GetQuotedPath(STR_PATH_QUOTED_LEFT);
  CheckEquals(STR_PATH_EXPECTED, ReturnValue, 'ReturnValue(STR_PATH_QUOTED_LEFT) = STR_EXPECTED');

  ReturnValue := TPath.GetQuotedPath(STR_PATH_QUOTED_RIGHT);
  CheckEquals(STR_PATH_EXPECTED, ReturnValue, 'ReturnValue(STR_PATH_QUOTED_RIGHT) = STR_EXPECTED');

  ReturnValue := TPath.GetQuotedPath(STR_PATH_QUOTED_BOTH);
  CheckEquals(STR_PATH_EXPECTED, ReturnValue, 'ReturnValue(STR_PATH_QUOTED_BOTH) = STR_EXPECTED');
end;

procedure TestTPathHelper.TestIsApplicableFileName;
var
  FileName : TFileName;
begin
  FileName := TPath.GetDirectoryName(ParamStr(0));
  CheckFalse(TPath.IsApplicableFileName(FileName), 'CheckFalse::(%s)', [FileName]);

  FileName := TPath.GetFileName(ParamStr(0));
  CheckTrue(TPath.IsApplicableFileName(FileName), 'CheckTrue::(%s)', [FileName]);

  FileName := ParamStr(0);
  CheckTrue(TPath.IsApplicableFileName(FileName), 'CheckTrue::(%s)', [FileName]);

  CheckFalse(TPath.IsApplicableFileName(STR_NON_EXISTENT_DIR), 'CheckFalse::(%s)', [STR_NON_EXISTENT_DIR]);
  CheckFalse(TPath.IsApplicableFileName(STR_INVALID_FILENAME), 'CheckFalse::(%s)', [STR_INVALID_FILENAME]);
end;

{ TestTRttiTypeHelper }

procedure TestTRttiTypeHelper.TestIsArray;
var
  Ctx : TRttiContext;
  Prop : TRttiProperty;
  Attr : TCustomAttribute;
begin
  Ctx := TRttiContext.Create;
  try
    for Prop in Ctx.GetType(Self.ClassType).GetDeclaredProperties do
      for Attr in Prop.GetAttributes do
        if Attr is IsArrayPropAttribute then
        begin
          CheckTrue(Prop.PropertyType.IsArray, 'CheckTrue::<%s is array>', [Prop.Name]);
          Break;
        end;
  finally
    Ctx.Free;
  end;
end;

procedure TestTRttiTypeHelper.TestIsString;
var
  Ctx : TRttiContext;
  Prop : TRttiProperty;
  Attr : TCustomAttribute;
begin
  Ctx := TRttiContext.Create;
  try
    for Prop in Ctx.GetType(Self.ClassType).GetDeclaredProperties do
      for Attr in Prop.GetAttributes do
        if Attr is IsStringPropAttribute then
        begin
          CheckTrue(Prop.PropertyType.IsString, 'CheckTrue::<%s is string>', [Prop.Name]);
          Break;
        end;
  finally
    Ctx.Free;
  end;
end;

{ TestTTypeInfoHelper }

procedure TestTTypeInfoHelper.TestIsArray;
type
  TTestStaticArray = array [0..9] of Byte;
  TTestDynamicArray = TArray<Byte>;
begin
  CheckTrue(PTypeInfo(TypeInfo(TTestStaticArray)).IsArray, 'CheckTrue::TTestStaticArray');
  CheckTrue(PTypeInfo(TypeInfo(TTestDynamicArray)).IsArray, 'CheckTrue::TTestDynamicArray');
end;

procedure TestTTypeInfoHelper.TestIsString;
begin
  CheckTrue(PTypeInfo(TypeInfo(String)).IsString, 'CheckTrue::String');
  CheckTrue(PTypeInfo(TypeInfo(ShortString)).IsString, 'CheckTrue::ShortString');
  CheckTrue(PTypeInfo(TypeInfo(AnsiString)).IsString, 'CheckTrue::AnsiString');
  CheckTrue(PTypeInfo(TypeInfo(WideString)).IsString, 'CheckTrue::WideString');
  CheckTrue(PTypeInfo(TypeInfo(UnicodeString)).IsString, 'CheckTrue::UnicodeString');
  CheckTrue(PTypeInfo(TypeInfo(UTF8String)).IsString, 'CheckTrue::UTF8String');
  CheckTrue(PTypeInfo(TypeInfo(RawByteString)).IsString, 'CheckTrue::RawByteString');
end;

{ TestTTypeKindHelper }

procedure TestTTypeKindHelper.TestIsArray;
type
  TTestStaticArray = array [0..9] of Byte;
  TTestDynamicArray = TArray<Byte>;
begin
  CheckTrue(PTypeInfo(TypeInfo(TTestStaticArray)).Kind.IsArray, 'CheckTrue::TTestStaticArray');
  CheckTrue(PTypeInfo(TypeInfo(TTestDynamicArray)).Kind.IsArray, 'CheckTrue::TTestDynamicArray');
end;

procedure TestTTypeKindHelper.TestIsString;
begin
  CheckTrue(PTypeInfo(TypeInfo(String)).Kind.IsString, 'CheckTrue::String');
  CheckTrue(PTypeInfo(TypeInfo(ShortString)).Kind.IsString, 'CheckTrue::ShortString');
  CheckTrue(PTypeInfo(TypeInfo(AnsiString)).Kind.IsString, 'CheckTrue::AnsiString');
  CheckTrue(PTypeInfo(TypeInfo(WideString)).Kind.IsString, 'CheckTrue::WideString');
  CheckTrue(PTypeInfo(TypeInfo(UnicodeString)).Kind.IsString, 'CheckTrue::UnicodeString');
  CheckTrue(PTypeInfo(TypeInfo(UTF8String)).Kind.IsString, 'CheckTrue::UTF8String');
  CheckTrue(PTypeInfo(TypeInfo(RawByteString)).Kind.IsString, 'CheckTrue::RawByteString');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestFIToolkitUtils.Suite);
  RegisterTest(TestTFileNameHelper.Suite);
  RegisterTest(TestTPathHelper.Suite);
  RegisterTest(TestTRttiTypeHelper.Suite);
  RegisterTest(TestTTypeInfoHelper.Suite);
  RegisterTest(TestTTypeKindHelper.Suite);

end.