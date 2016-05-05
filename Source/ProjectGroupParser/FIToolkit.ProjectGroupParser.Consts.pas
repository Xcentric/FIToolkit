unit FIToolkit.ProjectGroupParser.Consts;

interface

const

  { Common consts }

  STR_PROJECT_FILE_EXTENSION = '.dpr';  // Do not localize!

  { XML consts for a project group file format. Do not localize! }

  // <Project>\<ItemGroup>\<Projects Include="%RELATIVE_PATH_TO_DPROJ%">
  STR_ROOT_NODE                  = 'Project';
  STR_PROJECTS_GROUP_NODE        = 'ItemGroup';
  STR_INCLUDED_PROJECT_NODE      = 'Projects';
  STR_INCLUDED_PROJECT_ATTRIBUTE = 'Include';

resourcestring

  { Exceptions }

  RSProjectGroupParseError = 'Ошибка при разборе файла группы проектов.';

implementation

end.
