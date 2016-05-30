unit FIToolkit.Utils;

interface

uses
  FIToolkit.Types;

  function GetCLIOptionProcessingOrder(const OptionName : String; IgnoreCase : Boolean) : Integer;
  function TryCLIOptionToAppCommand(const OptionName : String; IgnoreCase : Boolean;
    out Command : TApplicationCommand) : Boolean;

implementation

uses
  System.SysUtils,
  FIToolkit.Consts;

//TODO: cover with test case {GetCLIOptionProcessingOrder}
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

//TODO: cover with test case {TryCLIOptionToAppCommand}
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
