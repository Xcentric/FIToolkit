unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);

implementation

uses
  System.IOUtils, System.Classes, System.Generics.Defaults, System.Math,
  FIToolkit.Exceptions, FIToolkit.Utils, FIToolkit.Types, FIToolkit.Consts,
  FIToolkit.Commons.FiniteStateMachine.FSM, //TODO: remove when "F2084 Internal Error: URW1175" fixed
  FIToolkit.Commons.StateMachine, FIToolkit.Commons.Utils,
  FIToolkit.CommandLine.Options, FIToolkit.CommandLine.Consts,
  FIToolkit.Config.Manager;

type

  TFIToolkit = class sealed
    private
      type
        //TODO: replace when "F2084 Internal Error: URW1175" fixed
        IStateMachine = IFiniteStateMachine<TApplicationState, TApplicationCommand, EStateMachineError>;
        TStateMachine = TFiniteStateMachine<TApplicationState, TApplicationCommand, EStateMachineError>;
    strict private
      FConfig : TConfigManager;
      FOptions : TCLIOptions;
      FStateMachine : IStateMachine;
    strict private
      procedure InitConfig;
      procedure InitOptions(const CmdLineOptions : TStringDynArray);
      procedure InitStateMachine;
    private
      procedure PrintHelp;
      procedure ProcessOptions;
    public
      class procedure PrintAbout;

      constructor Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
      destructor Destroy; override;

      procedure Run;
  end;

{ Utils }

procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
begin
  TFIToolkit.PrintAbout;

  with TFIToolkit.Create(FullExePath, CmdLineOptions) do
    try
      Run;
    finally
      Free;
    end;
end;

{ TFIToolkit }

constructor TFIToolkit.Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
begin
  inherited Create;

  InitStateMachine;
  InitOptions(CmdLineOptions);
end;

destructor TFIToolkit.Destroy;
begin
  FreeAndNil(FConfig);
  FreeAndNil(FOptions);
  FStateMachine := nil;

  inherited Destroy;
end;

//TODO: rewrite to accept parameters
procedure TFIToolkit.InitConfig;
var
  bHasGenerateConfigOption : Boolean;
  SetConfigOption : TCLIOption;
begin
  bHasGenerateConfigOption := FOptions.Contains(STR_CLI_OPTION_GENERATE_CONFIG);

  if FOptions.Find(STR_CLI_OPTION_SET_CONFIG, SetConfigOption) and
     TPath.IsApplicableFileName(SetConfigOption.Value) and
     (TFile.Exists(SetConfigOption.Value) or bHasGenerateConfigOption)
  then
    FConfig := TConfigManager.Create(SetConfigOption.Value, bHasGenerateConfigOption, True)
  else
    raise ENoValidConfigSpecified.Create;
end;

procedure TFIToolkit.InitOptions(const CmdLineOptions : TStringDynArray);
var
  S : String;
begin
  FOptions := TCLIOptions.Create;
  FOptions.Capacity := Length(CmdLineOptions);

  for S in CmdLineOptions do
    FOptions.Add(S);
end;

procedure TFIToolkit.InitStateMachine;
begin
  FStateMachine := TStateMachine.Create(asInitial);
  //TODO: implement {InitStateMachine}
end;

class procedure TFIToolkit.PrintAbout;
begin
  Writeln(RSApplicationAbout);
end;

procedure TFIToolkit.PrintHelp;
var
  RS : TResourceStream;
  SL : TStringList;
begin
  RS := TResourceStream.Create(HInstance, STR_RES_HELP, RT_RCDATA);
  try
    SL := TStringList.Create;
    try
      SL.LoadFromStream(RS, TEncoding.UTF8);
      Writeln(SL.Text);
    finally
      SL.Free;
    end;
  finally
    RS.Free;
  end;
end;

procedure TFIToolkit.ProcessOptions;
var
  O : TCLIOption;
  C : TApplicationCommand;
begin
  try
    FOptions.Sort(TComparer<TCLIOption>.Construct(
      function (const Left, Right : TCLIOption) : Integer
      begin
        Result := CompareValue(GetCLIOptionWeight(Left.Name), GetCLIOptionWeight(Right.Name));
        //TODO: compare CLI option weight values
      end
    ));

    for O in FOptions do
      if TryCLIOptionToAppCommand(O.Name, C) then
        FStateMachine.Execute(C);
  except
    //TODO: handle with no-exit specific
    raise;
  end;
end;

procedure TFIToolkit.Run;
begin
  ProcessOptions;

  try
    FStateMachine
      .Execute(acReset)
      .Execute(acParseProjectGroup)
      .Execute(acRunFixInsight)
      .Execute(acParseReports)
      .Execute(acBuildReport)
      .Execute(acTerminate);
  except
    //TODO: handle with no-exit specific
    raise;
  end;

  //TODO: implement {Run}
end;

end.
