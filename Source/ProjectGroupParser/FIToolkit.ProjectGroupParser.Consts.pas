unit FIToolkit.ProjectGroupParser.Consts;

interface

const

  { XML consts for a project group file format. Do not localize! }

  // <Project>\<ItemGroup>\<Projects Include="%RELATIVE_PATH_TO_DPROJ%">
  STR_GPROJ_ROOT_NODE                  = 'Project';
  STR_GPROJ_PROJECTS_GROUP_NODE        = 'ItemGroup';
  STR_GPROJ_INCLUDED_PROJECT_NODE      = 'Projects';
  STR_GPROJ_INCLUDED_PROJECT_ATTRIBUTE = 'Include';

  { XML consts for a project file format. Do not localize! }

  // <Project>\<PropertyGroup>\<MainSource>
  STR_DPROJ_ROOT_NODE           = 'Project';
  STR_DPROJ_PROPERTY_GROUP_NODE = 'PropertyGroup';
  STR_DPROJ_MAIN_SOURCE_NODE    = 'MainSource';

resourcestring

  { Exceptions }

  RSProjectGroupParseError = 'Ошибка при разборе файла группы проектов.';
  RSProjectParseError = 'Ошибка при разборе файла проекта.';

implementation

end.
