unit FIToolkit.Runner.Consts;

interface

uses
  FIToolkit.Localization;

const

  { Common consts }

  CHR_TASK_OUTPUT_FILENAME_PARTS_DELIM = Char('_');

  INT_SPIN_WAIT_ITERATIONS = 1000;

  { FixInsight output file waiting }

  INT_FIOFILE_WAIT_CHECK_INTERVAL = 1000;
  INT_FIOFILE_WAIT_TIMEOUT        = 5 * INT_FIOFILE_WAIT_CHECK_INTERVAL;

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
