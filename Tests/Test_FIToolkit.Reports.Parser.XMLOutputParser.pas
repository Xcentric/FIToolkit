﻿unit Test_FIToolkit.Reports.Parser.XMLOutputParser;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  System.SysUtils,
  TestFramework,
  FIToolkit.Reports.Parser.XMLOutputParser;

type
  // Test methods for class TFixInsightXMLParser

  TestTFixInsightXMLParser = class (TGenericTestCase)
  private
    const
      STR_TEST_XML_FILE = 'test.xml';
  strict private
    FFixInsightXMLParser : TFixInsightXMLParser;
  private
    function  GenerateXMLFile : TFileName;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParse;
  end;

implementation

uses
  System.IOUtils;

function TestTFixInsightXMLParser.GenerateXMLFile : TFileName;
const
  STR_XML =
  '<?xml version="1.0"?>' + sLineBreak +
  '<FixInsightReport version="2015.11upd6">' + sLineBreak +
  '  <file name="SourceFile_1.pas">' + sLineBreak +
  '    <message line="321" col="123" id="W777">W777 Some message text</message>' + sLineBreak +
  '    <message line="456" col="654" id="C666">C666 Some message text</message>' + sLineBreak +
  '  </file>' + sLineBreak +
  '  <file name="..\SourceFile_2.pas">' + sLineBreak +
  '    <message line="321" col="123" id="O000">O000 Some message text</message>' + sLineBreak +
  '    <message line="456" col="654" id="Tria">Triality!!!</message>' + sLineBreak +
  '  </file>' + sLineBreak +
  '  <file name="..\SourceFile_3.pas">' + sLineBreak +
  '    <message line="666" col="13" id="FATAL">Fatal parser error</message>' + sLineBreak +
  '  </file>' + sLineBreak +
  '</FixInsightReport>';
begin
  Result := TestDataDir + STR_TEST_XML_FILE;
  TFile.AppendAllText(Result, STR_XML);
end;

procedure TestTFixInsightXMLParser.SetUp;
begin
  FFixInsightXMLParser := TFixInsightXMLParser.Create;
end;

procedure TestTFixInsightXMLParser.TearDown;
begin
  FreeAndNil(FFixInsightXMLParser);
end;

procedure TestTFixInsightXMLParser.TestParse;
var
  sXMLFileName : TFileName;
  iOldCount : Integer;
begin
  sXMLFileName := GenerateXMLFile;
  try
    CheckEquals(0, FFixInsightXMLParser.Messages.Count, 'Messages.Count = 0');
    FFixInsightXMLParser.Parse(sXMLFileName, False);
    CheckTrue(FFixInsightXMLParser.Messages.Count > 0, 'CheckTrue::(Messages.Count > 0)');

    iOldCount := FFixInsightXMLParser.Messages.Count;
    FFixInsightXMLParser.Parse(sXMLFileName, False);
    CheckEquals(iOldCount, FFixInsightXMLParser.Messages.Count, 'Messages.Count = iOldCount');

    iOldCount := FFixInsightXMLParser.Messages.Count;
    FFixInsightXMLParser.Parse(sXMLFileName, True);
    CheckEquals(iOldCount * 2, FFixInsightXMLParser.Messages.Count, 'Messages.Count = 2 * iOldCount');
  finally
    DeleteFile(sXMLFileName);
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFixInsightXMLParser.Suite);

end.
