unit FIToolkit.Reports.Builder.Types;

interface

type

  TReportRecord = record
    Column,
    Line : Integer;
    FileName,
    MessageText,
    MessageTypeKeyword,
    MessageTypeName : String;
  end;

  TSummaryItem = record
    MessageCount : Integer;
    MessageTypeKeyword,
    MessageTypeName : String;
  end;

implementation

end.
