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
      function  GetCurrTestMethodAddr : Pointer;
      function  GetTestIniFileName : TFileName;
  end;

implementation

uses
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

function TTestCaseHelper.GetCurrTestMethodAddr: Pointer;
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
