unit FIToolkit.Config.Defaults;

interface

uses
  System.Rtti,
  FIToolkit.Config.Types;

type

  TDefaultValueAttributeClass = class of TDefaultValueAttribute;

  TDefaultValueAttribute = class abstract (TCustomAttribute)
    strict private
      FValue : TValue;
      FValueKind : TDefaultValueKind;
    private
      function GetClassType : TDefaultValueAttributeClass;
      function GetValue : TValue;
    protected
      function CalculateValue : TValue; virtual;
    public
      constructor Create(AValue : TValue); overload;
      constructor Create; overload;

      property Value : TValue read GetValue;
      property ValueKind : TDefaultValueKind read FValueKind;
  end;

  DefaultValue = class (TDefaultValueAttribute);

  procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);

implementation

uses
  System.SysUtils, System.Generics.Collections;

type

  TDefaultsMap = class (TDictionary<TDefaultValueAttributeClass, TValue>)
    strict private
      class var FStaticInstance : TDefaultsMap;
    private
      class procedure FreeStaticInstance; static;
      class function  GetStaticInstance : TDefaultsMap; static;
    public
      class property StaticInstance : TDefaultsMap read GetStaticInstance;
  end;

{ Utils }

procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
begin
  TDefaultsMap.StaticInstance.Add(DefValAttribClass, Value);
end;

{ TDefaultsMap }

class procedure TDefaultsMap.FreeStaticInstance;
begin
  FreeAndNil(FStaticInstance);
end;

class function TDefaultsMap.GetStaticInstance : TDefaultsMap;
begin
  if not Assigned(FStaticInstance) then
    FStaticInstance := TDefaultsMap.Create;

  Result := FStaticInstance;
end;

{ TDefaultValueAttribute }

constructor TDefaultValueAttribute.Create(AValue : TValue);
begin
  inherited Create;

  FValue := AValue;
  FValueKind := dvkData;
end;

constructor TDefaultValueAttribute.Create;
begin
  inherited Create;

  FValue := TValue.Empty;
  FValueKind := dvkCalculated;
end;

function TDefaultValueAttribute.CalculateValue : TValue;
begin
  with TDefaultsMap.StaticInstance do
    if ContainsKey(Self.GetClassType) then
      Result := Items[Self.GetClassType]
    else
      Result := TValue.Empty;
end;

function TDefaultValueAttribute.GetClassType : TDefaultValueAttributeClass;
begin
  Pointer(Result) := PPointer(Self)^;
end;

function TDefaultValueAttribute.GetValue : TValue;
begin
  Result := TValue.Empty;

  case ValueKind of
    dvkData:
      Result := FValue;
    dvkCalculated:
      Result := CalculateValue;
  else
    Assert(False, 'Unhandled default value kind while getting value.');
  end;
end;

initialization
  TDefaultsMap.GetStaticInstance;

finalization
  TDefaultsMap.FreeStaticInstance;

end.
