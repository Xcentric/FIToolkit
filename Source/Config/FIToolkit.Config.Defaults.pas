unit FIToolkit.Config.Defaults;

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections,
  FIToolkit.Config.Types;

type

  TDefaultValueAttributeClass = class of TDefaultValueAttribute;

  TDefaultValueAttribute = class abstract (TCustomAttribute)
    strict private
      FValueKind : TDefaultValueKind;
    private
      function GetClassType : TDefaultValueAttributeClass;

      function GetValue : TValue;
    strict protected
      FValue : TValue;

      constructor Create(AValueKind : TDefaultValueKind);
    protected
      function CalculateValue : TValue; virtual;
    public
      property Value : TValue read GetValue;
      property ValueKind : TDefaultValueKind read FValueKind;
  end;

  TDefaultValueAttribute<T> = class abstract (TDefaultValueAttribute)
    protected
      function MakeValue(const AValue : T) : TValue; virtual;
    public
      constructor Create(const AValue : T); overload;
      constructor Create; overload;
  end;

  TDefaultsMap = class sealed
    strict private
      type
        TInternalMap = class (TDictionary<TDefaultValueAttributeClass, TValue>);
    strict private
      class var
        FInternalMap : TInternalMap;
        FStaticInstance : TDefaultsMap;
    private
      class procedure FreeStaticInstance; static;
      class function  GetStaticInstance : TDefaultsMap; static;
    protected
      class property StaticInstance : TDefaultsMap read GetStaticInstance;
    public
      class procedure AddValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
      class function  GetValue(DefValAttribClass : TDefaultValueAttributeClass) : TValue;
      class function  HasValue(DefValAttribClass : TDefaultValueAttributeClass) : Boolean;
  end;

  procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue); overload;
  procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass;
    const Evaluator : TFunc<TValue>); overload;

implementation

{ Utils }

procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
begin
  TDefaultsMap.StaticInstance.AddValue(DefValAttribClass, Value);
end;

procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; const Evaluator : TFunc<TValue>);
begin
  RegisterDefaultValue(DefValAttribClass, Evaluator());
end;

{ TDefaultValueAttribute }

constructor TDefaultValueAttribute.Create(AValueKind : TDefaultValueKind);
begin
  inherited Create;

  FValue := TValue.Empty;
  FValueKind := AValueKind;
end;

function TDefaultValueAttribute.CalculateValue : TValue;
begin
  with TDefaultsMap.StaticInstance do
    if HasValue(Self.GetClassType) then
      Result := GetValue(Self.GetClassType)
    else
      Result := TValue.Empty;
end;

function TDefaultValueAttribute.GetClassType : TDefaultValueAttributeClass;
begin
  Result := TDefaultValueAttributeClass(ClassType);
end;

function TDefaultValueAttribute.GetValue : TValue;
begin
  Result := TValue.Empty;

  case FValueKind of
    dvkData:
      Result := FValue;
    dvkCalculated:
      Result := CalculateValue;
  else
    Assert(False, 'Unhandled default value kind while getting value.');
  end;
end;

{ TDefaultValueAttribute<T> }

constructor TDefaultValueAttribute<T>.Create(const AValue : T);
begin
  inherited Create(dvkData);

  FValue := MakeValue(AValue);
end;

constructor TDefaultValueAttribute<T>.Create;
begin
  inherited Create(dvkCalculated);
end;

function TDefaultValueAttribute<T>.MakeValue(const AValue : T) : TValue;
begin
  Result := TValue.From<T>(AValue);
end;

{ TDefaultsMap }

class procedure TDefaultsMap.AddValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
begin
  StaticInstance.FInternalMap.Add(DefValAttribClass, Value);
end;

class procedure TDefaultsMap.FreeStaticInstance;
begin
  FreeAndNil(FInternalMap);
  FreeAndNil(FStaticInstance);
end;

class function TDefaultsMap.GetStaticInstance : TDefaultsMap;
begin
  if not Assigned(FInternalMap) then
    FInternalMap := TInternalMap.Create;

  if not Assigned(FStaticInstance) then
    FStaticInstance := TDefaultsMap.Create;

  Result := FStaticInstance;
end;

class function TDefaultsMap.GetValue(DefValAttribClass : TDefaultValueAttributeClass) : TValue;
begin
  Result := StaticInstance.FInternalMap.Items[DefValAttribClass];
end;

class function TDefaultsMap.HasValue(DefValAttribClass : TDefaultValueAttributeClass) : Boolean;
begin
  Result := StaticInstance.FInternalMap.ContainsKey(DefValAttribClass);
end;

initialization
  TDefaultsMap.GetStaticInstance;

finalization
  TDefaultsMap.FreeStaticInstance;

end.
