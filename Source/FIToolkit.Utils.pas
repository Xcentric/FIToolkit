unit FIToolkit.Utils;

interface

uses
  FIToolkit.Types;

  function TryCLIOptionToAppCommand(const OptionName : String; out Command : TApplicationCommand) : Boolean;

implementation

uses
  System.SysUtils,
  FIToolkit.Consts;

//TODO: cover with test case
function TryCLIOptionToAppCommand(const OptionName : String; out Command : TApplicationCommand) : Boolean;
var
  C : TApplicationCommand;
begin
  Result := False;

  if not String.IsNullOrWhiteSpace(OptionName) then
    for C := Low(CLIOptionToAppCommandMapping) to High(CLIOptionToAppCommandMapping) do
      if CLIOptionToAppCommandMapping[C].Equals(OptionName) then
      begin
        Command := C;
        Exit(True);
      end;
end;

end.
