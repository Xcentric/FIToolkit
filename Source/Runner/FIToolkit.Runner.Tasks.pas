unit FIToolkit.Runner.Tasks;

interface

uses
  System.SysUtils, System.Threading,
  FIToolkit.Config.Data, FIToolkit.Config.FixInsight;

type

  TTaskRunner = class sealed
    strict private
      FExecutable : TFileName;
      FOptions : TFixInsightOptions;
      FOutputFileName : TFileName;
    private
      function  GenerateOutputFileName : String;
    public
      constructor Create(const Executable : TFileName; const Options : TFixInsightOptions);

      procedure Execute;

      property  OutputFileName : TFileName read FOutputFileName;
  end;

implementation

uses
  System.IOUtils, System.Classes,
  FIToolkit.Commons.Utils;

{ TTaskRunner }

constructor TTaskRunner.Create(const Executable : TFileName; const Options : TFixInsightOptions);
begin
  inherited Create;

  FExecutable := Executable;
  FOptions    := Options;
end;

procedure TTaskRunner.Execute;
begin
  FOutputFileName := GenerateOutputFileName;

  //TODO: implement {Execute}
end;

function TTaskRunner.GenerateOutputFileName : String;
const
  CHR_DELIMITER = '_';
var
  sDir, sFileName, sFileExt,
  sUniquePart : String;
begin
  sDir      := TPath.GetDirectoryName(FOptions.OutputFileName, True);
  sFileName := TPath.GetFileNameWithoutExtension(FOptions.OutputFileName);
  sFileExt  := TPath.GetExtension(FOptions.OutputFileName);

  sUniquePart := TThread.CurrentThread.ThreadID.ToString + CHR_DELIMITER + TPath.GetGUIDFileName(False);
  Result := TPath.GetFullPath(sDir + sFileName + CHR_DELIMITER + sUniquePart + sFileExt);
end;

end.
