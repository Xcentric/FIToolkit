unit FIToolkit.ProjectGroupParser.Parser;

interface

uses
  System.SysUtils, System.Types, Xml.XMLIntf, Xml.XMLDoc;

type

  TProjectGroupParser = class
    private
      const
        STR_ROOT_NODE                  = 'Project';
        STR_PROJECTS_GROUP_NODE        = 'ItemGroup';
        STR_INCLUDED_PROJECT_NODE      = 'Projects';
        STR_INCLUDED_PROJECT_ATTRIBUTE = 'Include';

        STR_PROJECT_FILE_EXTENSION = '.dpr';
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
  System.IOUtils;

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
end;

function TProjectGroupParser.GetIncludedProjectsFiles : TStringDynArray;
var
  sRootDir, S : String;
begin
  sRootDir := GetProjectGroupDir;

  for S in GetIncludedProjects do
    Result := Result + [sRootDir + TPath.ChangeExtension(S, STR_PROJECT_FILE_EXTENSION)];
end;

function TProjectGroupParser.GetProjectGroupDir : String;
begin
  Result := IncludeTrailingPathDelimiter(TPath.GetDirectoryName(FXML.FileName));
end;

end.
