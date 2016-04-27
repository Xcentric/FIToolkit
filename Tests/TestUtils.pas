﻿unit TestUtils;

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
      procedure CheckFalse(Condition : Boolean; const Msg : String; const Args : array of const); overload;
      procedure CheckNotEquals(Expected, Actual : TObject; const Msg : String = String.Empty); overload;
      procedure CheckTrue(Condition : Boolean; const Msg : String; const Args : array of const); overload;
      function  CloneFile(const FileName : TFileName) : TFileName;
      procedure DebugMsg(const Msg : String; const Args : array of const);
      function  GetCurrTestMethodAddr : Pointer;
      function  GetTestIniFileName : TFileName;
  end;

implementation

uses
  System.IOUtils, Winapi.Windows, Vcl.Dialogs,
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

procedure TTestCaseHelper.CheckFalse(Condition : Boolean; const Msg : String; const Args : array of const);
begin
  FCheckCalled := True;
  if Condition then
    FailNotEquals(BoolToStr(False), BoolToStr(True), Format(Msg, Args), ReturnAddress);
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

function TTestCaseHelper.GetTestIniFileName : TFileName;
begin
  Result := TestDataDir + TPath.GetFileNameWithoutExtension(ParamStr(0)) + '.ini';
end;

end.
