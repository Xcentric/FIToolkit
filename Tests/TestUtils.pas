unit TestUtils;

interface

uses
  System.SysUtils,
  TestFramework;

type

  TTestCaseHelper = class helper for TTestCase
    public
      procedure CheckEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      procedure CheckException(const AProc : TProc; AExceptionClass : ExceptClass;
        const Msg : String = String.Empty); overload;
      procedure CheckNotEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      function  CloneFile(const FileName : TFileName) : TFileName;
      function  GetCurrTestMethodAddr : Pointer;
      function  GetTestIniFileName : TFileName;
  end;

implementation

uses
  System.IOUtils, Winapi.Windows,
  DUnitConsts;

{ TTestCaseHelper }

procedure TTestCaseHelper.CheckEquals(Expected, Actual : TObject; const Msg : String);
begin
  FCheckCalled := True;
  if Pointer(Expected) <> Pointer(Actual) then
    FailNotEquals(Format('%p', [Pointer(Expected)]), Format('%p', [Pointer(Actual)]), Msg, ReturnAddress);
end;

procedure TTestCaseHelper.CheckException(const AProc : TProc; AExceptionClass : ExceptClass; const Msg : String);
begin
  FCheckCalled := True;
  try
    AProc;
  except
    on E: Exception do
    begin
      if not Assigned(AExceptionClass) then
        raise
      else
      if not E.InheritsFrom(AExceptionClass) then
        FailNotEquals(AExceptionClass.ClassName, E.ClassName, Msg, ReturnAddress)
      else
        AExceptionClass := nil;
    end;
  end;

  if Assigned(AExceptionClass) then
    FailNotEquals(AExceptionClass.ClassName, sExceptionNothig, Msg, ReturnAddress);
end;

procedure TTestCaseHelper.CheckNotEquals(Expected, Actual : TObject; const Msg : String);
begin
  FCheckCalled := True;
  if Pointer(Expected) = Pointer(Actual) then
    FailEquals(Format('%p', [Pointer(Expected)]), Format('%p', [Pointer(Actual)]), Msg, ReturnAddress);
end;

function TTestCaseHelper.CloneFile(const FileName : TFileName) : TFileName;
const
  STR_CLONE_EXT = '.clone';
var
  sCloneFileName : TFileName;
begin
  Result := String.Empty;

  if TFile.Exists(FileName) then
  begin
    sCloneFileName := String(FileName).Substring(0, MAX_PATH - Length(STR_CLONE_EXT) - 1) + STR_CLONE_EXT;
    TFile.Copy(FileName, sCloneFileName, True);

    if TFile.Exists(sCloneFileName) then
      Result := sCloneFileName;
  end;
end;

function TTestCaseHelper.GetCurrTestMethodAddr : Pointer;
begin
  if Assigned(fMethod) then
    Result := TMethod(fMethod).Code
  else
    Result := nil;
end;

function TTestCaseHelper.GetTestIniFileName : TFileName;
begin
  Result := TestDataDir + ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini');
end;

end.
