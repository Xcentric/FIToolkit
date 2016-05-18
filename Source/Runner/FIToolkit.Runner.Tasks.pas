﻿unit FIToolkit.Runner.Tasks;

interface

uses
  System.SysUtils, System.Threading, System.Generics.Collections,
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

  TTaskRunnerList = class (TObjectList<TTaskRunner>);

  //TODO: implement {TTaskManager}
  TTaskManager = class sealed
    strict private
      FRunners : TTaskRunnerList;
    public
      constructor Create(const Executable : TFileName; Options : TFixInsightOptions;
        const Files : TArray<TFileName>; const TempDirectory : String);
      destructor Destroy; override;

      function RunAndReturn : IFuture<TArray<TFileName>>;
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

{ TTaskManager }

constructor TTaskManager.Create(const Executable : TFileName; Options : TFixInsightOptions;
  const Files : TArray<TFileName>; const TempDirectory : String);
var
  FIO : TFixInsightOptions;
  S : String;
begin
  inherited Create;

  FRunners := TTaskRunnerList.Create(True);

  FIO := TFixInsightOptions.Create;
  try
    FIO.Assign(Options, False);
    FIO.OutputFileName := TPath.IncludeTrailingPathDelimiter(TempDirectory) + TPath.GetFileName(FIO.OutputFileName);

    for S in Files do
    begin
      FIO.ProjectFileName := S;
      FRunners.Add(TTaskRunner.Create(Executable, FIO));
    end;
  finally
    FIO.Free;
  end;
end;

destructor TTaskManager.Destroy;
begin
  FreeAndNil(FRunners);

  inherited Destroy;
end;

function TTaskManager.RunAndReturn : IFuture<TArray<TFileName>>;
var
  R : TTaskRunner;
  arrTasks : TArray<ITask>;
begin
  for R in FRunners do
    arrTasks := arrTasks + [R.Execute];

  Result := TTask.Future<TArray<TFileName>>(
    function : TArray<TFileName>
    var
      TR : TTaskRunner;
    begin
      //TODO: no exception handling - IFuture is a bad idea
      TTask.WaitForAll(arrTasks);

      //TODO: multi-threaded access to thread-unsafe classes
      for TR in FRunners do
        Result := Result + [TR.OutputFileName];
    end
  );
end;

end.
