unit FIToolkit.ProjectGroupParser.Consts;

interface

uses
  FIToolkit.Localization;

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

  {$IF LANGUAGE = LANG_EN_US}
    {$INCLUDE 'Locales\en-US.inc'}
  {$ELSEIF LANGUAGE = LANG_RU_RU}
    {$INCLUDE 'Locales\ru-RU.inc'}
  {$ELSE}
    {$MESSAGE FATAL 'No language defined!'}
  {$IFEND}

implementation

end.
