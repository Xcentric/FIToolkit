unit FIToolkit.Types;

interface

type

  TApplicationCommand = (
    acStart,
    acPrintHelp, acPrintVersion, acGenerateConfig, acSetConfig, acSetNoExitBehavior,
    acExtractProjects, acExcludeProjects, acRunFixInsight, acParseReports, acBuildReport, acMakeArchive,
    acTerminate);

  TApplicationState = (
    asInitial,
    asHelpPrinted, asVersionPrinted, asConfigGenerated, asConfigSet, asNoExitBehaviorSet,
    asProjectsExtracted, asProjectsExcluded, asFixInsightRan, asReportsParsed, asReportBuilt, asArchiveMade,
    asFinal);

  TInputFileType = (iftUnknown, iftDPR, iftDPK, iftDPROJ, iftGROUPPROJ);

  TNoExitBehavior = (neDisabled, neEnabled, neEnabledOnException);

implementation

end.
