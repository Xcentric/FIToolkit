unit TestUtils;

interface

uses
  System.SysUtils,
  TestFramework;

type

  TInterfaceTestCase<I : IInterface> = class abstract (TGenericTestCase)
    strict private
      FSUT : I;
    strict protected
      function SUTAsClass<T : class> : T;

      property SUT : I read FSUT;
    protected
      procedure DoSetUp; virtual;
      procedure DoTearDown; virtual;
      function  MakeSUT : I; virtual; abstract;
    public
      procedure SetUp; override; final;
      procedure TearDown; override; final;
  end;

  TTestCaseHelper = class helper for TTestCase
    private
      const
        STR_PROJECT_GROUP_DIR_RELATIVE_PATH = '..\..\..\';
    public
      procedure CheckAggregateException(const AProc : TProc; AExceptionClass : ExceptClass;
        const Msg : String = String.Empty);
      procedure CheckEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      procedure CheckException(const AProc : TProc; AExceptionClass : ExceptClass;
        const Msg : String = String.Empty); overload;
      procedure CheckFalse(Condition : Boolean; const Msg : String; const Args : array of const); overload;
      procedure CheckInnerException(const AProc : TProc; AExceptionClass : ExceptClass;
        const Msg : String = String.Empty);
      procedure CheckNotEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      procedure CheckTrue(Condition : Boolean; const Msg : String; const Args : array of const); overload;
      function  CloneFile(const FileName : TFileName) : TFileName;
      procedure DebugMsg(const Msg : String; const Args : array of const);
      function  GetCurrTestMethodAddr : Pointer;
      function  GetProjectGroupDir : String;
      function  GetTestIniFileName : TFileName;
  end;

  { Utils }

  function LinesCount(const S : String) : Integer;

implementation

uses
  System.IOUtils, System.Threading,
  Winapi.Windows, Vcl.Dialogs,
  DUnitConsts;

{ Utils }

function LinesCount(const S : String) : Integer;
begin
  if S.IsEmpty then
    Result := 0
  else
    Result := Length(S.Split([sLineBreak], None)) + 1;
end;

{ TInterfaceTestCase<I> }

procedure TInterfaceTestCase<I>.DoSetUp;
begin
  {NOP}
end;

procedure TInterfaceTestCase<I>.DoTearDown;
begin
  {NOP}
end;

procedure TInterfaceTestCase<I>.SetUp;
begin
  FSUT := MakeSUT;
  DoSetUp;
end;

function TInterfaceTestCase<I>.SUTAsClass<T> : T;
begin
  Result := nil;

  if FSUT <> nil then
    if TObject(IInterface(FSUT)).InheritsFrom(T) then
      Result := TObject(IInterface(FSUT)) as T;
end;

procedure TInterfaceTestCase<I>.TearDown;
begin
  DoTearDown;
  FSUT := nil;
end;

{ TTestCaseHelper }

procedure TTestCaseHelper.CheckAggregateException(const AProc : TProc; AExceptionClass : ExceptClass; const Msg : String);
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

        if Raised.InheritsFrom(EAggregateException) then
          for E in EAggregateException(Raised) do
            if E.InheritsFrom(AExceptionClass) then
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

function TTestCaseHelper.GetProjectGroupDir : String;
var
  iLevels, i : Integer;
  arrTokens : TArray<String>;
begin
  iLevels := 0;
  arrTokens := String(STR_PROJECT_GROUP_DIR_RELATIVE_PATH).Split([TPath.DirectorySeparatorChar], ExcludeEmpty);

  for i := High(arrTokens) downto 0 do
    if arrTokens[i] = '..' then
      Inc(iLevels)
    else
      Break;

  arrTokens := TestDataDir.Split([TPath.DirectorySeparatorChar], ExcludeEmpty);
  Result := String
    .Join(TPath.DirectorySeparatorChar, arrTokens, 0, Length(arrTokens) - iLevels) + TPath.DirectorySeparatorChar;
end;

function TTestCaseHelper.GetTestIniFileName : TFileName;
begin
  Result := TestDataDir + TPath.GetFileNameWithoutExtension(ParamStr(0)) + '.ini';
end;

end.
