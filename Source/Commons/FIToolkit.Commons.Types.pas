unit FIToolkit.Commons.Types;

interface

uses
  System.SysUtils, System.Rtti;

type

  TObjectPropertyFilter = reference to function (Instance : TObject; Prop : TRttiProperty) : Boolean;

  TAssignable<T> = record
    private
      type
        TOnChange   = reference to procedure (WasAssigned : Boolean; const CurrentValue, OldValue : T);
        TOnChanging = reference to procedure (WasAssigned : Boolean; const CurrentValue, NewValue : T;
          var AllowChange : Boolean);
        TOnUnassign = reference to procedure (WasAssigned : Boolean; const OldValue : T);
    strict private
      FAssigned : String;
      FValue : T;

      FOnChange : TOnChange;
      FOnChanging : TOnChanging;
      FOnUnassign : TOnUnassign;
    private
      function  GetValue : T;
      procedure SetValue(const AValue : T);
    public
      class operator Implicit(const AValue : T) : TAssignable<T>;
      class operator Implicit(const AValue : TAssignable<T>) : T;

      constructor Create(const AValue : T);

      function  Assigned : Boolean;
      procedure Unassign;

      property  Value : T read GetValue write SetValue;

      property  OnChange : TOnChange read FOnChange write FOnChange;
      property  OnChanging : TOnChanging read FOnChanging write FOnChanging;
      property  OnUnassign : TOnUnassign read FOnUnassign write FOnUnassign;
  end;

  TAssignableFileName = TAssignable<TFileName>;
  TAssignableString = TAssignable<String>;

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
  bAllowChange, bWasAssigned : Boolean;
  OldValue : T;
begin
  bAllowChange := True;
  bWasAssigned := Assigned;
  OldValue := GetValue;

  if System.Assigned(FOnChanging) then
    FOnChanging(bWasAssigned, OldValue, AValue, bAllowChange);

  if bAllowChange then
  begin
    FValue := AValue;
    FAssigned := True.ToString;

    if System.Assigned(FOnChange) then
      FOnChange(bWasAssigned, FValue, OldValue);
  end;
end;

procedure TAssignable<T>.Unassign;
var
  bWasAssigned : Boolean;
  OldValue : T;
begin
  bWasAssigned := Assigned;
  OldValue := GetValue;

  FValue := Default(T);
  FAssigned := String.Empty;

  if System.Assigned(FOnUnassign) then
    FOnUnassign(bWasAssigned, OldValue);
end;

end.
