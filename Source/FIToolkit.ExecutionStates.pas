﻿unit FIToolkit.ExecutionStates;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.TimeSpan,
  FIToolkit.Types,
  FIToolkit.Commons.FiniteStateMachine.FSM, //TODO: remove when "F2084 Internal Error: URW1175" fixed
  FIToolkit.Commons.StateMachine,
  FIToolkit.Config.Data, FIToolkit.ProjectGroupParser.Parser, FIToolkit.Runner.Tasks,
  FIToolkit.Reports.Parser.XMLOutputParser, FIToolkit.Reports.Parser.Messages, FIToolkit.Reports.Parser.Types,
  FIToolkit.Reports.Builder.Types, FIToolkit.Reports.Builder.Intf;

type

  TWorkflowStateHolder = class sealed
    private
      { Primary logical entities }

      FConfigData : TConfigData;
      FFixInsightXMLParser : TFixInsightXMLParser;
      FProjectGroupParser : TProjectGroupParser;
      FProjectParser : TProjectParser;
      FReportBuilder : IReportBuilder;
      FTaskManager : TTaskManager;

      { Supporting infrastructure }

      FDeduplicator : TFixInsightMessages;
      FMessages : TDictionary<TFileName, TArray<TFixInsightMessage>>;
      FProjects : TArray<TFileName>;
      FReportFileName : TFileName;
      FReportOutput : TStreamWriter;
      FReports : TArray<TPair<TFileName, TFileName>>;
      FStartTime : TDateTime;
      FTotalDuration : TTimeSpan;
      FTotalMessages : Integer;
    private
      procedure InitReportBuilder;
    public
      constructor Create(ConfigData : TConfigData);
      destructor Destroy; override;

      property TotalDuration : TTimeSpan read FTotalDuration;
      property TotalMessages : Integer read FTotalMessages;
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
  System.IOUtils, System.RegularExpressions, System.Zip, System.Rtti,
  FIToolkit.Exceptions, FIToolkit.Utils, FIToolkit.Consts,
  FIToolkit.Commons.Utils,
  FIToolkit.Reports.Builder.Consts, FIToolkit.Reports.Builder.HTML,
  FIToolkit.Logger.Default;

type

  TWorkflowHelper = class
    private
      class function CalcProjectSummary(StateHolder : TWorkflowStateHolder; const Project : TFileName) : TArray<TSummaryItem>;
      class function CalcSummary(StateHolder : TWorkflowStateHolder; const ProjectFilter : String) : TArray<TSummaryItem>;
      class function CalcTotalSummary(StateHolder : TWorkflowStateHolder) : TArray<TSummaryItem>;
      class function FormatProjectTitle(StateHolder : TWorkflowStateHolder; const Project : TFileName) : String;
      class function FormatReportTitle(StateHolder : TWorkflowStateHolder) : String;
      class function MakeRecord(Msg : TFixInsightMessage) : TReportRecord;
  end;

{ TWorkflowStateHolder }

constructor TWorkflowStateHolder.Create(ConfigData : TConfigData);
begin
  inherited Create;

  FDeduplicator := TFixInsightMessages.Create;
  FMessages := TDictionary<TFileName, TArray<TFixInsightMessage>>.Create;
  FReportFileName := TPath.Combine(ConfigData.OutputDirectory, ConfigData.OutputFileName);
  FReportOutput := TFile.CreateText(FReportFileName);

  FConfigData := ConfigData;
  FFixInsightXMLParser := TFixInsightXMLParser.Create;

  InitReportBuilder;
end;

destructor TWorkflowStateHolder.Destroy;
begin
  FreeAndNil(FFixInsightXMLParser);
  FreeAndNil(FProjectGroupParser);
  FreeAndNil(FProjectParser);
  FreeAndNil(FTaskManager);

  FreeAndNil(FDeduplicator);
  FreeAndNil(FMessages);
  FreeAndNil(FReportOutput);

  inherited Destroy;
end;

procedure TWorkflowStateHolder.InitReportBuilder;
var
  Template : IHTMLReportTemplate;
  Report : THTMLReportBuilder;
begin
  if FConfigData.CustomTemplateFileName.IsEmpty then
    Template := THTMLReportDefaultTemplate.Create
  else
    Template := THTMLReportCustomTemplate.Create(FConfigData.CustomTemplateFileName);

  Report := THTMLReportBuilder.Create(FReportOutput.BaseStream);
  Report.SetTemplate(Template);

  FReportBuilder := Report;
end;

{ TExecutiveTransitionsProvider }

class procedure TExecutiveTransitionsProvider.PrepareWorkflow(const StateMachine : IStateMachine;
  StateHolder : TWorkflowStateHolder);
begin //FI:C101
  StateMachine
    .AddTransition(asInitial, asProjectsExtracted, acExtractProjects,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        LInputFileType : TInputFileType;
      begin
        Log.EnterSection(RSExtractingProjects);

        with StateHolder do
        begin
          FStartTime := Now;
          LInputFileType := GetInputFileType(FConfigData.InputFileName);

          Log.DebugVal(['LInputFileType = ', TValue.From<TInputFileType>(LInputFileType)]);

          case LInputFileType of
            iftDPR, iftDPK:
              begin
                FProjects := [FConfigData.InputFileName];
              end;
            iftDPROJ:
              begin
                FProjectParser := TProjectParser.Create(FConfigData.InputFileName);
                FProjects := [FProjectParser.GetMainSourceFileName];
              end;
            iftGROUPPROJ:
              begin
                FProjectGroupParser := TProjectGroupParser.Create(FConfigData.InputFileName);
                FProjects := FProjectGroupParser.GetIncludedProjectsFiles;
                TArray.Sort<TFileName>(FProjects, TFileName.GetComparer);
              end;
          else
            raise EUnknownInputFileType.Create;
          end;
        end;

        Log.LeaveSection(RSProjectsExtracted);
      end
    )
    .AddTransition(asProjectsExtracted, asProjectsExcluded, acExcludeProjects,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        LProjects : TList<TFileName>;
        sPattern, sProject : String;
      begin
        Log.EnterSection(RSExcludingProjects);

        LProjects := TList<TFileName>.Create;
        try
          with StateHolder do
          begin
            LProjects.AddRange(FProjects);

            for sPattern in FConfigData.ExcludeProjectPatterns do
              for sProject in FProjects do
                if TRegEx.IsMatch(sProject, sPattern, [roIgnoreCase]) then
                begin
                  LProjects.Remove(sProject);
                  Log.InfoFmt(RSProjectExcluded, [sProject]);
                end;

            if LProjects.Count < Length(FProjects) then
              FProjects := LProjects.ToArray;
          end;
        finally
          LProjects.Free;
        end;

        Log.LeaveSection(RSProjectsExcluded);
      end
    )
    .AddTransition(asProjectsExcluded, asFixInsightRan, acRunFixInsight,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      begin
        Log.EnterSection(RSRunningFixInsight);

        with StateHolder do
        begin
          Log.DebugFmt('Length(FProjects) = %d', [Length(FProjects)]);

          FTaskManager := TTaskManager.Create(FConfigData.FixInsightExe, FConfigData.FixInsightOptions,
            FProjects, FConfigData.TempDirectory);
          FReports := FTaskManager.RunAndGetOutput;
        end;

        Log.LeaveSection(RSFixInsightRan);
      end
    )
    .AddTransition(asFixInsightRan, asReportsParsed, acParseReports,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        R : TPair<TFileName, TFileName>;
        i : Integer;
      begin
        Log.EnterSection(RSParsingReports);

        with StateHolder do
          for R in FReports do
            if TFile.Exists(R.Value) then
            begin
              Log.DebugVal(['FConfigData.Deduplicate = ', FConfigData.Deduplicate]);

              if not FConfigData.Deduplicate then
                FFixInsightXMLParser.Parse(R.Value, False)
              else
              begin
                FFixInsightXMLParser.Parse(R.Value, R.Key, False);

                for i := FFixInsightXMLParser.Messages.Count - 1 downto 0 do
                  if FDeduplicator.Contains(FFixInsightXMLParser.Messages[i]) then
                    FFixInsightXMLParser.Messages.Delete(i);

                FDeduplicator.AddRange(FFixInsightXMLParser.Messages.ToArray);
              end;

              FFixInsightXMLParser.Messages.Sort;
              FMessages.Add(R.Key, FFixInsightXMLParser.Messages.ToArray);
            end
            else
            begin
              FMessages.Add(R.Key, nil);
              Log.ErrorFmt(RSReportNotFound, [R.Key]);
            end;

        Log.LeaveSection(RSReportsParsed);
      end
    )
    .AddTransition(asReportsParsed, asUnitsExcluded, acExcludeUnits,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        LProjectMessages : TFixInsightMessages;
        LExcludedUnits : TList<TFileName>;
        sPattern : String;
        F : TFileName;
        Msg : TFixInsightMessage;
      begin
        Log.EnterSection(RSExcludingUnits);

        LProjectMessages := TFixInsightMessages.Create;
        LExcludedUnits := TList<TFileName>.Create;
        try
          with StateHolder do
            for sPattern in FConfigData.ExcludeUnitPatterns do
              for F in FProjects do
                if Assigned(FMessages[F]) then
                begin
                  LProjectMessages.Clear;
                  LProjectMessages.AddRange(FMessages[F]);

                  for Msg in FMessages[F] do
                    if TRegEx.IsMatch(Msg.FileName, sPattern, [roIgnoreCase]) then
                    begin
                      LProjectMessages.Remove(Msg);

                      if not LExcludedUnits.Contains(Msg.FileName) then
                        LExcludedUnits.Add(Msg.FileName);
                    end;

                  if LProjectMessages.Count < Length(FMessages[F]) then
                    FMessages[F] := LProjectMessages.ToArray;
                end;

          for F in LExcludedUnits do
            Log.InfoFmt(RSUnitExcluded, [F]);
        finally
          LExcludedUnits.Free;
          LProjectMessages.Free;
        end;

        Log.LeaveSection(RSUnitsExcluded);
      end
    )
    .AddTransition(asUnitsExcluded, asReportBuilt, acBuildReport,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        F : TFileName;
        Msg : TFixInsightMessage;
      begin
        Log.EnterSection(RSBuildingReport);

        with StateHolder do
        begin
          FReportBuilder.BeginReport;
          FReportBuilder.AddHeader(TWorkflowHelper.FormatReportTitle(StateHolder), FStartTime);
          FReportBuilder.AddTotalSummary(TWorkflowHelper.CalcTotalSummary(StateHolder));

          for F in FProjects do
            if Assigned(FMessages[F]) then
            begin
              FReportBuilder.BeginProjectSection(
                TWorkflowHelper.FormatProjectTitle(StateHolder, F),
                TWorkflowHelper.CalcProjectSummary(StateHolder, F)
              );

              for Msg in FMessages[F] do
                FReportBuilder.AppendRecord(TWorkflowHelper.MakeRecord(Msg));

              FReportBuilder.EndProjectSection;
            end;

          FReportBuilder.AddFooter(Now);
          FReportBuilder.EndReport;
          FReportOutput.Close;
        end;

        Log.LeaveSection(RSReportBuilt);
      end
    )
    .AddTransition(asReportBuilt, asArchiveMade, acMakeArchive,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        sArchiveFileName : TFileName;
        ZF : TZipFile;
      begin
        Log.EnterSection(RSMakingArchive);
        Log.DebugVal(['FConfigData.MakeArchive = ', StateHolder.FConfigData.MakeArchive]);

        with StateHolder do
          if FConfigData.MakeArchive then
          begin
            sArchiveFileName := FReportFileName + STR_ARCHIVE_FILE_EXT;

            Log.DebugFmt('sArchiveFileName = "%s"', [sArchiveFileName]);
            Log.DebugVal(['TFile.Exists(sArchiveFileName) = ', TFile.Exists(sArchiveFileName)]);

            if TFile.Exists(sArchiveFileName) then
              TFile.Delete(sArchiveFileName);

            ZF := TZipFile.Create;
            try
              ZF.Open(sArchiveFileName, zmWrite);
              ZF.Add(FReportFileName);
              ZF.Close;
            finally
              ZF.Free;
            end;

            DeleteFile(FReportFileName);
          end;

        Log.LeaveSection(RSArchiveMade);
      end
    )
    .AddTransition(asArchiveMade, asFinal, acTerminate,
      procedure (const PreviousState, CurrentState : TApplicationState; const UsedCommand : TApplicationCommand)
      var
        R : TPair<TFileName, TFileName>;
      begin
        Log.EnterSection(RSTerminating);

        with StateHolder do
        begin
          for R in FReports do
          begin
            Inc(FTotalMessages, Length(FMessages[R.Key]));
            DeleteFile(R.Value);
          end;

          FTotalDuration := TTimeSpan.Subtract(Now, FStartTime);
        end;

        Log.LeaveSection(RSTerminated);
      end
    );
end;

{ TWorkflowHelper }

class function TWorkflowHelper.CalcProjectSummary(StateHolder : TWorkflowStateHolder;
  const Project : TFileName) : TArray<TSummaryItem>;
begin
  Result := CalcSummary(StateHolder, Project);
end;

class function TWorkflowHelper.CalcSummary(StateHolder : TWorkflowStateHolder;
  const ProjectFilter : String) : TArray<TSummaryItem>;
var
  arrSummary : array [TFixInsightMessageType] of TSummaryItem;

  procedure CalcProjectMessages(Project : TFileName);
  var
    Msg : TFixInsightMessage;
  begin
    for Msg in StateHolder.FMessages[Project] do
      Inc(arrSummary[Msg.MsgType].MessageCount);
  end;

var
  MT : TFixInsightMessageType;
  F : TFileName;
begin
  Result := nil;

  for MT := Low(TFixInsightMessageType) to High(TFixInsightMessageType) do
    with arrSummary[MT] do
    begin
      MessageCount       := 0;
      MessageTypeKeyword := ARR_MSGTYPE_TO_MSGKEYWORD_MAPPING[MT];
      MessageTypeName    := ARR_MSGTYPE_TO_MSGNAME_MAPPING[MT];
    end;

  if not ProjectFilter.IsEmpty then
    CalcProjectMessages(ProjectFilter)
  else
    for F in StateHolder.FProjects do
      CalcProjectMessages(F);

  for MT := Low(arrSummary) to High(arrSummary) do
    if arrSummary[MT].MessageCount > 0 then
      Result := Result + [arrSummary[MT]];
end;

class function TWorkflowHelper.CalcTotalSummary(StateHolder : TWorkflowStateHolder) : TArray<TSummaryItem>;
begin
  Result := CalcSummary(StateHolder, String.Empty);
end;

class function TWorkflowHelper.FormatProjectTitle(StateHolder : TWorkflowStateHolder; const Project : TFileName) : String;
begin
  Result := String(Project).Replace(
    TPath.GetDirectoryName(StateHolder.FConfigData.InputFileName, True), String.Empty, [rfIgnoreCase]);
end;

class function TWorkflowHelper.FormatReportTitle(StateHolder : TWorkflowStateHolder) : String;
begin
  Result := TPath.GetFileName(StateHolder.FConfigData.InputFileName);
end;

class function TWorkflowHelper.MakeRecord(Msg : TFixInsightMessage) : TReportRecord;
begin
  Result.Column             := Msg.Column;
  Result.FileName           := Msg.FileName;
  Result.Line               := Msg.Line;
  Result.MessageText        := Msg.Text;
  Result.MessageTypeKeyword := ARR_MSGTYPE_TO_MSGKEYWORD_MAPPING[Msg.MsgType];
  Result.MessageTypeName    := ARR_MSGTYPE_TO_MSGNAME_MAPPING[Msg.MsgType];
end;

end.
