unit FIToolkit.Reports.Builder.Intf;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Types;

type

  IReportBuilder = interface
    ['{E5F3555E-A1B2-4087-AB75-F6A9DAB22627}']
    procedure AddFooter(FinishTime : TDateTime);
    procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
    procedure AddSummary(const Items : array of TSummaryItem);
    procedure AppendRecord(const Item : TReportRecord);
    procedure Initialize(Output : TStream);
  end;

implementation

end.
