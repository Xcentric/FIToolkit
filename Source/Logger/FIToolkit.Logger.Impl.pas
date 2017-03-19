unit FIToolkit.Logger.Impl;

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections,
  FIToolkit.Logger.Intf, FIToolkit.Logger.Types;

type

  TAbstractLogger = class abstract (TInterfacedObject, ILogger)
    strict private
      FOutputs : TList<ILogOutput>;
      FSeverityThreshold : TLogMsgSeverity;
    private
      function  GetSeverityThreshold : TLogMsgSeverity;
      procedure SetSeverityThreshold(Value : TLogMsgSeverity);
    strict protected
      property Outputs : TList<ILogOutput> read FOutputs;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      procedure AddOutput(const LogOutput : ILogOutput);

      procedure EnterSection(const Msg : String = String.Empty); overload; virtual; abstract;
      procedure EnterSection(const Vals : array of const); overload; virtual; abstract;
      procedure EnterSectionFmt(const Msg : String; const Args : array of const); virtual; abstract;
      procedure EnterSectionVal(const Vals : array of TValue); virtual; abstract;

      procedure LeaveSection(const Msg : String = String.Empty); overload; virtual; abstract;
      procedure LeaveSection(const Vals : array of const); overload; virtual; abstract;
      procedure LeaveSectionFmt(const Msg : String; const Args : array of const); virtual; abstract;
      procedure LeaveSectionVal(const Vals : array of TValue); virtual; abstract;

      procedure EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue); virtual; abstract;
      procedure LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue); virtual; abstract;

      procedure Log(Severity : TLogMsgSeverity; const Msg : String); overload; virtual; abstract;
      procedure Log(Severity : TLogMsgSeverity; const Vals : array of const); overload; virtual; abstract;
      procedure LogFmt(Severity : TLogMsgSeverity; const Msg : String; const Args : array of const); virtual; abstract;
      procedure LogVal(Severity : TLogMsgSeverity; const Vals : array of TValue); virtual; abstract;

      procedure Debug(const Msg : String); overload;
      procedure Debug(const Vals : array of const); overload;
      procedure DebugFmt(const Msg : String; const Args : array of const);
      procedure DebugVal(const Vals : array of TValue);

      procedure Info(const Msg : String); overload;
      procedure Info(const Vals : array of const); overload;
      procedure InfoFmt(const Msg : String; const Args : array of const);
      procedure InfoVal(const Vals : array of TValue);

      procedure Warning(const Msg : String); overload;
      procedure Warning(const Vals : array of const); overload;
      procedure WarningFmt(const Msg : String; const Args : array of const);
      procedure WarningVal(const Vals : array of TValue);

      procedure Error(const Msg : String); overload;
      procedure Error(const Vals : array of const); overload;
      procedure ErrorFmt(const Msg : String; const Args : array of const);
      procedure ErrorVal(const Vals : array of TValue);

      procedure Fatal(const Msg : String); overload;
      procedure Fatal(const Vals : array of const); overload;
      procedure FatalFmt(const Msg : String; const Args : array of const);
      procedure FatalVal(const Vals : array of TValue);

      property SeverityThreshold : TLogMsgSeverity read GetSeverityThreshold write SetSeverityThreshold;
  end;

  TAbstractLogOutput = class abstract (TInterfacedObject)
    //
  end;

implementation

uses
  FIToolkit.Logger.Consts;

{ TAbstractLogger }

procedure TAbstractLogger.AddOutput(const LogOutput : ILogOutput);
begin
  if not FOutputs.Contains(LogOutput) then
    FOutputs.Add(LogOutput);
end;

constructor TAbstractLogger.Create;
begin
  inherited Create;

  FOutputs := TList<ILogOutput>.Create;
end;

procedure TAbstractLogger.Debug(const Vals : array of const);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmDebug], Vals);
end;

procedure TAbstractLogger.Debug(const Msg : String);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmDebug], Msg);
end;

procedure TAbstractLogger.DebugFmt(const Msg : String; const Args : array of const);
begin
  LogFmt(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmDebug], Msg, Args);
end;

procedure TAbstractLogger.DebugVal(const Vals : array of TValue);
begin
  LogVal(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmDebug], Vals);
end;

destructor TAbstractLogger.Destroy;
begin
  FreeAndNil(FOutputs);

  inherited Destroy;
end;

procedure TAbstractLogger.Error(const Vals : array of const);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmError], Vals);
end;

procedure TAbstractLogger.Error(const Msg : String);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmError], Msg);
end;

procedure TAbstractLogger.ErrorFmt(const Msg : String; const Args : array of const);
begin
  LogFmt(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmError], Msg, Args);
end;

procedure TAbstractLogger.ErrorVal(const Vals : array of TValue);
begin
  LogVal(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmError], Vals);
end;

procedure TAbstractLogger.Fatal(const Msg : String);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmFatal], Msg);
end;

procedure TAbstractLogger.Fatal(const Vals : array of const);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmFatal], Vals);
end;

procedure TAbstractLogger.FatalFmt(const Msg : String; const Args : array of const);
begin
  LogFmt(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmFatal], Msg, Args);
end;

procedure TAbstractLogger.FatalVal(const Vals : array of TValue);
begin
  LogVal(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmFatal], Vals);
end;

function TAbstractLogger.GetSeverityThreshold : TLogMsgSeverity;
begin
  Result := FSeverityThreshold;
end;

procedure TAbstractLogger.Info(const Vals : array of const);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmInfo], Vals);
end;

procedure TAbstractLogger.Info(const Msg : String);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmInfo], Msg);
end;

procedure TAbstractLogger.InfoFmt(const Msg : String; const Args : array of const);
begin
  LogFmt(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmInfo], Msg, Args);
end;

procedure TAbstractLogger.InfoVal(const Vals : array of TValue);
begin
  LogVal(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmInfo], Vals);
end;

procedure TAbstractLogger.SetSeverityThreshold(Value : TLogMsgSeverity);
begin
  FSeverityThreshold := Value;
end;

procedure TAbstractLogger.Warning(const Vals : array of const);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmWarning], Vals);
end;

procedure TAbstractLogger.Warning(const Msg : String);
begin
  Log(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmWarning], Msg);
end;

procedure TAbstractLogger.WarningFmt(const Msg : String; const Args : array of const);
begin
  LogFmt(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmWarning], Msg, Args);
end;

procedure TAbstractLogger.WarningVal(const Vals : array of TValue);
begin
  LogVal(ARR_MSGTYPE_TO_MSGSEVERITY_MAPPING[lmWarning], Vals);
end;

end.
