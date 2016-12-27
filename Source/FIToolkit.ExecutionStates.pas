unit FIToolkit.ExecutionStates;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  FIToolkit.Types,
  FIToolkit.Commons.FiniteStateMachine.FSM, //TODO: remove when "F2084 Internal Error: URW1175" fixed
  FIToolkit.Commons.StateMachine,
  FIToolkit.Config.Data, FIToolkit.ProjectGroupParser.Parser, FIToolkit.Runner.Tasks,
  FIToolkit.Reports.Parser.XMLOutputParser, FIToolkit.Reports.Parser.Types, FIToolkit.Reports.Builder.Types,
  FIToolkit.Reports.Builder.Intf;

type

  TWorkflowStateHolder = class sealed
    private
      FConfigData : TConfigData;
      FFixInsightXMLParser : TFixInsightXMLParser;
      FProjectGroupParser : TProjectGroupParser;
      FReportBuilder : IReportBuilder;
      FReportOutput : TStreamWriter;
      FTaskManager : TTaskManager;

      FMessages : TDictionary<TFileName, TArray<TFixInsightMessage>>;
      FProjects : TArray<TFileName>;
      FReports : TArray<TPair<TFileName, TFileName>>;

      procedure InitReportBuilder;
    public
      constructor Create(ConfigData : TConfigData);
      destructor Destroy; override;
  end;

  TExecutiveTransitionsProvider = class sealed
    private
      type
        //TODO: replace when "F2084 Internal Error: URW1175" fixed
        IStateMachine = IFiniteStateMachine<TApplicationState, TApplicationCommand, EStateMachineError>;
    private
      class function  CalcProjectSummary(StateHolder : TWorkflowStateHolder; Project : TFileName) : TArray<TSummaryItem>;
      class function  CalcSummary(StateHolder : TWorkflowStateHolder; ProjectFilter : String) : TArray<TSummaryItem>;
      class function  CalcTotalSummary(StateHolder : TWorkflowStateHolder) : TArray<TSummaryItem>;
      class function  MakeRecord(Msg : TFixInsightMessage) : TReportRecord;
    public
      class procedure PrepareWorkflow(const StateMachine : IStateMachine; StateHolder : TWorkflowStateHolder);
  end;

implementation

uses
  System.IOUtils,
  FIToolkit.Reports.Builder.Consts, FIToolkit.Reports.Builder.HTML;

{ TWorkflowStateHolder }

constructor TWorkflowStateHolder.Create(ConfigData : TConfigData);
begin
  inherited Create;

  FMessages := TDictionary<TFileName, TArray<TFixInsightMessage>>.Create;

  FConfigData := ConfigData;
  FFixInsightXMLParser := TFixInsightXMLParser.Create;
  FProjectGroupParser := TProjectGroupParser.Create(FConfigData.InputFileName);

  InitReportBuilder;
end;

destructor TWorkflowStateHolder.Destroy;
begin
  FreeAndNil(FMessages);

  FreeAndNil(FFixInsightXMLParser);
  FreeAndNil(FProjectGroupParser);
  FreeAndNil(FReportOutput);
  FreeAndNil(FTaskManager);
  FReportBuilder := nil;

  inherited Destroy;
end;

procedure TWorkflowStateHolder.InitReportBuilder;
var
  Template : IHTMLReportTemplate;
  Report : THTMLReportBuilder;
begin
  // TODO: implement {THTMLReportCustomTemplate.Create(FConfigData.???)}
  Template := THTMLReportDefaultTemplate.Create;

  FReportOutput := TFile.CreateText(FConfigData.OutputDirectory + FConfigData.OutputFileName);
  Report := THTMLReportBuilder.Create(FReportOutput.BaseStream);
  Report.SetTemplate(Template);

  FReportBuilder := Report;
end;

{ TExecutiveTransitionsProvider }

class function TExecutiveTransitionsProvider.CalcProjectSummary(StateHolder : TWorkflowStateHolder;
  Project : TFileName) : TArray<TSummaryItem>;
begin
  Result := CalcSummary(StateHolder, Project);
end;

class function TExecutiveTransitionsProvider.CalcSummary(StateHolder : TWorkflowStateHolder;
  ProjectFilter : String) : TArray<TSummaryItem>;
var
  MT : TFixInsightMessageType;
  arrSummary : array [Low(TFixInsightMessageType)..High(TFixInsightMessageType)] of TSummaryItem;
  F : TFileName;
  Msg : TFixInsightMessage;
begin
  Result := nil;

  for MT := Low(TFixInsightMessageType) to High(TFixInsightMessageType) do
    with arrSummary[MT] do
    begin
      MessageCount       := 0;
      MessageTypeKeyword := ARR_MSGTYPE_TO_MSGKEYWORD_MAPPING[MT];
      MessageTypeName    := ARR_MSGTYPE_TO_MSGNAME_MAPPING[MT];
    end;

  if ProjectFilter.IsEmpty then
    for F in StateHolder.FProjects do
      for Msg in StateHolder.FMessages[F] do
        Inc(arrSummary[Msg.MsgType].MessageCount)
  else
    for Msg in StateHolder.FMessages[ProjectFilter] do
      Inc(arrSummary[Msg.MsgType].MessageCount);

  for MT := Low(arrSummary) to High(arrSummary) do
    if arrSummary[MT].MessageCount > 0 then
      Result := Result + [arrSummary[MT]];
end;

class function TExecutiveTransitionsProvider.CalcTotalSummary(StateHolder : TWorkflowStateHolder) : TArray<TSummaryItem>;
begin
  Result := CalcSummary(StateHolder, String.Empty);
end;

class function TExecutiveTransitionsProvider.MakeRecord(Msg : TFixInsightMessage) : TReportRecord;
begin
  Result.Column             := Msg.Column;
  Result.FileName           := Msg.FileName;
  Result.Line               := Msg.Line;
  Result.MessageText        := Msg.Text;
  Result.MessageTypeKeyword := ARR_MSGTYPE_TO_MSGKEYWORD_MAPPING[Msg.MsgType];
  Result.MessageTypeName    := ARR_MSGTYPE_TO_MSGNAME_MAPPING[Msg.MsgType];
end;

class procedure TExecutiveTransitionsProvider.PrepareWorkflow(const StateMachine : IStateMachine;
  StateHolder : TWorkflowStateHolder);
begin
  StateMachine
    .AddTransition(asInitial, asProjectGroupParsed, acParseProjectGroup,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        with StateHolder do
          FProjects := FProjectGroupParser.GetIncludedProjectsFiles;
      end
    )
    .AddTransition(asProjectGroupParsed, asFixInsightRan, acRunFixInsight,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        with StateHolder do
        begin
          FTaskManager := TTaskManager.Create(FConfigData.FixInsightExe, FConfigData.FixInsightOptions,
            FProjects, FConfigData.TempDirectory);
          FReports := FTaskManager.RunAndGetOutput;
        end;
      end
    )
    .AddTransition(asFixInsightRan, asReportsParsed, acParseReports,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        R : TPair<TFileName, TFileName>;
      begin
        with StateHolder do
          for R in FReports do
          begin
            FFixInsightXMLParser.Parse(R.Value, False);
            FMessages.Add(R.Key, FFixInsightXMLParser.Messages.ToArray);
          end;
      end
    )
    .AddTransition(asReportsParsed, asReportBuilt, acBuildReport,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        F : TFileName;
        Msg : TFixInsightMessage;
      begin
        with StateHolder do
        begin
          FReportBuilder.BeginReport;
          FReportBuilder.AddHeader(FConfigData.InputFileName, Now);
          FReportBuilder.AddTotalSummary(CalcTotalSummary(StateHolder));

          for F in FProjects do
          begin
            FReportBuilder.BeginProjectSection(F, CalcProjectSummary(StateHolder, F));

            for Msg in FMessages[F] do
              FReportBuilder.AppendRecord(MakeRecord(Msg));

            FReportBuilder.EndProjectSection;
          end;

          FReportBuilder.AddFooter(Now);
          FReportBuilder.EndReport;
        end;
      end
    )
    .AddTransition(asReportBuilt, asFinal, acTerminate,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        //
      end
    );
end;

end.
