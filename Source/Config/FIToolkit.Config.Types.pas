unit FIToolkit.Config.Types;

interface

type

  TDefaultValueType = (dvtUndefined, dvtStored, dvtEvaluable);

  TFixInsightOutputFormat = (fiofPlainText, fiofXML);

  TConfigAttribute = class abstract (TCustomAttribute);

  FIToolkitParam = class (TConfigAttribute);
  FixInsightParam = class (TConfigAttribute);

implementation

end.
