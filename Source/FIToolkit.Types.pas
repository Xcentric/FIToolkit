unit FIToolkit.Types;

interface

type

  TApplicationCommand = (
    acReset,
    acPrintHelp, acPrintVersion, acGenerateConfig, acSetConfig, acSetNoExit,
    acParseProjectGroup, acRunFixInsight, acParseReports, acBuildReport,
    acTerminate);

  TApplicationState = (
    asInitial,
    asHelpPrinted, asVersionPrinted, asConfigGenerated, asConfigSet, asNoExitSet,
    asProjectGroupParsed, asFixInsightRan, asReportsParsed, asReportBuilt,
    asFinal);

  TNoExitBehavior = (neDisabled, neEnabled, neEnabledOnException);

implementation

end.
