unit FIToolkit.Reports.Builder.Intf;

interface

uses
  System.Classes,
  FIToolkit.Reports.Builder.Types;

type

  IReportTemplate = interface
    ['{75F7631B-EF2E-4A04-93A0-DEB2A32455ED}']
    function GetFooterElement : TTemplateElement;
    function GetHeaderElement : TTemplateElement;

    property FooterElement : TTemplateElement read GetFooterElement;
    property HeaderElement : TTemplateElement read GetHeaderElement;
  end;

  IReportBuilder = interface
    ['{E5F3555E-A1B2-4087-AB75-F6A9DAB22627}']
    procedure AddFooter(FinishTime : TDateTime);
    procedure AddHeader(const ProjectTitle : String; StartTime : TDateTime);
    procedure AddSummary(const Items : array of TSummaryItem);
    procedure AppendRecord(const Item : TReportRecord);
    procedure Initialize(const Template : IReportTemplate; Output : TStream);
  end;

implementation

end.
