unit FIToolkit.Commons.Consts;

interface

uses
  FIToolkit.Localization;

const

  { Common consts }

  sDualBreak = sLineBreak + sLineBreak;

  { FixInsight registry consts. Do not localize! }

  STR_FIXINSIGHT_REGKEY   = 'Software\FixInsight';
  STR_FIXINSIGHT_REGVALUE = 'Path';
  STR_FIXINSIGHT_EXENAME  = 'FixInsightCL.exe';

resourcestring

  {$IF LANGUAGE = LANG_EN_US}
    {$INCLUDE 'Locales\en-US.inc'}
  {$ELSEIF LANGUAGE = LANG_RU_RU}
    {$INCLUDE 'Locales\ru-RU.inc'}
  {$ELSE}
    {$MESSAGE FATAL 'No language defined!'}
  {$ENDIF}

implementation

end.
