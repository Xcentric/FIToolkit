unit FIToolkit.Config.Manager;

interface

uses
  System.SysUtils, System.Rtti,
  FIToolkit.Config.Data, FIToolkit.Config.Storage;

type

  TConfigManager = class sealed
    strict private
      FConfigData : TConfigData;
      FConfigFile : TConfigFile;
    private
      type
        TFilterPropPredicate = reference to function (Instance : TObject; Prop : TRttiProperty) : Boolean;
      const
        CHR_ARRAY_DELIMITER = ',';
    private
      function  FilterConfigProp(Instance : TObject; Prop : TRttiProperty) : Boolean;
      function  GetConfigFileName : TFileName;
      function  GetPropDefaultValue(Prop : TRttiProperty) : TValue;
      procedure ReadObjectFromConfig(Instance : TObject; const Filter : TFilterPropPredicate);
      procedure SetObjectPropsDefaults(Instance : TObject);
      procedure WriteObjectToConfig(Instance : TObject; const Filter : TFilterPropPredicate);
    protected
      procedure FillDataFromFile;
      procedure FillFileFromData;
      procedure GenerateDefaultConfig;
      procedure SetDefaults;
    public
      constructor Create(const ConfigFileName : TFileName; GenerateConfig, Validate : Boolean);
      destructor Destroy; override;

      property ConfigData : TConfigData read FConfigData;
      property ConfigFileName : TFileName read GetConfigFileName;
  end;

implementation

uses
  System.TypInfo, System.Classes,
  FIToolkit.Config.FixInsight, FIToolkit.Config.Defaults, FIToolkit.Config.Types, FIToolkit.Commons.Utils;

{ TConfigManager }

constructor TConfigManager.Create(const ConfigFileName : TFileName; GenerateConfig, Validate : Boolean);
begin
  inherited Create;

  FConfigData := TConfigData.Create;
  FConfigData.Validate := Validate;
  FConfigData.FixInsightOptions.Validate := Validate;

  FConfigFile := TConfigFile.Create(ConfigFileName, GenerateConfig);

  if GenerateConfig then
    GenerateDefaultConfig
  else
  if FConfigFile.HasFile then
    FillDataFromFile
  else
    SetDefaults;
end;

destructor TConfigManager.Destroy;
begin
  FreeAndNil(FConfigFile);
  FreeAndNil(FConfigData);

  inherited Destroy;
end;

procedure TConfigManager.FillDataFromFile;
begin
  FConfigFile.Load;
  ReadObjectFromConfig(FConfigData,
    function (Instance : TObject; Prop : TRttiProperty) : Boolean
    begin
      Result := (Prop.IsWritable or Prop.PropertyType.IsInstance) and FilterConfigProp(Instance, Prop);
    end
  );
end;

procedure TConfigManager.FillFileFromData;
begin
  WriteObjectToConfig(FConfigData,
    function (Instance : TObject; Prop : TRttiProperty) : Boolean
    begin
      Result := Prop.IsReadable and FilterConfigProp(Instance, Prop);
    end
  );
  FConfigFile.Save;
end;

function TConfigManager.FilterConfigProp(Instance : TObject; Prop : TRttiProperty) : Boolean;
var
  Attr : TCustomAttribute;
begin
  Result := False;

  for Attr in Prop.GetAttributes do
    if Attr is TConfigAttribute then
      if TConfigAttribute(Attr).Serializable then
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

function TConfigManager.GetConfigFileName : TFileName;
begin
  Result := FConfigFile.FileName;
end;

function TConfigManager.GetPropDefaultValue(Prop : TRttiProperty) : TValue;
var
  Attr : TCustomAttribute;
begin
  Result := TValue.Empty;

  for Attr in Prop.GetAttributes do
    if Attr is TDefaultValueAttribute then
      Exit(TDefaultValueAttribute(Attr).Value);
end;

procedure TConfigManager.ReadObjectFromConfig(Instance : TObject; const Filter : TFilterPropPredicate);
var
  Ctx : TRttiContext;
  InstanceType : TRttiInstanceType;
  Prop : TRttiProperty;
  i : Integer;
  V : TValue;
  sArray : String;
  arrS : TArray<String>;
  arrV : TArray<TValue>;
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
        if Prop.PropertyType.IsString then
          Prop.SetValue(Instance, FConfigFile.Config.ReadString(Instance.QualifiedClassName, Prop.Name,
                                                                GetPropDefaultValue(Prop).AsVariant))
        else
        if Prop.PropertyType.IsOrdinal then
        begin
          i := FConfigFile.Config.ReadInteger(Instance.QualifiedClassName, Prop.Name,
                                              GetPropDefaultValue(Prop).AsVariant);
          TValue.Make(@i, Prop.PropertyType.Handle, V);
          Prop.SetValue(Instance, V);
        end
        else
        if Prop.PropertyType.IsArray then
        begin
          sArray := FConfigFile.Config.ReadString(Instance.QualifiedClassName, Prop.Name, String.Empty);

          if sArray.IsEmpty then
          begin
            if FConfigFile.Config.ValueExists(Instance.QualifiedClassName, Prop.Name) then
              V := TValue.Empty
            else
              V := GetPropDefaultValue(Prop);
          end
          else
          if Prop.PropertyType.Handle.TypeData.DynArrElType^.IsString then
          begin
            arrS := sArray.Split([CHR_ARRAY_DELIMITER], ExcludeEmpty);

            SetLength(arrV, Length(arrS));
            for i := 0 to High(arrV) do
              arrV[i] := arrS[i].Trim;

            V := TValue.FromArray(Prop.PropertyType.Handle, arrV);
          end
          else
            Assert(False, 'Unhandled array element type while deserializing object from config.');

          Prop.SetValue(Instance, V);
        end
        else
          Assert(False, 'Unhandled property type kind while deserializing object from config.');
      end;
  finally
    Ctx.Free;
  end;
end;

procedure TConfigManager.SetDefaults;
var
  bValidateCD, bValidateFI : Boolean;
begin
  bValidateCD := FConfigData.Validate;
  bValidateFI := FConfigData.FixInsightOptions.Validate;
  try
    FConfigData.Validate := False;
    FConfigData.FixInsightOptions.Validate := False;

    SetObjectPropsDefaults(FConfigData);
  finally
    FConfigData.Validate := bValidateCD;
    FConfigData.FixInsightOptions.Validate := bValidateFI;
  end;
end;

procedure TConfigManager.SetObjectPropsDefaults(Instance : TObject);
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
      if Prop.IsWritable then
        Prop.SetValue(Instance, GetPropDefaultValue(Prop));
  finally
    Ctx.Free;
  end;
end;

procedure TConfigManager.WriteObjectToConfig(Instance : TObject; const Filter : TFilterPropPredicate);
var
  Ctx : TRttiContext;
  InstanceType : TRttiInstanceType;
  Prop : TRttiProperty;
  S : String;
  V : TValue;
  i : Integer;
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
        if Prop.PropertyType.IsString then
          FConfigFile.Config.WriteString(Instance.QualifiedClassName, Prop.Name, Prop.GetValue(Instance).AsVariant)
        else
        if Prop.PropertyType.IsOrdinal then
          FConfigFile.Config.WriteInteger(Instance.QualifiedClassName, Prop.Name, Prop.GetValue(Instance).AsVariant)
        else
        if Prop.PropertyType.IsArray then
        begin
          S := String.Empty;
          V := Prop.GetValue(Instance);

          for i := 0 to V.GetArrayLength - 1 do
            if S.IsEmpty then
              S := V.GetArrayElement(i).ToString
            else
              S := S + CHR_ARRAY_DELIMITER + V.GetArrayElement(i).ToString;

          FConfigFile.Config.WriteString(Instance.QualifiedClassName, Prop.Name, S);
        end
        else
          Assert(False, 'Unhandled property type kind while serializing object to config.');
      end;
  finally
    Ctx.Free;
  end;
end;

end.
