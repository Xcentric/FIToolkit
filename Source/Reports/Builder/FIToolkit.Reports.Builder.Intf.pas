unit FIToolkit.Reports.Builder.Intf;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Types;

type

  { Generic interfaces }

  IReportTemplate<T> = interface
    function GetFooter : T;
    function GetHeader : T;
    function GetMessage : T;
    function GetMessageList : T;
    function GetSummary : T;
    function GetSummaryItem : T;
  end;

  IReportBuilder<T; I : IReportTemplate<T>> = interface
    procedure AddFooter(FinishTime : TDateTime);
    procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
    procedure AddSummary(const Items : array of TSummaryItem);
    procedure AppendRecord(const Item : TReportRecord);
    procedure Initialize(const Template : I; Output : TStream);
  end;

  { Type-specific interfaces }

  ITextReportTemplate = interface (IReportTemplate<String>)
    ['{75F7631B-EF2E-4A04-93A0-DEB2A32455ED}']
  end;

  ITextReportBuilder = interface (IReportBuilder<String, ITextReportTemplate>)
    ['{E5F3555E-A1B2-4087-AB75-F6A9DAB22627}']
  end;

implementation

end.
