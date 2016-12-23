unit FIToolkit.Types;

interface

type

  TApplicationCommand = (
    acStart,
    acPrintHelp, acPrintVersion, acGenerateConfig, acSetConfig, acSetNoExitBehavior,
    acParseProjectGroup, acRunFixInsight, acParseReports, acBuildReport,
    acTerminate);

  TApplicationState = (
    asInitial,
    asHelpPrinted, asVersionPrinted, asConfigGenerated, asConfigSet, asNoExitBehaviorSet,
    asProjectGroupParsed, asFixInsightRan, asReportsParsed, asReportBuilt,
    asFinal);

  TNoExitBehavior = (neDisabled, neEnabled, neEnabledOnException);

implementation

end.
