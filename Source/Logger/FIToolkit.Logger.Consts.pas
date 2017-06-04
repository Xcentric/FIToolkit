unit FIToolkit.Logger.Consts;

interface

uses
  FIToolkit.Logger.Types;

const

  { Severity consts }

  SEVERITY_NONE = Low(TLogMsgSeverity);
  SEVERITY_MIN  = TLogMsgSeverity(SEVERITY_NONE + 1);
  SEVERITY_MAX  = High(TLogMsgSeverity);

  SEVERITY_DEBUG   = TLogMsgSeverity(SEVERITY_MIN     + 1);
  SEVERITY_INFO    = TLogMsgSeverity(SEVERITY_DEBUG   + 98);
  SEVERITY_WARNING = TLogMsgSeverity(SEVERITY_INFO    + 100);
  SEVERITY_ERROR   = TLogMsgSeverity(SEVERITY_WARNING + 100);
  SEVERITY_FATAL   = TLogMsgSeverity(SEVERITY_ERROR   + 100);

  { Common consts }

  ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING : array [TLogMsgType] of TLogMsgSeverity = (
    SEVERITY_NONE, SEVERITY_DEBUG, SEVERITY_INFO, SEVERITY_WARNING, SEVERITY_ERROR, SEVERITY_FATAL
  );

resourcestring

  { Plain text output }

  RSPTOMainThreadName = 'MAIN';

implementation

end.
