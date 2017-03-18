unit FIToolkit.Logger.Utils;

interface

uses
  FIToolkit.Logger.Types, FIToolkit.Logger.Consts;

  function InferLogMsgType(Severity : TLogMsgSeverity) : TLogMsgType;

implementation

function InferLogMsgType(Severity : TLogMsgSeverity) : TLogMsgType;
var
  LMT : TLogMsgType;
begin
  Result := lmNone;

  for LMT := High(TLogMsgType) downto Low(TLogMsgType) do
    if Severity >= ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[LMT] then
      Exit(LMT);
end;

end.
