unit FIToolkit.ProjectGroupParser.Parser;

interface

uses
  System.SysUtils, System.Types, Xml.XMLIntf, Xml.XMLDoc,
  FIToolkit.ProjectGroupParser.Consts;

type

  TProjectGroupParser = class
    strict private
      FXML : IXMLDocument;
    private
      function GetIncludedProjects : TStringDynArray;
      function GetProjectGroupDir : String;
    public
      constructor Create(const FileName : TFileName);

      function GetIncludedProjectsFiles : TStringDynArray;
  end;

implementation

uses
  System.IOUtils,
  FIToolkit.ProjectGroupParser.Exceptions;

{ TProjectGroupParser }

constructor TProjectGroupParser.Create(const FileName : TFileName);
begin
  inherited Create;

  FXML := TXMLDocument.Create(FileName);
end;

function TProjectGroupParser.GetIncludedProjects : TStringDynArray;
var
  Root, ProjectsGroup, IncludedProject : IXMLNode;
  i : Integer;
begin
  try
    Root := FXML.Node.ChildNodes[STR_ROOT_NODE];

    if Assigned(Root) then
    begin
      ProjectsGroup := Root.ChildNodes[STR_PROJECTS_GROUP_NODE];

      if Assigned(ProjectsGroup) then
        for i := 0 to ProjectsGroup.ChildNodes.Count - 1 do
        begin
          IncludedProject := ProjectsGroup.ChildNodes.Get(i);

          if AnsiSameText(IncludedProject.NodeName, STR_INCLUDED_PROJECT_NODE) and
             IncludedProject.HasAttribute(STR_INCLUDED_PROJECT_ATTRIBUTE)
          then
            Result := Result + [IncludedProject.Attributes[STR_INCLUDED_PROJECT_ATTRIBUTE]];
        end;
    end;
  except
    Exception.RaiseOuterException(EProjectGroupParseError.Create);
  end;

  if Length(Result) = 0 then
    raise EProjectGroupParseError.Create;
end;

function TProjectGroupParser.GetIncludedProjectsFiles : TStringDynArray;
var
  sRootDir, S : String;
begin
  Result := [];
  sRootDir := GetProjectGroupDir;

  for S in GetIncludedProjects do
    Result := Result + [sRootDir + TPath.ChangeExtension(S, STR_PROJECT_FILE_EXTENSION)];
end;

function TProjectGroupParser.GetProjectGroupDir : String;
begin
  if FXML.FileName.IsEmpty then
    Result := String.Empty
  else
    Result := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(FXML.FileName));
end;

end.
