unit Test_FIToolkit.Utils;
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

  TestFIToolkitUtils = class (TTestCase)
    published
      procedure TestGetFixInsightExePath;
      procedure TestIff;
  end;

  TestTPathHelper = class (TTestCase)
    published
      procedure TestGetExePath;
  end;

  TestTTypeKindHelper = class (TTestCase)
    published
      procedure TestIsArray;
      procedure TestIsString;
  end;

  TestTTypeInfoHelper = class (TTestCase)
    published
      procedure TestIsArray;
      procedure TestIsString;
  end;

  TestTRttiTypeHelper = class (TTestCase)
    strict private
      type
        TTestAttribute = class abstract (TCustomAttribute);
        IsArrayPropAttribute = class (TTestAttribute);
        IsStringPropAttribute = class (TTestAttribute);

        TTestStaticArray = array [0..9] of Byte;
        TTestDynamicArray = array of Byte;
    private
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

implementation

uses
  System.SysUtils, System.IOUtils, System.TypInfo, System.Rtti;

procedure TestFIToolkitUtils.TestGetFixInsightExePath;
  var
    ReturnValue : TFileName;
begin
  ReturnValue := GetFixInsightExePath;

  CheckTrue(TPath.HasValidPathChars(ReturnValue, False), 'ReturnValue::HasValidPathChars');
  CheckTrue(TPath.HasValidFileNameChars(TPath.GetFileName(ReturnValue), False), 'ReturnValue::HasValidFileNameChars');
  CheckTrue(TPath.HasExtension(ReturnValue) or (ReturnValue = String.Empty), 'ReturnValue::HasExtension');
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
  CheckEquals(iTruePart, iReturnValue, 'Integer::TruePart');
  iReturnValue := Iff.Get<Integer>(False, iTruePart, iFalsePart);
  CheckEquals(iFalsePart, iReturnValue, 'Integer::FalsePart');

  sReturnValue := Iff.Get<String>(True, sTruePart, sFalsePart);
  CheckEquals(sTruePart, sReturnValue, 'String::TruePart');
  sReturnValue := Iff.Get<String>(False, sTruePart, sFalsePart);
  CheckEquals(sFalsePart, sReturnValue, 'String::FalsePart');

  eReturnValue := Iff.Get<TTestEnum>(True, eTruePart, eFalsePart);
  CheckTrue(eReturnValue = eTruePart, 'TTestEnum::TruePart');
  eReturnValue := Iff.Get<TTestEnum>(False, eTruePart, eFalsePart);
  CheckTrue(eReturnValue = eFalsePart, 'TTestEnum::FalsePart');
end;

{ TestTPathHelper }

procedure TestTPathHelper.TestGetExePath;
  var
    ReturnValue, sExpected : String;
begin
  ReturnValue := TPath.GetExePath;

  sExpected := ExtractFilePath(ParamStr(0));
  CheckEquals(sExpected, ReturnValue, 'ReturnValue = sExpected');
  CheckTrue(ReturnValue.EndsWith(TPath.DirectorySeparatorChar), 'ReturnValue::EndsWith(DirectorySeparatorChar)');
end;

{ TestTTypeKindHelper }

procedure TestTTypeKindHelper.TestIsArray;
  type
    TTestStaticArray = array [0..9] of Byte;
    TTestDynamicArray = array of Byte;
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

{ TestTTypeInfoHelper }

procedure TestTTypeInfoHelper.TestIsArray;
  type
    TTestStaticArray = array [0..9] of Byte;
    TTestDynamicArray = array of Byte;
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
          CheckTrue(Prop.PropertyType.IsArray, Format('CheckTrue::%s.IsArray', [Prop.Name]));
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
          CheckTrue(Prop.PropertyType.IsString, Format('CheckTrue::%s.IsString', [Prop.Name]));
          Break;
        end;
  finally
    Ctx.Free;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestFIToolkitUtils.Suite);
  RegisterTest(TestTPathHelper.Suite);
  RegisterTest(TestTTypeKindHelper.Suite);
  RegisterTest(TestTTypeInfoHelper.Suite);
  RegisterTest(TestTRttiTypeHelper.Suite);

end.
