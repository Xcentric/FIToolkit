unit FIToolkit.Config.TypedDefaults;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Config.Defaults, FIToolkit.Config.Types;

type

  TDefaultFileNameValue = class (TDefaultValueAttribute<TFileName>);
  TDefaultOutputFormatValue = class (TDefaultValueAttribute<TFixInsightOutputFormat>);
  TDefaultStringArrayValue = class (TDefaultValueAttribute<TStringDynArray>);
  TDefaultStringValue = class (TDefaultValueAttribute<String>);

implementation

end.
