unit ConnectionStringTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TConnectionStringTest = class
  public

    [Test]
    procedure ConnectionStringTestFull;
    [Test]
    procedure ConnectionStringTestOmitUsernameAndPassword;
    [Test]
    procedure ConnectionStringOmitPath;
    [Test]
    procedure ConnectionStringOmitProtocol;
    [Test]
    procedure TestBinding;
  end;

implementation
uses
  System.Classes, // TStringStream
  DotEnv4Delphi; // test subject

{ TMyTestObject }

procedure TConnectionStringTest.ConnectionStringTestFull;
var Intf :IConnectionString;
begin
  Intf := ConnectionStringFactory('mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30');
  Assert.AreEqual('mysql', Intf.GetProtocol);
  Assert.AreEqual('username', Intf.GetUsername);
  Assert.AreEqual('password', Intf.GetPassword);
  Assert.AreEqual('127.0.0.1:3306', Intf.GetHost);
  Assert.AreEqual('db_name', Intf.GetPath);
  Assert.AreEqual('serverVersion=8.0.30', Intf.GetParameters);
end;

procedure TConnectionStringTest.ConnectionStringTestOmitUsernameAndPassword;
var Intf :IConnectionString;
begin
  Intf := ConnectionStringFactory('mysql://127.0.0.1:3306/db_name?serverVersion=8.0.30');
  Assert.AreEqual('mysql', Intf.GetProtocol);
  Assert.AreEqual('', Intf.GetUsername);
  Assert.AreEqual('', Intf.GetPassword);
  Assert.AreEqual('127.0.0.1:3306', Intf.GetHost);
  Assert.AreEqual('db_name', Intf.GetPath);
  Assert.AreEqual('serverVersion=8.0.30', Intf.GetParameters);
end;

procedure TConnectionStringTest.TestBinding;
var LStream: TStringStream;
    LContentString: string;
    LEnv: IDotEnv4Delphi;
    Intf: IConnectionString;
begin
  LContentString :=
    'DATABASE_URL="mysql://username:password@127.0.0.1:3306/db_name?serverVersion=8.0.30"'+sLineBreak+
    'MAILER_DSN=smtp://service@example.com:testpassword@hostingprovider.tld'+sLineBreak+
    'APP_ENV=dev'+sLineBreak;

  LStream := TStringStream.Create;
  try
    LStream.WriteString(LContentString);
    LEnv := DotEnv4DelphiFactory(LStream);
    Intf := LEnv.GetConnectionStringByName('DATABASE_URL');
    Assert.AreEqual('mysql', Intf.GetProtocol);
    Assert.AreEqual('username', Intf.GetUsername);
    Assert.AreEqual('password', Intf.GetPassword);
    Assert.AreEqual('127.0.0.1:3306', Intf.GetHost);
    Assert.AreEqual('db_name', Intf.GetPath);
    Assert.AreEqual('serverVersion=8.0.30', Intf.GetParameters);
  finally
    LStream.Free;
  end;
end;


procedure TConnectionStringTest.ConnectionStringOmitPath;
var Intf :IConnectionString;
begin
  Intf := ConnectionStringFactory('mysql://127.0.0.1:3306/?serverVersion=8.0.30');
  Assert.AreEqual('mysql', Intf.GetProtocol);
  Assert.AreEqual('', Intf.GetUsername);
  Assert.AreEqual('', Intf.GetPassword);
  Assert.AreEqual('127.0.0.1:3306', Intf.GetHost);
  Assert.AreEqual('', Intf.GetPath);
  Assert.AreEqual('serverVersion=8.0.30', Intf.GetParameters);
end;

procedure TConnectionStringTest.ConnectionStringOmitProtocol;
var Intf :IConnectionString;
begin
  Assert.WillRaise(
    procedure
    begin
      Intf := ConnectionStringFactory('127.0.0.1:3306/?serverVersion=8.0.30');
    end
  );
end;

initialization
  TDUnitX.RegisterTestFixture(TConnectionStringTest);

end.
