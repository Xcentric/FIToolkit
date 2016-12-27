unit FIToolkit.ExecutionStates;

interface

uses
  System.Classes,
  FIToolkit.Types,
  FIToolkit.Commons.FiniteStateMachine.FSM, //TODO: remove when "F2084 Internal Error: URW1175" fixed
  FIToolkit.Commons.StateMachine,
  FIToolkit.Config.Data, FIToolkit.ProjectGroupParser.Parser, FIToolkit.Runner.Tasks,
  FIToolkit.Reports.Parser.XMLOutputParser, FIToolkit.Reports.Builder.Intf;

type

  TWorkflowStateHolder = class sealed
    private
      FConfigData : TConfigData;
      FFixInsightXMLParser : TFixInsightXMLParser;
      FProjectGroupParser : TProjectGroupParser;
      FReportBuilder : IReportBuilder;
      FReportOutput : TStreamWriter;
      FTaskRunner : TTaskRunner;

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
    public
      class procedure PrepareWorkflow(const StateMachine : IStateMachine; StateHolder : TWorkflowStateHolder);
  end;

implementation

uses
  System.SysUtils, System.IOUtils,
  FIToolkit.Reports.Builder.HTML;

{ TWorkflowStateHolder }

constructor TWorkflowStateHolder.Create(ConfigData : TConfigData);
begin
  inherited Create;

  FConfigData := ConfigData;
  FFixInsightXMLParser := TFixInsightXMLParser.Create;
  FProjectGroupParser := TProjectGroupParser.Create(FConfigData.InputFileName);
  FTaskRunner := TTaskRunner.Create(FConfigData.FixInsightExe, FConfigData.FixInsightOptions);

  InitReportBuilder;
end;

destructor TWorkflowStateHolder.Destroy;
begin
  FreeAndNil(FFixInsightXMLParser);
  FreeAndNil(FProjectGroupParser);
  FreeAndNil(FReportOutput);
  FreeAndNil(FTaskRunner);
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

class procedure TExecutiveTransitionsProvider.PrepareWorkflow(const StateMachine : IStateMachine;
  StateHolder : TWorkflowStateHolder);
begin
  StateMachine
    .AddTransition(asInitial, asProjectGroupParsed, acParseProjectGroup,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        //
      end
    )
    .AddTransition(asProjectGroupParsed, asFixInsightRan, acRunFixInsight,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        //
      end
    )
    .AddTransition(asFixInsightRan, asReportsParsed, acParseReports,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        //
      end
    )
    .AddTransition(asReportsParsed, asReportBuilt, acBuildReport,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        //
      end
    )
    .AddTransition(asReportBuilt, asFinal, acTerminate,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        //
      end
    );

  // TODO: implement {TExecutiveTransitionsProvider.PrepareWorkflow}
end;

end.
