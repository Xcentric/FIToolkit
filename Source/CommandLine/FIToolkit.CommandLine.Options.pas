unit FIToolkit.CommandLine.Options;

interface

uses
  FIToolkit.CommandLine.Types;

type

  TCLIOption = record
    private
      type
        TCLIOptionTokens = record
          Delimiter,
          Name,
          Prefix,
          Value : String;
        end;
    strict private
      FOptionString : TCLIOptionString;
      FOptionTokens : TCLIOptionTokens;
    private
      procedure Parse(const AOptionString : TCLIOptionString; const APrefix, ADelimiter : String;
        out Tokens : TCLIOptionTokens);
    public
      class operator Implicit(const Value : String) : TCLIOption;
      class operator Implicit(Value : TCLIOption) : String;

      constructor Create(const AOptionString : TCLIOptionString); overload;
      constructor Create(const AOptionString : TCLIOptionString; const APrefix, ADelimiter : String); overload;

      function HasDelimiter : Boolean;
      function HasNonEmptyValue : Boolean;
      function HasPrefix : Boolean;
      function ToString : TCLIOptionString;
      function ValueContainsSpaces : Boolean;

      property Delimiter : String read FOptionTokens.Delimiter;
      property Name : String read FOptionTokens.Name;
      property OptionString : TCLIOptionString read FOptionString;
      property Prefix : String read FOptionTokens.Prefix;
      property Value : String read FOptionTokens.Value;
  end;

implementation

uses
  System.SysUtils,
  FIToolkit.Utils, FIToolkit.CommandLine.Exceptions, FIToolkit.CommandLine.Consts;

{ TCLIOption }

constructor TCLIOption.Create(const AOptionString : TCLIOptionString; const APrefix, ADelimiter : String);
begin
  FOptionString := AOptionString;
  FOptionTokens := Default(TCLIOptionTokens);
  Parse(FOptionString, APrefix, ADelimiter, FOptionTokens);
end;

constructor TCLIOption.Create(const AOptionString : TCLIOptionString);
begin
  Create(AOptionString, STR_CLI_OPTION_PREFIX, STR_CLI_OPTION_DELIMITER);
end;

function TCLIOption.HasDelimiter : Boolean;
begin
  Result := not FOptionTokens.Delimiter.IsEmpty;
end;

function TCLIOption.HasNonEmptyValue : Boolean;
begin
  Result := not FOptionTokens.Value.IsEmpty;
end;

function TCLIOption.HasPrefix : Boolean;
begin
  Result := not FOptionTokens.Prefix.IsEmpty;
end;

class operator TCLIOption.Implicit(const Value : String) : TCLIOption;
begin
  Result := TCLIOption.Create(Value);
end;

class operator TCLIOption.Implicit(Value : TCLIOption) : String;
begin
  Result := Value.ToString;
end;

procedure TCLIOption.Parse(const AOptionString : TCLIOptionString; const APrefix, ADelimiter : String;
  out Tokens : TCLIOptionTokens);
  var
    S : String;
    iPrefixPos, iDelimiterPos : Integer;
begin
  S := AOptionString;
  iPrefixPos := S.IndexOf(APrefix);
  iDelimiterPos := S.IndexOf(ADelimiter);

  if String.IsNullOrWhiteSpace(S) then
    raise ECLIOptionIsEmpty.Create;

  with Tokens do
  begin
    Prefix := Iff.Get<String>(not String.IsNullOrWhiteSpace(APrefix) and
      S.StartsWith(APrefix), APrefix, String.Empty);

    Delimiter := Iff.Get<String>(not String.IsNullOrWhiteSpace(ADelimiter) and
      (iDelimiterPos > iPrefixPos), ADelimiter, String.Empty);

    Name := Iff.Get<String>(
      Delimiter.IsEmpty,
      S.Substring(iPrefixPos + Prefix.Length),
      S.Substring(iPrefixPos + Prefix.Length, iDelimiterPos - iPrefixPos + 1)
    );

    Value := Iff.Get<String>(
      Delimiter.IsEmpty,
      String.Empty,
      S.Substring(iDelimiterPos + Delimiter.Length)
    );
  end;

  if Tokens.Name.IsEmpty then
    raise ECLIOptionHasNoName.Create;
end;

function TCLIOption.ToString : TCLIOptionString;
begin
  with FOptionTokens do
    Result := Prefix + Name + Delimiter +
      Iff.Get<String>(ValueContainsSpaces, Value.QuotedString(TCLIOptionString.CHR_QUOTE), Value);
end;

function TCLIOption.ValueContainsSpaces : Boolean;
begin
  Result := FOptionTokens.Value.Contains(TCLIOptionString.CHR_SPACE);
end;

end.
