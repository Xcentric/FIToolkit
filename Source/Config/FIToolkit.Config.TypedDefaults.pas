unit FIToolkit.Config.TypedDefaults;

interface

uses
  System.SysUtils, System.Types,
  FIToolkit.Config.Defaults, FIToolkit.Config.Types;

type

  TDefaultBooleanValue = class (TDefaultValueAttribute<Boolean>);
  TDefaultFileNameValue = class (TDefaultValueAttribute<TFileName>);
  TDefaultIntegerValue = class (TDefaultValueAttribute<Integer>);
  TDefaultOutputFormatValue = class (TDefaultValueAttribute<TFixInsightOutputFormat>);
  TDefaultStringArrayValue = class (TDefaultValueAttribute<TStringDynArray>);
  TDefaultStringValue = class (TDefaultValueAttribute<String>);

implementation

end.
