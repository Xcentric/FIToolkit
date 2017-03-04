unit FIToolkit.Reports.Parser.Messages;

interface

uses
  System.Generics.Collections,
  FIToolkit.Reports.Parser.Types;

type

  TFixInsightMessages = class (TList<TFixInsightMessage>)
    public
      constructor Create;
  end;

implementation

{ TFixInsightMessages }

constructor TFixInsightMessages.Create;
begin
  inherited Create(TFixInsightMessage.GetComparer);
end;

end.
