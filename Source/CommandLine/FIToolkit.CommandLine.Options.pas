unit FIToolkit.CommandLine.Options;

interface

uses
  FIToolkit.CommandLine.Types;

type

  TCLIOption = record
    private
      const
        CHR_SPACE = ' ';  // do not localize!
        CHR_QUOTE = '"';  // do not localize!
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
      class operator Implicit(const Value : TCLIOption) : String;

      constructor Create(const AOptionString : TCLIOptionString); overload;
      constructor Create(const AOptionString : TCLIOptionString; const APrefix, ADelimiter : String); overload;

      function HasDelimiter : Boolean;
      function HasPrefix : Boolean;
      function HasValue : Boolean;
      function HasWhiteSpaceInValue : Boolean;
      function ToString : TCLIOptionString;

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

function TCLIOption.HasPrefix : Boolean;
begin
  Result := not FOptionTokens.Prefix.IsEmpty;
end;

function TCLIOption.HasValue : Boolean;
begin
  //TODO: what if Value IS empty (delimiter and nothing after it)
  Result := not FOptionTokens.Value.IsEmpty;
end;

function TCLIOption.HasWhiteSpaceInValue : Boolean;
begin
  Result := FOptionTokens.Value.Contains(CHR_SPACE);
end;

class operator TCLIOption.Implicit(const Value : String) : TCLIOption;
begin
  Result := TCLIOption.Create(Value);
end;

class operator TCLIOption.Implicit(const Value : TCLIOption) : String;
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
    raise Exception.Create('TODO: replace');

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
end;

function TCLIOption.ToString : TCLIOptionString;
begin
  with FOptionTokens do
    Result := Prefix + Name + Delimiter +
      Iff.Get<String>(HasWhiteSpaceInValue, Value.QuotedString(CHR_QUOTE), Value);
end;

end.
