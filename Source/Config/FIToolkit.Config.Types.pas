unit FIToolkit.Config.Types;

interface

type

  TConfigPropCategory = (cpcAny, cpcSerializable, cpcNonSerializable);

  TDefaultValueKind = (dvkUndefined, dvkData, dvkCalculated);

  TFixInsightOutputFormat = (fiofPlainText, fiofXML);

  TConfigAttribute = class abstract (TCustomAttribute)
    strict private
      FArrayDelimiter : String;
      FSerializable : Boolean;
    public
      constructor Create(Serialize : Boolean = True); overload;
      constructor Create(const AnArrayDelimiter : String); overload;

      property ArrayDelimiter : String read FArrayDelimiter;
      property Serializable : Boolean read FSerializable;
  end;

  FIToolkitParam = class (TConfigAttribute);  //FI:C104
  FixInsightParam = class (TConfigAttribute); //FI:C104

implementation

uses
  System.SysUtils;

{ TConfigAttribute }

constructor TConfigAttribute.Create(Serialize : Boolean);
begin
  inherited Create;

  FSerializable := Serialize;
end;

constructor TConfigAttribute.Create(const AnArrayDelimiter : String);
begin
  Create(True);

  Assert(not AnArrayDelimiter.IsEmpty, Format('Empty array delimiter passed to %s attribute.', [ClassName]));
  FArrayDelimiter := AnArrayDelimiter;
end;

end.
