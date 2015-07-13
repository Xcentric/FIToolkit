unit FIToolkit.Config.Defaults;

interface

uses
  System.SysUtils, System.Rtti,
  FIToolkit.Config.Types;

type

  { Base classes }

  TDefaultValueAttributeClass = class of TDefaultValueAttribute;

  TDefaultValueAttribute = class abstract (TCustomAttribute)
    strict private
      FValueType : TDefaultValueType;
    private
      function GetClassType : TDefaultValueAttributeClass;
    public
      constructor Create(AValueType : TDefaultValueType);

      property ValueType : TDefaultValueType read FValueType;
  end;

  TDefaultValueAttribute<T> = class abstract (TDefaultValueAttribute)
    strict private
      FValue : T;
    public
      constructor Create(const AValue : T); overload;
      constructor Create; overload;

      property Value : T read FValue;
  end;

  function GetDefaultValue(DefValAttribute : TDefaultValueAttribute) : TValue;

  { Actual default value attribute classes }

  //TODO: define descedants

implementation

uses
  System.Generics.Collections;

type

  TDefaultsMap = class (TDictionary<TDefaultValueAttributeClass, TValue>)
    strict private
      class var FStaticInstance : TDefaultsMap;
    private
      class procedure FreeStaticInstance;
      class function  GetStaticInstance : TDefaultsMap; static;
    public
      class property StaticInstance : TDefaultsMap read GetStaticInstance;
  end;

{ Utils }

function GetDefaultValue(DefValAttribute : TDefaultValueAttribute) : TValue;
begin
  with TDefaultsMap.StaticInstance do
    if ContainsKey(DefValAttribute.GetClassType) then
      Result := Items[DefValAttribute.GetClassType]
    else
      Result := TValue.Empty;
end;

procedure RegisterDefaults;
begin
  with TDefaultsMap.StaticInstance do
  begin
    //TODO: fill value map with consts
  end;
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

constructor TDefaultValueAttribute.Create(AValueType : TDefaultValueType);
begin
  inherited Create;

  FValueType := AValueType;
end;

function TDefaultValueAttribute.GetClassType : TDefaultValueAttributeClass;
begin
  Pointer(Result) := PPointer(Self)^;
end;

{ TDefaultValueAttribute<T> }

constructor TDefaultValueAttribute<T>.Create(const AValue : T);
begin
  inherited Create(dvtStored);

  FValue := AValue;
end;

constructor TDefaultValueAttribute<T>.Create;
begin
  inherited Create(dvtEvaluable);
end;

initialization
  RegisterDefaults;

finalization
  TDefaultsMap.FreeStaticInstance;

end.
