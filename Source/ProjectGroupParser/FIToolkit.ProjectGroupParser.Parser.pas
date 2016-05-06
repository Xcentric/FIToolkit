unit FIToolkit.ProjectGroupParser.Parser;

interface

uses
  System.SysUtils, System.Types, Xml.XMLIntf, Xml.XMLDoc,
  FIToolkit.ProjectGroupParser.Consts;

type

  TProjectGroupParser = class sealed
    strict private
      FXML : IXMLDocument;
    private
      function GetIncludedProjects : TStringDynArray;
      function GetProjectGroupDir : String;
    public
      constructor Create(const FileName : TFileName);

      function GetIncludedProjectsFiles : TStringDynArray;
  end;

  TProjectParser = class sealed
    strict private
      FXML : IXMLDocument;
    public
      constructor Create(const FileName : TFileName);

      function GetMainSourceFileName : TFileName;
  end;

implementation

uses
  System.IOUtils,
  FIToolkit.Commons.Utils,
  FIToolkit.ProjectGroupParser.Exceptions;

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
        for i := 0 to ProjectsGroup.ChildNodes.Count - 1 do
        begin
          IncludedProject := ProjectsGroup.ChildNodes.Get(i);

          if AnsiSameText(IncludedProject.NodeName, STR_GPROJ_INCLUDED_PROJECT_NODE) and
             IncludedProject.HasAttribute(STR_GPROJ_INCLUDED_PROJECT_ATTRIBUTE)
          then
            Result := Result + [IncludedProject.Attributes[STR_GPROJ_INCLUDED_PROJECT_ATTRIBUTE]];
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

  //TODO: implement {EXTRACT CORRECT PROJECT FILE NAME !!! DPR/DPK !!!}
  for S in GetIncludedProjects do
    Result := Result + [sRootDir + S];
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

function TProjectParser.GetMainSourceFileName : TFileName;
begin
  //TODO: implement {GetMainSourceFileName}
end;

end.
