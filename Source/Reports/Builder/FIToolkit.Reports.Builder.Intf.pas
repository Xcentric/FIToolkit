unit FIToolkit.Reports.Builder.Intf;

interface

uses
  FIToolkit.Reports.Builder.Types;

type

  { Common }

  IReportBuilder = interface
    ['{68BE0EA3-035D-42B9-B20F-CFF16DA05DA8}']
    procedure AddFooter(FinishTime : TDateTime);
    procedure AddHeader(const Title : String; StartTime : TDateTime);
    procedure AddTotalSummary(const Items : array of TSummaryItem);
    procedure AppendRecord(Item : TReportRecord);
    procedure BeginProjectSection(const Title : String; const ProjectSummary : array of TSummaryItem);
    procedure BeginReport;
    procedure EndProjectSection;
    procedure EndReport;
  end;

  { Generic interfaces }

  IReportTemplate<T> = interface
    function GetFooterElement : T;
    function GetHeaderElement : T;
    function GetMessageElement : T;
    function GetProjectMessagesElement : T;
    function GetProjectSectionElement : T;
    function GetProjectSummaryElement : T;
    function GetProjectSummaryItemElement : T;
    function GetTotalSummaryElement : T;
    function GetTotalSummaryItemElement : T;
  end;

  ITemplatableReport<T; I : IReportTemplate<T>> = interface
    procedure SetTemplate(const Template : I);
  end;

  { Type-specific interfaces }

  ITextReportTemplate = interface (IReportTemplate<String>)
    ['{42897586-028B-4AEE-A518-B86074D7DCEB}']
  end;

  ITemplatableTextReport = interface (ITemplatableReport<String, ITextReportTemplate>)
    ['{EC0ADF10-E81C-4602-867D-EE060A9B8020}']
  end;

implementation

end.
