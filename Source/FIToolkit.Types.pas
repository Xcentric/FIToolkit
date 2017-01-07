unit FIToolkit.Types;

interface

type

  TApplicationCommand = (
    acStart,
    acPrintHelp, acPrintVersion, acGenerateConfig, acSetConfig, acSetNoExitBehavior,
    acExtractProjects, acExcludeProjects, acRunFixInsight, acParseReports, acBuildReport,
    acTerminate);

  TApplicationState = (
    asInitial,
    asHelpPrinted, asVersionPrinted, asConfigGenerated, asConfigSet, asNoExitBehaviorSet,
    asProjectsExtracted, asProjectsExcluded, asFixInsightRan, asReportsParsed, asReportBuilt,
    asFinal);

  TInputFileType = (iftUnknown, iftDPR, iftDPROJ, iftGROUPPROJ);

  TNoExitBehavior = (neDisabled, neEnabled, neEnabledOnException);

implementation

end.
