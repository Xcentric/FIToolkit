﻿unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);

implementation

uses
  System.Classes, System.IOUtils, System.Math, System.Generics.Defaults,
  FIToolkit.Exceptions, FIToolkit.Types, FIToolkit.Consts, FIToolkit.Utils,
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
      procedure InitConfig(GenerateFlag : Boolean);
      procedure InitOptions(const CmdLineOptions : TStringDynArray);
      procedure InitStateMachine;
    private
      FNoExitBehavior : TNoExitBehavior;

      procedure PrintException(E : Exception);
      procedure ProcessOptions;

      // Application command implementations:
      procedure PrintHelp;
      procedure PrintVersion;
      procedure SetNoExitBehavior;
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

procedure TFIToolkit.InitConfig(GenerateFlag : Boolean);
var
  SetConfigOption : TCLIOption;
begin
  if FOptions.Find(STR_CLI_OPTION_SET_CONFIG, SetConfigOption,
                   not IsCaseSensitiveCLIOption(STR_CLI_OPTION_SET_CONFIG)) and
     TPath.IsApplicableFileName(SetConfigOption.Value) and
     (TFile.Exists(SetConfigOption.Value) or GenerateFlag)
  then
    FConfig := TConfigManager.Create(SetConfigOption.Value, GenerateFlag, True)
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
    FOptions.AddUnique(S, not IsCaseSensitiveCLIOption(TCLIOption(S).Name));
end;

procedure TFIToolkit.InitStateMachine;
var
  P : TOnEnterStateProc<TApplicationState, TApplicationCommand>;
begin
  FStateMachine := TStateMachine.Create(asInitial);

  { Common states }

  FStateMachine
    .AddTransition(asInitial, asHelpPrinted, acPrintHelp,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        PrintHelp;
      end
    )
    .AddTransition(asInitial, asVersionPrinted, acPrintVersion,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        PrintVersion;
      end
    )
    .AddTransition(asInitial, asNoExitBehaviorSet, acSetNoExitBehavior,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        SetNoExitBehavior;
      end
    );

  { Config states }

  P :=
    procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
    begin
      case CurrentState of
        asConfigGenerated:
          if not Assigned(FConfig) then
            InitConfig(True);
        asConfigSet:
          if not Assigned(FConfig) then
            InitConfig(False);
      else
        Assert(False, 'Unhandled application state while initializing configuration.');
      end;
    end;

  FStateMachine
    .AddTransition(asInitial,           asConfigGenerated, acGenerateConfig, P)
    .AddTransition(asNoExitBehaviorSet, asConfigGenerated, acGenerateConfig, P)
    .AddTransition(asInitial,           asConfigSet, acSetConfig, P)
    .AddTransition(asNoExitBehaviorSet, asConfigSet, acSetConfig, P)
    .AddTransition(asConfigGenerated,   asConfigSet, acSetConfig, P);

  { Execution states }

  FStateMachine
    .AddTransition(asConfigSet, asInitial, acStart,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        if not Assigned(FConfig) then
          raise ENoValidConfigSpecified.Create;
      end
    );

  //TODO: implement {InitStateMachine → Execution States}
end;

class procedure TFIToolkit.PrintAbout;
begin
  Writeln(RSApplicationAbout);
end;

procedure TFIToolkit.PrintException(E : Exception);
begin
  Writeln(E.ToString(True), sLineBreak);
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

procedure TFIToolkit.PrintVersion;
begin
  //TODO: implement {PrintVersion}
end;

procedure TFIToolkit.ProcessOptions;
var
  O : TCLIOption;
  C : TApplicationCommand;
begin
  FOptions.Sort(TComparer<TCLIOption>.Construct(
    function (const Left, Right : TCLIOption) : Integer
    begin
      Result := CompareValue(
        GetCLIOptionProcessingOrder(Left.Name,  not IsCaseSensitiveCLIOption(Left.Name)),
        GetCLIOptionProcessingOrder(Right.Name, not IsCaseSensitiveCLIOption(Right.Name))
      );
    end
  ));

  for O in FOptions do
    if TryCLIOptionToAppCommand(O.Name, not IsCaseSensitiveCLIOption(O.Name), C) then
      FStateMachine.Execute(C);
end;

procedure TFIToolkit.Run;
begin
  try
    try
      ProcessOptions;
    except
      Exception.RaiseOuterException(ECLIOptionsProcessingFailed.Create);
    end;

    try
      FStateMachine
        .Execute(acStart)
        .Execute(acParseProjectGroup)
        .Execute(acRunFixInsight)
        .Execute(acParseReports)
        .Execute(acBuildReport)
        .Execute(acTerminate);
    except
      Exception.RaiseOuterException(EApplicationExecutionFailed.Create);
    end;

    if FNoExitBehavior = neEnabled then
      PressAnyKeyPrompt;
  except
    on E: Exception do
      case FNoExitBehavior of
        neDisabled:
          raise;
        neEnabledOnException, neEnabled:
          begin
            PrintException(E);
            PressAnyKeyPrompt;
            //TODO: re-raise or return exit code <> 0
          end;
      else
        Assert(False, 'Unhandled no-exit behavior while handling exception.');
      end;
  end;
end;

procedure TFIToolkit.SetNoExitBehavior;
var
  NoExitOption : TCLIOption;
  iValue : Integer;
begin
  if FOptions.Find(STR_CLI_OPTION_NO_EXIT, NoExitOption, not IsCaseSensitiveCLIOption(STR_CLI_OPTION_NO_EXIT)) then
    if Integer.TryParse(NoExitOption.Value, iValue) then
      if InRange(iValue, Integer(Low(TNoExitBehavior)), Integer(High(TNoExitBehavior))) then
        FNoExitBehavior := TNoExitBehavior(iValue);
end;

end.
