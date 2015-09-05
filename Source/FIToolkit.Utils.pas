unit FIToolkit.Utils;

interface

uses
  System.TypInfo, System.Rtti;

type

  TIff = record
    public
      class function Get<T>(const Condition : Boolean; const TruePart, FalsePart : T) : T; static;
  end;

  function Iff : TIff;

type

  TTypeKindHelper = record helper for TTypeKind
    public
      function IsArray : Boolean;
      function IsString : Boolean;
  end;

  TTypeInfoHelper = record helper for TTypeInfo
    public
      function IsArray : Boolean;
      function IsString : Boolean;
  end;

  TRttiTypeHelper = class helper for TRttiType
    public
      function IsArray : Boolean;
      function IsString : Boolean;
  end;

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

{ TTypeKindHelper }

function TTypeKindHelper.IsArray : Boolean;
begin
  Result := Self in [tkArray, tkDynArray];
end;

function TTypeKindHelper.IsString : Boolean;
begin
  Result := Self in [tkString, tkLString, tkWString, tkUString];
end;

{ TTypeInfoHelper }

function TTypeInfoHelper.IsArray : Boolean;
begin
  Result := Kind.IsArray;
end;

function TTypeInfoHelper.IsString : Boolean;
begin
  Result := Kind.IsString;
end;

{ TRttiTypeHelper }

function TRttiTypeHelper.IsArray : Boolean;
begin
  Result := TypeKind.IsArray;
end;

function TRttiTypeHelper.IsString : Boolean;
begin
  Result := TypeKind.IsString;
end;

end.
