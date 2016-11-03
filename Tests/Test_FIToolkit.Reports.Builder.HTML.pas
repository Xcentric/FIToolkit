﻿unit Test_FIToolkit.Reports.Builder.HTML;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework,
  System.Classes,
  FIToolkit.Reports.Builder.HTML, FIToolkit.Reports.Builder.Consts,
  TestTypes;

type

  // Test methods for class THTMLReportBuilder

  TestTHTMLReportBuilder = class (TGenericTestCase)
  private
    const
      START_TIME : TDateTimeRec = (
        Year : 2015; Month : 06; Day : 29;
        Hour : 18; Minute : 24; Second : 44;
      );
      FINISH_TIME : TDateTimeRec = (
        Year : 2016; Month : 10; Day : 31;
        Hour : 20; Minute : 35; Second : 54;
      );
  strict private
    FHTMLReportBuilder : THTMLReportBuilder;
    FReportOutput : TStringStream;
    FReportPrevPos : Int64;
  private
    procedure CheckReportPositionIncreased;
    function  GetReportText : String;
    function  GetTemplate : IHTMLReportTemplate;
    procedure SaveReportPosition;

    property  ReportText : String read GetReportText;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddFooter;
    procedure TestAddHeader;
    procedure TestAddTotalSummary;
    procedure TestAppendRecord;
    procedure TestBeginProjectSection;
    procedure TestBeginReport;
    procedure TestEndProjectSection;
    procedure TestEndReport;
    procedure TestSetTemplate;
  end;

  // Test methods for class THTMLReportTemplate

  TestTHTMLReportTemplate = class (TGenericTestCase)
    private
      const
        STR_TEMPLATE =
          {$REGION 'XML'}
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<HTMLReportTemplate>' +
          '	<CSS>' +
          '		<![CDATA[%STYLE%]]>' +
          '	</CSS>' +
          '	<Header>' +
          '		<Element>' +
          '			<![CDATA[' + STR_HTML_REPORT_TITLE + '|' + STR_HTML_START_TIME + ']]>' +
          '		</Element>' +
          '	</Header>' +
          '	<TotalSummary>' +
          '		<Element>' +
          '			<![CDATA[%TOTAL_SUMMARY_ELEMENT%]]>' +
          '		</Element>' +
          '		<TotalSummaryItem>' +
          '			<Element>' +
          '				<![CDATA[%TOTAL_SUMMARY_ITEM_ELEMENT%]]>' +
          '			</Element>' +
          '		</TotalSummaryItem>' +
          '	</TotalSummary>' +
          '	<ProjectSection>' +
          '		<Element>' +
          '			<![CDATA[%PROJECT_SECTION_ELEMENT%]]>' +
          '		</Element>' +
          '		<ProjectSummary>' +
          '			<Element>' +
          '				<![CDATA[%PROJECT_SUMMARY_ELEMENT%]]>' +
          '			</Element>' +
          '			<ProjectSummaryItem>' +
          '				<Element>' +
          '					<![CDATA[%PROJECT_SUMMARY_ITEM_ELEMENT%]]>' +
          '				</Element>' +
          '			</ProjectSummaryItem>' +
          '		</ProjectSummary>' +
          '		<ProjectMessages>' +
          '			<Element>' +
          '				<![CDATA[%PROJECT_MESSAGES_ELEMENT%]]>' +
          '			</Element>' +
          '			<Message>' +
          '				<Element>' +
          '					<![CDATA[%MESSAGE_ELEMENT%]]>' +
          '				</Element>' +
          '			</Message>' +
          '		</ProjectMessages>' +
          '	</ProjectSection>' +
          '	<Footer>' +
          '		<Element>' +
          '			<![CDATA[' + STR_HTML_FINISH_TIME + ']]>' +
          '		</Element>' +
          '	</Footer>' +
          '</HTMLReportTemplate>';
          {$ENDREGION}
    type
      TTestHTMLReportTemplate = class sealed (THTMLReportTemplate);
  strict private
    FHTMLReportTemplate : TTestHTMLReportTemplate;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetCSS;
    procedure TestGetFooterElement;
    procedure TestGetHeaderElement;
    procedure TestGetMessageElement;
    procedure TestGetProjectMessagesElement;
    procedure TestGetProjectSectionElement;
    procedure TestGetProjectSummaryElement;
    procedure TestGetProjectSummaryItemElement;
    procedure TestGetTotalSummaryElement;
    procedure TestGetTotalSummaryItemElement;
  end;

  // Test methods for class THTMLReportCustomTemplate

  TestTHTMLReportCustomTemplate = class (TGenericTestCase)
  private
    function  GetTestXMLFileName : String;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreate;
  end;

  // Test methods for class THTMLReportDefaultTemplate

  TestTHTMLReportDefaultTemplate = class (TGenericTestCase)
  published
    procedure TestCreate;
  end;

implementation

uses
  System.SysUtils,
  FIToolkit.Reports.Builder.Intf, FIToolkit.Reports.Builder.Types, FIToolkit.Reports.Builder.Exceptions,
  TestUtils;

{ TestTHTMLReportBuilder }

procedure TestTHTMLReportBuilder.CheckReportPositionIncreased;
begin
  CheckTrue(FReportOutput.Position > FReportPrevPos, 'CheckTrue::(FReportOutput.Position > FReportPrevPos)');
end;

function TestTHTMLReportBuilder.GetReportText : String;
begin
  Result := FReportOutput.DataString;
end;

function TestTHTMLReportBuilder.GetTemplate : IHTMLReportTemplate;
var
  XML : TStringStream;
begin
  XML := TStringStream.Create(TestTHTMLReportTemplate.STR_TEMPLATE);
  try
    Result := TestTHTMLReportTemplate.TTestHTMLReportTemplate.Create(XML);
  finally
    XML.Free;
  end;
end;

procedure TestTHTMLReportBuilder.SaveReportPosition;
begin
  FReportPrevPos := FReportOutput.Position;
end;

procedure TestTHTMLReportBuilder.SetUp;
begin
  FReportOutput := TStringStream.Create;
  FHTMLReportBuilder := THTMLReportBuilder.Create(FReportOutput);
  FHTMLReportBuilder.SetTemplate(GetTemplate);
end;

procedure TestTHTMLReportBuilder.TearDown;
begin
  FreeAndNil(FHTMLReportBuilder);
  FreeAndNil(FReportOutput);
end;

procedure TestTHTMLReportBuilder.TestAddFooter;
var
  FinishTime : TDateTime;
begin
  FinishTime := FINISH_TIME;
  SaveReportPosition;

  FHTMLReportBuilder.AddFooter(FinishTime);

  CheckReportPositionIncreased;
  CheckTrue(ReportText.Contains(DateTimeToStr(FinishTime)), 'CheckTrue::Contains(FinishTime)');
end;

procedure TestTHTMLReportBuilder.TestAddHeader;
var
  Title : String;
  StartTime : TDateTime;
begin
  Title := 'HTML Report Title';
  StartTime := START_TIME;
  SaveReportPosition;

  FHTMLReportBuilder.AddHeader(Title, StartTime);

  CheckReportPositionIncreased;
  CheckTrue(ReportText.Contains(Title), 'CheckTrue::Contains(Title)');
  CheckTrue(ReportText.Contains(DateTimeToStr(StartTime)), 'CheckTrue::Contains(StartTime)');
end;

procedure TestTHTMLReportBuilder.TestAddTotalSummary;
const
  ARR_SUMMARY_ITEMS : array [0..1] of TSummaryItem = (
    (MessageCount: 6667; MessageTypeKeyWord: 'classError'; MessageTypeName: 'ERROR'),
    (MessageCount: 7776; MessageTypeKeyword: 'classWarning'; MessageTypeName: 'WARNING')
  );
var
  Items : array of TSummaryItem;
begin
  SetLength(Items, Length(ARR_SUMMARY_ITEMS));
  CopyArray(@Items[0], @ARR_SUMMARY_ITEMS[0], TypeInfo(TSummaryItem), Length(ARR_SUMMARY_ITEMS));
  SaveReportPosition;

  FHTMLReportBuilder.AddTotalSummary(Items);

  CheckReportPositionIncreased;
  //
  CheckTrue(ReportText.Contains(6667.ToString), 'CheckTrue::Contains(6667)');
  CheckTrue(ReportText.Contains('classError'), 'CheckTrue::Contains(classError)');
  CheckTrue(ReportText.Contains('ERROR'), 'CheckTrue::Contains(ERROR)');
  //
  CheckTrue(ReportText.Contains(7776.ToString), 'CheckTrue::Contains(7776)');
  CheckTrue(ReportText.Contains('classWarning'), 'CheckTrue::Contains(classWarning)');
  CheckTrue(ReportText.Contains('WARNING'), 'CheckTrue::Contains(WARNING)');
end;

procedure TestTHTMLReportBuilder.TestAppendRecord;
var
  Item : TReportRecord;
begin
  with Item do
  begin
    Column             := 81;
    Line               := 666;
    FileName           := 'TestFileName';
    MessageText        := 'TestMessageText';
    MessageTypeKeyword := 'TestMessageTypeKeyword';
    MessageTypeName    := 'TestMessageTypeName';
  end;
  SaveReportPosition;

  FHTMLReportBuilder.AppendRecord(Item);

  CheckReportPositionIncreased;
  CheckTrue(ReportText.Contains(Item.Column.ToString), 'CheckTrue::Contains(Column)');
  CheckTrue(ReportText.Contains(Item.Line.ToString), 'CheckTrue::Contains(Line)');
  CheckTrue(ReportText.Contains(Item.FileName), 'CheckTrue::Contains(FileName)');
  CheckTrue(ReportText.Contains(Item.MessageText), 'CheckTrue::Contains(MessageText)');
  CheckTrue(ReportText.Contains(Item.MessageTypeKeyword), 'CheckTrue::Contains(MessageTypeKeyword)');
  CheckTrue(ReportText.Contains(Item.MessageTypeName), 'CheckTrue::Contains(MessageTypeName)');
end;

procedure TestTHTMLReportBuilder.TestBeginProjectSection;
const
  ARR_SUMMARY_ITEMS : array [0..1] of TSummaryItem = (
    (MessageCount: 7778; MessageTypeKeyWord: 'classOptimization'; MessageTypeName: 'OPTIMIZATION'),
    (MessageCount: 8887; MessageTypeKeyword: 'classHint'; MessageTypeName: 'HINT')
  );
var
  ProjectSummary : array of TSummaryItem;
  Title : String;
begin
  SetLength(ProjectSummary, Length(ARR_SUMMARY_ITEMS));
  CopyArray(@ProjectSummary[0], @ARR_SUMMARY_ITEMS[0], TypeInfo(TSummaryItem), Length(ARR_SUMMARY_ITEMS));
  Title := 'ProjectTitle';
  SaveReportPosition;

  FHTMLReportBuilder.BeginProjectSection(Title, ProjectSummary);

  CheckReportPositionIncreased;
  //
  CheckTrue(ReportText.Contains(7778.ToString), 'CheckTrue::Contains(7778)');
  CheckTrue(ReportText.Contains('classOptimization'), 'CheckTrue::Contains(classOptimization)');
  CheckTrue(ReportText.Contains('OPTIMIZATION'), 'CheckTrue::Contains(OPTIMIZATION)');
  //
  CheckTrue(ReportText.Contains(8777.ToString), 'CheckTrue::Contains(8777)');
  CheckTrue(ReportText.Contains('classHint'), 'CheckTrue::Contains(classHint)');
  CheckTrue(ReportText.Contains('HINT'), 'CheckTrue::Contains(HINT)');
end;

procedure TestTHTMLReportBuilder.TestBeginReport;
begin
  SaveReportPosition;

  FHTMLReportBuilder.BeginReport;

  CheckReportPositionIncreased;
  CheckTrue(ReportText.StartsWith('<!DOCTYPE html>'), 'CheckTrue::StartsWith(<!DOCTYPE html>)');
  CheckTrue(ReportText.Contains('<html>'), 'CheckTrue::Contains(<html>)');
  CheckTrue(ReportText.Contains('<body>'), 'CheckTrue::Contains(<body>)');
  CheckTrue(ReportText.Contains('<head>'), 'CheckTrue::Contains(<head>)');
  CheckTrue(ReportText.Contains('<meta charset="UTF-8">'), 'CheckTrue::Contains(charset="UTF-8")');
  CheckTrue(ReportText.Contains('<title>'), 'CheckTrue::Contains(<title>)');
  CheckTrue(ReportText.Contains(RSReportTitle), 'CheckTrue::Contains(%s)', [RSReportTitle]);
  CheckTrue(ReportText.Contains('<style>'), 'CheckTrue::Contains(<style>)');
end;

procedure TestTHTMLReportBuilder.TestEndProjectSection;
begin
  SaveReportPosition;

  FHTMLReportBuilder.EndProjectSection;

  CheckReportPositionIncreased;
  CheckTrue(ReportText.EndsWith('</div>'), 'CheckTrue::EndsWith(</div>)');
end;

procedure TestTHTMLReportBuilder.TestEndReport;
begin
  SaveReportPosition;

  FHTMLReportBuilder.EndReport;

  CheckReportPositionIncreased;
  CheckTrue(ReportText.Contains('</div>'), 'CheckTrue::Contains(</div>)');
  CheckTrue(ReportText.Contains('</body>'), 'CheckTrue::Contains(</body>)');
  CheckTrue(ReportText.EndsWith('</html>' + sLineBreak), 'CheckTrue::EndsWith(</html>)');
end;

procedure TestTHTMLReportBuilder.TestSetTemplate;
begin
  CheckException(
    procedure
    begin
      FHTMLReportBuilder.SetTemplate(nil);
    end,
    EInvalidReportTemplate,
    'CheckException::EInvalidReportTemplate'
  );
end;

{ TestTHTMLReportTemplate }

procedure TestTHTMLReportTemplate.SetUp;
var
  XML : TStringStream;
begin
  XML := TStringStream.Create(STR_TEMPLATE);
  try
    FHTMLReportTemplate := TTestHTMLReportTemplate.Create(XML);
  finally
    XML.Free;
  end;
end;

procedure TestTHTMLReportTemplate.TearDown;
begin
  FHTMLReportTemplate.Free;
  FHTMLReportTemplate := nil;
end;

procedure TestTHTMLReportTemplate.TestGetCSS;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetCSS;

  CheckEquals('%STYLE%', ReturnValue, 'ReturnValue = %STYLE%');
end;

procedure TestTHTMLReportTemplate.TestGetFooterElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetFooterElement;

  CheckEquals(STR_HTML_FINISH_TIME, ReturnValue, 'ReturnValue = ' + STR_HTML_FINISH_TIME);
end;

procedure TestTHTMLReportTemplate.TestGetHeaderElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetHeaderElement;

  CheckTrue(ReturnValue.StartsWith(STR_HTML_REPORT_TITLE), 'CheckTrue::StartsWith(%s)', [STR_HTML_REPORT_TITLE]);
  CheckTrue(ReturnValue.EndsWith(STR_HTML_START_TIME), 'CheckTrue::EndsWith(%s)', [STR_HTML_START_TIME]);
end;

procedure TestTHTMLReportTemplate.TestGetMessageElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetMessageElement;

  CheckEquals('%MESSAGE_ELEMENT%', ReturnValue, 'ReturnValue = %MESSAGE_ELEMENT%');
end;

procedure TestTHTMLReportTemplate.TestGetProjectMessagesElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetProjectMessagesElement;

  CheckEquals('%PROJECT_MESSAGES_ELEMENT%', ReturnValue, 'ReturnValue = %PROJECT_MESSAGES_ELEMENT%');
end;

procedure TestTHTMLReportTemplate.TestGetProjectSectionElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetProjectSectionElement;

  CheckEquals('%PROJECT_SECTION_ELEMENT%', ReturnValue, 'ReturnValue = %PROJECT_SECTION_ELEMENT%');
end;

procedure TestTHTMLReportTemplate.TestGetProjectSummaryElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetProjectSummaryElement;

  CheckEquals('%PROJECT_SUMMARY_ELEMENT%', ReturnValue, 'ReturnValue = %PROJECT_SUMMARY_ELEMENT%');
end;

procedure TestTHTMLReportTemplate.TestGetProjectSummaryItemElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetProjectSummaryItemElement;

  CheckEquals('%PROJECT_SUMMARY_ITEM_ELEMENT%', ReturnValue, 'ReturnValue = %PROJECT_SUMMARY_ITEM_ELEMENT%');
end;

procedure TestTHTMLReportTemplate.TestGetTotalSummaryElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetTotalSummaryElement;

  CheckEquals('%TOTAL_SUMMARY_ELEMENT%', ReturnValue, 'ReturnValue = %TOTAL_SUMMARY_ELEMENT%');
end;

procedure TestTHTMLReportTemplate.TestGetTotalSummaryItemElement;
var
  ReturnValue : String;
begin
  ReturnValue := FHTMLReportTemplate.GetTotalSummaryItemElement;

  CheckEquals('%TOTAL_SUMMARY_ITEM_ELEMENT%', ReturnValue, 'ReturnValue = %TOTAL_SUMMARY_ITEM_ELEMENT%');
end;

{ TestTHTMLReportCustomTemplate }

function TestTHTMLReportCustomTemplate.GetTestXMLFileName : String;
begin
  Result := TestDataDir + ClassName + '.xml';
end;

procedure TestTHTMLReportCustomTemplate.SetUp;
var
  L : TStringList;
begin
  L := TStringList.Create;
  try
    L.Text := TestTHTMLReportTemplate.STR_TEMPLATE;
    L.SaveToFile(GetTestXMLFileName);
  finally
    L.Free;
  end;
end;

procedure TestTHTMLReportCustomTemplate.TearDown;
begin
  DeleteFile(GetTestXMLFileName);
end;

procedure TestTHTMLReportCustomTemplate.TestCreate;
begin
  CheckException(
    procedure
    begin
      THTMLReportCustomTemplate.Create(String.Empty);
    end,
    EReportTemplateLoadError,
    'CheckException::EReportTemplateLoadError'
  );

  CheckException(
    procedure
    begin
      THTMLReportCustomTemplate.Create(GetTestXMLFileName).Free;
    end,
    nil,
    'CheckException::nil'
  );
end;

{ TestTHTMLReportDefaultTemplate }

procedure TestTHTMLReportDefaultTemplate.TestCreate;
begin
  CheckException(
    procedure
    begin
      THTMLReportDefaultTemplate.Create;
    end,
    EReportTemplateLoadError,
    'CheckException::EReportTemplateLoadError'
  );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTHTMLReportBuilder.Suite);
  RegisterTest(TestTHTMLReportTemplate.Suite);
  RegisterTest(TestTHTMLReportCustomTemplate.Suite);
  RegisterTest(TestTHTMLReportDefaultTemplate.Suite);

end.
