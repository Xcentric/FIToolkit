unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
  procedure TerminateApplication(E : Exception);

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

      // Application command implementations:
      procedure PrintHelp;
      procedure PrintVersion;
      procedure SetNoExitBehavior;
    public
      class procedure PrintAbout;
      class procedure Terminate(Instance : TFIToolkit; E : Exception = nil);

      constructor Create(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
      destructor Destroy; override;

      procedure Run;
  end;

{ Utils }

procedure RunApplication(const FullExePath : TFileName; const CmdLineOptions : TStringDynArray);
begin
  TFIToolkit.PrintAbout;
  TFIToolkit.Create(FullExePath, CmdLineOptions).Run;
end;

procedure TerminateApplication(E : Exception);
begin
  TFIToolkit.Terminate(nil, E);
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
    FConfig := TConfigManager.Create(ConfigOption.Value, GenerateFlag, True)
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
begin //FI:C101
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
        WriteLn(RSConfigWasGenerated);
        WriteLn(RSEditConfigManually);
      end
    )
    .AddTransitions([asInitial, asNoExitBehaviorSet], asConfigSet, acSetConfig,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        InitConfig(False);
      end
    );

  { Execution states }

  FStateMachine
    .AddTransition(asConfigSet, asInitial, acStart,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        if not Assigned(FConfig) then
          raise ENoValidConfigSpecified.Create;
      end
    );
end;

class procedure TFIToolkit.PrintAbout;
begin
  WriteLn(RSApplicationAbout);
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
      WriteLn(SL.Text);
    finally
      SL.Free;
    end;
  finally
    RS.Free;
  end;
end;

procedure TFIToolkit.PrintTotalDuration;
begin
  WriteLn(Format(RSTotalDuration, [String(FWorkflowState.TotalDuration)]));
end;

procedure TFIToolkit.PrintVersion;
begin
  WriteLn(GetAppVersionInfo);
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

    if not (FStateMachine.CurrentState in SET_FINAL_APPSTATES) then
      try
        FWorkflowState := TWorkflowStateHolder.Create(FConfig.ConfigData);
        TExecutiveTransitionsProvider.PrepareWorkflow(FStateMachine, FWorkflowState);

        FStateMachine
          .Execute(acStart)
          .Execute(acParseProjectGroup)
          .Execute(acRunFixInsight)
          .Execute(acParseReports)
          .Execute(acBuildReport)
          .Execute(acTerminate);

        PrintTotalDuration;
      except
        Exception.RaiseOuterException(EApplicationExecutionFailed.Create);
      end;
  except
    on E: Exception do
    begin
      Terminate(Self, E);
      Exit;
    end;
  end;

  Terminate(Self);
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

class procedure TFIToolkit.Terminate(Instance : TFIToolkit; E : Exception);
var
  iExitCode : Integer;
  bCanExit : Boolean;
begin //FI:C101
  iExitCode := System.ExitCode;

  try
    {$IFDEF DEBUG}
    bCanExit := False;
    {$ELSE}
    if not Assigned(Instance) then
      bCanExit := True
    else
    begin
      case Instance.FNoExitBehavior of
        neDisabled:
          bCanExit := True;
        neEnabled:
          bCanExit := False;
        neEnabledOnException:
          bCanExit := not Assigned(E);
      else
        Assert(False, 'Unhandled no-exit behavior while terminating application.');
        Exit;
      end;
    end;
    {$ENDIF}

    try
      if Assigned(Instance) then
        with Instance do
          try
            if FConfig.ConfigData.UseBadExitCode and (FWorkflowState.TotalMessages > 0) then
              iExitCode := INT_EC_ANALYSIS_MESSAGES_FOUND;
          finally
            Free;
          end;

      { Any new code should be placed here }
    finally
      if Assigned(E) then
      begin
        WriteLn(E.ToString(True), sLineBreak);
        iExitCode := INT_EC_ERROR_OCCURED;
      end;

      if not bCanExit then
        PressAnyKeyPrompt;
    end;
  except
    on E: Exception do
    begin
      WriteLn(E.ClassName, ': ', E.Message);
      iExitCode := INT_EC_ERROR_OCCURED;
    end;
  end;

  System.ExitCode := iExitCode;
end;

end.
