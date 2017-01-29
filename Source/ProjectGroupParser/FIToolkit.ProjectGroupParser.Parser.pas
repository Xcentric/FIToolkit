unit FIToolkit.ProjectGroupParser.Parser;

interface

uses
  System.SysUtils, System.Types, Xml.XMLIntf;

type

  TProjectGroupParser = class sealed
    strict private
      FXML : IXMLDocument;
    private
      function GetIncludedProjects : TStringDynArray;
      function GetProjectGroupDir : String;
    public
      constructor Create(const FileName : TFileName);

      function GetIncludedProjectsFiles : TArray<TFileName>;
  end;

  TProjectParser = class sealed
    strict private
      FXML : IXMLDocument;
    private
      function GetMainSource : String;
    public
      constructor Create(const FileName : TFileName);

      function GetMainSourceFileName : TFileName;
  end;

implementation

uses
  System.IOUtils, Xml.XMLDoc, Winapi.ActiveX,
  FIToolkit.Commons.Utils,
  FIToolkit.ProjectGroupParser.Exceptions, FIToolkit.ProjectGroupParser.Consts;

{ TProjectGroupParser }

constructor TProjectGroupParser.Create(const FileName : TFileName);
begin
  inherited Create;

  try
    FXML := TXMLDocument.Create(FileName);
  except
    Exception.RaiseOuterException(EProjectGroupParseError.Create);
  end;
end;

function TProjectGroupParser.GetIncludedProjects : TStringDynArray;
var
  Root, ProjectsGroup, IncludedProject : IXMLNode;
  i : Integer;
begin
  try
    Root := FXML.Node.ChildNodes[STR_GPROJ_ROOT_NODE];

    if Assigned(Root) then
    begin
      ProjectsGroup := Root.ChildNodes[STR_GPROJ_PROJECTS_GROUP_NODE];

      if Assigned(ProjectsGroup) then
        repeat
          IncludedProject := ProjectsGroup.ChildNodes[STR_GPROJ_INCLUDED_PROJECT_NODE];

          if not Assigned(IncludedProject) then
            ProjectsGroup := ProjectsGroup.NextSibling;
        until Assigned(IncludedProject) or not Assigned(ProjectsGroup);

      if Assigned(ProjectsGroup) then
        for i := 0 to ProjectsGroup.ChildNodes.Count - 1 do
        begin
          IncludedProject := ProjectsGroup.ChildNodes.Get(i);

          if IncludedProject.HasAttribute(STR_GPROJ_INCLUDED_PROJECT_ATTRIBUTE) then
            Result := Result + [IncludedProject.Attributes[STR_GPROJ_INCLUDED_PROJECT_ATTRIBUTE]];
        end;
    end;
  except
    Exception.RaiseOuterException(EProjectGroupParseError.Create);
  end;

  if Length(Result) = 0 then
    raise EProjectGroupParseError.Create;
end;

function TProjectGroupParser.GetIncludedProjectsFiles : TArray<TFileName>;
var
  sRootDir, S : String;
begin
  Result   := [];
  sRootDir := GetProjectGroupDir;

  for S in GetIncludedProjects do
    with TProjectParser.Create(TPath.Combine(sRootDir, S)) do
      try
        Result := Result + [GetMainSourceFileName];
      finally
        Free;
      end;
end;

function TProjectGroupParser.GetProjectGroupDir : String;
begin
  Result := TPath.GetDirectoryName(FXML.FileName, True);
end;

{ TProjectParser }

constructor TProjectParser.Create(const FileName : TFileName);
begin
  inherited Create;

  try
    FXML := TXMLDocument.Create(FileName);
  except
    Exception.RaiseOuterException(EProjectParseError.Create);
  end;
end;

function TProjectParser.GetMainSource : String;
var
  Root, PropertyGroup, MainSource : IXMLNode;
begin
  Result := String.Empty;

  try
    Root := FXML.Node.ChildNodes[STR_DPROJ_ROOT_NODE];

    if Assigned(Root) then
    begin
      PropertyGroup := Root.ChildNodes[STR_DPROJ_PROPERTY_GROUP_NODE];

      if Assigned(PropertyGroup) then
        repeat
          MainSource := PropertyGroup.ChildNodes[STR_DPROJ_MAIN_SOURCE_NODE];

          if not Assigned(MainSource) then
            PropertyGroup := PropertyGroup.NextSibling;
        until Assigned(MainSource) or not Assigned(PropertyGroup);

      if Assigned(MainSource) then
        Result := MainSource.Text;
    end;
  except
    Exception.RaiseOuterException(EProjectParseError.Create);
  end;

  if Result.IsEmpty then
    raise EProjectParseError.Create;
end;

function TProjectParser.GetMainSourceFileName : TFileName;
begin
  Result := TPath.GetDirectoryName(FXML.FileName, True) + GetMainSource;
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
