﻿unit FIToolkit.Config.Types;

interface

type

  TDefaultValueKind = (dvkUndefined, dvkData, dvkCalculated);

  TFixInsightOutputFormat = (fiofPlainText, fiofXML);

  TConfigAttribute = class abstract (TCustomAttribute)
    strict private
      FSerializable : Boolean;
    public
      constructor Create(Serialize : Boolean = True);

      property Serializable : Boolean read FSerializable;
  end;

  FIToolkitParam = class (TConfigAttribute);
  FixInsightParam = class (TConfigAttribute);

implementation

{ TConfigAttribute }

constructor TConfigAttribute.Create(Serialize : Boolean);
begin
  inherited Create;

  FSerializable := Serialize;
end;

end.
