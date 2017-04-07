unit FIToolkit.Logger.Types;

interface

type

  TLogItem = (liMessage, liSection, liMethod);

  TLogItems = set of TLogItem;

  TLogMsgSeverity = type Word;

  TLogMsgType = (lmNone, lmDebug, lmInfo, lmWarning, lmError, lmFatal);

implementation

end.
