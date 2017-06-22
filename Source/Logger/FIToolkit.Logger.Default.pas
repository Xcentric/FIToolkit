unit FIToolkit.Logger.Default;

interface

uses
  FIToolkit.Logger.Intf;

  function Log : IAbstractLogger;

implementation

uses
  System.Classes, System.SysUtils,
  FIToolkit.Logger.Impl,
  FIToolkit.Commons.Utils;

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
    protected
      constructor Create(Writer : TStreamWriter; OwnsWriter : Boolean); overload;
      destructor Destroy; override;
  end;

{ Utils }

function Log : IAbstractLogger;
begin
  // TODO: implement {Log}
  Result := nil;
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

end.
