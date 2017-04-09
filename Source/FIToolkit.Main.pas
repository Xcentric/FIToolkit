unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  function RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray) : Integer;
  function TerminateApplication(E : Exception) : Integer;

implementation

uses
  System.Classes, System.IOUtils, System.Math, System.Generics.Defaults,
  FIToolkit.ExecutionStates, FIToolkit.Exceptions, FIToolkit.Types, FIToolkit.Consts, FIToolkit.Utils,
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
      FWorkflowState : TWorkflowStateHolder;
    strict private
      procedure InitConfig(GenerateFlag : Boolean);
      procedure InitOptions(const CmdLineOptions : TStringDynArray);
      procedure InitStateMachine;
    private
      FNoExitBehavior : TNoExitBehavior;

      procedure PrintTotalDuration;
      procedure ProcessOptions;
      procedure UpdateExitCode(var AnExitCode : Integer);

      // Application commands implementation:
      procedure PrintHelp;
      procedure PrintVersion;
      procedure SetNoExitBehavior;
    public
      class procedure PrintAbout;
      class procedure PrintHelpSuggestion(const FullExePath : TFileName);

      constructor Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
      destructor Destroy; override;

      function Run : Integer;
  end;

{ Utils }

function _CanExit(Instance : TFIToolkit; E : Exception) : Boolean;
begin
  {$IFDEF DEBUG}
  Result := False;
  {$ELSE}
  if not Assigned(Instance) then
    Result := True
  else
  begin
    case Instance.FNoExitBehavior of
      neDisabled:
        Result := True;
      neEnabled:
        Result := False;
      neEnabledOnException:
        Result := not Assigned(E);
    else
      Assert(False, 'Unhandled no-exit behavior while terminating application.');
      raise AbortException;
    end;
  end;
  {$ENDIF}
end;

procedure _OnException(E : Exception; out AnExitCode : Integer);
begin
  PrintLn([E.ToString(True), sLineBreak]);
  AnExitCode := INT_EC_ERROR_OCCURRED;
end;

procedure _OnTerminate(const AnExitCode : Integer; CanExit : Boolean);
begin
  PrintLn([sLineBreak, Format(RSTerminatingWithExitCode, [AnExitCode]), sLineBreak]);

  if not CanExit then
    PressAnyKeyPrompt;
end;

function RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray) : Integer;
var
  App : TFIToolkit;
begin
  if Length(CmdLineOptions) = 0 then
  begin
    TFIToolkit.PrintHelpSuggestion(FullExePath);
    Result := INT_EC_ERROR_OCCURRED;
    _OnTerminate(Result, _CanExit(nil, nil));
    Exit;
  end;

  TFIToolkit.PrintAbout;

  App := TFIToolkit.Create(FullExePath, CmdLineOptions);
  try
    try
      Result := App.Run;
      _OnTerminate(Result, _CanExit(App, nil));
    except
      on E: Exception do
      begin
        _OnException(E, Result);
        _OnTerminate(Result, _CanExit(App, E));
      end;
    end;
  finally
    App.Free;
  end;
end;

function TerminateApplication(E : Exception) : Integer;
begin
  if Assigned(E) then
    _OnException(E, Result)
  else
    Result := INT_EC_NO_ERROR;

  _OnTerminate(Result, _CanExit(nil, E));
end;

{ TFIToolkit }

constructor TFIToolkit.Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
begin
  inherited Create;

  InitOptions(CmdLineOptions);
  InitStateMachine;
end;

destructor TFIToolkit.Destroy;
begin
  FStateMachine := nil;
  FreeAndNil(FWorkflowState);
  FreeAndNil(FConfig);
  FreeAndNil(FOptions);

  inherited Destroy;
end;

procedure TFIToolkit.InitConfig(GenerateFlag : Boolean);
var
  sConfigOptionName : String;
  ConfigOption : TCLIOption;
begin
  sConfigOptionName := Iff.Get<String>(GenerateFlag, STR_CLI_OPTION_GENERATE_CONFIG, STR_CLI_OPTION_SET_CONFIG);

  if FOptions.Find(sConfigOptionName, ConfigOption, not IsCaseSensitiveCLIOption(sConfigOptionName)) and
     TPath.IsApplicableFileName(ConfigOption.Value) and
     (TFile.Exists(ConfigOption.Value) or GenerateFlag)
  then
    try
      FConfig := TConfigManager.Create(ConfigOption.Value, GenerateFlag, True)
    except
      if GenerateFlag then
        Exception.RaiseOuterException(EUnableToGenerateConfig.Create)
      else
        Exception.RaiseOuterException(EErroneousConfigSpecified.Create);
    end
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
begin
  FStateMachine := TStateMachine.Create(asInitial);

  { Common states }

  FStateMachine
    .AddTransition(asInitial, asNoExitBehaviorSet, acSetNoExitBehavior,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        SetNoExitBehavior;
      end
    )
    .AddTransitions([asInitial, asNoExitBehaviorSet], asHelpPrinted, acPrintHelp,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        PrintHelp;
      end
    )
    .AddTransitions([asInitial, asNoExitBehaviorSet], asVersionPrinted, acPrintVersion,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        PrintVersion;
      end
    );

  { Config states }

  FStateMachine
    .AddTransitions([asInitial, asNoExitBehaviorSet], asConfigGenerated, acGenerateConfig,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        InitConfig(True);
        PrintLn(RSConfigWasGenerated);
        PrintLn(RSEditConfigManually);
      end
    )
    .AddTransitions([asInitial, asNoExitBehaviorSet], asConfigSet, acSetConfig,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        InitConfig(False);
      end
    );

  { Execution states }

  FStateMachine.AddTransition(asConfigSet, asInitial, acStart);
end;

class procedure TFIToolkit.PrintAbout;
begin
  PrintLn(RSApplicationAbout);
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
      PrintLn(SL.Text);
    finally
      SL.Free;
    end;
  finally
    RS.Free;
  end;
end;

class procedure TFIToolkit.PrintHelpSuggestion(const FullExePath : TFileName);
begin
  PrintLn(Format(RSHelpSuggestion,
    [TPath.GetFileName(FullExePath) + ' ' + STR_CLI_OPTION_PREFIX + STR_CLI_OPTION_HELP]));
end;

procedure TFIToolkit.PrintTotalDuration;
begin
  PrintLn(Format(RSTotalDuration, [String(FWorkflowState.TotalDuration)]));
end;

procedure TFIToolkit.PrintVersion;
begin
  PrintLn(GetAppVersionInfo);
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

function TFIToolkit.Run : Integer;
begin
  Result := INT_EC_NO_ERROR;

  try
    ProcessOptions;
  except
    Exception.RaiseOuterException(ECLIOptionsProcessingFailed.Create);
  end;

  if not (FStateMachine.CurrentState in SET_FINAL_APPSTATES) then
    try
      if not Assigned(FConfig) then
        raise ENoValidConfigSpecified.Create;

      FWorkflowState := TWorkflowStateHolder.Create(FConfig.ConfigData);
      TExecutiveTransitionsProvider.PrepareWorkflow(FStateMachine, FWorkflowState);

      FStateMachine
        .Execute(acStart)
        .Execute(acExtractProjects)
        .Execute(acExcludeProjects)
        .Execute(acRunFixInsight)
        .Execute(acParseReports)
        .Execute(acExcludeUnits)
        .Execute(acBuildReport)
        .Execute(acMakeArchive)
        .Execute(acTerminate);

      UpdateExitCode(Result);
      PrintTotalDuration;
    except
      Exception.RaiseOuterException(EApplicationExecutionFailed.Create);
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

procedure TFIToolkit.UpdateExitCode(var AnExitCode : Integer);
begin
  if FStateMachine.CurrentState = asFinal then
    if FConfig.ConfigData.UseBadExitCode and (FWorkflowState.TotalMessages > 0) then
      AnExitCode := INT_EC_ANALYSIS_MESSAGES_FOUND;
end;

end.
