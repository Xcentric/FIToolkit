unit FIToolkit.Types;

interface

type

  TApplicationCommand = (
    acPrintHelp, acPrintVersion, acGenerateConfig, acSetConfig, acSetNoExit,
    acParseProjectGroup, acRunFixInsight, acParseReports, acBuildReport);

  TApplicationState = (
    asInitial,
    asHelpPrinted, asVersionPrinted, asConfigGenerated, asConfigSet, asNoExitSet,
    asProjectGroupParsed, asFixInsightRan, asReportsParsed, asReportBuilt,
    asFinal);

implementation

end.
