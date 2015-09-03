unit FIToolkit.Config.Defaults;

interface

uses
  System.Generics.Collections, System.Rtti,
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
    protected
      constructor Create(AValueKind : TDefaultValueKind);

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

  TDefaultsMap = class
    strict private
      type
        TInternalMap = class (TDictionary<TDefaultValueAttributeClass, TValue>);
    strict private
      class var FStaticInstance : TDefaultsMap;

      FInternalMap : TInternalMap;
    private
      class procedure FreeStaticInstance; static;
      class function  GetStaticInstance : TDefaultsMap; static;
    public
      class property StaticInstance : TDefaultsMap read GetStaticInstance;

      constructor Create;
      destructor Destroy; override;

      procedure AddValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
      function  GetValue(DefValAttribClass : TDefaultValueAttributeClass) : TValue;
      function  HasValue(DefValAttribClass : TDefaultValueAttributeClass) : Boolean;
  end;

  procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);

implementation

uses
  System.SysUtils;

{ Utils }

procedure RegisterDefaultValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
begin
  TDefaultsMap.StaticInstance.AddValue(DefValAttribClass, Value);
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

constructor TDefaultsMap.Create;
begin
  inherited Create;

  FInternalMap := TInternalMap.Create;
end;

destructor TDefaultsMap.Destroy;
begin
  FreeAndNil(FInternalMap);

  inherited Destroy;
end;

procedure TDefaultsMap.AddValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
begin
  FInternalMap.Add(DefValAttribClass, Value);
end;

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

function TDefaultsMap.GetValue(DefValAttribClass : TDefaultValueAttributeClass) : TValue;
begin
  Result := FInternalMap.Items[DefValAttribClass];
end;

function TDefaultsMap.HasValue(DefValAttribClass : TDefaultValueAttributeClass) : Boolean;
begin
  Result := FInternalMap.ContainsKey(DefValAttribClass);
end;

initialization
  TDefaultsMap.GetStaticInstance;

finalization
  TDefaultsMap.FreeStaticInstance;

end.
