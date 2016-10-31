unit TestTypes;

interface

type

  TDateTimeRec = record
    Year, Month, Day,
    Hour, Minute, Second : Word;

    class operator Implicit(ADateTimeRec : TDateTimeRec) : TDateTime;
  end;

implementation

uses
  System.DateUtils;

{ TDateTimeRec }

class operator TDateTimeRec.Implicit(ADateTimeRec : TDateTimeRec) : TDateTime;
begin
  with ADateTimeRec do
    Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, 0);
end;

end.
