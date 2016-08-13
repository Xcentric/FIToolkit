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
      procedure AppendMessagesFromXML(const XML : IXMLDocument);
    public
      constructor Create;
      destructor Destroy; override;

      procedure Parse(const FileName : TFileName; Append : Boolean);

      property Messages : TFixInsightMessages read FMessages;
  end;

implementation

uses
  Xml.XMLDoc, Winapi.ActiveX,
  FIToolkit.Reports.Parser.Exceptions, FIToolkit.Reports.Parser.Consts;

{ TFixInsightXMLParser }

procedure TFixInsightXMLParser.AppendMessagesFromXML(const XML : IXMLDocument);
begin
  // TODO: implement {TFixInsightXMLParser.AppendMessagesFromXML}
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

procedure TFixInsightXMLParser.Parse(const FileName : TFileName; Append : Boolean);
var
  XML : IXMLDocument;
begin
  if not Append then
    FMessages.Clear;

  try
    XML := TXMLDocument.Create(FileName);
  except
    Exception.RaiseOuterException(EFixInsightXMLParseError.Create);
  end;

  AppendMessagesFromXML(XML);
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
