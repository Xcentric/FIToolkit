unit FIToolkit.Utils;

interface

type

  TIff = record
    public
      class function Get<T>(const Condition : Boolean; const TruePart, FalsePart : T) : T; static;
  end;

  function Iff : TIff;

implementation

{ Utils }

function Iff : TIff;
begin
  Result := Default(TIff);
end;

{ TIff }

class function TIff.Get<T>(const Condition : Boolean; const TruePart, FalsePart : T) : T;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

end.
