unit FIToolkit.Base.Exceptions;

interface

uses
  System.SysUtils;

type

  ECustomExceptionClass = class of ECustomException;

  ECustomException = class abstract (Exception)
    private
      function GetClassType : ECustomExceptionClass;
    protected
      function GetDefaultMessage : String; virtual;
    public
      constructor Create; overload;
  end;

  procedure RegisterExceptionMessage(AnExceptionClass : ECustomExceptionClass; const Msg : String);

implementation

uses
  System.Generics.Collections,
  FIToolkit.Base.Consts;

type

  TExceptionMessageMap = class (TDictionary<ECustomExceptionClass, String>)
    strict private
      class var
        FStaticInstance : TExceptionMessageMap;
    private
      class procedure FreeStaticInstance; static;
      class function  GetStaticInstance : TExceptionMessageMap; static;
    protected
      class property  StaticInstance : TExceptionMessageMap read GetStaticInstance;
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

function ECustomException.GetClassType : ECustomExceptionClass;
begin
  Result := ECustomExceptionClass(ClassType);
end;

function ECustomException.GetDefaultMessage : String;
begin
  with TExceptionMessageMap.StaticInstance do
    if ContainsKey(Self.GetClassType) then
      Result := Items[Self.GetClassType]
    else
      Result := RSDefaultErrMsg;
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
