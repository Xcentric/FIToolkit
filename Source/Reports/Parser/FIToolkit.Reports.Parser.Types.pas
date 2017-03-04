unit FIToolkit.Reports.Parser.Types;

interface

uses
  System.SysUtils, System.Generics.Defaults;

type

  TFixInsightMessageType = (fimtUnknown, fimtWarning, fimtOptimization, fimtCodingConvention, fimtFatal, fimtTrial);

  TFixInsightMessage = record
    private
      type
        IFixInsightMessageComparer = IComparer<TFixInsightMessage>;
    strict private
      FColumn,
      FLine : Integer;
      FFileName,
      FFullFileName : TFileName;
      FID,
      FText : String;
      FMsgType : TFixInsightMessageType;
    private
      function GetMsgTypeByID(const MsgID : String) : TFixInsightMessageType;
    public
      class function GetComparer : IFixInsightMessageComparer; static;

      constructor Create(const AFileName : TFileName; ALine, AColumn : Integer; const AID, AText : String); overload;
      constructor Create(const AFileName, AFullFileName : TFileName; ALine, AColumn : Integer;
        const AID, AText : String); overload;

      property Column : Integer read FColumn;
      property FileName : TFileName read FFileName;
      property FullFileName : TFileName read FFullFileName;
      property ID : String read FID;
      property Line : Integer read FLine;
      property MsgType : TFixInsightMessageType read FMsgType;
      property Text : String read FText;
  end;

implementation

uses
  System.RegularExpressions, System.Types, System.StrUtils, System.Math,
  FIToolkit.Commons.Utils,
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

constructor TFixInsightMessage.Create(const AFileName, AFullFileName : TFileName; ALine, AColumn : Integer;
  const AID, AText : String);
begin
  Create(AFileName, ALine, AColumn, AID, AText);

  FFullFileName := AFullFileName;
end;

class function TFixInsightMessage.GetComparer : IFixInsightMessageComparer;
begin
  Result := TComparer<TFixInsightMessage>.Construct(
    function (const Left, Right : TFixInsightMessage) : Integer
    begin
      if Left.FullFileName.IsEmpty or Right.FullFileName.IsEmpty then
        Result := AnsiCompareText(Left.FileName, Right.FileName)
      else
        Result := AnsiCompareText(Left.FullFileName, Right.FullFileName);

      if Result = EqualsValue then
        Result := CompareValue(Left.Line, Right.Line);

      if Result = EqualsValue then
        Result := CompareValue(Left.Column, Right.Column);
    end
  );
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
