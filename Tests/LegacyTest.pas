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

  end;

implementation
uses
  System.SysUtils, // FileExists
  System.Classes,  // TStreamWriter
  DotEnv4Delphi;   // Test subject

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

procedure TMyTestObject.RemoveMockEnvFile;
begin
  if FileExists('.env') then
    DeleteFile('.env');
end;


initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);

end.
