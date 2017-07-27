unit FIToolkit.Config.Storage;

interface

uses
  System.Classes, System.SysUtils, System.IniFiles;

type

  TConfigFile = class sealed
    strict private
      FConfig : TMemIniFile;
      FConfigFile : TFileStream;
    private
      function GetFileName : TFileName;
      function GetHasFile : Boolean;
    public
      constructor Create(const FileName : TFileName; Writable : Boolean);
      destructor Destroy; override;

      procedure AfterConstruction; override;

      function  Load : Boolean;
      function  Save : Boolean;

      property Config : TMemIniFile read FConfig;
      property FileName : TFileName read GetFileName;
      property HasFile : Boolean read GetHasFile;
  end;

implementation

uses
  System.IOUtils,
  FIToolkit.Commons.Utils;

type

  TMemIniFileHelper = class helper for TMemIniFile
    public
      procedure LoadFromStream(Stream : TStream);
      procedure SaveToStream(Stream : TStream);
  end;

{ TMemIniFileHelper }

procedure TMemIniFileHelper.LoadFromStream(Stream : TStream);
var
  L : TStringList;
begin
  L := TStringList.Create;
  try
    Stream.Position := 0;
    L.LoadFromStream(Stream, Encoding);
    SetStrings(L);
  finally
    L.Free;
  end;
end;

procedure TMemIniFileHelper.SaveToStream(Stream : TStream);
var
  L : TStringList;
begin
  L := TStringList.Create;
  try
    GetStrings(L);
    Stream.Position := 0;
    Stream.Size := 0;
    L.SaveToStream(Stream, Encoding);
  finally
    L.Free;
  end;
end;

{ TConfigFile }

procedure TConfigFile.AfterConstruction;
begin
  inherited AfterConstruction;

  if HasFile then
    Load;
end;

constructor TConfigFile.Create(const FileName : TFileName; Writable : Boolean);
begin
  inherited Create;

  if TFile.Exists(FileName) or Writable then
    FConfigFile := TFile.Open(FileName,
      Iff.Get<TFileMode>(Writable, TFileMode.fmOpenOrCreate, TFileMode.fmOpen),
      Iff.Get<TFileAccess>(Writable, TFileAccess.faReadWrite, TFileAccess.faRead),
      TFileShare.fsRead);

  FConfig := TMemIniFile.Create(String.Empty, TEncoding.UTF8);
end;

destructor TConfigFile.Destroy;
begin
  FreeAndNil(FConfig);
  FreeAndNil(FConfigFile);

  inherited Destroy;
end;

function TConfigFile.GetFileName : TFileName;
begin
  if Assigned(FConfigFile) then
    Result := TPath.GetFullPath(FConfigFile.FileName)
  else
    Result := String.Empty;
end;

function TConfigFile.GetHasFile : Boolean;
begin
  Result := Assigned(FConfigFile);
end;

function TConfigFile.Load : Boolean;
begin
  Result := HasFile;

  if Result then
    FConfig.LoadFromStream(FConfigFile);
end;

function TConfigFile.Save : Boolean;
begin
  Result := HasFile;

  if Result then
    FConfig.SaveToStream(FConfigFile);
end;

end.
