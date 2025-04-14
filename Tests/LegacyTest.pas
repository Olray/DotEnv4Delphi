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
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure GeneralAvailabilityTest;
  end;

implementation
uses
  System.SysUtils, // FileExists
  System.Classes,  // TStreamWriter
  DotEnv4Delphi;   // Test subject

procedure TMyTestObject.GeneralAvailabilityTest;
var LEnv : TDotEnv4Delphi;
begin
  WriteMockEnvFile(
    'DATABASE_URL="mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30"'+sLineBreak+
    'MAILER_DSN=smtp://service@example.com:testpassword@hostingprovider.tld'+sLineBreak+
    'APP_ENV=dev'+sLineBreak
  );
  try
    LEnv := TDotEnv4Delphi.Create;
    try
      Assert.AreEqual('mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30', LEnv.Env('DATABASE_URL'));
      Assert.AreEqual('smtp://service@example.com:testpassword@hostingprovider.tld', LEnv.Env('MAILER_DSN'));
      Assert.AreEqual('dev', LEnv.Env('APP_ENV'));
    finally
      LEnv.Free;
    end;
  finally
    RemoveMockEnvFile;
  end;
end;

procedure TMyTestObject.Setup;
begin
end;

procedure TMyTestObject.TearDown;
begin
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
