unit FIToolkit.Base.Types;

interface

uses
  System.SysUtils;

type

  TAssignable<T> = record
    private
      type
        TOnChange = reference to procedure (const CurrentValue, OldValue : T);
        TOnChanging = reference to procedure (const CurrentValue, NewValue : T);
    strict private
      FAssigned : String;
      FValue : T;

      FOnChange : TOnChange;
      FOnChanging : TOnChanging;
    private
      function  GetValue : T;
      procedure SetValue(const AValue : T);
    public
      class operator Implicit(const AValue : T) : TAssignable<T>;
      class operator Implicit(const AValue : TAssignable<T>) : T;

      constructor Create(const AValue : T);

      function  Assigned : Boolean;
      procedure Unassign;

      property Value : T read GetValue write SetValue;

      property OnChange : TOnChange read FOnChange write FOnChange;
      property OnChanging : TOnChanging read FOnChanging write FOnChanging;
  end;

implementation

{ TAssignable<T> }

function TAssignable<T>.Assigned : Boolean;
begin
  Result := not FAssigned.IsEmpty;
end;

constructor TAssignable<T>.Create(const AValue : T);
begin
  SetValue(AValue);
end;

function TAssignable<T>.GetValue : T;
begin
  if Assigned then
    Result := FValue
  else
    Result := Default(T);
end;

class operator TAssignable<T>.Implicit(const AValue : T) : TAssignable<T>;
begin
  Result := TAssignable<T>.Create(AValue);
end;

class operator TAssignable<T>.Implicit(const AValue : TAssignable<T>) : T;
begin
  Result := AValue.Value;
end;

procedure TAssignable<T>.SetValue(const AValue : T);
  var
    OldValue : T;
begin
  OldValue := GetValue;

  if System.Assigned(FOnChanging) then
    FOnChanging(OldValue, AValue);

  FValue := AValue;
  FAssigned := True.ToString;

  if System.Assigned(FOnChange) then
    FOnChange(FValue, OldValue);
end;

procedure TAssignable<T>.Unassign;
begin
  FValue := Default(T);
  FAssigned := String.Empty;
end;

end.
