unit FIToolkit.Config.Defaults;

interface

uses
  System.Generics.Collections, System.Rtti,
  FIToolkit.Config.Types;

type

  { Base classes }

  TDefaultValueAttributeClass = class of TDefaultValueAttribute;

  TDefaultValueAttribute = class abstract (TCustomAttribute)
    strict private
      FValueType : TDefaultValueKind;
    private
      function GetClassType : TDefaultValueAttributeClass;
    protected
      constructor Create(AValueType : TDefaultValueKind);
    public
      property ValueKind : TDefaultValueKind read FValueType;
  end;

  TDefaultValueAttribute<T> = class abstract (TDefaultValueAttribute)
    strict private
      FValue : T;
    private
      function GetValue : T;
    protected
      function CalculateValue : T; virtual;
    public
      constructor Create(const AValue : T); overload;
      constructor Create; overload;

      property Value : T read GetValue;
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

{ TDefaultsMap }

procedure TDefaultsMap.AddValue(DefValAttribClass : TDefaultValueAttributeClass; Value : TValue);
begin
  FInternalMap.Add(DefValAttribClass, Value);
end;

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

{ TDefaultValueAttribute }

constructor TDefaultValueAttribute.Create(AValueType : TDefaultValueKind);
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
  inherited Create(dvkData);

  FValue := AValue;
end;

constructor TDefaultValueAttribute<T>.Create;
begin
  inherited Create(dvkCalculated);
end;

function TDefaultValueAttribute<T>.CalculateValue : T;
  var
    V : TValue;
begin
  with TDefaultsMap.StaticInstance do
    if HasValue(Self.GetClassType) then
      V := GetValue(Self.GetClassType)
    else
      V := TValue.Empty;

  Result := V.AsType<T>;
end;

function TDefaultValueAttribute<T>.GetValue : T;
begin
  Result := Default(T);

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
