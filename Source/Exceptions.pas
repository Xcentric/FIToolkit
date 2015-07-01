unit Exceptions;

interface

uses
  System.SysUtils, System.Generics.Collections;

const

  SDefaultErrMsg = 'UNEXPECTED ERROR';

type

  TExceptionMessage = type String;

  ECustomException = class abstract (Exception)
    protected
      function GetDefaultMessage : TExceptionMessage; virtual;
    public
      constructor Create(const Msg : TExceptionMessage = SDefaultErrMsg);
  end;

  ECustomExceptionClass = class of ECustomException;

  TExceptionMessageMap = class (TDictionary<ECustomExceptionClass, TExceptionMessage>)
    strict private
      class var FStaticInstance : TExceptionMessageMap;
    private
      class procedure FreeStaticInstance;
      class function  GetStaticInstance : TExceptionMessageMap; static;
    public
      class property StaticInstance : TExceptionMessageMap read GetStaticInstance;
  end;

  function GlobalExceptionsMap : TExceptionMessageMap;

implementation

function GlobalExceptionsMap : TExceptionMessageMap;
begin
  Result := TExceptionMessageMap.StaticInstance;
end;

{ ECustomException }

constructor ECustomException.Create(const Msg : TExceptionMessage);
begin
  if Msg = SDefaultErrMsg then
    inherited Create(GetDefaultMessage)
  else
    inherited Create(Msg);
end;

function ECustomException.GetDefaultMessage : TExceptionMessage;
begin
  if GlobalExceptionsMap.ContainsKey(Self.ClassType) then
    Result := GlobalExceptionsMap.Items[Self.ClassType]
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
