unit FIToolkit.Reports.Builder.HTML;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Intf, FIToolkit.Reports.Builder.Types;

type

  THTMLReportBuilder = class (TInterfacedObject, IReportBuilder, ITemplatableTextReport)
    strict private
      FOutput : TStream;
      FTemplate : ITextReportTemplate;
    public
      procedure AddFooter(FinishTime : TDateTime);
      procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
      procedure AddSummary(const Items : array of TSummaryItem);
      procedure AppendRecord(Item : TReportRecord);
      procedure BeginReport;
      procedure EndReport;
      procedure SetOutput(Output : TStream);
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

procedure THTMLReportBuilder.AddHeader(const ProjectTitle : String; StartTime : TDateTime);
begin
  // TODO: implement {THTMLReportBuilder.AddHeader}
end;

procedure THTMLReportBuilder.AddSummary(const Items : array of TSummaryItem);
begin
  // TODO: implement {THTMLReportBuilder.AddSummary}
end;

procedure THTMLReportBuilder.AppendRecord(Item : TReportRecord);
begin
  // TODO: implement {THTMLReportBuilder.AppendRecord}
end;

procedure THTMLReportBuilder.BeginReport;
begin
  // TODO: implement {THTMLReportBuilder.BeginReport}
end;

procedure THTMLReportBuilder.EndReport;
begin
  // TODO: implement {THTMLReportBuilder.EndReport}
end;

procedure THTMLReportBuilder.SetOutput(Output : TStream);
begin
  FOutput := Output;

  FOutput.Position := 0;
  FOutput.Size := 0;
end;

procedure THTMLReportBuilder.SetTemplate(const Template : ITextReportTemplate);
begin
  FTemplate := Template;
end;

end.
