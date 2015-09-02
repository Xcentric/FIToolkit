unit FIToolkit.Config.Types;

interface

type

  TDefaultValueKind = (dvkUndefined, dvkData, dvkCalculated);

  TFixInsightOutputFormat = (fiofPlainText, fiofXML);

  TConfigAttribute = class abstract (TCustomAttribute);

  FIToolkitParam = class (TConfigAttribute);
  FixInsightParam = class (TConfigAttribute);

implementation

end.
