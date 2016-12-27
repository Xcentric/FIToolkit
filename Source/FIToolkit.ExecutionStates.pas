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
  // TODO: implement {TExecutiveTransitionsProvider.CalcProjectSummary}
end;

class function TExecutiveTransitionsProvider.CalcTotalSummary(StateHolder : TWorkflowStateHolder) : TArray<TSummaryItem>;
begin
  // TODO: implement {TExecutiveTransitionsProvider.CalcTotalSummary}
end;

class function TExecutiveTransitionsProvider.MakeRecord(Msg : TFixInsightMessage) : TReportRecord;
begin
  // TODO: implement {TExecutiveTransitionsProvider.MakeRecord}
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
        S : TFileName;
        Msg : TFixInsightMessage;
      begin
        with StateHolder do
        begin
          FReportBuilder.BeginReport;
          FReportBuilder.AddHeader(FConfigData.InputFileName, Now);
          FReportBuilder.AddTotalSummary(CalcTotalSummary(StateHolder));

          for S in FProjects do
          begin
            FReportBuilder.BeginProjectSection(S, CalcProjectSummary(StateHolder, S));

            for Msg in FMessages[S] do
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
