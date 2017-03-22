unit FIToolkit.Logger.Impl;

interface

uses
  System.SysUtils, System.Rtti, System.Generics.Collections,
  FIToolkit.Logger.Intf, FIToolkit.Logger.Types;

type

  TLogOutputList = class (TThreadList<ILogOutput>);

  TAbstractLogger = class abstract (TInterfacedObject, ILogger)
    strict private
      FOutputs : TLogOutputList;
      FSeverityThreshold : TLogMsgSeverity;
    private
      function  GetEnabled : Boolean;
      function  GetSeverityThreshold : TLogMsgSeverity;
      procedure SetSeverityThreshold(Value : TLogMsgSeverity);
    strict protected
      property Outputs : TLogOutputList read FOutputs;
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

      property Enabled : Boolean read GetEnabled;
      property SeverityThreshold : TLogMsgSeverity read GetSeverityThreshold write SetSeverityThreshold;
  end;

  TBaseLogger = class abstract (TAbstractLogger, ILogger)
    strict protected
      procedure IterateOutputs(const Action : TProc<ILogOutput>);
    protected
      procedure DoEnterSection(const Msg : String);
      procedure DoLeaveSection(const Msg : String);
      procedure DoLog(Severity : TLogMsgSeverity; const Msg : String);
    public
      procedure EnterSection(const Msg : String = String.Empty); override;
      procedure EnterSectionFmt(const Msg : String; const Args : array of const); override;

      procedure LeaveSection(const Msg : String = String.Empty); override;
      procedure LeaveSectionFmt(const Msg : String; const Args : array of const); override;

      procedure Log(Severity : TLogMsgSeverity; const Msg : String); override;
      procedure LogFmt(Severity : TLogMsgSeverity; const Msg : String; const Args : array of const); override;
  end;

  TLogger = class (TBaseLogger, ILogger)
    public
      procedure EnterSection(const Vals : array of const); override;
      procedure EnterSectionVal(const Vals : array of TValue); override;

      procedure LeaveSection(const Vals : array of const); override;
      procedure LeaveSectionVal(const Vals : array of TValue); override;

      procedure EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue); override;
      procedure LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue); override;

      procedure Log(Severity : TLogMsgSeverity; const Vals : array of const); override;
      procedure LogVal(Severity : TLogMsgSeverity; const Vals : array of TValue); override;
  end;

  TAbstractLogOutput = class abstract (TInterfacedObject)
    //
  end;

implementation

uses
  System.Types,
  FIToolkit.Commons.Utils,
  FIToolkit.Logger.Consts;

{ TAbstractLogger }

procedure TAbstractLogger.AddOutput(const LogOutput : ILogOutput);
begin
  FOutputs.Add(LogOutput);
end;

constructor TAbstractLogger.Create;
begin
  inherited Create;

  FOutputs := TLogOutputList.Create;
  FOutputs.Duplicates := dupIgnore;
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

function TAbstractLogger.GetEnabled : Boolean;
begin
  Result := FSeverityThreshold <> SEVERITY_NONE;
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

{ TBaseLogger }

procedure TBaseLogger.DoEnterSection(const Msg : String);
begin
  IterateOutputs(
    procedure (Output : ILogOutput)
    begin
      Output.BeginSection(Msg);
    end
  );
end;

procedure TBaseLogger.DoLeaveSection(const Msg : String);
begin
  // TODO: leave section only if it was entered
  IterateOutputs(
    procedure (Output : ILogOutput)
    begin
      Output.EndSection(Msg);
    end
  );
end;

procedure TBaseLogger.DoLog(Severity : TLogMsgSeverity; const Msg : String);
begin
  if Severity >= SeverityThreshold then
    IterateOutputs(
      procedure (Output : ILogOutput)
      begin
        if Severity >= Output.SeverityThreshold then
          Output.WriteMessage(Severity, Msg);
      end
    );
end;

procedure TBaseLogger.EnterSection(const Msg : String);
begin
  DoEnterSection(Msg);
end;

procedure TBaseLogger.EnterSectionFmt(const Msg : String; const Args : array of const);
begin
  EnterSection(Format(Msg, Args));
end;

procedure TBaseLogger.IterateOutputs(const Action : TProc<ILogOutput>);
var
  Output : ILogOutput;
begin
  if Enabled then
    try
      for Output in Outputs.LockList do
        Action(Output);
    finally
      Outputs.UnlockList;
    end;
end;

procedure TBaseLogger.LeaveSection(const Msg : String);
begin
  DoLeaveSection(Msg);
end;

procedure TBaseLogger.LeaveSectionFmt(const Msg : String; const Args : array of const);
begin
  LeaveSection(Format(Msg, Args));
end;

procedure TBaseLogger.Log(Severity : TLogMsgSeverity; const Msg : String);
begin
  DoLog(Severity, Msg);
end;

procedure TBaseLogger.LogFmt(Severity : TLogMsgSeverity; const Msg : String; const Args : array of const);
begin
  Log(Severity, Format(Msg, Args));
end;

{ TLogger }

procedure TLogger.EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue);
var
  Ctx : TRttiContext;
  LClass : TRttiType;
  Method : TRttiMethod;
  Param : TRttiParameter;
  i : Integer;
  sMsg : String;
begin
  Ctx := TRttiContext.Create;
  try
    LClass := Ctx.GetType(AClass);

    for Method in LClass.GetDeclaredMethods do
      if Method.CodeAddress = MethodAddress then
      begin
        EnterSection(LClass.QualifiedName + ' :: ' + Method.ToString);

        i := 0;
        for Param in Method.GetParameters do
        begin
          if not sMsg.IsEmpty then
            sMsg := sMsg + sLineBreak;

          sMsg := sMsg + Param.Name + ' = ' + Params[i].ToString;
          Inc(i);
        end;
        Debug(sMsg);
        // TODO: implement {TLogger.EnterMethod}

        Break;
      end;
  finally
    Ctx.Free;
  end;
end;

procedure TLogger.EnterSection(const Vals : array of const);
begin
  EnterSection(String.Join(String.Empty, ArrayOfConstToStringArray(Vals)));
end;

procedure TLogger.EnterSectionVal(const Vals : array of TValue);
begin
  EnterSection(String.Join(String.Empty, TValueArrayToStringArray(Vals)));
end;

procedure TLogger.LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue);
begin
  // TODO: implement {TLogger.LeaveMethod}
end;

procedure TLogger.LeaveSection(const Vals : array of const);
begin
  LeaveSection(String.Join(String.Empty, ArrayOfConstToStringArray(Vals)));
end;

procedure TLogger.LeaveSectionVal(const Vals : array of TValue);
begin
  LeaveSection(String.Join(String.Empty, TValueArrayToStringArray(Vals)));
end;

procedure TLogger.Log(Severity : TLogMsgSeverity; const Vals : array of const);
begin
  Log(Severity, String.Join(String.Empty, ArrayOfConstToStringArray(Vals)));
end;

procedure TLogger.LogVal(Severity : TLogMsgSeverity; const Vals : array of TValue);
begin
  Log(Severity, String.Join(String.Empty, TValueArrayToStringArray(Vals)));
end;

end.
