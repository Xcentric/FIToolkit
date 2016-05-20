unit FIToolkit.Utils;

interface

uses
  FIToolkit.Types;

  function GetCLIOptionWeight(const OptionName : String) : Integer;
  function TryCLIOptionToAppCommand(const OptionName : String; out Command : TApplicationCommand) : Boolean;

implementation

uses
  System.SysUtils,
  FIToolkit.Consts;

//TODO: cover with test case {GetCLIOptionWeight}
function GetCLIOptionWeight(const OptionName : String) : Integer;
var
  W : TCLIOptionWeight;
begin
  Result := -1;

  for W in ARR_CLIOPTION_WEIGHTS do
    if W.OptionName.Equals(OptionName) then
      Exit(W.OptionWeight);
end;

//TODO: cover with test case {TryCLIOptionToAppCommand}
function TryCLIOptionToAppCommand(const OptionName : String; out Command : TApplicationCommand) : Boolean;
var
  C : TApplicationCommand;
begin
  Result := False;

  if not String.IsNullOrWhiteSpace(OptionName) then
    for C := Low(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING) to High(ARR_APPCOMMAND_TO_CLIOPTION_MAPPING) do
      if ARR_APPCOMMAND_TO_CLIOPTION_MAPPING[C].Equals(OptionName) then
      begin
        Command := C;
        Exit(True);
      end;
end;

end.
