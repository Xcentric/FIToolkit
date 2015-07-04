unit FIToolkit.Main;

interface

uses
  System.SysUtils, System.Types;

  procedure RunApplication(const FullExePath : TFileName; const LaunchParams : TStringDynArray);

implementation

type

  TFIToolkit = class
    public
      constructor Create(const FullExePath : TFileName; const LaunchParams : TStringDynArray);
      destructor Destroy; override;

      procedure Run;
  end;

{ Utils }

procedure RunApplication(const FullExePath : TFileName; const LaunchParams : TStringDynArray);
  var
    FIToolkit : TFIToolkit;
begin
  FIToolkit := TFIToolkit.Create(FullExePath, LaunchParams);
  try
    FIToolkit.Run;
  finally
    FIToolkit.Free;
  end;
end;

{ TFIToolkit }

constructor TFIToolkit.Create(const FullExePath : TFileName; const LaunchParams : TStringDynArray);
begin
  inherited Create;

  //
end;

destructor TFIToolkit.Destroy;
begin
  //

  inherited Destroy;
end;

procedure TFIToolkit.Run;
begin
  //
end;

end.
