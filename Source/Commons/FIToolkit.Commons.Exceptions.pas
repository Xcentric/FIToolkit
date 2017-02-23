unit FIToolkit.Commons.Exceptions;

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
      constructor CreateFmt(const Args : array of const); overload;
  end;

  procedure RegisterExceptionMessage(AnExceptionClass : ECustomExceptionClass; const Msg : String);

implementation

uses
  System.Generics.Collections,
  FIToolkit.Commons.Consts;

type

  TExceptionMessageMap = class (TDictionary<ECustomExceptionClass, String>)
    strict private
      class var
        FStaticInstance : TExceptionMessageMap;
    private
      class constructor Create;
      class destructor Destroy;
    protected
      class property StaticInstance : TExceptionMessageMap read FStaticInstance;
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

constructor ECustomException.CreateFmt(const Args : array of const);
begin
  inherited CreateFmt(GetDefaultMessage, Args);
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

class constructor TExceptionMessageMap.Create;
begin
  FStaticInstance := TExceptionMessageMap.Create;
end;

class destructor TExceptionMessageMap.Destroy;
begin
  FreeAndNil(FStaticInstance);
end;

end.
