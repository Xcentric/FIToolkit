unit FIToolkit.Reports.Builder.HTML;

interface

uses
  System.Classes, Xml.XMLIntf,
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

  THTMLReportTemplate = class abstract (TInterfacedObject, ITextReportTemplate)
    strict private
      FCSS,
      FFooterElement,
      FHeaderElement,
      FMessageElement,
      FProjectMessagesElement,
      FProjectSectionElement,
      FProjectSummaryElement,
      FProjectSummaryItemElement,
      FTotalSummaryElement,
      FTotalSummaryItemElement : String;
    private
      procedure Parse(const TemplateSource : IXMLDocument);
    protected
      constructor Create(XMLStream : TStream);
    public
      function GetFooterElement : String;
      function GetHeaderElement : String;
      function GetMessageElement : String;
      function GetProjectMessagesElement : String;
      function GetProjectSectionElement : String;
      function GetProjectSummaryElement : String;
      function GetProjectSummaryItemElement : String;
      function GetTotalSummaryElement : String;
      function GetTotalSummaryItemElement : String;
  end;

implementation

uses
  System.SysUtils, Xml.XMLDoc, Winapi.ActiveX,
  FIToolkit.Reports.Builder.Exceptions, FIToolkit.Reports.Builder.Consts;

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

constructor THTMLReportTemplate.Create(XMLStream : TStream);
var
  XML : IXMLDocument;
begin
  XML := TXMLDocument.Create(nil);

  try
    XML.LoadFromStream(XMLStream);
    Parse(XML);
  except
    Exception.RaiseOuterException(EReportTemplateParseError.Create);
  end;
end;

function THTMLReportTemplate.GetFooterElement : String;
begin
  Result := FFooterElement;
end;

function THTMLReportTemplate.GetHeaderElement : String;
begin
  Result := FHeaderElement;
end;

function THTMLReportTemplate.GetMessageElement : String;
begin
  Result := FMessageElement;
end;

function THTMLReportTemplate.GetProjectMessagesElement : String;
begin
  Result := FProjectMessagesElement;
end;

function THTMLReportTemplate.GetProjectSectionElement : String;
begin
  Result := FProjectSectionElement;
end;

function THTMLReportTemplate.GetProjectSummaryElement : String;
begin
  Result := FProjectSummaryElement;
end;

function THTMLReportTemplate.GetProjectSummaryItemElement : String;
begin
  Result := FProjectSummaryItemElement;
end;

function THTMLReportTemplate.GetTotalSummaryElement : String;
begin
  Result := FTotalSummaryElement;
end;

function THTMLReportTemplate.GetTotalSummaryItemElement : String;
begin
  Result := FTotalSummaryItemElement;
end;

procedure THTMLReportTemplate.Parse(const TemplateSource : IXMLDocument);
begin
  // TODO: implement {THTMLReportTemplate.Parse}
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
