unit FIToolkit.Reports.Builder.Intf;

interface

type

  IReportBuilder = interface
    ['{E5F3555E-A1B2-4087-AB75-F6A9DAB22627}']
    procedure AddFooter();
    procedure AddHeader();
    procedure AddSummary();
    procedure AppendRecord();
  end;

implementation

end.
