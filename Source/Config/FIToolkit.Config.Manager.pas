unit FIToolkit.Config.Manager;

interface

uses
  System.SysUtils, System.Rtti,
  FIToolkit.Config.Data, FIToolkit.Config.Storage, FIToolkit.Config.Types, FIToolkit.Commons.Types;

type

  TConfigManager = class sealed
    strict private
      FConfigData : TConfigData;
      FConfigFile : TConfigFile;
    private
      function  FilterConfigProp(Instance : TObject; Prop : TRttiProperty) : Boolean;
      function  FindConfigAttribute(Prop : TRttiProperty; out Value : TConfigAttribute) : Boolean;
      function  GetConfigFileName : TFileName;
      function  GetConfigPropArrayDelimiter(Prop : TRttiProperty) : String;
      function  GetPropDefaultValue(Prop : TRttiProperty) : TValue;
      function  PropHasDefaultValue(Prop : TRttiProperty) : Boolean;
      procedure ReadObjectFromConfig(Instance : TObject; const Filter : TObjectPropertyFilter);
      procedure SetObjectPropsDefaults(Instance : TObject; const Filter : TObjectPropertyFilter);
      procedure WriteObjectToConfig(Instance : TObject; const Filter : TObjectPropertyFilter);
    protected
      procedure FillDataFromFile;
      procedure FillFileFromData;
      procedure GenerateDefaultConfig;
      procedure SetDefaults(TargetProps : TConfigPropCategory);
    public
      constructor Create(const ConfigFileName : TFileName; GenerateConfig, Validate : Boolean);
      destructor Destroy; override;

      property ConfigData : TConfigData read FConfigData;
      property ConfigFileName : TFileName read GetConfigFileName;
  end;

implementation

uses
  System.TypInfo,
  FIToolkit.Config.FixInsight, FIToolkit.Config.Defaults, FIToolkit.Config.Consts,
  FIToolkit.Commons.Utils;

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
  begin
    SetDefaults(cpcNonSerializable);
    FillDataFromFile;
  end
  else
    SetDefaults(cpcAny);
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
  CfgAttr : TConfigAttribute;
begin
  Result := False;

  if FindConfigAttribute(Prop, CfgAttr) then
    if CfgAttr.Serializable then
      Result := ((Instance is TConfigData) and (CfgAttr is FIToolkitParam)) or
                ((Instance is TFixInsightOptions) and (CfgAttr is FixInsightParam));
end;

function TConfigManager.FindConfigAttribute(Prop : TRttiProperty; out Value : TConfigAttribute) : Boolean;
var
  Attr : TCustomAttribute;
begin
  Result := False;

  for Attr in Prop.GetAttributes do
    if Attr is TConfigAttribute then
    begin
      Value := TConfigAttribute(Attr);
      Exit(True);
    end;
end;

procedure TConfigManager.GenerateDefaultConfig;
begin
  SetDefaults(cpcSerializable);
  FillFileFromData;
end;

function TConfigManager.GetConfigFileName : TFileName;
begin
  Result := FConfigFile.FileName;
end;

function TConfigManager.GetConfigPropArrayDelimiter(Prop : TRttiProperty) : String;
var
  CfgAttr : TConfigAttribute;
begin
  Result := String.Empty;

  if FindConfigAttribute(Prop, CfgAttr) then
    Result := CfgAttr.ArrayDelimiter;

  Assert(not (Prop.PropertyType.IsArray and Result.IsEmpty),
    Format('Property %s has an array type but no array delimiter.', [Prop.Name]));
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

function TConfigManager.PropHasDefaultValue(Prop : TRttiProperty) : Boolean;
var
  Attr : TCustomAttribute;
begin
  Result := False;

  for Attr in Prop.GetAttributes do
    if Attr is TDefaultValueAttribute then
      Exit(True);
end;

procedure TConfigManager.ReadObjectFromConfig(Instance : TObject; const Filter : TObjectPropertyFilter);  //FI:C103
var
  Ctx : TRttiContext;
  InstanceType : TRttiInstanceType;
  Prop : TRttiProperty;
  i : Integer;
  V : TValue;
  sArray : String;
  arrS : TArray<String>;
  arrV : TArray<TValue>;
begin //FI:C101
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
            arrS := sArray.Split([GetConfigPropArrayDelimiter(Prop)], ExcludeEmpty);

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

procedure TConfigManager.SetDefaults(TargetProps : TConfigPropCategory);
var
  bValidateCD, bValidateFI : Boolean;
  Filter : TObjectPropertyFilter;
begin
  bValidateCD := FConfigData.Validate;
  bValidateFI := FConfigData.FixInsightOptions.Validate;
  try
    FConfigData.Validate := False;
    FConfigData.FixInsightOptions.Validate := False;

    case TargetProps of
      cpcAny:
        Filter :=
          function (Instance : TObject; Prop : TRttiProperty) : Boolean
          begin
            Result := PropHasDefaultValue(Prop);
          end;
      cpcSerializable:
        Filter :=
          function (Instance : TObject; Prop : TRttiProperty) : Boolean
          var
            CfgAttr : TConfigAttribute;
          begin
            Result := PropHasDefaultValue(Prop);

            if Result and FindConfigAttribute(Prop, CfgAttr) then
              Result := CfgAttr.Serializable;
          end;
      cpcNonSerializable:
        Filter :=
          function (Instance : TObject; Prop : TRttiProperty) : Boolean
          var
            CfgAttr : TConfigAttribute;
          begin
            Result := PropHasDefaultValue(Prop);

            if Result and FindConfigAttribute(Prop, CfgAttr) then
              Result := not CfgAttr.Serializable;
          end;
    end;

    SetObjectPropsDefaults(FConfigData, Filter);
  finally
    FConfigData.Validate := bValidateCD;
    FConfigData.FixInsightOptions.Validate := bValidateFI;
  end;
end;

procedure TConfigManager.SetObjectPropsDefaults(Instance : TObject; const Filter : TObjectPropertyFilter);
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
        SetObjectPropsDefaults(Prop.GetValue(Instance).AsObject, Filter)
      else
      if Prop.IsWritable and Filter(Instance, Prop) then
        Prop.SetValue(Instance, GetPropDefaultValue(Prop));
  finally
    Ctx.Free;
  end;
end;

procedure TConfigManager.WriteObjectToConfig(Instance : TObject; const Filter : TObjectPropertyFilter);
var
  Ctx : TRttiContext;
  InstanceType : TRttiInstanceType;
  Prop : TRttiProperty;
  S, sArrDelim : String;
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
          sArrDelim := GetConfigPropArrayDelimiter(Prop);

          for i := 0 to V.GetArrayLength - 1 do
            if S.IsEmpty then
              S := V.GetArrayElement(i).ToString
            else
              S := S + sArrDelim + V.GetArrayElement(i).ToString;

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
