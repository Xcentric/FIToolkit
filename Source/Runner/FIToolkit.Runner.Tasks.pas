unit FIToolkit.Runner.Tasks;

interface

uses
  System.SysUtils, System.Threading,
  FIToolkit.Config.FixInsight;

type

  TTaskRunner = class sealed
    strict private
      FExecutable : TFileName;
      FOptions : TFixInsightOptions;
      [volatile] FOutputFileName : TFileName;
    private
      function GenerateOutputFileName : String;
    public
      constructor Create(const Executable : TFileName; Options : TFixInsightOptions);

      function Execute : ITask;

      property OutputFileName : TFileName read FOutputFileName;
  end;

implementation

uses
  System.IOUtils, System.Classes,
  FIToolkit.Commons.Utils,
  FIToolkit.Runner.Consts;

{ TTaskRunner }

constructor TTaskRunner.Create(const Executable : TFileName; Options : TFixInsightOptions);
begin
  inherited Create;

  FExecutable := Executable;
  FOptions := TFixInsightOptions.Create;
  FOptions.Assign(Options, False);
end;

function TTaskRunner.Execute : ITask;
begin
  FOutputFileName := GenerateOutputFileName;

  //TODO: implement {Execute}
end;

function TTaskRunner.GenerateOutputFileName : String;
const
  CHR_DELIMITER = Char(CHR_TASK_OUTPUT_FILENAME_PARTS_DELIM);
var
  sDir, sFileName, sFileExt, sProject,
  sUniquePart : String;
begin
  sDir      := TPath.GetDirectoryName(FOptions.OutputFileName, True);
  sFileName := TPath.GetFileNameWithoutExtension(FOptions.OutputFileName);
  sFileExt  := TPath.GetExtension(FOptions.OutputFileName);
  sProject  := TPath.GetFileNameWithoutExtension(FOptions.ProjectFileName);

  sUniquePart := TThread.CurrentThread.ThreadID.ToString + CHR_DELIMITER + TPath.GetGUIDFileName(False);
  Result := TPath.GetFullPath(sDir + sFileName + CHR_DELIMITER + sProject + CHR_DELIMITER + sUniquePart + sFileExt);
end;

end.
