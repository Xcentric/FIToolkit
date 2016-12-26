unit FIToolkit.ExecutionStates;

interface

uses
  FIToolkit.Types,
  FIToolkit.Commons.FiniteStateMachine.FSM, //TODO: remove when "F2084 Internal Error: URW1175" fixed
  FIToolkit.Commons.StateMachine,
  FIToolkit.Config.Data;

type

  TWorkflowStateHolder = class sealed
    private
      FConfigData : TConfigData;
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

{ TWorkflowStateHolder }

constructor TWorkflowStateHolder.Create(ConfigData : TConfigData);
begin
  inherited Create;

  FConfigData := ConfigData;

  // TODO: implement {TWorkflowStateHolder.Create}
end;

destructor TWorkflowStateHolder.Destroy;
begin
  FConfigData := nil;

  // TODO: implement {TWorkflowStateHolder.Destroy}

  inherited Destroy;
end;

{ TExecutiveTransitionsProvider }

class procedure TExecutiveTransitionsProvider.PrepareWorkflow(const StateMachine : IStateMachine;
  StateHolder : TWorkflowStateHolder);
begin
  // TODO: implement {TExecutiveTransitionsProvider.PrepareWorkflow}
end;

end.
