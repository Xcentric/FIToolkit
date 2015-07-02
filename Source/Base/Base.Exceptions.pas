unit Base.Exceptions;

interface

uses
  System.SysUtils, System.Generics.Collections;

type

  ECustomException = class abstract (Exception)
    protected
      function GetDefaultMessage : String; virtual;
    public
      constructor Create;
  end;

  ECustomExceptionClass = class of ECustomException;

  procedure RegisterExceptionMessage(AnExceptionClass : ECustomExceptionClass; const Msg : String);

implementation

uses
  Base.Consts;

type

  TExceptionMessageMap = class (TDictionary<ECustomExceptionClass, String>)
    strict private
      class var FStaticInstance : TExceptionMessageMap;
    private
      class procedure FreeStaticInstance;
      class function  GetStaticInstance : TExceptionMessageMap; static;
    public
      class property StaticInstance : TExceptionMessageMap read GetStaticInstance;
  end;

{ Utils }

procedure RegisterExceptionMessage(AnExceptionClass : ECustomExceptionClass; const Msg : String);
begin
  TExceptionMessageMap.StaticInstance.Add(AnExceptionClass, Msg);
end;

{ ECustomException }

constructor ECustomException.Create;
begin
  inherited Create(GetDefaultMessage);
end;

function ECustomException.GetDefaultMessage : String;
begin
  with TExceptionMessageMap.StaticInstance do
    if ContainsKey(ECustomExceptionClass(ClassType)) then
      Result := Items[ECustomExceptionClass(ClassType)]
    else
      Result := SDefaultErrMsg;
end;

{ TExceptionMessageMap }

class procedure TExceptionMessageMap.FreeStaticInstance;
begin
  FreeAndNil(FStaticInstance);
end;

class function TExceptionMessageMap.GetStaticInstance : TExceptionMessageMap;
begin
  if not Assigned(FStaticInstance) then
    FStaticInstance := TExceptionMessageMap.Create;

  Result := FStaticInstance;
end;

initialization
  TExceptionMessageMap.GetStaticInstance;

finalization
  TExceptionMessageMap.FreeStaticInstance;

end.
