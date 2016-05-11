unit FIToolkit.Commons.Consts;

interface

const

  { Common consts }

  sDualBreak = sLineBreak + sLineBreak;

  { FixInsight registry consts }

  STR_FIXINSIGHT_REGKEY   = 'Software\FixInsight';
  STR_FIXINSIGHT_REGVALUE = 'Path';
  STR_FIXINSIGHT_EXENAME  = 'FixInsightCL.exe';

resourcestring

  { Common strings }

  RSPressAnyKey = 'Нажмите любую клавишу для продолжения...';

  { Exceptions }

  RSDefaultErrMsg = 'Непредвиденная ошибка.';
  RSStateMachineError = 'Ошибка в работе машины состояний.';

implementation

end.
