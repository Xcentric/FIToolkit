unit FIToolkit.Utils;

interface

uses
  System.SysUtils,
  FIToolkit.Types;

  function GetAppVersionInfo : String;
  function GetCLIOptionProcessingOrder(const OptionName : String; IgnoreCase : Boolean) : Integer;
  function GetInputFileType(const FileName : TFileName) : TInputFileType;
  function IsCaseSensitiveCLIOption(const OptionName : String) : Boolean;
  function TryCLIOptionToAppCommand(const OptionName : String; IgnoreCase : Boolean;
    out Command : TApplicationCommand) : Boolean;

implementation

uses
  System.IOUtils,
  FIToolkit.Consts,
  FIToolkit.Commons.Utils;

function GetAppVersionInfo : String;
var
  iMajor, iMinor, iRelease, iBuild : Word;
begin
  if GetModuleVersion(HInstance, iMajor, iMinor, iRelease, iBuild) then
    Result := Format('%s %d.%d.%d', [STR_APP_TITLE, iMajor, iMinor, iRelease])
  else
    Result := Format('%s %s', [STR_APP_TITLE, RSNoVersionInfoAvailable]);
end;

function GetCLIOptionProcessingOrder(const OptionName : String; IgnoreCase : Boolean) : Integer;
var
  i : Integer;
begin
  if not String.IsNullOrWhiteSpace(OptionName) then
    for i := 0 to High(ARR_CLIOPTION_PROCESSING_ORDER) do
      if ARR_CLIOPTION_PROCESSING_ORDER[i].Equals(OptionName) or
        (IgnoreCase and AnsiSameText(ARR_CLIOPTION_PROCESSING_ORDER[i], OptionName))
      then
        Exit(i);

  Result := -1;
end;

function GetInputFileType(const FileName : TFileName) : TInputFileType;
var
  sFileExt : String;
  X : TInputFileType;
begin
  Result := iftUnknown;
  sFileExt := TPath.GetExtension(FileName);

  if not sFileExt.IsEmpty then
    for X := Low(TInputFileType) to High(TInputFileType) do
      if AnsiSameText(sFileExt, ARR_INPUT_FILE_TYPE_TO_EXT_MAPPING[X]) then
        Exit(X);
end;

function IsCaseSensitiveCLIOption(const OptionName : String) : Boolean;
var
  S : String;
begin
  Result := False;

  if not String.IsNullOrWhiteSpace(OptionName) then
    for S in ARR_CASE_SENSITIVE_CLI_OPTIONS do
      if AnsiSameText(S, OptionName) then
        Exit(True);
end;

function TryCLIOptionToAppCommand(const OptionName : String; IgnoreCase : Boolean;
  out Command : TApplicationCommand) : Boolean;
var
  C : TApplicationCommand;
begin
  Result := False;

  if not String.IsNullOrWhiteSpace(OptionName) then
    for C := Low(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING) to High(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING) do
      if ARR_APPCOMMAND_TO_CLIOPTION_MAPPING[C].Equals(OptionName) or
        (IgnoreCase and AnsiSameText(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING[C], OptionName)) then
      begin
        Command := C;
        Exit(True);
      end;
end;

end.
