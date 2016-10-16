unit FIToolkit.Reports.Builder.Intf;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Types;

type

  { Common }

  IReportBuilder = interface
    ['{68BE0EA3-035D-42B9-B20F-CFF16DA05DA8}']
    procedure AddFooter(FinishTime : TDateTime);
    procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
    procedure AddSummary(const Items : array of TSummaryItem);
    procedure AppendRecord(Item : TReportRecord);
    procedure BeginReport;
    procedure EndReport;
    procedure SetOutput(Output : TStream);
  end;

  { Generic interfaces }

  IReportTemplate<T> = interface
    function GetFooter : T;
    function GetHeader : T;
    function GetMessage : T;
    function GetMessageList : T;
    function GetSummary : T;
    function GetSummaryItem : T;
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
