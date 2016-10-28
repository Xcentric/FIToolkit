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

end.
