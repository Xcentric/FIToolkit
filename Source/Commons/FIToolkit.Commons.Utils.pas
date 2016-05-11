﻿unit FIToolkit.Commons.Utils;

interface

uses
  System.SysUtils, System.IOUtils, System.TypInfo, System.Rtti;

type

  TIff = record
    public
      class function Get<T>(const Condition : Boolean; const TruePart, FalsePart : T) : T; static; inline;
  end;

  { Helpers }

  TFileNameHelper = record helper for TFileName
    public
      function IsApplicable : Boolean;
      function IsEmpty : Boolean;
  end;

  TPathHelper = record helper for TPath
    public
      class function GetDirectoryName(const FileName : String; TrailingPathDelim : Boolean) : String; overload; static;
      class function GetExePath : String; static;
      class function GetQuotedPath(const Path : String; QuoteChar : Char) : String; static;
      class function IncludeTrailingPathDelimiter(const Path : String) : String; static;
      class function IsApplicableFileName(const FileName : TFileName) : Boolean; static;
  end;

  TRttiTypeHelper = class helper for TRttiType
    public
      function IsArray : Boolean;
      function IsString : Boolean;
  end;

  TTypeInfoHelper = record helper for TTypeInfo
    public
      function IsArray : Boolean;
      function IsString : Boolean;
  end;

  TTypeKindHelper = record helper for TTypeKind
    public
      function IsArray : Boolean;
      function IsString : Boolean;
  end;

  { Utils }

  function  GetFixInsightExePath : TFileName;
  function  Iff : TIff; inline;
  procedure PressAnyKey;

implementation

uses
  System.Win.Registry, Winapi.Windows,
  FIToolkit.Commons.Consts;

{ Utils }

function GetFixInsightExePath : TFileName;
var
  R : TRegistry;
  S : String;
begin
  Result := String.Empty;

  R := TRegistry.Create;
  try
    R.RootKey := HKEY_CURRENT_USER;
    if R.OpenKeyReadOnly(STR_FIXINSIGHT_REGKEY) then
    begin
      S := IncludeTrailingPathDelimiter(R.ReadString(STR_FIXINSIGHT_REGVALUE)) + STR_FIXINSIGHT_EXENAME;
      if TFile.Exists(S) then
        Result := S;
    end;
  finally
    R.Free;
  end;
end;

function Iff : TIff;
begin
  Result := Default(TIff);
end;

procedure PressAnyKey;
var
  hConsole : THandle;
  ConsoleInput : TInputRecord;
  iDummy : Cardinal;
begin
  Writeln(RSPressAnyKey);

  hConsole := GetStdHandle(STD_INPUT_HANDLE);
  if hConsole <> INVALID_HANDLE_VALUE then
    repeat
      WaitForSingleObjectEx(hConsole, INFINITE, False);

      if ReadConsoleInput(hConsole, ConsoleInput, 1, iDummy) then
        if ConsoleInput.EventType = KEY_EVENT then
          if ConsoleInput.Event.KeyEvent.bKeyDown then
            Break;
    until False;
end;

{ TFileNameHelper }

function TFileNameHelper.IsApplicable : Boolean;
begin
  Result := TPath.IsApplicableFileName(Self);
end;

function TFileNameHelper.IsEmpty : Boolean;
begin
  Result := String.IsNullOrEmpty(Self);
end;

{ TIff }

class function TIff.Get<T>(const Condition : Boolean; const TruePart, FalsePart : T) : T;
begin
  if Condition then
    Result := TruePart
  else
    Result := FalsePart;
end;

{ TPathHelper }

class function TPathHelper.GetDirectoryName(const FileName : String; TrailingPathDelim : Boolean) : String;
begin
  Result := String.Empty;

  if not String.IsNullOrWhiteSpace(FileName) and TPath.HasValidPathChars(FileName, True) then
  begin
    Result := GetDirectoryName(FileName);

    if TrailingPathDelim then
      Result := TPath.IncludeTrailingPathDelimiter(Result);
  end;
end;

class function TPathHelper.GetExePath : String;
begin
  Result := GetDirectoryName(ParamStr(0), True);
end;

class function TPathHelper.GetQuotedPath(const Path : String; QuoteChar : Char) : String;
begin
  Result := Path;

  if QuoteChar <> #0 then
  begin
    if not Result.StartsWith(QuoteChar) then
      Result := QuoteChar + Result;

    if not Result.EndsWith(QuoteChar) then
      Result := Result + QuoteChar;
  end;
end;

class function TPathHelper.IncludeTrailingPathDelimiter(const Path : String) : String;
begin
  Result := Path;

  if not Result.IsEmpty then
    Result := System.SysUtils.IncludeTrailingPathDelimiter(Result);
end;

class function TPathHelper.IsApplicableFileName(const FileName : TFileName) : Boolean;
begin
  Result := False;

  if not String.IsNullOrWhiteSpace(FileName) then
    if TPath.HasValidPathChars(FileName, False) and not TDirectory.Exists(FileName) then
      Result := TPath.HasValidFileNameChars(TPath.GetFileName(FileName), False);
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

{ TTypeInfoHelper }

function TTypeInfoHelper.IsArray : Boolean;
begin
  Result := Kind.IsArray;
end;

function TTypeInfoHelper.IsString : Boolean;
begin
  Result := Kind.IsString;
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

end.
