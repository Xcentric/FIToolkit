﻿unit FIToolkit.Reports.Parser.Messages;

interface

uses
  System.Generics.Collections,
  FIToolkit.Reports.Parser.Types;

type

  TFixInsightMessages = class (TList<TFixInsightMessage>)
    private
      type
        TCollectionNotifications = set of TCollectionNotification;
    strict private
      FSorted : Boolean;
      FUpdateActions : TCollectionNotifications;
      FUpdateCount : Integer;
    private
      procedure SetSorted(Value : Boolean);
    strict protected
      procedure Changed;
    protected
      procedure Notify(const Item : TFixInsightMessage; Action : TCollectionNotification); override; final;
    public
      constructor Create;

      procedure AddRange(const Values : array of TFixInsightMessage);
      procedure BeginUpdate;
      function  Contains(Value : TFixInsightMessage) : Boolean;
      procedure EndUpdate;

      property Sorted : Boolean read FSorted write SetSorted;
      property UpdateCount : Integer read FUpdateCount;
  end;

implementation

{ TFixInsightMessages }

procedure TFixInsightMessages.AddRange(const Values : array of TFixInsightMessage);
begin
  BeginUpdate;
  try
    inherited AddRange(Values);
  finally
    EndUpdate;
  end;
end;

procedure TFixInsightMessages.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TFixInsightMessages.Changed;
begin
  if UpdateCount = 0 then
    try
      if FSorted and (cnAdded in FUpdateActions) then
        Sort;
    finally
      FUpdateActions := [];
    end;
end;

function TFixInsightMessages.Contains(Value : TFixInsightMessage) : Boolean;
var
  i : Integer;
begin
  if FSorted then
    Result := BinarySearch(Value, i)
  else
    Result := inherited Contains(Value);
end;

constructor TFixInsightMessages.Create;
begin
  inherited Create(TFixInsightMessage.GetComparer);
end;

procedure TFixInsightMessages.EndUpdate;
begin
  Dec(FUpdateCount);
  Changed;
end;

procedure TFixInsightMessages.Notify(const Item : TFixInsightMessage; Action : TCollectionNotification);
begin
  inherited Notify(Item, Action);

  Include(FUpdateActions, Action);
  Changed;
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
