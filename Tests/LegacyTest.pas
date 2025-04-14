unit LegacyTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMyTestObject = class
  private
    procedure WriteMockEnvFile(const Content: string);
    procedure RemoveMockEnvFile;
    procedure WriteMockLocalEnvFile(const Content: string);
    procedure RemoveMockLocalEnvFile;
  public
    [Test]
    procedure GeneralAvailabilityTest;
    [Test]
    procedure CreateFromStreamTest;
    [Test]
    procedure GetFirstEnvVarInListTest;
    [Test]
    procedure CanOverrideValuesTest;
    [Test]
    procedure InterpolationTest;
    [Test]
    procedure PresenceTest;
    [Test]
    procedure CascadeTest;
    [Test]
    procedure CanImportEnvironmentVariables;

  end;

implementation
uses
  System.SysUtils, // FileExists
  System.Classes,  // TStreamWriter
  DotEnv4Delphi;   // Test subject

procedure TMyTestObject.CanImportEnvironmentVariables;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
begin
  LContentString :=
    'KEY=${PATH}'+sLineBreak+
    'KEY2=${NON_EXISTING_ENV_VAR}'+sLineBreak;

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    var PathVar := LEnv.Env('KEY');
    Assert.IsTrue(Length(LEnv.Env('KEY')) > 10);
    Assert.AreEqual('', LEnv.Env('KEY2'));
  finally
    LStream.Free;
  end;
end;

procedure TMyTestObject.CanOverrideValuesTest;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
begin
  LContentString :=
    'KEY=value'+sLineBreak+
    'KEY=value2'+sLineBreak+
    'KEY=value2'+sLineBreak;

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    Assert.AreEqual('value2', LEnv.Env('KEY'));
  finally
    LStream.Free;
  end;
end;

procedure TMyTestObject.CascadeTest;
var LEnv : IDotEnv4Delphi;
begin
  WriteMockEnvFile(
    'USERNAME=username'+sLineBreak+
    'PASSWORD=password'+sLineBreak
  );
  WriteMockLocalEnvFile(
    'DATABASE_URL="mysql://${USERNAME}:${PASSWORD}@127.0.0.1:3306/db_name?serverVersion=8.0.30"'+sLineBreak
  );
  try
    LEnv := DotEnv4DelphiFactory(['.env', '.env.local']);
    Assert.AreEqual('mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30', LEnv.Env('DATABASE_URL'));
  finally
    RemoveMockEnvFile;
    RemoveMockLocalEnvFile;
  end;
end;

procedure TMyTestObject.CreateFromStreamTest;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
begin
  LContentString :=
    'DATABASE_URL="mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30"'+sLineBreak+
    'MAILER_DSN=smtp://service@example.com:testpassword@hostingprovider.tld'+sLineBreak+
    'APP_ENV=dev'+sLineBreak;

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    Assert.AreEqual('mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30', LEnv.Env('DATABASE_URL'));
    Assert.AreEqual('smtp://service@example.com:testpassword@hostingprovider.tld', LEnv.Env('MAILER_DSN'));
    Assert.AreEqual('dev', LEnv.Env('APP_ENV'));
  finally
    LStream.Free;
  end;
end;

procedure TMyTestObject.GeneralAvailabilityTest;
var LEnv : IDotEnv4Delphi;
begin
  WriteMockEnvFile(
    'DATABASE_URL="mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30"'+sLineBreak+
    'MAILER_DSN=smtp://service@example.com:testpassword@hostingprovider.tld'+sLineBreak+
    'APP_ENV=dev'+sLineBreak
  );
  try
    LEnv := DotEnv4DelphiFactory('.env');
    Assert.AreEqual('mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30', LEnv.Env('DATABASE_URL'));
    Assert.AreEqual('smtp://service@example.com:testpassword@hostingprovider.tld', LEnv.Env('MAILER_DSN'));
    Assert.AreEqual('dev', LEnv.Env('APP_ENV'));
  finally
    RemoveMockEnvFile;
  end;
end;

procedure TMyTestObject.GetFirstEnvVarInListTest;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
begin
  LContentString :=
    'TEST3=value'+sLineBreak;

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    Assert.AreEqual('value', LEnv.GetFirstEnvVarInList(['TEST1', 'TEST2', 'TEST3', 'TEST4']));
  finally
    LStream.Free;
  end;
end;

procedure TMyTestObject.InterpolationTest;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
begin
  LContentString :=
    'HOST=127.0.0.1:3306 # The host name'+sLineBreak+
    'USERNAME=username # The user name'+sLineBreak+
    'PASSWORD=password'+sLineBreak+
    'DATABASE_URL="mysql://${USERNAME}:${PASSWORD}@${HOST}/db_name?serverVersion=8.0.30"'+sLineBreak;

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    Assert.AreEqual('mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30', LEnv.Env('DATABASE_URL'));
  finally
    LStream.Free;
  end;
end;

procedure TMyTestObject.PresenceTest;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
begin
  LContentString :=
    'I_AM_HERE'+sLineBreak+
    'I_AM_EMPTY=';

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    Assert.AreEqual('1', LEnv.Env('I_AM_HERE'));
    Assert.AreEqual('', LEnv.Env('I_AM_EMPTY'));
  finally
    LStream.Free;
  end;
end;

procedure TMyTestObject.WriteMockEnvFile(const Content: string);
var LFile: TStreamWriter;
begin
  LFile := TStreamWriter.Create('.env');
  try
    LFile.Write(Content);
  finally
    LFile.Free;
  end;
end;

procedure TMyTestObject.WriteMockLocalEnvFile(const Content: string);
var LFile: TStreamWriter;
begin
  LFile := TStreamWriter.Create('.env.local');
  try
    LFile.Write(Content);
  finally
    LFile.Free;
  end;
end;

procedure TMyTestObject.RemoveMockEnvFile;
begin
  if FileExists('.env') then
    DeleteFile('.env');
end;


procedure TMyTestObject.RemoveMockLocalEnvFile;
begin
  if FileExists('.env.local') then
    DeleteFile('.env.local');
end;

initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);

end.
