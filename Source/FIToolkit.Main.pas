unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

type

  TExitCode = type LongWord;

  function RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray) : TExitCode;
  function TerminateApplication(E : Exception) : TExitCode;

implementation

uses
  System.Classes, System.IOUtils, System.Math, System.Generics.Defaults, System.Rtti,
  FIToolkit.ExecutionStates, FIToolkit.Exceptions, FIToolkit.Types, FIToolkit.Consts, FIToolkit.Utils,
  FIToolkit.Commons.FiniteStateMachine.FSM, //TODO: remove when "F2084 Internal Error: URW1175" fixed
  FIToolkit.Commons.StateMachine, FIToolkit.Commons.Utils,
  FIToolkit.CommandLine.Options, FIToolkit.CommandLine.Consts,
  FIToolkit.Config.Manager,
  FIToolkit.Logger.Default;

type

  TFIToolkit = class sealed (TLoggable)
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

      procedure ActualizeExitCode(var CurrentCode : TExitCode);
      procedure ProcessOptions;

      // Application commands implementation:
      procedure PrintHelp;
      procedure PrintVersion;
      procedure SetLogFile;
      procedure SetNoExitBehavior;
    public
      class procedure PrintAbout;
      class procedure PrintHelpSuggestion(const FullExePath : TFileName);

      constructor Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
      destructor Destroy; override;

      function Run : TExitCode;
  end;

{ Utils }

function _IsInDebugMode : Boolean;
begin
  Result := FindCmdLineSwitch(STR_CMD_LINE_SWITCH_DEBUG, True);
end;

function _CanExit(Instance : TFIToolkit; E : Exception) : Boolean;
begin
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
end;

procedure _OnException(E : Exception; out AnExitCode : TExitCode);
begin
  if Log.Enabled then
    Log.Fatal(E.ToString(True) + sLineBreak)
  else
    PrintLn(E.ToString(True) + sLineBreak);

  AnExitCode := UINT_EC_ERROR_OCCURRED;
end;

procedure _OnTerminate(AnExitCode : TExitCode; CanExit : Boolean);
begin
  PrintLn;

  if not Log.Enabled then
    PrintLn(Format(RSTerminatingWithExitCode, [AnExitCode]))
  else
    case AnExitCode of
      UINT_EC_NO_ERROR:
        Log.InfoFmt(RSTerminatingWithExitCode, [AnExitCode]);
      UINT_EC_ERROR_OCCURRED:
        Log.FatalFmt(RSTerminatingWithExitCode, [AnExitCode]);
    else
      Log.WarningFmt(RSTerminatingWithExitCode, [AnExitCode]);
    end;

  if not CanExit then
  begin
    PrintLn;
    PressAnyKeyPrompt;
  end;
end;

{ Export }

function RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray) : TExitCode;
var
  App : TFIToolkit;
begin
  InitConsoleLog(_IsInDebugMode);

  if Length(CmdLineOptions) = 0 then
  begin
    TFIToolkit.PrintHelpSuggestion(FullExePath);
    Result := UINT_EC_ERROR_OCCURRED;
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

function TerminateApplication(E : Exception) : TExitCode;
begin
  if Assigned(E) then
    _OnException(E, Result)
  else
    Result := UINT_EC_NO_ERROR;

  _OnTerminate(Result, _CanExit(nil, E));
end;

{ TFIToolkit }

procedure TFIToolkit.ActualizeExitCode(var CurrentCode : TExitCode);
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.ActualizeExitCode, [CurrentCode]);

  if FStateMachine.CurrentState = asFinal then
    if FConfig.ConfigData.UseBadExitCode and (FWorkflowState.TotalMessages > 0) then
      CurrentCode := UINT_EC_ANALYSIS_MESSAGES_FOUND;

  Log.DebugFmt('CurrentCode = %d', [CurrentCode]);
  Log.LeaveMethod(TFIToolkit, @TFIToolkit.ActualizeExitCode);
end;

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
  Log.EnterMethod(TFIToolkit, @TFIToolkit.InitConfig, [GenerateFlag]);

  sConfigOptionName := Iff.Get<String>(GenerateFlag, STR_CLI_OPTION_GENERATE_CONFIG, STR_CLI_OPTION_SET_CONFIG);

  if FOptions.Find(sConfigOptionName, ConfigOption, not IsCaseSensitiveCLIOption(sConfigOptionName)) and
     TPath.IsApplicableFileName(ConfigOption.Value) and
     (TFile.Exists(ConfigOption.Value) or GenerateFlag)
  then
    try
      Log.DebugFmt('ConfigOption.Value = "%s"', [ConfigOption.Value]);

      FConfig := TConfigManager.Create(ConfigOption.Value, GenerateFlag, True)
    except
      if GenerateFlag then
        Exception.RaiseOuterException(EUnableToGenerateConfig.Create)
      else
        Exception.RaiseOuterException(EErroneousConfigSpecified.Create);
    end
  else
  begin
    Log.DebugFmt('ConfigOption.Value = "%s"', [ConfigOption.Value]);

    raise ENoValidConfigSpecified.Create;
  end;

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.InitConfig);
end;

procedure TFIToolkit.InitOptions(const CmdLineOptions : TStringDynArray);
var
  S : String;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.InitOptions, [String.Join(STR_CLI_OPTIONS_DELIMITER, CmdLineOptions)]);

  FOptions := TCLIOptions.Create;
  FOptions.Capacity := Length(CmdLineOptions);

  for S in CmdLineOptions do
    FOptions.AddUnique(S, not IsCaseSensitiveCLIOption(TCLIOption(S).Name));

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.InitOptions);
end;

procedure TFIToolkit.InitStateMachine;
begin //FI:C101
  Log.EnterMethod(TFIToolkit, @TFIToolkit.InitStateMachine, []);

  FStateMachine := TStateMachine.Create(asInitial);

  { Common states }

  FStateMachine
    .AddTransition(asInitial, asNoExitBehaviorSet, acSetNoExitBehavior,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.DebugFmt('%s: %s → %s', [UsedCommand.ToString, PreviousState.ToString, CurrentState.ToString]);

        SetNoExitBehavior;
      end
    )
    .AddTransitions([asInitial, asNoExitBehaviorSet], asLogFileSet, acSetLogFile,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.DebugFmt('%s: %s → %s', [UsedCommand.ToString, PreviousState.ToString, CurrentState.ToString]);

        SetLogFile;
      end
    )
    .AddTransitions(ARR_INITIAL_APPSTATES, asHelpPrinted, acPrintHelp,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.DebugFmt('%s: %s → %s', [UsedCommand.ToString, PreviousState.ToString, CurrentState.ToString]);

        PrintHelp;
      end
    )
    .AddTransitions(ARR_INITIAL_APPSTATES, asVersionPrinted, acPrintVersion,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.DebugFmt('%s: %s → %s', [UsedCommand.ToString, PreviousState.ToString, CurrentState.ToString]);

        PrintVersion;
      end
    );

  { Config states }

  FStateMachine
    .AddTransitions(ARR_INITIAL_APPSTATES, asConfigGenerated, acGenerateConfig,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.DebugFmt('%s: %s → %s', [UsedCommand.ToString, PreviousState.ToString, CurrentState.ToString]);

        InitConfig(True);
        Log.Info(RSConfigWasGenerated + sLineBreak + RSEditConfigManually);
      end
    )
    .AddTransitions(ARR_INITIAL_APPSTATES, asConfigSet, acSetConfig,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.DebugFmt('%s: %s → %s', [UsedCommand.ToString, PreviousState.ToString, CurrentState.ToString]);

        InitConfig(False);
      end
    );

  { Execution states }

  FStateMachine.AddTransition(asConfigSet, asInitial, acStart);

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.InitStateMachine);
end;

class procedure TFIToolkit.PrintAbout;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.PrintAbout, []);

  PrintLn(RSApplicationAbout);

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.PrintAbout);
end;

procedure TFIToolkit.PrintHelp;
var
  RS : TResourceStream;
  SL : TStringList;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.PrintHelp, []);

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

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.PrintHelp);
end;

class procedure TFIToolkit.PrintHelpSuggestion(const FullExePath : TFileName);
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.PrintHelpSuggestion, [FullExePath]);

  PrintLn(Format(RSHelpSuggestion,
    [TPath.GetFileName(FullExePath) + STR_CLI_OPTIONS_DELIMITER + STR_CLI_OPTION_PREFIX + STR_CLI_OPTION_HELP]));

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.PrintHelpSuggestion);
end;

procedure TFIToolkit.PrintVersion;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.PrintVersion, []);

  PrintLn(GetAppVersionInfo);

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.PrintVersion);
end;

procedure TFIToolkit.ProcessOptions;
var
  Opt : TCLIOption;
  Cmd : TApplicationCommand;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.ProcessOptions, []);

  FOptions.Sort(TComparer<TCLIOption>.Construct(
    function (const Left, Right : TCLIOption) : Integer
    begin
      Result := CompareValue(
        GetCLIOptionProcessingOrder(Left.Name,  not IsCaseSensitiveCLIOption(Left.Name)),
        GetCLIOptionProcessingOrder(Right.Name, not IsCaseSensitiveCLIOption(Right.Name))
      );
    end
  ));

  Log.Debug('FOptions.ToString = ' + FOptions.ToString);

  for Opt in FOptions do
    if TryCLIOptionToAppCommand(Opt.Name, not IsCaseSensitiveCLIOption(Opt.Name), Cmd) then
    begin
      Log.DebugFmt('Opt.Name = "%s" → Cmd = "%s"', [Opt.Name, Cmd.ToString]);

      FStateMachine.Execute(Cmd);
    end;

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.ProcessOptions);
end;

function TFIToolkit.Run : TExitCode;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.Run, []);

  Result := UINT_EC_NO_ERROR;

  try
    ProcessOptions;
  except
    Exception.RaiseOuterException(ECLIOptionsProcessingFailed.Create);
  end;

  Log.Debug('FStateMachine.CurrentState = ' + FStateMachine.CurrentState.ToString);

  if not (FStateMachine.CurrentState in SET_FINAL_APPSTATES) then
    try
      if not Assigned(FConfig) then
        raise ENoValidConfigSpecified.Create;

      Log.EnterSection(RSPreparingWorkflow);
      FWorkflowState := TWorkflowStateHolder.Create(FConfig.ConfigData);
      TExecutiveTransitionsProvider.PrepareWorkflow(FStateMachine, FWorkflowState);
      Log.LeaveSection(RSWorkflowPrepared);

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

      Log.InfoFmt(RSTotalDuration, [String(FWorkflowState.TotalDuration)]);
      Log.InfoFmt(RSTotalMessages, [FWorkflowState.TotalMessages]);

      ActualizeExitCode(Result);
    except
      Exception.RaiseOuterException(EApplicationExecutionFailed.Create);
    end;

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.Run, Result);
end;

procedure TFIToolkit.SetLogFile;
var
  LogFileOption : TCLIOption;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.SetLogFile, []);

  if FOptions.Find(STR_CLI_OPTION_LOG_FILE, LogFileOption, not IsCaseSensitiveCLIOption(STR_CLI_OPTION_LOG_FILE)) then
  begin
    Log.DebugFmt('LogFileOption.Value = "%s"', [LogFileOption.Value]);

    if TPath.IsApplicableFileName(LogFileOption.Value) then
      InitFileLog(LogFileOption.Value);
  end;

  Log.LeaveMethod(TFIToolkit, @TFIToolkit.SetLogFile);
end;

procedure TFIToolkit.SetNoExitBehavior;
var
  NoExitOption : TCLIOption;
  iValue : Integer;
begin
  Log.EnterMethod(TFIToolkit, @TFIToolkit.SetNoExitBehavior, []);

  if FOptions.Find(STR_CLI_OPTION_NO_EXIT, NoExitOption, not IsCaseSensitiveCLIOption(STR_CLI_OPTION_NO_EXIT)) then
  begin
    Log.DebugFmt('NoExitOption.Value = "%s"', [NoExitOption.Value]);

    if Integer.TryParse(NoExitOption.Value, iValue) then
      if InRange(iValue, Integer(Low(TNoExitBehavior)), Integer(High(TNoExitBehavior))) then
        FNoExitBehavior := TNoExitBehavior(iValue);
  end;

  Log.DebugVal(['FNoExitBehavior = ', TValue.From<TNoExitBehavior>(FNoExitBehavior)]);
  Log.LeaveMethod(TFIToolkit, @TFIToolkit.SetNoExitBehavior);
end;

end.
