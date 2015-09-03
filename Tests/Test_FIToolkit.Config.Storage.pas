unit Test_FIToolkit.Config.Storage;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, System.SysUtils, System.IniFiles,
  FIToolkit.Config.Storage;

type
  // Test methods for class TConfigFile

  TestTConfigFile = class(TTestCase)
  strict private
    FConfigFile : TConfigFile;
  private
    const
      STR_INI_SECTION = 'TestSection';
      STR_INI_PARAM = 'TestParam';
      INT_INI_VALUE = 777;
  private
    function  CreateConfigFile(CurrentTest : Pointer) : TConfigFile;
    function  GetTestIniFileName : TFileName;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAfterConstruction;
    procedure TestCreate;
    procedure TestLoad;
    procedure TestSave;
  end;

implementation

uses
  TestUtils;

function TestTConfigFile.CreateConfigFile(CurrentTest : Pointer) : TConfigFile;
  var
    sFileName : TFileName;
begin
  Result := nil;
  sFileName := GetTestIniFileName;

  if CurrentTest = @TestTConfigFile.TestSave then
    Result := TConfigFile.Create(sFileName, True)
  else
  if (CurrentTest = @TestTConfigFile.TestAfterConstruction) or (CurrentTest = @TestTConfigFile.TestLoad) then
  begin
    with TIniFile.Create(sFileName) do
      try
        WriteInteger(STR_INI_SECTION, STR_INI_PARAM, INT_INI_VALUE);
      finally
        Free;
      end;

    Result := TConfigFile.Create(sFileName, False);
  end;
end;

function TestTConfigFile.GetTestIniFileName : TFileName;
begin
  Result := TestDataDir + ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini');
end;

procedure TestTConfigFile.SetUp;
begin
  FConfigFile := CreateConfigFile(GetCurrTestMethodAddr);
end;

procedure TestTConfigFile.TearDown;
begin
  FreeAndNil(FConfigFile);
  DeleteFile(GetTestIniFileName);
end;

procedure TestTConfigFile.TestAfterConstruction;
begin
  FConfigFile.AfterConstruction;

  CheckTrue(FConfigFile.Config.SectionExists(STR_INI_SECTION), 'TestAfterConstruction::SectionExists');
end;

procedure TestTConfigFile.TestCreate;
  var
    sFileName : TFileName;
    Cfg : TConfigFile;
    bWasException : Boolean;
begin
  sFileName := GetTestIniFileName;

  { File not exists / Can't create }

  Cfg := nil;
  try
    DeleteFile(sFileName);
    bWasException := False;
    try
      Cfg := TConfigFile.Create(sFileName, False);
    except
      bWasException := True;
    end;
    CheckFalse(bWasException, 'Create(NotExists,NotWritable)::bWasException');
    CheckFalse(FileExists(sFileName), 'Create(NotExists,NotWritable)::FileExists');
  finally
    if Assigned(Cfg) then
      Cfg.Free;
  end;

  { File not exists / Can create }

  Cfg := nil;
  try
    DeleteFile(sFileName);
    bWasException := False;
    try
      Cfg := TConfigFile.Create(sFileName, True);
    except
      bWasException := True;
    end;
    CheckFalse(bWasException, 'Create(NotExists,Writable)::bWasException');
    CheckTrue(FileExists(sFileName), 'Create(NotExists,Writable)::FileExists');
  finally
    if Assigned(Cfg) then
      Cfg.Free;
  end;

  { File exists / Not writable }

  Cfg := nil;
  try
    Assert(FileExists(sFileName));
    bWasException := False;
    try
      Cfg := TConfigFile.Create(sFileName, False);
    except
      bWasException := True;
    end;
    CheckFalse(bWasException, 'Create(Exists,NotWritable)::bWasException');
  finally
    if Assigned(Cfg) then
      Cfg.Free;
  end;

  { File exists / Writable }

  Cfg := nil;
  try
    Assert(FileExists(sFileName));
    bWasException := False;
    try
      Cfg := TConfigFile.Create(sFileName, True);
    except
      bWasException := True;
    end;
    CheckFalse(bWasException, 'Create(Exists,Writable)::bWasException');
  finally
    if Assigned(Cfg) then
      Cfg.Free;
  end;
end;

procedure TestTConfigFile.TestLoad;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FConfigFile.Load;

  CheckTrue(ReturnValue, 'TestLoad::ReturnValue');
  CheckEquals(FConfigFile.Config.ReadInteger(STR_INI_SECTION, STR_INI_PARAM, 0), INT_INI_VALUE, 'TestLoad::ReadInteger');
end;

procedure TestTConfigFile.TestSave;
var
  ReturnValue: Boolean;
begin
  FConfigFile.Config.WriteInteger(STR_INI_SECTION, STR_INI_PARAM, INT_INI_VALUE);
  ReturnValue := FConfigFile.Save;

  CheckTrue(ReturnValue, 'TestSave::ReturnValue');
  with TIniFile.Create(GetTestIniFileName) do
    try
      CheckEquals(ReadInteger(STR_INI_SECTION, STR_INI_PARAM, 0), INT_INI_VALUE, 'TestSave::WriteInteger');
    finally
      Free;
    end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTConfigFile.Suite);
end.
