﻿unit Test_FIToolkit.Config.Defaults;
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
  FIToolkit.Config.Defaults;

type
  // Test methods for class TDefaultValueAttribute

  TestTDefaultValueAttribute = class(TGenericTestCase)
  strict private
    FDefaultValueAttribute: TDefaultValueAttribute;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsEmpty;
  end;

  // Test methods for class TDefaultValueAttribute<T>

  TestTDefaultValueAttributeT = class(TGenericTestCase)
  private
    type
      TTestAttribute = class (TDefaultValueAttribute<Integer>);
    const
      INT_ATTR_VALUE = 777;
  strict private
    FAttrWithNoValue,
    FAttrWithValue : TTestAttribute;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAttributeWithNoValue;
    procedure TestAttributeWithValue;
  end;

  // Test methods for class TDefaultsMap

  TestTDefaultsMap = class(TGenericTestCase)
  private
    type
      TTestAttributeBase = class abstract (TDefaultValueAttribute<Integer>);
      TTestAddAttr = class (TTestAttributeBase);
      TTestGetAttr = class (TTestAttributeBase);
      TTestHasAttr = class (TTestAttributeBase);
      TDummyAttr   = class (TTestAttributeBase);
    const
      INT_ATTR_VALUE = 777;
  strict private
    FDefaultsMap1,
    FDefaultsMap2 : TDefaultsMap;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddValue;
    procedure TestGetValue;
    procedure TestHasValue;
    procedure TestIsSingleton;
  end;

implementation

uses
  System.SysUtils, System.Rtti,
  TestUtils,
  FIToolkit.Config.Types;

{ TestTDefaultValueAttribute }

procedure TestTDefaultValueAttribute.SetUp;
begin
  FDefaultValueAttribute := TDefaultValueAttribute.Create;
end;

procedure TestTDefaultValueAttribute.TearDown;
begin
  FreeAndNil(FDefaultValueAttribute);
end;

procedure TestTDefaultValueAttribute.TestIsEmpty;
var
  ReturnValue : TValue;
begin
  CheckEquals<TDefaultValueKind>(dvkUndefined, FDefaultValueAttribute.ValueKind, 'ValueKind = dvkUndefined');

  CheckException(
    procedure
    begin
      ReturnValue := FDefaultValueAttribute.Value;
    end,
    EAssertionFailed,
    'CheckException::EAssertionFailed(ValueKind <> dvkUndefined)'
  );
end;

{ TestTDefaultValueAttributeT }

procedure TestTDefaultValueAttributeT.SetUp;
begin
  FAttrWithNoValue := TTestAttribute.Create;
  FAttrWithValue := TTestAttribute.Create(INT_ATTR_VALUE);
end;

procedure TestTDefaultValueAttributeT.TearDown;
begin
  FreeAndNil(FAttrWithNoValue);
  FreeAndNil(FAttrWithValue);
end;

procedure TestTDefaultValueAttributeT.TestAttributeWithNoValue;
begin
  CheckEquals<TDefaultValueKind>(dvkCalculated, FAttrWithNoValue.ValueKind, 'ValueKind = dvkCalculated');
  CheckTrue(FAttrWithNoValue.Value.IsEmpty, 'CheckTrue::IsEmpty');

  RegisterDefaultValue(TTestAttribute, INT_ATTR_VALUE);

  CheckEquals(INT_ATTR_VALUE, FAttrWithNoValue.Value.AsInteger, 'Value = INT_ATTR_VALUE');
end;

procedure TestTDefaultValueAttributeT.TestAttributeWithValue;
begin
  CheckEquals<TDefaultValueKind>(dvkData, FAttrWithValue.ValueKind, 'ValueKind = dvkData');
  CheckFalse(FAttrWithValue.Value.IsEmpty, 'CheckFalse::IsEmpty');
  CheckEquals(INT_ATTR_VALUE, FAttrWithValue.Value.AsInteger, 'Value = INT_ATTR_VALUE');
end;

{ TestTDefaultsMap }

procedure TestTDefaultsMap.SetUp;
begin
  FDefaultsMap1 := TDefaultsMap.Create;
  FDefaultsMap2 := TDefaultsMap.Create;
end;

procedure TestTDefaultsMap.TearDown;
begin
  FreeAndNil(FDefaultsMap1);
  FreeAndNil(FDefaultsMap2);
end;

procedure TestTDefaultsMap.TestAddValue;
var
  Value: TValue;
  DefValAttribClass: TDefaultValueAttributeClass;
begin
  Value := INT_ATTR_VALUE;
  DefValAttribClass := TTestAddAttr;

  TDefaultsMap.AddValue(DefValAttribClass, Value);

  CheckTrue(TDefaultsMap.HasValue(DefValAttribClass), 'CheckTrue::HasValue');
  CheckEquals(INT_ATTR_VALUE, TDefaultsMap.GetValue(DefValAttribClass).AsInteger,
    'TDefaultsMap.GetValue = INT_ATTR_VALUE');
  CheckEquals(INT_ATTR_VALUE, FDefaultsMap1.GetValue(DefValAttribClass).AsInteger,
    'FDefaultsMap1.GetValue = INT_ATTR_VALUE');
  CheckEquals(FDefaultsMap1.GetValue(DefValAttribClass).AsInteger, FDefaultsMap2.GetValue(DefValAttribClass).AsInteger,
    'FDefaultsMap2.GetValue = FDefaultsMap1.GetValue');
end;

procedure TestTDefaultsMap.TestGetValue;
var
  ReturnValue: TValue;
  DefValAttribClass: TDefaultValueAttributeClass;
begin
  DefValAttribClass := TTestGetAttr;

  CheckException(
    procedure
    begin
      ReturnValue := TDefaultsMap.GetValue(DefValAttribClass);
    end,
    EListError,
    'CheckException::EListError'
  );

  TDefaultsMap.AddValue(DefValAttribClass, INT_ATTR_VALUE);
  ReturnValue := TDefaultsMap.GetValue(DefValAttribClass);

  CheckEquals(INT_ATTR_VALUE, ReturnValue.AsInteger, 'ReturnValue = INT_ATTR_VALUE');
end;

procedure TestTDefaultsMap.TestHasValue;
var
  ReturnValue: Boolean;
  DefValAttribClass: TDefaultValueAttributeClass;
begin
  DefValAttribClass := TTestHasAttr;

  ReturnValue := TDefaultsMap.HasValue(DefValAttribClass);

  CheckFalse(ReturnValue, 'CheckFalse::ReturnValue');

  TDefaultsMap.AddValue(DefValAttribClass, INT_ATTR_VALUE);
  ReturnValue := TDefaultsMap.HasValue(DefValAttribClass);

  CheckTrue(ReturnValue, 'CheckTrue::ReturnValue');
end;

procedure TestTDefaultsMap.TestIsSingleton;
var
  DefValAttribClass: TDefaultValueAttributeClass;
begin
  DefValAttribClass := TDummyAttr;

  TDefaultsMap.AddValue(DefValAttribClass, INT_ATTR_VALUE);

  CheckNotEquals(FDefaultsMap1, FDefaultsMap2, 'FDefaultsMap1 <> FDefaultsMap2');
  CheckTrue(FDefaultsMap1.HasValue(DefValAttribClass),
    'CheckTrue::(FDefaultsMap1.StaticInstance = TDefaultsMap.StaticInstance)');
  CheckTrue(FDefaultsMap2.HasValue(DefValAttribClass),
    'CheckTrue::(FDefaultsMap2.StaticInstance = TDefaultsMap.StaticInstance)');
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTDefaultValueAttribute.Suite);
  RegisterTest(TestTDefaultValueAttributeT.Suite);
  RegisterTest(TestTDefaultsMap.Suite);
end.
