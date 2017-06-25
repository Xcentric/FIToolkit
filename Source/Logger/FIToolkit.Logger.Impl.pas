unit FIToolkit.Logger.Impl;

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo, System.Generics.Collections,
  FIToolkit.Logger.Intf, FIToolkit.Logger.Types;

type

  TLogOutputList = class (TThreadList<ILogOutput>);

  TAbstractLogger = class abstract (TInterfacedObject, ILogger)
    strict private
      FAllowedItems : TLogItems;
      FOutputs : TLogOutputList;
      FSeverityThreshold : TLogMsgSeverity;
    private
      function  GetAllowedItems : TLogItems;
      function  GetEnabled : Boolean;
      function  GetSeverityThreshold : TLogMsgSeverity;
      procedure SetAllowedItems(Value : TLogItems);
      procedure SetSeverityThreshold(Value : TLogMsgSeverity);
    strict protected
      property Outputs : TLogOutputList read FOutputs;
    protected
      function GetDefaultAllowedItems : TLogItems; virtual;
      function GetDefaultSeverityThreshold : TLogMsgSeverity; virtual;
      function IsAllowedItem(Item : TLogItem) : Boolean; virtual;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      function  AddOutput(const LogOutput : ILogOutput) : ILogOutput;

      procedure EnterSection(const Msg : String = String.Empty); overload; virtual; abstract;
      procedure EnterSection(const Vals : array of const); overload; virtual; abstract;
      procedure EnterSectionFmt(const Msg : String; const Args : array of const); virtual; abstract;
      procedure EnterSectionVal(const Vals : array of TValue); virtual; abstract;

      procedure LeaveSection(const Msg : String = String.Empty); overload; virtual; abstract;
      procedure LeaveSection(const Vals : array of const); overload; virtual; abstract;
      procedure LeaveSectionFmt(const Msg : String; const Args : array of const); virtual; abstract;
      procedure LeaveSectionVal(const Vals : array of TValue); virtual; abstract;

      procedure EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue); overload; virtual; abstract;
      procedure EnterMethod(ARecord : PTypeInfo; MethodAddress : Pointer; const Params : array of TValue); overload; virtual; abstract;

      procedure LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue); overload; virtual; abstract;
      procedure LeaveMethod(ARecord : PTypeInfo; MethodAddress : Pointer; AResult : TValue); overload; virtual; abstract;

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

      property AllowedItems : TLogItems read GetAllowedItems write SetAllowedItems;
      property Enabled : Boolean read GetEnabled;
      property SeverityThreshold : TLogMsgSeverity read GetSeverityThreshold write SetSeverityThreshold;
  end;

  TBaseLogger = class abstract (TAbstractLogger, ILogger)
    strict private
      class var
        FRttiCtx : TRttiContext;
    strict protected
      procedure IterateOutputs(const Action : TProc<ILogOutput>; CheckEnabled : Boolean); overload;
      procedure IterateOutputs(const Action : TProc<ILogOutput>; ForItem : TLogItem); overload;
    protected
      procedure DoEnterSection(const Msg : String);
      procedure DoLeaveSection(const Msg : String);
      procedure DoEnterMethod(AType : TRttiType; AMethod : TRttiMethod; const Params : array of TValue);
      procedure DoLeaveMethod(AType : TRttiType; AMethod : TRttiMethod; AResult : TValue);
      procedure DoLog(Severity : TLogMsgSeverity; const Msg : String);

      function  FormatEnterMethod(AType : TRttiType; AMethod : TRttiMethod;
        const Params : array of TValue) : String; virtual; abstract;
      function  FormatLeaveMethod(AType : TRttiType; AMethod : TRttiMethod;
        AResult : TValue) : String; virtual; abstract;
      function  GetInstant : TLogTimestamp; virtual;
    public
      procedure EnterSection(const Msg : String = String.Empty); override;
      procedure EnterSectionFmt(const Msg : String; const Args : array of const); override;

      procedure LeaveSection(const Msg : String = String.Empty); override;
      procedure LeaveSectionFmt(const Msg : String; const Args : array of const); override;

      procedure EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue); override;
      procedure EnterMethod(ARecord : PTypeInfo; MethodAddress : Pointer; const Params : array of TValue); override;

      procedure LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue); override;
      procedure LeaveMethod(ARecord : PTypeInfo; MethodAddress : Pointer; AResult : TValue); override;

      procedure Log(Severity : TLogMsgSeverity; const Msg : String); override;
      procedure LogFmt(Severity : TLogMsgSeverity; const Msg : String; const Args : array of const); override;
  end;

  TLogger = class (TBaseLogger, ILogger)
    private
      function FormatMethod(AType : TRttiType; AMethod : TRttiMethod) : String;
    protected
      function FormatEnterMethod(AType : TRttiType; AMethod : TRttiMethod; const Params : array of TValue) : String; override;
      function FormatLeaveMethod(AType : TRttiType; AMethod : TRttiMethod; AResult : TValue) : String; override;
    public
      procedure EnterSection(const Vals : array of const); override;
      procedure EnterSectionVal(const Vals : array of TValue); override;

      procedure LeaveSection(const Vals : array of const); override;
      procedure LeaveSectionVal(const Vals : array of TValue); override;

      procedure Log(Severity : TLogMsgSeverity; const Vals : array of const); override;
      procedure LogVal(Severity : TLogMsgSeverity; const Vals : array of TValue); override;
  end;

  TLoggerList = class (TThreadList<ILogger>);

  TMetaLogger = class (TInterfacedObject, IMetaLogger)
    strict private
      FLoggers : TLoggerList;
    private
      function GetEnabled : Boolean;
    strict protected
      procedure IterateLoggers(const Action : TProc<ILogger>);
      procedure UnsafeCopyOpenArray<T>(const Source : array of T; var Dest : TArray<T>);

      property Loggers : TLoggerList read FLoggers;
    public
      constructor Create; virtual;
      destructor Destroy; override;

      function  AddLogger(const Logger : ILogger) : ILogger;

      procedure EnterSection(const Msg : String = String.Empty); overload;
      procedure EnterSection(const Vals : array of const); overload;
      procedure EnterSectionFmt(const Msg : String; const Args : array of const);
      procedure EnterSectionVal(const Vals : array of TValue);

      procedure LeaveSection(const Msg : String = String.Empty); overload;
      procedure LeaveSection(const Vals : array of const); overload;
      procedure LeaveSectionFmt(const Msg : String; const Args : array of const);
      procedure LeaveSectionVal(const Vals : array of TValue);

      procedure EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue); overload;
      procedure EnterMethod(ARecord : PTypeInfo; MethodAddress : Pointer; const Params : array of TValue); overload;

      procedure LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue); overload;
      procedure LeaveMethod(ARecord : PTypeInfo; MethodAddress : Pointer; AResult : TValue); overload;

      procedure Log(Severity : TLogMsgSeverity; const Msg : String); overload;
      procedure Log(Severity : TLogMsgSeverity; const Vals : array of const); overload;
      procedure LogFmt(Severity : TLogMsgSeverity; const Msg : String; const Args : array of const);
      procedure LogVal(Severity : TLogMsgSeverity; const Vals : array of TValue);

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
  end;

  TAbstractLogOutput = class abstract (TInterfacedObject, ILogOutput)
    strict private
      FSectionLevel : Integer;
      FSeverityThreshold : TLogMsgSeverity;
    private
      function  GetSeverityThreshold : TLogMsgSeverity;
      procedure SetSeverityThreshold(Value : TLogMsgSeverity);
    strict protected
      procedure DoBeginSection(Instant : TLogTimestamp; const Msg : String); virtual; abstract;
      procedure DoEndSection(Instant : TLogTimestamp; const Msg : String); virtual; abstract;
      procedure DoWriteMessage(Instant : TLogTimestamp; Severity : TLogMsgSeverity; const Msg : String); virtual; abstract;
    protected
      function GetDefaultSeverityThreshold : TLogMsgSeverity; virtual;

      property SectionLevel : Integer read FSectionLevel;
    public
      constructor Create; virtual;

      procedure BeginSection(Instant : TLogTimestamp; const Msg : String);
      procedure EndSection(Instant : TLogTimestamp; const Msg : String);
      procedure WriteMessage(Instant : TLogTimestamp; Severity : TLogMsgSeverity; const Msg : String);

      property SeverityThreshold : TLogMsgSeverity read GetSeverityThreshold write SetSeverityThreshold;
  end;

  TPlainTextOutput = class abstract (TAbstractLogOutput, ILogOutput)
    strict private
      FStringBuilder : TStringBuilder;
    strict protected
      procedure DoBeginSection(Instant : TLogTimestamp; const Msg : String); override;
      procedure DoEndSection(Instant : TLogTimestamp; const Msg : String); override;
      procedure DoWriteMessage(Instant : TLogTimestamp; Severity : TLogMsgSeverity; const Msg : String); override;

      function  AcquireBuilder(Capacity : Integer = 0) : TStringBuilder;
      procedure ReleaseBuilder;
      procedure WriteLine(const S : String); virtual; abstract;
    protected
      function FormatLogMessage(PreambleLength : Word; Severity : TLogMsgSeverity; const Msg : String) : String; virtual;
      function FormatLogSectionBeginning(PreambleLength : Word; const Msg : String) : String; virtual;
      function FormatLogSectionEnding(PreambleLength : Word; const Msg : String) : String; virtual;

      function FormatCurrentThread : String; virtual;
      function FormatPreamble(Instant : TLogTimestamp) : String; virtual;
      function FormatSeverity(Severity : TLogMsgSeverity) : String; virtual;
      function FormatTimestamp(Timestamp : TLogTimestamp) : String; virtual;
      function GetPreambleCompensatorFiller : Char; virtual;
      function GetSectionBeginningPrefix : String; virtual;
      function GetSectionEndingPrefix : String; virtual;
      function GetSectionIndentStr : String; virtual;
      function GetSeverityDescriptions : TLogMsgTypeDescriptions; virtual;
      function IndentText(const Text : String) : String; overload;
      function IndentText(const Text, PaddingStr : String; LeftPadding : Word; ExceptFirstLine : Boolean) : String; overload;
    public
      constructor Create; override;
      destructor Destroy; override;
  end;

implementation

uses
  System.Classes, System.Types, System.Math, System.StrUtils, System.Character,
  FIToolkit.Commons.Utils,
  FIToolkit.Logger.Utils, FIToolkit.Logger.Consts;

{ TAbstractLogger }

function TAbstractLogger.AddOutput(const LogOutput : ILogOutput) : ILogOutput;
begin
  FOutputs.Add(LogOutput);
  Result := LogOutput;
end;

constructor TAbstractLogger.Create;
begin
  inherited Create;

  FOutputs := TLogOutputList.Create;
  FOutputs.Duplicates := dupIgnore;

  FAllowedItems := GetDefaultAllowedItems;
  FSeverityThreshold := GetDefaultSeverityThreshold;
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

function TAbstractLogger.GetAllowedItems : TLogItems;
begin
  Result := FAllowedItems;
end;

function TAbstractLogger.GetDefaultAllowedItems : TLogItems;
begin
  Result := [liMessage, liSection];
end;

function TAbstractLogger.GetDefaultSeverityThreshold : TLogMsgSeverity;
begin
  Result := SEVERITY_MIN;
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

function TAbstractLogger.IsAllowedItem(Item : TLogItem) : Boolean;
begin
  Result := Item in FAllowedItems;
end;

procedure TAbstractLogger.SetAllowedItems(Value : TLogItems);
begin
  FAllowedItems := Value;
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

procedure TBaseLogger.DoEnterMethod(AType : TRttiType; AMethod : TRttiMethod; const Params : array of TValue);
var
  tsInstant : TLogTimestamp;
  sMsg : String;
begin
  tsInstant := GetInstant;
  sMsg := FormatEnterMethod(AType, AMethod, Params);

  IterateOutputs(
    procedure (Output : ILogOutput)
    begin
      Output.BeginSection(tsInstant, sMsg);
    end,
    liMethod
  );
end;

procedure TBaseLogger.DoEnterSection(const Msg : String);
var
  tsInstant : TLogTimestamp;
begin
  tsInstant := GetInstant;

  IterateOutputs(
    procedure (Output : ILogOutput)
    begin
      Output.BeginSection(tsInstant, Msg);
    end,
    liSection
  );
end;

procedure TBaseLogger.DoLeaveMethod(AType : TRttiType; AMethod : TRttiMethod; AResult : TValue);
var
  tsInstant : TLogTimestamp;
  sMsg : String;
begin
  tsInstant := GetInstant;
  sMsg := FormatLeaveMethod(AType, AMethod, AResult);

  IterateOutputs(
    procedure (Output : ILogOutput)
    begin
      Output.EndSection(tsInstant, sMsg);
    end,
    liMethod
  );
end;

procedure TBaseLogger.DoLeaveSection(const Msg : String);
var
  tsInstant : TLogTimestamp;
begin
  tsInstant := GetInstant;

  IterateOutputs(
    procedure (Output : ILogOutput)
    begin
      Output.EndSection(tsInstant, Msg);
    end,
    liSection
  );
end;

procedure TBaseLogger.DoLog(Severity : TLogMsgSeverity; const Msg : String);
var
  tsInstant : TLogTimestamp;
begin
  if Severity >= SeverityThreshold then
  begin
    tsInstant := GetInstant;

    IterateOutputs(
      procedure (Output : ILogOutput)
      begin
        if Severity >= Output.SeverityThreshold then
          Output.WriteMessage(tsInstant, Severity, Msg);
      end,
      liMessage
    );
  end;
end;

procedure TBaseLogger.EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue);
var
  LType : TRttiType;
begin
  LType := FRttiCtx.GetType(AClass);
  DoEnterMethod(LType, LType.GetMethod(MethodAddress), Params);
end;

procedure TBaseLogger.EnterMethod(ARecord : PTypeInfo; MethodAddress : Pointer; const Params : array of TValue);
var
  LType : TRttiType;
begin
  LType := FRttiCtx.GetType(ARecord);
  DoEnterMethod(LType, LType.GetMethod(MethodAddress), Params);
end;

procedure TBaseLogger.EnterSection(const Msg : String);
begin
  DoEnterSection(Msg);
end;

procedure TBaseLogger.EnterSectionFmt(const Msg : String; const Args : array of const);
begin
  EnterSection(Format(Msg, Args));
end;

function TBaseLogger.GetInstant : TLogTimestamp;
begin
  Result := Now;
end;

procedure TBaseLogger.IterateOutputs(const Action : TProc<ILogOutput>; CheckEnabled : Boolean);
var
  Output : ILogOutput;
begin
  if not CheckEnabled or Enabled then
    try
      for Output in Outputs.LockList do
        Action(Output);
    finally
      Outputs.UnlockList;
    end;
end;

procedure TBaseLogger.IterateOutputs(const Action : TProc<ILogOutput>; ForItem : TLogItem);
begin
  if IsAllowedItem(ForItem) then
    IterateOutputs(Action, True);
end;

procedure TBaseLogger.LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue);
var
  LType : TRttiType;
begin
  LType := FRttiCtx.GetType(AClass);
  DoLeaveMethod(LType, LType.GetMethod(MethodAddress), AResult);
end;

procedure TBaseLogger.LeaveMethod(ARecord : PTypeInfo; MethodAddress : Pointer; AResult : TValue);
var
  LType : TRttiType;
begin
  LType := FRttiCtx.GetType(ARecord);
  DoLeaveMethod(LType, LType.GetMethod(MethodAddress), AResult);
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

procedure TLogger.EnterSection(const Vals : array of const);
begin
  EnterSection(String.Join(String.Empty, ArrayOfConstToStringArray(Vals)));
end;

procedure TLogger.EnterSectionVal(const Vals : array of TValue);
begin
  EnterSection(String.Join(String.Empty, TValueArrayToStringArray(Vals)));
end;

function TLogger.FormatEnterMethod(AType : TRttiType; AMethod : TRttiMethod; const Params : array of TValue) : String;
var
  i : Integer;
  P : TRttiParameter;
begin
  Result := String.Empty;

  if Assigned(AType) and Assigned(AMethod) then
  begin
    Result := FormatMethod(AType, AMethod);

    if Length(Params) > 0 then
    begin
      i := 0;
      for P in AMethod.GetParameters do
      begin
        if i > High(Params) then
          Break
        else
          Result := Result + sLineBreak + P.Name + ' = ' + Params[i].ToString;

        Inc(i);
      end;
    end;
  end;
end;

function TLogger.FormatLeaveMethod(AType : TRttiType; AMethod : TRttiMethod; AResult : TValue) : String;
begin
  Result := String.Empty;

  if Assigned(AType) and Assigned(AMethod) then
  begin
    if Assigned(AMethod.ReturnType) then
      Result := 'Result = ' + AResult.ToString + sLineBreak;

    Result := Result + FormatMethod(AType, AMethod);
  end;
end;

function TLogger.FormatMethod(AType : TRttiType; AMethod : TRttiMethod) : String;
begin
  Result := AType.GetFullName + ' :: ' + AMethod.ToString;
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

{ TMetaLogger }

function TMetaLogger.AddLogger(const Logger : ILogger) : ILogger;
begin
  FLoggers.Add(Logger);
  Result := Logger;
end;

constructor TMetaLogger.Create;
begin
  inherited Create;

  FLoggers := TLoggerList.Create;
  FLoggers.Duplicates := dupIgnore;
end;

procedure TMetaLogger.Debug(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Debug(LVals);
    end
  );
end;

procedure TMetaLogger.Debug(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Debug(Msg);
    end
  );
end;

procedure TMetaLogger.DebugFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.DebugFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.DebugVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.DebugVal(LVals);
    end
  );
end;

destructor TMetaLogger.Destroy;
begin
  FreeAndNil(FLoggers);

  inherited Destroy;
end;

procedure TMetaLogger.EnterMethod(AClass : TClass; MethodAddress : Pointer; const Params : array of TValue);
var
  LParams : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Params, LParams);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.EnterMethod(AClass, MethodAddress, LParams);
    end
  );
end;

procedure TMetaLogger.EnterMethod(ARecord : PTypeInfo; MethodAddress : Pointer; const Params : array of TValue);
var
  LParams : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Params, LParams);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.EnterMethod(ARecord, MethodAddress, LParams);
    end
  );
end;

procedure TMetaLogger.EnterSection(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.EnterSection(Msg);
    end
  );
end;

procedure TMetaLogger.EnterSection(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.EnterSection(LVals);
    end
  );
end;

procedure TMetaLogger.EnterSectionFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.EnterSectionFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.EnterSectionVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.EnterSectionVal(LVals);
    end
  );
end;

procedure TMetaLogger.Error(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Error(Msg);
    end
  );
end;

procedure TMetaLogger.Error(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Error(LVals);
    end
  );
end;

procedure TMetaLogger.ErrorFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.ErrorFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.ErrorVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.ErrorVal(LVals);
    end
  );
end;

procedure TMetaLogger.Fatal(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Fatal(LVals);
    end
  );
end;

procedure TMetaLogger.Fatal(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Fatal(Msg);
    end
  );
end;

procedure TMetaLogger.FatalFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.FatalFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.FatalVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.FatalVal(LVals);
    end
  );
end;

function TMetaLogger.GetEnabled : Boolean;
var
  Logger : ILogger;
begin
  Result := False;

  try
    for Logger in Loggers.LockList do
      if Logger.Enabled then
        Exit(True);
  finally
    Loggers.UnlockList;
  end;
end;

procedure TMetaLogger.Info(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Info(Msg);
    end
  );
end;

procedure TMetaLogger.Info(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Info(LVals);
    end
  );
end;

procedure TMetaLogger.InfoFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.InfoFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.InfoVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.InfoVal(LVals);
    end
  );
end;

procedure TMetaLogger.IterateLoggers(const Action : TProc<ILogger>);
var
  Logger : ILogger;
begin
  try
    for Logger in Loggers.LockList do
      Action(Logger);
  finally
    Loggers.UnlockList;
  end;
end;

procedure TMetaLogger.LeaveMethod(AClass : TClass; MethodAddress : Pointer; AResult : TValue);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LeaveMethod(AClass, MethodAddress, AResult);
    end
  );
end;

procedure TMetaLogger.LeaveMethod(ARecord : PTypeInfo; MethodAddress : Pointer; AResult : TValue);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LeaveMethod(ARecord, MethodAddress, AResult);
    end
  );
end;

procedure TMetaLogger.LeaveSection(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LeaveSection(LVals);
    end
  );
end;

procedure TMetaLogger.LeaveSection(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LeaveSection(Msg);
    end
  );
end;

procedure TMetaLogger.LeaveSectionFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LeaveSectionFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.LeaveSectionVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LeaveSectionVal(LVals);
    end
  );
end;

procedure TMetaLogger.Log(Severity : TLogMsgSeverity; const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Log(Severity, Msg);
    end
  );
end;

procedure TMetaLogger.Log(Severity : TLogMsgSeverity; const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Log(Severity, LVals);
    end
  );
end;

procedure TMetaLogger.LogFmt(Severity : TLogMsgSeverity; const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LogFmt(Severity, Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.LogVal(Severity : TLogMsgSeverity; const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.LogVal(Severity, LVals);
    end
  );
end;

procedure TMetaLogger.UnsafeCopyOpenArray<T>(const Source : array of T; var Dest : TArray<T>);
var
  i : Integer;
begin
  SetLength(Dest, Length(Source));

  for i := 0 to High(Source) do
    Dest[i] := Source[i];
end;

procedure TMetaLogger.Warning(const Vals : array of const);
var
  LVals : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Warning(LVals);
    end
  );
end;

procedure TMetaLogger.Warning(const Msg : String);
begin
  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.Warning(Msg);
    end
  );
end;

procedure TMetaLogger.WarningFmt(const Msg : String; const Args : array of const);
var
  LArgs : TArray<TVarRec>;
begin
  UnsafeCopyOpenArray<TVarRec>(Args, LArgs);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.WarningFmt(Msg, LArgs);
    end
  );
end;

procedure TMetaLogger.WarningVal(const Vals : array of TValue);
var
  LVals : TArray<TValue>;
begin
  UnsafeCopyOpenArray<TValue>(Vals, LVals);

  IterateLoggers(
    procedure (Logger : ILogger)
    begin
      Logger.WarningVal(LVals);
    end
  );
end;

{ TAbstractLogOutput }

procedure TAbstractLogOutput.BeginSection(Instant : TLogTimestamp; const Msg : String);
begin
  if FSectionLevel >= 0 then
  begin
    DoBeginSection(Instant, Msg);
    Inc(FSectionLevel);
  end;
end;

constructor TAbstractLogOutput.Create;
begin
  inherited Create;

  FSeverityThreshold := GetDefaultSeverityThreshold;
end;

procedure TAbstractLogOutput.EndSection(Instant : TLogTimestamp; const Msg : String);
begin
  if FSectionLevel > 0 then
  begin
    Dec(FSectionLevel);
    DoEndSection(Instant, Msg);
  end;
end;

function TAbstractLogOutput.GetDefaultSeverityThreshold : TLogMsgSeverity;
begin
  Result := SEVERITY_MIN;
end;

function TAbstractLogOutput.GetSeverityThreshold : TLogMsgSeverity;
begin
  Result := FSeverityThreshold;
end;

procedure TAbstractLogOutput.SetSeverityThreshold(Value : TLogMsgSeverity);
begin
  FSeverityThreshold := Value;
end;

procedure TAbstractLogOutput.WriteMessage(Instant : TLogTimestamp; Severity : TLogMsgSeverity; const Msg : String);
begin
  if (FSeverityThreshold <> SEVERITY_NONE) and (Severity >= FSeverityThreshold) then
    DoWriteMessage(Instant, Severity, Msg);
end;

{ TPlainTextOutput }

function TPlainTextOutput.AcquireBuilder(Capacity : Integer) : TStringBuilder;
begin
  TMonitor.Enter(FStringBuilder);

  FStringBuilder.Clear;
  if Capacity > 0 then
    FStringBuilder.Capacity := Capacity;

  Result := FStringBuilder;
end;

constructor TPlainTextOutput.Create;
begin
  inherited Create;

  FStringBuilder := TStringBuilder.Create;
end;

destructor TPlainTextOutput.Destroy;
begin
  FreeAndNil(FStringBuilder);

  inherited Destroy;
end;

procedure TPlainTextOutput.DoBeginSection(Instant : TLogTimestamp; const Msg : String);
var
  sPreamble : String;
begin
  sPreamble := FormatPreamble(Instant);
  WriteLine(sPreamble + FormatLogSectionBeginning(sPreamble.Length, Msg));
end;

procedure TPlainTextOutput.DoEndSection(Instant : TLogTimestamp; const Msg : String);
var
  sPreamble : String;
begin
  sPreamble := FormatPreamble(Instant);
  WriteLine(sPreamble + FormatLogSectionEnding(sPreamble.Length, Msg));
end;

procedure TPlainTextOutput.DoWriteMessage(Instant : TLogTimestamp; Severity : TLogMsgSeverity; const Msg : String);
var
  sPreamble : String;
begin
  sPreamble := FormatPreamble(Instant);
  WriteLine(sPreamble + FormatLogMessage(sPreamble.Length, Severity, Msg));
end;

function TPlainTextOutput.FormatCurrentThread : String;
begin
  if TThread.Current.ThreadID = MainThreadID then
    Result := RSPTOMainThreadName
  else
    Result := TThread.Current.ThreadID.ToString;

  Result := Result.PadRight(Max(RSPTOMainThreadName.Length, High(TThreadID).ToString.Length));
end;

function TPlainTextOutput.FormatLogMessage(PreambleLength : Word; Severity : TLogMsgSeverity; const Msg : String) : String;
var
  sSeverity : String;
  cFiller : Char;
begin
  sSeverity := FormatSeverity(Severity);
  Result := sSeverity + IndentText(Msg);

  cFiller := GetPreambleCompensatorFiller;
  if not cFiller.IsControl then
    Result := IndentText(Result, cFiller, PreambleLength + sSeverity.Length, True);
end;

function TPlainTextOutput.FormatLogSectionBeginning(PreambleLength : Word; const Msg : String) : String;
var
  sPrefix : String;
  cFiller : Char;
begin
  sPrefix := GetSectionBeginningPrefix;
  Result := sPrefix + IndentText(Msg);

  cFiller := GetPreambleCompensatorFiller;
  if not cFiller.IsControl then
    Result := IndentText(Result, cFiller, PreambleLength + sPrefix.Length, True);
end;

function TPlainTextOutput.FormatLogSectionEnding(PreambleLength : Word; const Msg : String) : String;
var
  sPrefix : String;
  cFiller : Char;
begin
  sPrefix := GetSectionEndingPrefix;
  Result := sPrefix + IndentText(Msg);

  cFiller := GetPreambleCompensatorFiller;
  if not cFiller.IsControl then
    Result := IndentText(Result, cFiller, PreambleLength + sPrefix.Length, True);
end;

function TPlainTextOutput.FormatPreamble(Instant : TLogTimestamp) : String;
begin
  Result := Format('[%s] {%s} ', [FormatTimestamp(Instant), FormatCurrentThread]);
end;

function TPlainTextOutput.FormatSeverity(Severity : TLogMsgSeverity) : String;
begin
  Result := GetSeverityDescriptions[InferLogMsgType(Severity)];
end;

function TPlainTextOutput.FormatTimestamp(Timestamp : TLogTimestamp) : String;
begin
  Result := DateTimeToStr(Timestamp);
end;

function TPlainTextOutput.GetPreambleCompensatorFiller : Char;
begin
  Result := CHR_PTO_PREAMBLE_COMPENSATOR_FILLER;
end;

function TPlainTextOutput.GetSectionBeginningPrefix : String;
begin
  Result := RSPTOSectionBeginningPrefix.PadRight(GetSeverityDescriptions.MaxItemLength);
end;

function TPlainTextOutput.GetSectionEndingPrefix : String;
begin
  Result := RSPTOSectionEndingPrefix.PadRight(GetSeverityDescriptions.MaxItemLength);
end;

function TPlainTextOutput.GetSectionIndentStr : String;
begin
  Result := RSPTOSectionIndentStr;
end;

function TPlainTextOutput.GetSeverityDescriptions : TLogMsgTypeDescriptions;
begin
  Result := TLogMsgTypeDescriptions.Create([
    TLogMsgTypeDescription.Create(lmDebug,   RSPTOMsgTypeDescDebug),
    TLogMsgTypeDescription.Create(lmInfo,    RSPTOMsgTypeDescInfo),
    TLogMsgTypeDescription.Create(lmWarning, RSPTOMsgTypeDescWarning),
    TLogMsgTypeDescription.Create(lmError,   RSPTOMsgTypeDescError),
    TLogMsgTypeDescription.Create(lmFatal,   RSPTOMsgTypeDescFatal)
  ]);
end;

function TPlainTextOutput.IndentText(const Text : String) : String;
begin
  Result := IndentText(Text, GetSectionIndentStr, SectionLevel, False);
end;

function TPlainTextOutput.IndentText(const Text, PaddingStr : String; LeftPadding : Word;
  ExceptFirstLine : Boolean) : String;
var
  arrText : TArray<String>;
  i : Integer;
begin
  arrText := Text.Split([sLineBreak]);

  with AcquireBuilder(Length(Text) + Length(PaddingStr) * LeftPadding * Max(Length(arrText), 1)) do
    try
      for i := 0 to High(arrText) do
      begin
        if (i = 0) and ExceptFirstLine then
          Append(arrText[i])
        else
          Append(DupeString(PaddingStr, LeftPadding)).Append(arrText[i]);

        if i < High(arrText) then
          AppendLine;
      end;

      Result := ToString;
    finally
      ReleaseBuilder;
    end;
end;

procedure TPlainTextOutput.ReleaseBuilder;
begin
  FStringBuilder.Clear;
  TMonitor.Exit(FStringBuilder);
end;

end.
