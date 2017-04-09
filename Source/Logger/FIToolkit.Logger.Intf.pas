unit FIToolkit.Logger.Intf;

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo,
  FIToolkit.Logger.Types;

type

  ILogOutput = interface
    ['{D66F4536-61D8-481D-9055-3F063F23E0B5}']

    function  GetSeverityThreshold : TLogMsgSeverity;
    procedure SetSeverityThreshold(Value : TLogMsgSeverity);

    procedure BeginSection(const Msg : String);
    procedure EndSection(const Msg : String);
    procedure WriteMessage(Severity : TLogMsgSeverity; const Msg : String);

    property SeverityThreshold : TLogMsgSeverity read GetSeverityThreshold write SetSeverityThreshold;
  end;

  ILogger = interface
    ['{0E36214F-FFD4-4715-9631-0B6D7F12006A}']

    { Property accessors }

    function  GetAllowedItems : TLogItems;
    function  GetEnabled : Boolean;
    function  GetSeverityThreshold : TLogMsgSeverity;
    procedure SetAllowedItems(Value : TLogItems);
    procedure SetSeverityThreshold(Value : TLogMsgSeverity);

    { Logging: output }

    procedure AddOutput(const LogOutput : ILogOutput);

    { Logging: structure }

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

    { Logging: messages }

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

    { Properties }

    property AllowedItems : TLogItems read GetAllowedItems write SetAllowedItems;
    property Enabled : Boolean read GetEnabled;
    property SeverityThreshold : TLogMsgSeverity read GetSeverityThreshold write SetSeverityThreshold;
  end;

implementation

end.
