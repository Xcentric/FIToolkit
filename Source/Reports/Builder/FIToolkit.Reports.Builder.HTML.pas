unit FIToolkit.Reports.Builder.HTML;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Intf, FIToolkit.Reports.Builder.Types;

type

  THTMLReportBuilder = class (TInterfacedObject, IReportBuilder)
    public
      procedure AddFooter(FinishTime : TDateTime);
      procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
      procedure AddSummary(const Items : array of TSummaryItem);
      procedure AppendRecord(const Item : TReportRecord);
      procedure Initialize(Output : TStream);
  end;

implementation

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

procedure THTMLReportBuilder.AppendRecord(const Item : TReportRecord);
begin
  // TODO: implement {THTMLReportBuilder.AppendRecord}
end;

procedure THTMLReportBuilder.Initialize(Output : TStream);
begin
  // TODO: implement {THTMLReportBuilder.Initialize}
end;

end.
