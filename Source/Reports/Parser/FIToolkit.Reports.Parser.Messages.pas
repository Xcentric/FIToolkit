unit FIToolkit.Reports.Parser.Messages;

interface

uses
  System.Generics.Collections,
  FIToolkit.Reports.Parser.Types;

type

  TFixInsightMessages = class (TList<TFixInsightMessage>)
    strict private
      FSorted : Boolean;
    private
      procedure SetSorted(Value : Boolean);
    protected
      procedure Notify(const Item : TFixInsightMessage; Action : TCollectionNotification); override; final;
    public
      constructor Create;

      property Sorted : Boolean read FSorted write SetSorted;
  end;

implementation

{ TFixInsightMessages }

constructor TFixInsightMessages.Create;
begin
  inherited Create(TFixInsightMessage.GetComparer);
end;

procedure TFixInsightMessages.Notify(const Item : TFixInsightMessage; Action : TCollectionNotification);
begin
  inherited Notify(Item, Action);

  if FSorted and (Action = cnAdded) then
    Sort;
end;

procedure TFixInsightMessages.SetSorted(Value : Boolean);
begin
  if FSorted <> Value then
  begin
    Sort;
    FSorted := True;
  end;
end;

end.
