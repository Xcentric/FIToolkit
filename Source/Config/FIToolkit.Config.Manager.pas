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
      procedure GenerateDefaultConfig;
      procedure ReadObjectFromConfig(const Instance : TObject; Filter : TFilterPropPredicate);
      procedure WriteObjectToConfig(const Instance : TObject; Filter : TFilterPropPredicate);
    protected
      procedure FillDataFromFile;
      procedure FillFileFromData;
      procedure SetDefaults;
    public
      constructor Create(const ConfigFileName : TFileName; GenerateConfig, Validate : Boolean);
      destructor Destroy; override;

      property ConfigData : TConfigData read FConfigData;
  end;

implementation

uses
  System.TypInfo,
  FIToolkit.Config.FixInsight, FIToolkit.Config.Types;

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
          //TODO: third patameter must be a routine for getting the default value (parameterized?)
          Prop.SetValue(Instance, FConfigFile.Config.ReadInteger(Instance.QualifiedClassName, Prop.Name, 0))
        else
          case Prop.PropertyType.TypeKind of
            tkString, tkLString, tkWString, tkUString:
              //TODO: third patameter must be a routine for getting the default value (parameterized?)
              Prop.SetValue(Instance, FConfigFile.Config.ReadString(Instance.QualifiedClassName, Prop.Name, String.Empty));
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
