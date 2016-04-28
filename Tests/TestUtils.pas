unit TestUtils;

interface

uses
  System.SysUtils,
  TestFramework;

type

  TTestCaseHelper = class helper for TTestCase
    public
      procedure CheckEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      procedure CheckEquals<T>(Expected, Actual : T; const Msg : String = String.Empty); overload;
      procedure CheckException(const AProc : TProc; AExceptionClass : ExceptClass;
        const Msg : String = String.Empty); overload;
      procedure CheckFalse(Condition : Boolean; const Msg : String; const Args : array of const); overload;
      procedure CheckInnerException(const AProc : TProc; AExceptionClass : ExceptClass;
        const Msg : String = String.Empty);
      procedure CheckNotEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      procedure CheckNotEquals<T>(Expected, Actual : T; const Msg : String = String.Empty); overload;
      procedure CheckTrue(Condition : Boolean; const Msg : String; const Args : array of const); overload;
      function  CloneFile(const FileName : TFileName) : TFileName;
      procedure DebugMsg(const Msg : String; const Args : array of const);
      function  GetCurrTestMethodAddr : Pointer;
      function  GetTestIniFileName : TFileName;
  end;

implementation

uses
  System.Generics.Defaults, System.Rtti, System.IOUtils, Winapi.Windows, Vcl.Dialogs,
  DUnitConsts;

{ TTestCaseHelper }

procedure TTestCaseHelper.CheckEquals(Expected, Actual : TObject; const Msg : String);
begin
  FCheckCalled := True;
  if Pointer(Expected) <> Pointer(Actual) then
    FailNotEquals(Format('%p', [Pointer(Expected)]), Format('%p', [Pointer(Actual)]), Msg, ReturnAddress);
end;

procedure TTestCaseHelper.CheckEquals<T>(Expected, Actual : T; const Msg : String);
var
  Comparer : IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;

  FCheckCalled := True;
  if not Comparer.Equals(Expected, Actual) then
    FailNotEquals(
      Format('%s at %p', [TValue.From<T>(Expected).ToString, Pointer(@Expected)]),
      Format('%s at %p', [TValue.From<T>(Actual).ToString, Pointer(@Actual)]),
      Msg, ReturnAddress);
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

procedure TTestCaseHelper.CheckFalse(Condition : Boolean; const Msg : String; const Args : array of const);
begin
  FCheckCalled := True;
  if Condition then
    FailNotEquals(BoolToStr(False), BoolToStr(True), Format(Msg, Args), ReturnAddress);
end;

procedure TTestCaseHelper.CheckInnerException(const AProc : TProc; AExceptionClass : ExceptClass; const Msg : String);
var
  bFound : Boolean;
  E : Exception;
begin
  FCheckCalled := True;
  try
    AProc;
  except
    on Raised: Exception do
    begin
      if not Assigned(AExceptionClass) then
        raise
      else
      begin
        bFound := False;
        E := Raised;

        while Assigned(E.InnerException) do
          if not E.InnerException.InheritsFrom(AExceptionClass) then
            E := E.InnerException
          else
          begin
            bFound := True;
            Break;
          end;

        if bFound then
          AExceptionClass := nil
        else
          FailNotEquals(AExceptionClass.ClassName,
            Format('%s:%s%s', [Raised.ClassName, sLineBreak, Raised.ToString]), Msg, ReturnAddress);
      end;
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

procedure TTestCaseHelper.CheckNotEquals<T>(Expected, Actual : T; const Msg : String);
var
  Comparer : IEqualityComparer<T>;
begin
  Comparer := TEqualityComparer<T>.Default;

  FCheckCalled := True;
  if Comparer.Equals(Expected, Actual) then
    FailEquals(
      Format('%s at %p', [TValue.From<T>(Expected).ToString, Pointer(@Expected)]),
      Format('%s at %p', [TValue.From<T>(Actual).ToString, Pointer(@Actual)]),
      Msg, ReturnAddress);
end;

procedure TTestCaseHelper.CheckTrue(Condition : Boolean; const Msg : String; const Args : array of const);
begin
  FCheckCalled := True;
  if not Condition then
    FailNotEquals(BoolToStr(True), BoolToStr(False), Format(Msg, Args), ReturnAddress);
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

procedure TTestCaseHelper.DebugMsg(const Msg : String; const Args : array of const);
begin
  ShowMessageFmt(Msg, Args);
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
  Result := TestDataDir + TPath.GetFileNameWithoutExtension(ParamStr(0)) + '.ini';
end;

end.
