unit ConenctionStringTest;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TMyTestObject = class
  public

    [Test]
    procedure ConnectionStringTestFull;
    [Test]
    procedure ConnectionStringTestOmitUsernameAndPassword;
    [Test]
    procedure ConnectionStringOmitPath;
    [Test]
    procedure ConnectionStringOmitProtocol;
  end;

implementation
uses DotEnv4Delphi; // test subject

{ TMyTestObject }

procedure TMyTestObject.ConnectionStringTestFull;
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

procedure TMyTestObject.ConnectionStringTestOmitUsernameAndPassword;
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

procedure TMyTestObject.ConnectionStringOmitPath;
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

procedure TMyTestObject.ConnectionStringOmitProtocol;
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
  TDUnitX.RegisterTestFixture(TMyTestObject);

end.
