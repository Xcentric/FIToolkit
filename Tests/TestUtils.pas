unit TestUtils;

interface

uses
  System.SysUtils,
  TestFramework;

type

  TTestCaseHelper = class helper for TTestCase
    public
      procedure CheckEquals(Expected, Actual : TObject; Msg : String = String.Empty); overload;
      function  GetCurrTestMethodAddr : Pointer;
      function  GetTestIniFileName : TFileName;
  end;

implementation

{ TTestCaseHelper }

procedure TTestCaseHelper.CheckEquals(Expected, Actual : TObject; Msg : String);
begin
  FCheckCalled := True;
  if Pointer(Expected) <> Pointer(Actual) then
    FailNotEquals(Format('%p', [Pointer(Expected)]), Format('%p', [Pointer(Actual)]), Msg, ReturnAddress);
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
