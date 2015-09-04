unit FIToolkit.Config.Manager;

interface

uses
  System.SysUtils, System.Rtti,
  FIToolkit.Config.Data, FIToolkit.Config.Storage;

type

  TConfigManager = class
    strict private
      FConfigData : TConfigData;
      FConfigFile : TConfigFile;
    private
      type
        TFilterPropPredicate = reference to function (const Instance : TObject; const Prop : TRttiProperty) : Boolean;
    private
      function  FilterConfigProp(const Instance : TObject; const Prop : TRttiProperty) : Boolean;
      function  GetPropDefaultValue(const Prop : TRttiProperty) : TValue;
      procedure ReadObjectFromConfig(const Instance : TObject; Filter : TFilterPropPredicate);
      procedure SetObjectPropsDefaults(const Instance : TObject);
      procedure WriteObjectToConfig(const Instance : TObject; Filter : TFilterPropPredicate);
    protected
      procedure FillDataFromFile;
      procedure FillFileFromData;
      procedure GenerateDefaultConfig;
      procedure SetDefaults;
    public
      constructor Create(const ConfigFileName : TFileName; GenerateConfig, Validate : Boolean);
      destructor Destroy; override;

      property ConfigData : TConfigData read FConfigData;
  end;

implementation

uses
  System.TypInfo,
  FIToolkit.Config.FixInsight, FIToolkit.Config.Types, FIToolkit.Config.Defaults;

{ TConfigManager }

constructor TConfigManager.Create(const ConfigFileName : TFileName; GenerateConfig, Validate : Boolean);
begin
  inherited Create;

  FConfigData := TConfigData.Create;
  FConfigData.Validate := Validate;
  FConfigData.FixInsightOptions.Validate := Validate;

  FConfigFile := TConfigFile.Create(ConfigFileName, GenerateConfig);

  if GenerateConfig then
    GenerateDefaultConfig;
end;

destructor TConfigManager.Destroy;
begin
  FreeAndNil(FConfigData);
  FreeAndNil(FConfigFile);

  inherited Destroy;
end;

procedure TConfigManager.FillDataFromFile;
begin
  FConfigFile.Load;
  ReadObjectFromConfig(FConfigData,
    function (const Instance : TObject; const Prop : TRttiProperty) : Boolean
    begin
      Result := Prop.IsWritable and FilterConfigProp(Instance, Prop);
    end
  );
end;

procedure TConfigManager.FillFileFromData;
begin
  WriteObjectToConfig(FConfigData,
    function (const Instance : TObject; const Prop : TRttiProperty) : Boolean
    begin
      Result := Prop.IsReadable and FilterConfigProp(Instance, Prop);
    end
  );
  FConfigFile.Save;
end;

function TConfigManager.FilterConfigProp(const Instance : TObject; const Prop : TRttiProperty) : Boolean;
  var
    Attr : TCustomAttribute;
begin
  Result := False;

  for Attr in Prop.GetAttributes do
  begin
    Result := ((Instance is TConfigData) and (Attr is FIToolkitParam)) or
              ((Instance is TFixInsightOptions) and (Attr is FixInsightParam));

    if Result then
      Break;
  end;
end;

procedure TConfigManager.GenerateDefaultConfig;
begin
  SetDefaults;
  FillFileFromData;
end;

function TConfigManager.GetPropDefaultValue(const Prop : TRttiProperty) : TValue;
  var
    Attr : TCustomAttribute;
begin
  Result := TValue.Empty;

  for Attr in Prop.GetAttributes do
    if Attr is TDefaultValueAttribute then
    begin
      Result := TDefaultValueAttribute(Attr).Value;
      if not Result.IsEmpty then
        Break;
    end;
end;

procedure TConfigManager.ReadObjectFromConfig(const Instance : TObject; Filter : TFilterPropPredicate);
  var
    Ctx : TRttiContext;
    InstanceType : TRttiInstanceType;
    Prop : TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  try
    InstanceType := Ctx.GetType(Instance.ClassType) as TRttiInstanceType;

    for Prop in InstanceType.GetProperties do
      if Filter(Instance, Prop) then
      begin
        if Prop.PropertyType.IsInstance then
          ReadObjectFromConfig(Prop.GetValue(Instance).AsObject, Filter)
        else
        if Prop.PropertyType.IsOrdinal then
          Prop.SetValue(Instance, FConfigFile.Config.ReadInteger(Instance.QualifiedClassName, Prop.Name,
                                                                 GetPropDefaultValue(Prop).AsVariant))
        else
          case Prop.PropertyType.TypeKind of
            tkString, tkLString, tkWString, tkUString:
              Prop.SetValue(Instance, FConfigFile.Config.ReadString(Instance.QualifiedClassName, Prop.Name,
                                                                    GetPropDefaultValue(Prop).AsVariant));
          else
            Assert(False, 'Unhandled property type kind while deserializing object from config.');
          end;
      end;
  finally
    Ctx.Free;
  end;
end;

procedure TConfigManager.SetDefaults;
begin
  SetObjectPropsDefaults(FConfigData);
end;

procedure TConfigManager.SetObjectPropsDefaults(const Instance : TObject);
  var
    Ctx : TRttiContext;
    InstanceType : TRttiInstanceType;
    Prop : TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  try
    InstanceType := Ctx.GetType(Instance.ClassType) as TRttiInstanceType;

    for Prop in InstanceType.GetProperties do
      if Prop.PropertyType.IsInstance then
        SetObjectPropsDefaults(Prop.GetValue(Instance).AsObject)
      else
        Prop.SetValue(Instance, GetPropDefaultValue(Prop));
  finally
    Ctx.Free;
  end;
end;

procedure TConfigManager.WriteObjectToConfig(const Instance : TObject; Filter : TFilterPropPredicate);
  var
    Ctx : TRttiContext;
    InstanceType : TRttiInstanceType;
    Prop : TRttiProperty;
begin
  Ctx := TRttiContext.Create;
  try
    InstanceType := Ctx.GetType(Instance.ClassType) as TRttiInstanceType;

    for Prop in InstanceType.GetProperties do
      if Filter(Instance, Prop) then
      begin
        if Prop.PropertyType.IsInstance then
          WriteObjectToConfig(Prop.GetValue(Instance).AsObject, Filter)
        else
        if Prop.PropertyType.IsOrdinal then
          FConfigFile.Config.WriteInteger(Instance.QualifiedClassName, Prop.Name, Prop.GetValue(Instance).AsVariant)
        else
          case Prop.PropertyType.TypeKind of
            tkString, tkLString, tkWString, tkUString:
              FConfigFile.Config.WriteString(Instance.QualifiedClassName, Prop.Name, Prop.GetValue(Instance).AsString);
          else
            Assert(False, 'Unhandled property type kind while serializing object to config.');
          end;
      end;
  finally
    Ctx.Free;
  end;
end;

end.
