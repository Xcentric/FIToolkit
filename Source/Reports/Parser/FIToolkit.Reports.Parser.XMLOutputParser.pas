unit FIToolkit.Reports.Parser.XMLOutputParser;

interface

uses
  System.SysUtils, System.Types, Xml.XMLIntf, Xml.XMLDoc;

type

  TFixInsightXMLParser = class sealed
    strict private
      //FXML : IXMLDocument;
    public
      //
  end;

implementation

uses
  Winapi.ActiveX,
  FIToolkit.Reports.Parser.Consts;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;

end.
