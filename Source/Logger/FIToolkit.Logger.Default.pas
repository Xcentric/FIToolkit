unit FIToolkit.Logger.Default;

interface

uses
  System.SysUtils,
  FIToolkit.Logger.Intf;

  procedure InitConsoleLog;
  procedure InitFileLog(const FileName : TFileName);
  function  Log : IAbstractLogger;

type

  {$RTTI EXPLICIT METHODS([vcPrivate, vcProtected, vcPublic, vcPublished])}
  TLoggable = class abstract (TObject);

implementation

uses
  System.Classes, System.IOUtils,
  FIToolkit.Logger.Impl, FIToolkit.Logger.Types, FIToolkit.Logger.Consts,
  FIToolkit.Commons.Utils;

var
  LoggingFacility : IMetaLogger;

type

  TConsoleOutput = class (TPlainTextOutput)
    strict protected
      procedure WriteLine(const S : String); override;
  end;

  TTextStreamOutput = class (TPlainTextOutput)
    strict private
      FOwnsWriter : Boolean;
      FWriter : TStreamWriter;
    strict protected
      procedure WriteLine(const S : String); override;
    public
      constructor Create(Writer : TStreamWriter; OwnsWriter : Boolean); reintroduce;
      destructor Destroy; override;
  end;

{ Export }

procedure InitConsoleLog;
begin
  with LoggingFacility.AddLogger(TLogger.Create) do
  begin
    AllowedItems := [liMessage, liSection];
    SeverityThreshold := SEVERITY_INFO;
    AddOutput(TConsoleOutput.Create);
  end;
end;

procedure InitFileLog(const FileName : TFileName);
begin
  with LoggingFacility.AddLogger(TLogger.Create) do
  begin
    AllowedItems := [liMessage, liSection, liMethod];
    SeverityThreshold := SEVERITY_DEBUG;
    AddOutput(TTextStreamOutput.Create(TFile.CreateText(FileName), True));
  end;
end;

function Log : IAbstractLogger;
begin
  Result := LoggingFacility;
end;

{ TConsoleOutput }

procedure TConsoleOutput.WriteLine(const S : String);
begin
  PrintLn(S);
end;

{ TTextStreamOutput }

constructor TTextStreamOutput.Create(Writer : TStreamWriter; OwnsWriter : Boolean);
begin
  inherited Create;

  FOwnsWriter := OwnsWriter;
  FWriter := Writer;
end;

destructor TTextStreamOutput.Destroy;
begin
  if FOwnsWriter then
    FreeAndNil(FWriter);

  inherited Destroy;
end;

procedure TTextStreamOutput.WriteLine(const S : String);
begin
  FWriter.WriteLine(S);
end;

initialization
  LoggingFacility := TMetaLogger.Create;

finalization
  LoggingFacility := nil;

end.
