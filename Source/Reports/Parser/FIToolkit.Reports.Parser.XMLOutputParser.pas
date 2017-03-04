unit FIToolkit.Reports.Parser.XMLOutputParser;

interface

uses
  System.SysUtils, System.Generics.Collections, Xml.XMLIntf,
  FIToolkit.Reports.Parser.Types;

type

  TFixInsightXMLParser = class sealed
    private
      type
        TFixInsightMessages = class (TList<TFixInsightMessage>);
    strict private
      FMessages : TFixInsightMessages;
    private
      procedure AppendMessagesFromXML(const XML : IXMLDocument; const ProjectDir : String);
    public
      constructor Create;
      destructor Destroy; override;

      procedure Parse(const ReportFile : TFileName; Append : Boolean); overload;
      procedure Parse(const ReportFile, ProjectFile : TFileName; Append : Boolean); overload;

      property Messages : TFixInsightMessages read FMessages;
  end;

implementation

uses
  Xml.XMLDoc, Winapi.ActiveX, System.IOUtils,
  FIToolkit.Commons.Utils,
  FIToolkit.Reports.Parser.Exceptions, FIToolkit.Reports.Parser.Consts;

{ TFixInsightXMLParser }

procedure TFixInsightXMLParser.AppendMessagesFromXML(const XML : IXMLDocument; const ProjectDir : String);
var
  RootNode, FileNode, MessageNode : IXMLNode;
  i, k : Integer;
  sFileName, sFullFileName : String;
begin
  try
    RootNode := XML.Node.ChildNodes[STR_FIXML_ROOT_NODE];

    if Assigned(RootNode) then
      for i := 0 to RootNode.ChildNodes.Count - 1 do
      begin
        FileNode := RootNode.ChildNodes.Get(i);

        if SameText(FileNode.NodeName, STR_FIXML_FILE_NODE) then
        begin
          sFileName := FileNode.Attributes[STR_FIXML_NAME_ATTRIBUTE];
          sFullFileName := Iff.Get<String>(ProjectDir.IsEmpty, String.Empty, TPath.Combine(ProjectDir, sFileName));

          for k := 0 to FileNode.ChildNodes.Count - 1 do
          begin
            MessageNode := FileNode.ChildNodes.Get(k);

            if SameText(MessageNode.NodeName, STR_FIXML_MESSAGE_NODE) then
            begin
              if sFullFileName.IsEmpty then
                FMessages.Add(
                  TFixInsightMessage.Create(
                    sFileName,
                    MessageNode.Attributes[STR_FIXML_LINE_ATTRIBUTE],
                    MessageNode.Attributes[STR_FIXML_COL_ATTRIBUTE],
                    MessageNode.Attributes[STR_FIXML_ID_ATTRIBUTE],
                    MessageNode.Text))
              else
                FMessages.Add(
                  TFixInsightMessage.Create(
                    sFileName,
                    sFullFileName,
                    MessageNode.Attributes[STR_FIXML_LINE_ATTRIBUTE],
                    MessageNode.Attributes[STR_FIXML_COL_ATTRIBUTE],
                    MessageNode.Attributes[STR_FIXML_ID_ATTRIBUTE],
                    MessageNode.Text));
            end;
          end;
        end;
      end;
  except
    Exception.RaiseOuterException(EFixInsightXMLParseError.Create);
  end;
end;

constructor TFixInsightXMLParser.Create;
begin
  inherited Create;

  FMessages := TFixInsightMessages.Create;
end;

destructor TFixInsightXMLParser.Destroy;
begin
  FreeAndNil(FMessages);

  inherited Destroy;
end;

procedure TFixInsightXMLParser.Parse(const ReportFile : TFileName; Append : Boolean);
begin
  Parse(ReportFile, String.Empty, Append);
end;

procedure TFixInsightXMLParser.Parse(const ReportFile, ProjectFile : TFileName; Append : Boolean);
var
  XML : IXMLDocument;
begin
  if not Append then
    FMessages.Clear;

  try
    XML := TXMLDocument.Create(ReportFile);
  except
    Exception.RaiseOuterException(EFixInsightXMLParseError.Create);
  end;

  AppendMessagesFromXML(XML, TPath.GetDirectoryName(ProjectFile, True));
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
