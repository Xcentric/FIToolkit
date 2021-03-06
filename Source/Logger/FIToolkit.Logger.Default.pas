﻿unit FIToolkit.Logger.Default;

interface

uses
  System.SysUtils,
  FIToolkit.Logger.Intf;

  procedure InitConsoleLog(DebugMode : Boolean);
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

  TConsoleOutput = class abstract (TPlainTextOutput)
    strict protected
      procedure WriteLine(const S : String); override;
  end;

  TDebugConsoleOutput = class (TConsoleOutput);

  TPrettyConsoleOutput = class (TConsoleOutput)
    protected
      function FormatPreamble(Instant : TLogTimestamp) : String; override;
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

procedure InitConsoleLog(DebugMode : Boolean);
begin
  with LoggingFacility.AddLogger(TLogger.Create) do
    if DebugMode then
    begin
      AllowedItems := [liMessage, liSection, liMethod];
      SeverityThreshold := SEVERITY_DEBUG;
      AddOutput(TDebugConsoleOutput.Create);
    end
    else
    begin
      AllowedItems := [liMessage, liSection];
      SeverityThreshold := SEVERITY_INFO;
      AddOutput(TPrettyConsoleOutput.Create);
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

{ TPrettyConsoleOutput }

function TPrettyConsoleOutput.FormatPreamble(Instant : TLogTimestamp) : String;
begin
  Result := String.Empty;
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
