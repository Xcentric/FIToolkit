﻿unit FIToolkit.Consts;

interface

uses
  System.SysUtils,
  FIToolkit.Types,
  FIToolkit.Commons.Consts, FIToolkit.CommandLine.Consts,
  FIToolkit.Localization;

const

  { About }

  STR_APP_ABOUT_STRIP = '----------------------------------------------------------------------';
  STR_APP_COPYRIGHT_HOLDER = 'Xcentric <true.xcentric@gmail.com>';
  STR_APP_COPYRIGHT_TEXT = ' Copyright (c) 2017 ' + STR_APP_COPYRIGHT_HOLDER;
  STR_APP_DESCRIPTION = ' A set of tools for TMS Software(R) FixInsight(TM).';
  STR_APP_TITLE = 'FIToolkit';
  STR_APP_TITLE_ALIGNED = '                           ' + STR_APP_TITLE;

  { Common consts }

  ARR_APPCOMMAND_TO_CLIOPTION_MAPPING : array [TApplicationCommand] of String = (
    String.Empty,
    //
    STR_CLI_OPTION_HELP, STR_CLI_OPTION_VERSION, STR_CLI_OPTION_GENERATE_CONFIG, STR_CLI_OPTION_SET_CONFIG,
    STR_CLI_OPTION_NO_EXIT, STR_CLI_OPTION_LOG_FILE,
    //
    String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty,
    //
    String.Empty
  );

  ARR_CASE_SENSITIVE_CLI_OPTIONS : TArray<String> = [];

  ARR_CLIOPTION_PROCESSING_ORDER : TArray<String> = [
    // Fixed order. Do not change!
    STR_CLI_OPTION_NO_EXIT,
    STR_CLI_OPTION_LOG_FILE,
    // Changeable order below.
    STR_CLI_OPTION_HELP,
    STR_CLI_OPTION_VERSION,
    STR_CLI_OPTION_GENERATE_CONFIG,
    STR_CLI_OPTION_SET_CONFIG
  ];

  ARR_INPUT_FILE_TYPE_TO_EXT_MAPPING : array [TInputFileType] of String = (
    String.Empty, '.dpr', '.dpk', '.dproj', '.groupproj'  // Do not localize!
  );

  ARR_INITIAL_APPSTATES : TArray<TApplicationState> = [asInitial, asNoExitBehaviorSet, asLogFileSet];
  SET_FINAL_APPSTATES : set of TApplicationState =
    [asFinal, asHelpPrinted, asVersionPrinted, asConfigGenerated];

  STR_ARCHIVE_FILE_EXT = '.zip';
  STR_CMD_LINE_SWITCH_DEBUG = 'debug';

  { Exit codes }

  UINT_EC_NO_ERROR                = 0;
  UINT_EC_ERROR_OCCURRED          = 1;
  UINT_EC_ANALYSIS_MESSAGES_FOUND = 2;

  { Resources. Do not localize! }

  STR_RES_HELP = 'HelpOutput';

resourcestring

  { About }

  RSApplicationAbout =
    STR_APP_ABOUT_STRIP + sLineBreak +
    STR_APP_TITLE_ALIGNED + sDualBreak + STR_APP_DESCRIPTION + sDualBreak + STR_APP_COPYRIGHT_TEXT + sLineBreak +
    STR_APP_ABOUT_STRIP + sLineBreak;

  {$IF LANGUAGE = LANG_EN_US}
    {$INCLUDE 'Locales\en-US.inc'}
  {$ELSEIF LANGUAGE = LANG_RU_RU}
    {$INCLUDE 'Locales\ru-RU.inc'}
  {$ELSE}
    {$MESSAGE FATAL 'No language defined!'}
  {$ENDIF}

implementation

end.
