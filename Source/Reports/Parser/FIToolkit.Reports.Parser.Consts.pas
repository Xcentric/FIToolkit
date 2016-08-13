unit FIToolkit.Reports.Parser.Consts;

interface

uses
  System.SysUtils,
  FIToolkit.Reports.Parser.Types;

const

  { FixInsight message types. Do not localize! }

  REGEX_FIMSG_CODING_CONVENTION = '^C[0-9]+$';
  REGEX_FIMSG_OPTIMIZATION      = '^O[0-9]+$';
  REGEX_FIMSG_TRIAL             = '^Tria$';
  REGEX_FIMSG_WARNING           = '^W[0-9]+$';

  { Common consts }

  ARR_MSGTYPE_TO_MSGID_REGEX_MAPPING : array [Low(TFixInsightMessageType)..High(TFixInsightMessageType)] of String =
    (String.Empty, REGEX_FIMSG_WARNING, REGEX_FIMSG_OPTIMIZATION, REGEX_FIMSG_CODING_CONVENTION, REGEX_FIMSG_TRIAL);

implementation

end.
