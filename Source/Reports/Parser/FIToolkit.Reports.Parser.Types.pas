unit FIToolkit.Reports.Parser.Types;

interface

uses
  System.SysUtils;

type

  TFixInsightMessageType = (fimtUnknown, fimtWarning, fimtOptimization, fimtCodingConvention, fimtFatal, fimtTrial);

  TFixInsightMessage = record
    strict private
      FColumn,
      FLine : Integer;
      FFileName : TFileName;
      FID,
      FText : String;
      FMsgType : TFixInsightMessageType;
    private
      function GetMsgTypeByID(const MsgID : String) : TFixInsightMessageType;
    public
      constructor Create(const AFileName : TFileName; ALine, AColumn : Integer; const AID, AText : String);

      property Column : Integer read FColumn;
      property FileName : TFileName read FFileName;
      property ID : String read FID;
      property Line : Integer read FLine;
      property MsgType : TFixInsightMessageType read FMsgType;
      property Text : String read FText;
  end;

implementation

uses
  System.RegularExpressions,
  FIToolkit.Reports.Parser.Consts;

{ TFixInsightMessage }

constructor TFixInsightMessage.Create(const AFileName : TFileName; ALine, AColumn : Integer; const AID, AText : String);
begin
  FFileName := AFileName;
  FLine     := ALine;
  FColumn   := AColumn;
  FID       := AID;
  FText     := AText;

  FMsgType := GetMsgTypeByID(FID);
end;

function TFixInsightMessage.GetMsgTypeByID(const MsgID : String) : TFixInsightMessageType;
var
  MT : TFixInsightMessageType;
begin
  Result := fimtUnknown;

  for MT := Low(TFixInsightMessageType) to High(TFixInsightMessageType) do
    if (MT <> fimtUnknown) and TRegEx.IsMatch(MsgID, ARR_MSGTYPE_TO_MSGID_REGEX_MAPPING[MT]) then
      Exit(MT);
end;

end.
