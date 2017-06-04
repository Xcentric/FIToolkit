unit FIToolkit.Logger.Types;

interface

uses
  System.Generics.Collections;

type

  TLogTimestamp = type TDateTime;

  TLogItem = (liMessage, liSection, liMethod);

  TLogItems = set of TLogItem;

  TLogMsgSeverity = type Word;

  TLogMsgType = (lmNone, lmDebug, lmInfo, lmWarning, lmError, lmFatal);

  TLogMsgTypeDescription = TPair<TLogMsgType, String>;

  // TODO: cover with tests {TLogMsgTypeDescriptions}
  TLogMsgTypeDescriptions = record
    strict private
      FItems : array [TLogMsgType] of String;
    private
      function  GetItem(Index : TLogMsgType) : String;
      function  GetMaxItemLength : Integer;
      procedure SetItem(Index : TLogMsgType; const Value : String);
    public
      constructor Create(const Descriptions : array of TLogMsgTypeDescription);

      property Items[Index : TLogMsgType] : String read GetItem write SetItem; default;
      property MaxItemLength : Integer read GetMaxItemLength;
  end;

implementation

uses
  System.SysUtils, System.Math;

{ TLogMsgTypeDescriptions }

constructor TLogMsgTypeDescriptions.Create(const Descriptions : array of TLogMsgTypeDescription);
var
  Desc : TLogMsgTypeDescription;
begin
  for Desc in Descriptions do
    FItems[Desc.Key] := Desc.Value;
end;

function TLogMsgTypeDescriptions.GetItem(Index : TLogMsgType) : String;
begin
  Result := FItems[Index];
end;

function TLogMsgTypeDescriptions.GetMaxItemLength : Integer;
var
  LMT : TLogMsgType;
begin
  Result := 0;

  for LMT := Low(TLogMsgType) to High(TLogMsgType) do
    Result := Max(Result, FItems[LMT].Length);
end;

procedure TLogMsgTypeDescriptions.SetItem(Index : TLogMsgType; const Value : String);
begin
  FItems[Index] := Value;
end;

end.
