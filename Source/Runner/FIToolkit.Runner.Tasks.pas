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
      FOutputFileName : TFileName;
    private
      function GenerateOutputFileName : String;
    public
      constructor Create(const Executable : TFileName; Options : TFixInsightOptions);
      destructor Destroy; override;

      function Execute : ITask;

      property OutputFileName : TFileName read FOutputFileName;
  end;

implementation

uses
  System.IOUtils, System.Classes, Winapi.Windows,
  FIToolkit.Commons.Utils, FIToolkit.CommandLine.Types, FIToolkit.Runner.Exceptions, FIToolkit.Runner.Consts;

{ TTaskRunner }

constructor TTaskRunner.Create(const Executable : TFileName; Options : TFixInsightOptions);
begin
  inherited Create;

  FExecutable := Executable;
  FOptions := TFixInsightOptions.Create;
  FOptions.Assign(Options, False);
end;

destructor TTaskRunner.Destroy;
begin
  FreeAndNil(FOptions);

  inherited Destroy;
end;

function TTaskRunner.Execute : ITask;
begin
  Result := TTask.Run(
    procedure
    var
      sCmdLine : String;
      SI : TStartupInfo;
      PI : TProcessInformation;
    begin
      FOptions.Validate := True;
      FOptions.OutputFileName := GenerateOutputFileName;
      FOutputFileName := FOptions.OutputFileName;

      sCmdLine := Format('%s %s', [TPath.GetQuotedPath(FExecutable, TCLIOptionString.CHR_QUOTE), FOptions.ToString]);
      FillChar(SI, SizeOf(TStartupInfo), 0);
      SI.cb := SizeOf(TStartupInfo);
      SI.wShowWindow := SW_HIDE;

      if CreateProcess(PChar(FExecutable), PChar(sCmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, SI, PI) then
        try
          while WaitForSingleObject(PI.hProcess, INFINITE) <> WAIT_OBJECT_0 do
            TThread.SpinWait(INT_SPIN_WAIT_ITERATIONS);
        finally
          CloseHandle(PI.hProcess);
          CloseHandle(PI.hThread);
        end
      else
        try
          RaiseLastOSError;
        except
          Exception.RaiseOuterException(ECreateProcessError.Create);
        end;
    end
  );
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
