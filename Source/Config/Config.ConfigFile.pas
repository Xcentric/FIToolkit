unit Config.ConfigFile;

interface

uses
  System.IniFiles, System.Classes, System.SysUtils, System.IOUtils;

type

  TConfigFile = class
    strict private
      FConfig : TMemIniFile;
      FConfigFile : TFileStream;
    public
      constructor Create(const FileName : TFileName);
      destructor Destroy; override;

      procedure AfterConstruction; override;
      procedure Load;
      procedure Save;
  end;

implementation

type

  TMemIniFileHelper = class helper for TMemIniFile
    public
      procedure LoadFromStream(const Stream : TStream);
      procedure SaveToStream(const Stream : TStream);
  end;

{ TMemIniFileHelper }

procedure TMemIniFileHelper.LoadFromStream(const Stream : TStream);
  var
    L : TStringList;
begin
  L := TStringList.Create;
  try
    Stream.Position := 0;
    L.LoadFromStream(Stream);
    SetStrings(L);
  finally
    L.Free;
  end;
end;

procedure TMemIniFileHelper.SaveToStream(const Stream : TStream);
  var
    L : TStringList;
begin
  L := TStringList.Create;
  try
    GetStrings(L);
    Stream.Position := 0;
    Stream.Size := 0;
    L.SaveToStream(Stream);
  finally
    L.Free;
  end;
end;

{ TConfigFile }

procedure TConfigFile.AfterConstruction;
begin
  inherited AfterConstruction;

  Load;
end;

constructor TConfigFile.Create(const FileName : TFileName);
begin
  inherited Create;

  if TFile.Exists(FileName) then
    FConfigFile := TFile.OpenRead(FileName)
  else
    FConfigFile := TFile.Create(FileName);

  FConfig := TMemIniFile.Create(EmptyStr);
end;

destructor TConfigFile.Destroy;
begin
  FreeAndNil(FConfig);
  FreeAndNil(FConfigFile);

  inherited Destroy;
end;

procedure TConfigFile.Load;
begin
  FConfig.LoadFromStream(FConfigFile);
end;

procedure TConfigFile.Save;
begin
  FConfig.SaveToStream(FConfigFile);
end;

end.
