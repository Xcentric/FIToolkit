unit FIToolkit.Reports.Builder.HTML;

interface

uses
  System.Classes, System.SysUtils, System.RegularExpressions, Xml.XMLIntf,
  FIToolkit.Reports.Builder.Intf, FIToolkit.Reports.Builder.Types;

type

  THTMLReportBuilder = class (TInterfacedObject, IReportBuilder, ITemplatableTextReport)
    strict private
      FOutput : TStream;
      FOwnsOutput : Boolean;
      FTemplate : ITextReportTemplate;
    private
      function  Encode(const Value : String) : String;
      function  ExcludeClosingTag(const TemplateElement : String) : String;
      function  ExtractClosingTag(const TemplateElement : String) : String;
      function  FindClosingTag(const TemplateElement : String; out ClosingTag : TMatch) : Boolean;
      function  GenerateHTMLHead : String;
      procedure WriteLine(const Text : String);
    public
      constructor Create(Output : TStream; OwnsOutput : Boolean = False);
      destructor Destroy; override;

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

  IHTMLReportTemplate = interface (ITextReportTemplate)
    ['{C2CC3425-2FEC-4F41-A122-9FA3F8CC16D5}']
    function GetCSS : String;
  end;

  THTMLReportTemplate = class abstract (TInterfacedObject, IHTMLReportTemplate)
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
      function GetCSS : String;
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

  THTMLReportCustomTemplate = class (THTMLReportTemplate)
    public
      constructor Create(const FileName : TFileName);
  end;

  THTMLReportDefaultTemplate = class (THTMLReportTemplate)
    public
      constructor Create;
  end;

implementation

uses
  System.Types, System.IOUtils, System.NetEncoding, Xml.XMLDoc, Winapi.ActiveX,
  FIToolkit.Reports.Builder.Exceptions, FIToolkit.Reports.Builder.Consts,
  FIToolkit.Commons.Utils;

{ THTMLReportBuilder }

procedure THTMLReportBuilder.AddFooter(FinishTime : TDateTime);
begin
  WriteLine(
    FTemplate.GetFooterElement
      .Replace(STR_HTML_FINISH_TIME, Encode(DateTimeToStr(FinishTime)))
  );
end;

procedure THTMLReportBuilder.AddHeader(const Title : String; StartTime : TDateTime);
begin
  WriteLine(
    FTemplate.GetHeaderElement
      .Replace(STR_HTML_REPORT_TITLE, Encode(Title))
      .Replace(STR_HTML_START_TIME, Encode(DateTimeToStr(StartTime)))
  );
end;

procedure THTMLReportBuilder.AddTotalSummary(const Items : array of TSummaryItem);
var
  sSummaryItem, sAllSummaryItems : String;
  Item : TSummaryItem;
begin
  for Item in Items do
  begin
    sSummaryItem :=
      FTemplate.GetTotalSummaryItemElement
        .Replace(STR_HTML_SUMMARY_MESSAGE_TYPE_KEYWORD, Encode(Item.MessageTypeKeyword))
        .Replace(STR_HTML_SUMMARY_MESSAGE_TYPE_NAME, Encode(Item.MessageTypeName))
        .Replace(STR_HTML_SUMMARY_MESSAGE_COUNT, Encode(Item.MessageCount.ToString));
    sAllSummaryItems := Iff.Get<String>(
      sAllSummaryItems.IsEmpty, sSummaryItem, sAllSummaryItems + sLineBreak + sSummaryItem);
  end;

  WriteLine(
    FTemplate.GetTotalSummaryElement
      .Replace(STR_HTML_TOTAL_SUMMARY_ITEMS, sAllSummaryItems)
  );
end;

procedure THTMLReportBuilder.AppendRecord(Item : TReportRecord);
begin
  WriteLine(
    FTemplate.GetMessageElement
      .Replace(STR_HTML_MESSAGE_TYPE_KEYWORD, Encode(Item.MessageTypeKeyword))
      .Replace(STR_HTML_FILE_NAME, Encode(Item.FileName))
      .Replace(STR_HTML_LINE, Encode(Item.Line.ToString))
      .Replace(STR_HTML_COLUMN, Encode(Item.Column.ToString))
      .Replace(STR_HTML_MESSAGE_TYPE_NAME, Encode(Item.MessageTypeName))
      .Replace(STR_HTML_MESSAGE_TEXT, Encode(Item.MessageText))
      .Replace(STR_HTML_SNIPPET, Encode(Item.Snippet))
  );
end;

procedure THTMLReportBuilder.BeginProjectSection(const Title : String; const ProjectSummary : array of TSummaryItem);
var
  sSummaryItem, sAllSummaryItems, sSummary : String;
  Item : TSummaryItem;
begin
  for Item in ProjectSummary do
  begin
    sSummaryItem :=
      FTemplate.GetProjectSummaryItemElement
        .Replace(STR_HTML_SUMMARY_MESSAGE_TYPE_KEYWORD, Encode(Item.MessageTypeKeyword))
        .Replace(STR_HTML_SUMMARY_MESSAGE_TYPE_NAME, Encode(Item.MessageTypeName))
        .Replace(STR_HTML_SUMMARY_MESSAGE_COUNT, Encode(Item.MessageCount.ToString));
    sAllSummaryItems := Iff.Get<String>(
      sAllSummaryItems.IsEmpty, sSummaryItem, sAllSummaryItems + sLineBreak + sSummaryItem);
  end;

  sSummary := FTemplate.GetProjectSummaryElement.Replace(STR_HTML_PROJECT_SUMMARY_ITEMS, sAllSummaryItems);
  WriteLine(
    ExcludeClosingTag(FTemplate.GetProjectSectionElement)
      .Replace(STR_HTML_PROJECT_TITLE, Encode(Title))
      .Replace(STR_HTML_PROJECT_SUMMARY, sSummary)
  );
  WriteLine(ExcludeClosingTag(FTemplate.GetProjectMessagesElement));
end;

procedure THTMLReportBuilder.BeginReport;
begin
  WriteLine('<!DOCTYPE html>');
  WriteLine('<html>');
  WriteLine(GenerateHTMLHead);
  WriteLine('<body>');
  WriteLine('<div id="' + STR_HTML_REPORT_ROOT_ID + '">');
end;

constructor THTMLReportBuilder.Create(Output : TStream; OwnsOutput : Boolean);
begin
  inherited Create;

  FOutput := Output;
  FOwnsOutput := OwnsOutput;
end;

destructor THTMLReportBuilder.Destroy;
begin
  if FOwnsOutput then
    FreeAndNil(FOutput);

  inherited Destroy;
end;

function THTMLReportBuilder.Encode(const Value : String) : String;
begin
  Result := TNetEncoding.HTML.Encode(Value);
end;

procedure THTMLReportBuilder.EndProjectSection;
begin
  WriteLine(ExtractClosingTag(FTemplate.GetProjectMessagesElement));
  WriteLine(ExtractClosingTag(FTemplate.GetProjectSectionElement));
end;

procedure THTMLReportBuilder.EndReport;
begin
  WriteLine('</div>');
  WriteLine('</body>');
  WriteLine('</html>');
end;

function THTMLReportBuilder.ExcludeClosingTag(const TemplateElement : String) : String;
var
  ClosingTag : TMatch;
begin
  Result := TemplateElement;

  if FindClosingTag(Result, ClosingTag) then
    Delete(Result, ClosingTag.Index, ClosingTag.Length);
end;

function THTMLReportBuilder.ExtractClosingTag(const TemplateElement : String) : String;
var
  ClosingTag : TMatch;
begin
  if FindClosingTag(TemplateElement, ClosingTag) then
    Result := Copy(TemplateElement, ClosingTag.Index, ClosingTag.Length)
  else
    Result := String.Empty;
end;

function THTMLReportBuilder.FindClosingTag(const TemplateElement : String; out ClosingTag : TMatch) : Boolean;
var
  AllClosingTags : TMatchCollection;
begin
  Result := False;
  AllClosingTags := TRegEx.Matches(TemplateElement, '<\/[a-z0-9]*>', [roIgnoreCase]);

  if AllClosingTags.Count > 0 then
  begin
    ClosingTag := AllClosingTags[AllClosingTags.Count-1];
    Exit(True);
  end;
end;

function THTMLReportBuilder.GenerateHTMLHead : String;
var
  HTMLTemplate : IHTMLReportTemplate;
begin
  Result :=
    '<head>' + sLineBreak +
    '<meta charset="UTF-8">' + sLineBreak +
    '<title>' + Encode(RSReportTitle) + '</title>' + sLineBreak;

  if Supports(FTemplate, IHTMLReportTemplate, HTMLTemplate) then
    Result := Result +
      '<style>' + sLineBreak +
      HTMLTemplate.GetCSS + sLineBreak +
      '</style>' + sLineBreak;

  Result := Result + '</head>';
end;

procedure THTMLReportBuilder.SetTemplate(const Template : ITextReportTemplate);
begin
  if Assigned(Template) then
    FTemplate := Template
  else
    raise EInvalidReportTemplate.Create;
end;

procedure THTMLReportBuilder.WriteLine(const Text : String);
var
  TextBytes : TBytes;
begin
  TextBytes := TEncoding.UTF8.GetBytes(Text + sLineBreak);
  FOutput.WriteData(TextBytes, Length(TextBytes));
end;

{ THTMLReportTemplate }

constructor THTMLReportTemplate.Create(XMLStream : TStream);
var
  XML : IXMLDocument;
begin
  inherited Create;

  XML := TXMLDocument.Create(nil);
  try
    XML.LoadFromStream(XMLStream);
    Parse(XML);
  except
    Exception.RaiseOuterException(EReportTemplateParseError.Create);
  end;
end;

function THTMLReportTemplate.GetCSS : String;
begin
  Result := FCSS;
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
var
  RootNode, TotalSummaryNode, ProjectSectionNode, ProjectSummaryNode, ProjectMessagesNode : IXMLNode;
begin //FI:C101
  RootNode := TemplateSource.Node.ChildNodes[STR_RPTXML_ROOT_NODE];
  TotalSummaryNode := RootNode.ChildNodes[STR_RPTXML_TOTAL_SUMMARY_NODE];
  ProjectSectionNode := RootNode.ChildNodes[STR_RPTXML_PROJECT_SECTION_NODE];
  ProjectSummaryNode := ProjectSectionNode.ChildNodes[STR_RPTXML_PROJECT_SUMMARY_NODE];
  ProjectMessagesNode := ProjectSectionNode.ChildNodes[STR_RPTXML_PROJECT_MESSAGES_NODE];

  FCSS :=
    RootNode
    .ChildNodes[STR_RPTXML_CSS_NODE].Text;

  FHeaderElement :=
    RootNode
    .ChildNodes[STR_RPTXML_HEADER_NODE]
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FTotalSummaryElement :=
    TotalSummaryNode
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FTotalSummaryItemElement :=
    TotalSummaryNode
    .ChildNodes[STR_RPTXML_TOTAL_SUMMARY_ITEM_NODE]
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FProjectSectionElement :=
    ProjectSectionNode
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FProjectSummaryElement :=
    ProjectSummaryNode
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FProjectSummaryItemElement :=
    ProjectSummaryNode
    .ChildNodes[STR_RPTXML_PROJECT_SUMMARY_ITEM_NODE]
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FProjectMessagesElement :=
    ProjectMessagesNode
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FMessageElement :=
    ProjectMessagesNode
    .ChildNodes[STR_RPTXML_MESSAGE_NODE]
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;

  FFooterElement :=
    RootNode
    .ChildNodes[STR_RPTXML_FOOTER_NODE]
    .ChildNodes[STR_RPTXML_ELEMENT_NODE].Text;    
end;

{ THTMLReportCustomTemplate }

constructor THTMLReportCustomTemplate.Create(const FileName : TFileName);
var
  FS : TFileStream;
begin
  try
    FS := TFile.Open(FileName, TFileMode.fmOpen, TFileAccess.faRead, TFileShare.fsRead);
    try
      inherited Create(FS);
    finally
      FS.Free;
    end;
  except
    Exception.RaiseOuterException(EReportTemplateLoadError.Create);
  end;
end;

{ THTMLReportDefaultTemplate }

constructor THTMLReportDefaultTemplate.Create;
var
  RS : TResourceStream;
begin
  try
    RS := TResourceStream.Create(HInstance, STR_RES_HTML_REPORT_DEFAULT_TEMPLATE, RT_RCDATA);
    try
      inherited Create(RS);
    finally
      RS.Free;
    end;
  except
    Exception.RaiseOuterException(EReportTemplateLoadError.Create);
  end;
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
