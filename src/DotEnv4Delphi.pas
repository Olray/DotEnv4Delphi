unit DotEnv4Delphi;

{$IFDEF FPC}
  {$mode delphi}
{$ENDIF}

interface

uses
  {$IFDEF FPC}
    Generics.Collections;
  {$ELSE}
    System.Generics.Collections,
    System.Classes; // TStream
  {$ENDIF}

type
{$Region 'EnumEnvVars'}
  TEnvVar = (ALLUSERSPROFILE, APPDATA, CLIENTNAME, COMMONPROGRAMFILES, COMPUTERNAME, COMSPEC, HOMEDRIVE, HOMEPATH, LOGONSERVER,
             NUMBER_OF_PROCESSORS, OS, PATH, PATHEXT, PROCESSOR_ARCHITECTURE, PROCESSOR_IDENTIFIER, PROCESSOR_LEVEL,
             PROCESSOR_REVISION, PROGRAMFILES, SESSIONNAME, SYSTEMDRIVE, SYSTEMROOT, TEMP, TMP, USERDOMAIN, USERNAME, USERPROFILE,
             WINDIR, DB_USERNAME, DBUSERNAME, DBPORT, DB_PORT, PORT, HOSTNAME, DB_HOST, DB_USER, DBHOST, DBUSER, DBPASS, DB_PASS,
             PASSWORD, DBPASSWORD, BASE_URL, TOKEN, API_TOKEN, CONNECTIONSTRING, DEVELOPMENT, DATABASE_URL, SECRET_KEY);
{$EndRegion}
//--------------------------------------------------------------------------------------------------------------------------
{$REGION 'DotEnv4Delphi´s interface'}

  IEnvReader = interface
  ['{D8074174-D0AB-455E-B0BC-81E33FBB25E4}']
    procedure LoadEnvStreamAddToDictionary(const AStream: TStream; const Dict: TDictionary<string, string>);
  end;

  IConnectionString = interface
  ['{6A8046DB-4346-43BA-993E-318291C3A4C0}']
    function GetProtocol: string;
    function GetUsername: string;
    function GetPassword: string;
    function GetHost: string;
    function GetPath: string;
    function GetParameters: string;
  end;

  iDotEnv4Delphi = interface
    ['{3BF1532F-91B1-4C1F-A40A-CD81F8754451}']
    //Main methods
    function Config(const OnlyFromEnvFile: Boolean = False): iDotEnv4Delphi; overload;
    function Config(const path: string = ''; OnlyFromEnvFile: Boolean = False): iDotEnv4Delphi; overload;
    function Env(const name: string): string; overload;
    function Env(const EnvVar: TEnvVar): string; overload;
    function EnvOrDefault(const name, default: string): string; overload;
    function EnvOrDefault(const EnvVar: TEnvVar; default: string): string; overload;
    function GetFirstEnvVarInList(const keys: array of string): string;
    function GetVersion: string;

    //Specific methods to access specific variables

    //To access WebAPI specific variables
    function BaseUrl: string;
    function SecretKey: string;
    function Port: integer;
    function PortOrDefault(const default: integer = 0): integer;
    function Token: string;

    //To access Database Connection specific variables
    function GetConnectionStringByName(const EnvVarName: string): IConnectionString;

    //To access Development specific variables
    function isDevelopment: Boolean;
    function ComputerName: string;
    function ProcessorArchitecture: string;

    function ClientName: string;
    function OS: string;
    function AppPath: string;
  end;

{$ENDREGION}
//--------------------------------------------------------------------------------------------------------------------------
{$REGION 'DotEnv4Delphi´s class declaration'}
  TDotEnv4Delphi = class(TInterfacedObject, iDotEnv4Delphi)
    private
     //Variables to manage the class
     fromDotEnvFile: Boolean;
     EnvDict:        TDictionary<string, string>;

     //Methods to make the class work
     procedure ReadEnvFile(const AStream: TStream);
     function ReadValueFromEnvFile(const key: string): string;
    public
     //Constructors and Destructors
     constructor Create;
     constructor CreateFromStream(const FileStream: TStream);
     Destructor Destroy; override;

     //Main methods
     function Config(const OnlyFromEnvFile: Boolean = False): iDotEnv4Delphi; overload;
     function Config(const path: string = ''; OnlyFromEnvFile: Boolean = False): iDotEnv4Delphi; overload;
     function Env(const name: string): string; overload;
     function Env(const EnvVar: TEnvVar): string; overload;
     function EnvOrDefault(const name, default: string): string; overload;
     function EnvOrDefault(const EnvVar: TEnvVar; default: string): string; overload;
     function GetVersion: string;
     function GetFirstEnvVarInList(const keys: array of string): string;

     //Specific methods to access specific variables

     //To access WebAPI specific variables
     function BaseUrl: string;
     function SecretKey: string;
     function Port: integer;
     function PortOrDefault(const default: integer = 0): integer;
     function Token: string;

     //To access Database Connection specific variables
     function GetConnectionStringByName(const EnvVarName: string): IConnectionString;

     //To access Development specific variables
     function isDevelopment: Boolean;
     function ComputerName: string;
     function ProcessorArchitecture: string;

     // access to various system and user paths is already available in TPath:
     // removed

     function ClientName: string;
     function OS: string;
     function AppPath: string;
  end;

  TConnectionString = class(TInterfacedObject, IConnectionString)
  private
    FProtocol: string;
    FUsername: string;
    FPassword: string;
    FHost: string;
    FPath: string;
    FParameters: string;

    procedure ParseConnectionString(const AConnectionString: string);
  public
    constructor Create(const AConnectionString: string);
      // interface IDatabaseConnection
    function GetProtocol: string;
    function GetUsername: string;
    function GetPassword: string;
    function GetHost: string;
    function GetPath: string;
    function GetParameters: string;
  end;

  TEnvReader = class(TInterfacedObject, IEnvReader)
  private
    function RemoveComments(const valor: string): string;
    function StripQuotes(const AStr: string): string;
    function Interpolate(const Value: string; ExistingVars: TDictionary<string, string>): string;
  public
    procedure LoadEnvStreamAddToDictionary(const AStream: TStream; const Dict: TDictionary<string, string>);
  end;

{$ENDREGION}

function DotEnv4DelphiFactory(const FileName: string): IDotEnv4Delphi; overload;
function DotEnv4DelphiFactory(const FileStream: TStream): IDotEnv4Delphi; overload;
function ConnectionStringFactory(const ConnectionString: string): IConnectionString;

resourcestring
  SFileNotFoundError = 'Environment file %s not found';

//--------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------

const
 fVersion = '2.0.0'; // Const to manage versioning
 SingleQuote = '''';
 DoubleQuote = '"';

//--------------------------------------------------------------------------------------------------------------------------

implementation

uses
  {$IFDEF FPC}
    SysUtils,
    TypInfo,
    Classes;
  {$ELSE}
    System.StrUtils,
    System.IOUtils,
    System.SysUtils,
    System.TypInfo;
  {$ENDIF}

{ TDotEnv4Delphi }

{$REGION 'Constructor and Destructor'}

constructor TDotEnv4Delphi.Create;
begin
  raise Exception.Create('not implemented, use DotEnv4DelphiFactory()');
end;

constructor TDotEnv4Delphi.CreateFromStream(const FileStream: TStream);
begin
  EnvDict := TDictionary<string, string>.Create;
  fromDotEnvFile := False;
  FileStream.Position := 0;
  ReadEnvFile(FileStream);
end;

destructor TDotEnv4Delphi.Destroy;
begin
  FreeAndNil(EnvDict);
  inherited;
end;

{$ENDREGION}
//--------------------------------------------------------------------------------------------------------------------------
{$REGION 'Internal Methods to make the class work'}

function TDotEnv4Delphi.ReadValueFromEnvFile(const key: string): string;
begin
  EnvDict.TryGetValue(key.ToUpper, Result);
end;

procedure TDotEnv4Delphi.ReadEnvFile(const AStream: TStream);
var LReader : IEnvReader;
begin
  LReader := TEnvReader.Create;
  // do not clear to allow cascading of .env files
//  EnvDict.Clear;
  LReader.LoadEnvStreamAddToDictionary(AStream, EnvDict);
end;

{$ENDREGION}
//--------------------------------------------------------------------------------------------------------------------------
{$REGION 'Main methods of DotEnv4Delphi Class'}
/// <summary>
///   Use this method to get the value of the variable you inform in the "name" parameter from either Environment or DotEnv file
/// </summary>
/// <param name="name">The name of the variable you want to get its value</param>
function TDotEnv4Delphi.Env(const name: string): string;
begin
  if fromDotEnvFile then
    Exit(ReadValueFromEnvFile(name));

  Result := GetEnvironmentVariable(name);

  if Result = EmptyStr then
   Result := ReadValueFromEnvFile(name);
end;

/// <summary>
///   Use this method to get the value of the variable you inform in the "EnvVar" parameter from either Environment or DotEnv file
/// </summary>
/// <param name="EnvVar">The Enum name of the variable you want to get its value</param>
function TDotEnv4Delphi.Env(const EnvVar: TEnvVar): string;
begin
  Result := Env(GetEnumName(TypeInfo(TEnvVar), integer(EnvVar)));
end;

/// <summary>
///   Use this method to get the value of the variable you inform in the "EnvVar" parameter from either Environment or DotEnv file
///   If it doesn't exist, it'll return the value you pass as Default value
/// </summary>
/// <param name="EnvVar">The Enum name of the variable you want to get its value</param>
/// <param name="Default">The default value you can get if the env var doesn't exist</param>
function TDotEnv4Delphi.EnvOrDefault(const EnvVar: TEnvVar; default: string): string;
var
  Value: string;
begin
  Value := Env(EnvVar);

  if Value = EmptyStr then
   Result := default
  else
   Result := Value;
end;

/// <summary>
///   Use this method to get the value of the variable you inform in the "name" parameter from either Environment or DotEnv file
///   If it doesn't exist, it'll return the value you pass as Default value
/// </summary>
/// <param name="name">The name of the variable you want to get its value</param>
/// <param name="Default">The default value you can get if the env var doesn't exist</param>
function TDotEnv4Delphi.EnvOrDefault(const name, default: string): string;
var
  Value: string;
begin
  Value := Env(name);

  if Value = EmptyStr then
   Result := default
  else
   Result := Value;
end;

function TDotEnv4Delphi.GetConnectionStringByName(
  const EnvVarName: string): IConnectionString;
begin
  Result := TConnectionString.Create(Env(EnvVarName));
end;

function TDotEnv4Delphi.GetFirstEnvVarInList(
  const keys: array of string): string;
var LKey: string;
    LValue: string;
begin
  for LKey in keys do
  begin
    if EnvDict.TryGetValue(LKey, LValue) then
      Exit(LValue);
  end;
end;

/// <summary>
///   Use this method to get the version of DotEnv4Delphi
/// </summary>
function TDotEnv4Delphi.GetVersion: string;
begin
  Result := fVersion;
end;

/// <summary>
///   Use this method to set some specific configurations. The first could be if you only want to read values from a DotEnv file
/// </summary>
/// <param name="OnlyFromEnvFile">Set it to True to only use variables declared in the DotEnv file</param>
function TDotEnv4Delphi.Config(const OnlyFromEnvFile: Boolean): iDotEnv4Delphi;
begin
  Result := Self;
  fromDotEnvFile := OnlyFromEnvFile;
end;

/// <summary>
///   Use this method to set some specific configurations. The first could be if you only want to read values from a DotEnv file and you can specify a path to the DotEnv file
/// </summary>
/// <param name="path">Set the path of the DotEnv file you want to use</param>
/// <param name="OnlyFromEnvFile">Set it to True to only use variables declared in the DotEnv file</param>
function TDotEnv4Delphi.Config(const path: string; OnlyFromEnvFile: Boolean): iDotEnv4Delphi;
var LStream: TFileStream;
begin
  Result := Self;
  fromDotEnvFile := OnlyFromEnvFile;

  LStream := TFileStream.Create(path, fmOpenRead or fmShareDenyWrite);
  try
    ReadEnvFile(LStream);
  finally
    LStream.Free;
  end;
end;
{$ENDREGION}
//--------------------------------------------------------------------------------------------------------------------------
{$REGION 'Methods to help development'}
/// <summary>
///   Gets the variable value and returns True if the environment is set to Development
/// </summary>
function TDotEnv4Delphi.isDevelopment: Boolean;
var
 Dev: string;
begin
  Dev := Env('APP_ENV');
  Result := (Dev <> EmptyStr) and (Dev.ToUpper = 'DEV');
end;

/// <summary>
///   Gets the variable value and returns the Operating System
/// </summary>
function TDotEnv4Delphi.OS: string;
begin
  Result := Env(TEnvVar.OS);
end;

/// <summary>
///   Gets the variable value and returns the Name of Client machine.
/// </summary>
function TDotEnv4Delphi.ClientName: string;
begin
  Result := Env(TEnvVar.CLIENTNAME);
end;

/// <summary>
///   Gets the variable value and returns the Name of Computer code is running on.
/// </summary>
function TDotEnv4Delphi.ComputerName: string;
begin
  Result := Env(TEnvVar.COMPUTERNAME);
end;

/// <summary>
///   Gets the variable value and returns the Type of CPU architecture. For example, X86 for Intel Pentium processors.
/// </summary>
function TDotEnv4Delphi.ProcessorArchitecture: string;
begin
  Result := Env(TEnvVar.PROCESSOR_ARCHITECTURE);
end;

function TDotEnv4Delphi.AppPath: string;
begin
  Result := ExtractFileDir(ParamStr(0));
end;

{$ENDREGION}
//--------------------------------------------------------------------------------------------------------------------------
{$REGION 'Methods to access variables for a WebAPI'}
/// <summary>
///   Read the variable and fill the BaseUrl of the webAPI
/// </summary>
function TDotEnv4Delphi.BaseUrl: string;
begin
  Result := GetFirstEnvVarInList(['BASE_URL', 'BASEURL']);
end;

/// <summary>
///   Read the variable and fill the Secret Key of the webAPI
/// </summary>
function TDotEnv4Delphi.SecretKey: string;
begin
  Result := GetFirstEnvVarInList(['SECRET_KEY', 'Secret_Key', 'SecretKey', 'SECRETKEY']);
end;

/// <summary>
///   Read the variable and fill the Port of the webAPI
/// </summary>
function TDotEnv4Delphi.Port: integer;
var
  _port: string;
begin
  Result := 0;

  _port := GetFirstEnvVarInList(['Port', 'PORT']);

  if _Port <> EmptyStr then
   Result := StrToInt(_Port);
end;

/// <summary>
///   Read the variable and fill the Port of the webAPI. If it doesn't exist, it'll be filled with the default value defined in the parameter
/// </summary>
/// <param name="default">The default value</param>
function TDotEnv4Delphi.PortOrDefault(const default: integer): integer;
var
  _port: string;
begin
  _port := GetFirstEnvVarInList(['Port', 'PORT']);

  if _Port <> EmptyStr then
   Result := StrToInt(_Port)
  else
   Result := default;
end;

/// <summary>
///   Read the variable and fill the Token of the webAPI
/// </summary>
function TDotEnv4Delphi.Token: string;
begin
  Result := Env('TOKEN');
end;

{$ENDREGION}
//--------------------------------------------------------------------------------------------------------------------------

{$REGION 'TConnectionString' }

constructor TConnectionString.Create(const AConnectionString: string);
begin
  ParseConnectionString(AConnectionString);
end;

procedure TConnectionString.ParseConnectionString(const AConnectionString: string);
var
  URI, AuthPart, HostPart, ParamsPart: string;
  AuthDelimiter, HostDelimiter, ParamsDelimiter: Integer;
begin
  // Split protocol
  AuthDelimiter := Pos('://', AConnectionString);
  if AuthDelimiter = 0 then
    raise Exception.Create('Invalid connection string: Missing protocol');
  FProtocol := Copy(AConnectionString, 1, AuthDelimiter - 1);
  URI := Copy(AConnectionString, AuthDelimiter + 3, Length(AConnectionString));

  // Split parameters
  ParamsDelimiter := Pos('?', URI);
  if ParamsDelimiter > 0 then
  begin
    FParameters := Copy(URI, ParamsDelimiter + 1, Length(URI));
    URI := Copy(URI, 1, ParamsDelimiter - 1);
  end;

  // Split host and authentication
  HostDelimiter := Pos('@', URI);
  if HostDelimiter > 0 then
  begin
    AuthPart := Copy(URI, 1, HostDelimiter - 1);
    HostPart := Copy(URI, HostDelimiter + 1, Length(URI));
  end
  else
    HostPart := URI;

  // Parse authentication
  if AuthPart <> '' then
  begin
    AuthDelimiter := Pos(':', AuthPart);
    if AuthDelimiter > 0 then
    begin
      FUsername := Copy(AuthPart, 1, AuthDelimiter - 1);
      FPassword := Copy(AuthPart, AuthDelimiter + 1, Length(AuthPart));
    end
    else
      FUsername := AuthPart;
  end;

  // Parse host and path
  HostDelimiter := Pos('/', HostPart);
  if HostDelimiter > 0 then
  begin
    FHost := Copy(HostPart, 1, HostDelimiter - 1);
    FPath := Copy(HostPart, HostDelimiter + 1, Length(HostPart));
  end
  else
    FHost := HostPart;

end;

function TConnectionString.GetProtocol: string;
begin
  Result := FProtocol;
end;

function TConnectionString.GetUsername: string;
begin
  Result := FUsername;
end;

function TConnectionString.GetPassword: string;
begin
  Result := FPassword;
end;

function TConnectionString.GetHost: string;
begin
  Result := FHost;
end;

function TConnectionString.GetPath: string;
begin
  Result := FPath;
end;

function TConnectionString.GetParameters: string;
begin
  Result := FParameters;
end;

{$ENDREGION}

{$REGION 'Factories'}

function DotEnv4DelphiFactory(const FileName: string): IDotEnv4Delphi;
var LStream: TFileStream;
begin
  if not FileExists(FileName) then
    raise Exception.CreateResFmt(@SFileNotFoundError, [ExpandFileName(FileName)]);
  LStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := DotEnv4DelphiFactory(LStream);
  finally
    LStream.Free;
  end;
end;

function DotEnv4DelphiFactory(const FileStream: TStream): IDotEnv4Delphi;
begin
  Result := TDotEnv4Delphi.CreateFromStream(FileStream);
end;

function ConnectionStringFactory(const ConnectionString: string): IConnectionString;
begin
  Result := TConnectionString.Create(ConnectionString);
end;

{$ENDREGION}

{$REGION 'TEnvReader' }

function TEnvReader.RemoveComments(const valor: string): string;
 var
  positionOfLastQuote: integer;
 begin
   if (valor.StartsWith(DoubleQuote)) or (valor.StartsWith(SingleQuote)) then
    begin
      positionOfLastQuote := Pos('"', Copy(valor, 2, length(valor) - 1));
      if positionOfLastQuote = 0 then
       positionOfLastQuote := Pos(SingleQuote, Copy(valor, 2, length(valor) - 1));

      if positionOfLastQuote > 0 then
       begin
         if Pos('# ', valor) > positionOfLastQuote then
          Result := Copy(valor, 1, Pos('# ', valor) - 2)
         else
          Result := valor;
       end;
    end
   else
    begin
     if Pos('# ', valor) > 0 then
      Result := Copy(valor, 1, Pos('# ', valor) - 2)
     else
      Result := valor;
    end;
 end;

function TEnvReader.StripQuotes(const AStr: string): string;
begin
  if (Length(AStr) > 1) and
     ((AStr[1] = '''') and (AStr[High(AStr)] = '''') or
      (AStr[1] = '"') and (AStr[High(AStr)] = '"')) then
    Result := Copy(AStr, 2, Length(AStr) - 2)
  else
    Result := AStr;
end;

function TEnvReader.Interpolate(const Value: string; ExistingVars: TDictionary<string, string>): string;
var
  PosIni, PosFim : integer;
  LKey, LValue: string;
 begin
   Result := Value;
   if (not Value.StartsWith('"')) and (not Value.StartsWith(SingleQuote)) then
    begin
      while Pos('${', Result) > 0 do
       begin
         PosIni := Pos('${', Result);
         PosFim := Pos('}', Result);
         LKey := Copy(Result, PosIni + 2, PosFim - (PosIni + 2));
         if ExistingVars.TryGetValue(LKey, LValue) then
           Result := StringReplace(Result, '${' + LKey + '}', LValue, [rfReplaceAll]);
       end;
    end;
 end;

procedure TEnvReader.LoadEnvStreamAddToDictionary(
  const AStream: TStream; const Dict: TDictionary<string, string>);

  // splits line in pair at the first Equal ("=") and trims
  // if no Equal is present, the line is used as Key and the value set to "1"
  function SplitLine(const AString: string): TPair<string, string>;
  var LPos: Integer;
  begin
    LPos := Pos('=', AString);
    if(LPos > 0) then
    begin
     Result.Key := Trim(LeftStr(AString, Pred(LPos)));
     Result.Value := Trim(RightStr(AString, Pred(Length(AString)-Length(Result.Key))));
    end
    else
    begin
      Result.Key := Trim(AString);
      Result.Value := '1';
    end;
  end;

  function GetValuePair(const AString: string): TPair<string, string>;
  begin
    // remove comments
    var CommentsRemoved := RemoveComments(AString);
    // split into key/value pair and trim
    Result := SplitLine(CommentsRemoved);
    // unwrap value from single or double quotes
    Result.Value := StripQuotes(Result.Value);
  end;

var
  LStringList: TStringList;
  LKeyValue: TPair<string, string>;
begin
  LStringList := TStringList.Create;
  LStringList.LoadFromStream(AStream);
  try
    for var i := 0 to LStringList.Count - 1 do
    begin
      LKeyValue := GetValuePair(LStringList[i]);
      var Interpolated := Interpolate(LKeyValue.Value, Dict);
      Dict.AddOrSetValue(LKeyValue.Key, Interpolated);
    end;

  finally
    LStringList.Free;
  end;

{$ENDREGION}

end;

initialization


end.
