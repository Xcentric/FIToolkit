unit FIToolkit.Reports.Builder.HTML;

interface

uses
  FIToolkit.Reports.Builder.Intf, FIToolkit.Reports.Builder.Types;

type

  THTMLReportBuilder = class (TInterfacedObject, IReportBuilder, ITemplatableTextReport)
    strict private
      FTemplate : ITextReportTemplate;
    public
      procedure AddFooter(FinishTime : TDateTime);
      procedure AddHeader(const Title : String; StartTime : TDateTime);
      procedure AddTotalSummary(const Items : array of TSummaryItem);
      procedure AppendRecord(Item : TReportRecord);
      procedure BeginProjectSection(const Title : String; const ProjectSummary : array of TSummaryItem);
      procedure BeginReport;
      procedure EndProjectSection;
      procedure EndReport;
      procedure SetTemplate(const Template : ITextReportTemplate);
  end;

  THTMLReportTemplate = class (TInterfacedObject, ITextReportTemplate)
    public
      function GetFooterElement : String;
      function GetHeaderElement : String;
      function GetMessageElement : String;
      function GetProjectMessagesElement : String;
      function GetProjectSectionElement : String;
      function GetProjectSummaryElement : String;
      function GetTotalSummaryElement : String;
      function GetTotalSummaryItemElement : String;
  end;

implementation

uses
  FIToolkit.Reports.Builder.Consts;

{ THTMLReportBuilder }

procedure THTMLReportBuilder.AddFooter(FinishTime : TDateTime);
begin
  // TODO: implement {THTMLReportBuilder.AddFooter}
end;

procedure THTMLReportBuilder.AddHeader(const Title : String; StartTime : TDateTime);
begin
  // TODO: implement {THTMLReportBuilder.AddHeader}
end;

procedure THTMLReportBuilder.AddTotalSummary(const Items : array of TSummaryItem);
begin
  // TODO: implement {THTMLReportBuilder.AddTotalSummary}
end;

procedure THTMLReportBuilder.AppendRecord(Item : TReportRecord);
begin
  // TODO: implement {THTMLReportBuilder.AppendRecord}
end;

procedure THTMLReportBuilder.BeginProjectSection(const Title : String; const ProjectSummary : array of TSummaryItem);
begin
  // TODO: implement {THTMLReportBuilder.BeginProjectSection}
end;

procedure THTMLReportBuilder.BeginReport;
begin
  // TODO: implement {THTMLReportBuilder.BeginReport}
end;

procedure THTMLReportBuilder.EndProjectSection;
begin
  // TODO: implement {THTMLReportBuilder.EndProjectSection}
end;

procedure THTMLReportBuilder.EndReport;
begin
  // TODO: implement {THTMLReportBuilder.EndReport}
end;

procedure THTMLReportBuilder.SetTemplate(const Template : ITextReportTemplate);
begin
  FTemplate := Template;
end;

{ THTMLReportTemplate }

function THTMLReportTemplate.GetFooterElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetFooterElement}
end;

function THTMLReportTemplate.GetHeaderElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetHeaderElement}
end;

function THTMLReportTemplate.GetMessageElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetMessageElement}
end;

function THTMLReportTemplate.GetProjectMessagesElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetProjectMessagesElement}
end;

function THTMLReportTemplate.GetProjectSectionElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetProjectSectionElement}
end;

function THTMLReportTemplate.GetProjectSummaryElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetProjectSummaryElement}
end;

function THTMLReportTemplate.GetTotalSummaryElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetTotalSummaryElement}
end;

function THTMLReportTemplate.GetTotalSummaryItemElement : String;
begin
  // TODO: implement {THTMLReportTemplate.GetTotalSummaryItemElement}
end;

end.
