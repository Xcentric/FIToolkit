unit FIToolkit.Reports.Builder.HTML;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Intf, FIToolkit.Reports.Builder.Types;

type

  THTMLReportBuilder = class (TInterfacedObject, ITextReportBuilder)
    strict private
      FOutput : TStream;
      FTemplate : ITextReportTemplate;
    public
      procedure AddFooter(FinishTime : TDateTime);
      procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
      procedure AddSummary(const Items : array of TSummaryItem);
      procedure AppendRecord(const Item : TReportRecord);
      procedure Initialize(const Template : ITextReportTemplate; Output : TStream);
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

procedure THTMLReportBuilder.AppendRecord(const Item : TReportRecord);
begin
  // TODO: implement {THTMLReportBuilder.AppendRecord}
end;

procedure THTMLReportBuilder.Initialize(const Template : ITextReportTemplate; Output : TStream);
begin
  FOutput := Output;
  FTemplate := Template;

  FOutput.Position := 0;
  FOutput.Size := 0;
end;

end.
