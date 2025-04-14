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

  iDotEnv4Delphi = interface
    ['{3BF1532F-91B1-4C1F-A40A-CD81F8754451}']
    //Main methods
    function Config(const OnlyFromEnvFile: Boolean = False): iDotEnv4Delphi; overload;
    function Config(const path: string = ''; OnlyFromEnvFile: Boolean = False): iDotEnv4Delphi; overload;
    function Env(const name: string): string; overload;
    function Env(const EnvVar: TEnvVar): string; overload;
    function EnvOrDefault(const name, default: string): string; overload;
    function EnvOrDefault(const EnvVar: TEnvVar; default: string): string; overload;
    function GetVersion: string;

    //Specific methods to access specific variables

    //To access WebAPI specific variables
    function BaseUrl: string;
    function SecretKey: string;
    function Port: integer;
    function PortOrDefault(const default: integer = 0): integer;
    function Token: string;

    //To access Database Connection specific variables
    function Hostname: string;
    function DBHost: string;
    function DBPort: integer;
    function DBPortOrDefault(const default: integer = 0): integer;
    function DBPassword: string;
    function ConnectionString: string;
    function Password: string;
    function DatabaseURL: string;

    //To access Development specific variables
    function isDevelopment: Boolean;
    function ComputerName: string;
    function ProcessorArchitecture: string;
    function TEMP_Dir: string;
    function WindowsDir: string;
    function AppData: string;
    function ClientName: string;
    function CommonProgramFiles: string;
    function ProgramFiles: String;
    function OS: string;
    function AppPath: string;
  end;

  IConnectionString = interface
    function GetProtocol: string;
    function GetUsername: string;
    function GetPassword: string;
    function GetHost: string;
    function GetPath: string;
    function GetParameters: string;
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

     //Specific methods to access specific variables

     //To access WebAPI specific variables
     function BaseUrl: string;
     function SecretKey: string;
     function Port: integer;
     function PortOrDefault(const default: integer = 0): integer;
     function Token: string;

     //To access Database Connection specific variables
     function Hostname: string;
     function DBHost: string;
     function DBPort: integer;
     function DBPortOrDefault(const default: integer = 0): integer;
     function DBPassword: string;
     function ConnectionString: string;
     function DatabaseURL: string;
     function Password: string;

     //To access Development specific variables
     function isDevelopment: Boolean;
     function ComputerName: string;
     function ProcessorArchitecture: string;
     function TEMP_Dir: string;
     function WindowsDir: string;
     function AppData: string;
     function ClientName: string;
     function CommonProgramFiles: string;
     function ProgramFiles: String;
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
 SingleQuote = ''''; // Character '
//--------------------------------------------------------------------------------------------------------------------------

implementation

uses
  {$IFDEF FPC}
    SysUtils,
    TypInfo,
    Classes;
  {$ELSE}
    System.StrUtils,
    System.SysUtils,
    System.TypInfo;
  {$ENDIF}

{ TDotEnv4Delphi }

{$REGION 'Constructor and Destructor'}
constructor TDotEnv4Delphi.Create;
begin
  raise Exception.Create('not implemented');
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

  function PegarValor(const valor: string): string;

    function RemoverComentario(const valor: string): string;
     var
      positionOfLastQuote: integer;
     begin
       if (valor.StartsWith('"')) or (valor.StartsWith(SingleQuote)) then
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

    function Interpolar(const valor: string): string;
     var
      PosIni, PosFim : integer;
      chave, ValorChave: string;
     begin
       Result := valor;
       if (not valor.StartsWith('"')) and (not valor.StartsWith(SingleQuote)) then
        begin
          while Pos('${', Result) > 0 do
           begin
             PosIni := Pos('${', Result);
             PosFim := Pos('}', Result);
             chave := Copy(Result, PosIni + 2, PosFim - (PosIni + 2));
             ValorChave := Env(chave);
             Result := StringReplace(Result, '${' + chave + '}', ValorChave, [rfReplaceAll]);
           end;
        end;
     end;

    function RemoverAspas(const valor: string): string;
    var
      positionOfLastQuote: integer;
    begin
      if (valor.StartsWith('"')) or (valor.StartsWith(SingleQuote)) then
      begin
        positionOfLastQuote := Pos('"', Copy(valor, 2, length(valor) - 1));
        if positionOfLastQuote = 0 then
          positionOfLastQuote := Pos(SingleQuote, Copy(valor, 2, length(valor) - 1));

        if positionOfLastQuote > 0 then
        begin
          Result := StringReplace(valor, '"', '', [rfReplaceAll]);
          Result := StringReplace(valor, SingleQuote, '', [rfReplaceAll]);
        end;
      end
      else
       Result := valor;
     end;

    function StripQuotes(const AStr: string): string;
    begin
      if (Length(AStr) > 1) and
         ((AStr[1] = '''') and (AStr[High(AStr)] = '''') or
          (AStr[1] = '"') and (AStr[High(AStr)] = '"')) then
        Result := Copy(AStr, 2, Length(AStr) - 2)
      else
        Result := AStr;
    end;

  begin
    Result := StripQuotes(Trim(RemoverAspas(Interpolar(RemoverComentario(valor)))));
  end;

  procedure PopulateDictionary(const Dict: TDictionary<string, string>; const SourceStream: TStream);
  var
    fFile    : tstringlist;
    position : Integer;
  begin
    fFile := TStringList.Create;
    try
      fFile.LoadFromStream(SourceStream);
      for position := 0 to fFile.Count - 1 do
       begin
         if not (fFile.Names[position].ToUpper = EmptyStr) then
          begin
           Dict.Add(fFile.Names[position].ToUpper, PegarValor(fFile.Values[fFile.Names[position]]));
          end;
       end;
    finally
      FreeAndNil(fFile)
    end;
  end;

begin
  EnvDict.Clear;
  PopulateDictionary(EnvDict, AStream);
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
   begin
     Result := ReadValueFromEnvFile(name);
     Exit;
   end;

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
  Result := false;

  Dev := Env('Development');

  if Dev = EmptyStr then
   Dev := Env('DEVELOPMENT');

  if (Dev <> EmptyStr) and (Dev.ToUpper = 'TRUE')  then
   Result := True;
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
///   Gets the variable value and returns the Path of common program files folder.
/// </summary>
function TDotEnv4Delphi.CommonProgramFiles: string;
begin
  Result := Env(TEnvVar.COMMONPROGRAMFILES);
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

/// <summary>
///   Gets the variable value and returns the Path of the program files folder.
/// </summary>
function TDotEnv4Delphi.ProgramFiles: String;
begin
  Result := Env(TEnvVar.PROGRAMFILES);
end;

/// <summary>
///   Gets the variable value and returns the Path of the Windows folder.
/// </summary>
function TDotEnv4Delphi.WindowsDir: string;
begin
  Result := Env(TEnvVar.WINDIR);
end;

/// <summary>
///   Gets the variable value and returns the Path of the temporary files folder.
/// </summary>
function TDotEnv4Delphi.TEMP_Dir: string;
begin
  Result := Env(TEnvVar.TEMP);
end;

/// <summary>
///   Gets the variable value and returns the Path of the application data folder.
/// </summary>
function TDotEnv4Delphi.AppData: string;
begin
  Result := Env(TEnvVar.APPDATA);
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
var
 Base: string;
begin
  Base := Env('BASE_URL');

  if Base = EmptyStr then
   Base := Env('BASEURL');

  Result := Base;
end;

/// <summary>
///   Read the variable and fill the Secret Key of the webAPI
/// </summary>
function TDotEnv4Delphi.SecretKey: string;
var
  fSecret: string;
begin
  fSecret := Env('SECRET_KEY');

  if fSecret = EmptyStr then
   fSecret := Env('Secret_Key');

  if fSecret = EmptyStr then
   fSecret := Env('SecretKey');

  if fSecret = EmptyStr then
   fSecret := Env('SECRETKEY');

  Result := fSecret;
end;

/// <summary>
///   Read the variable and fill the Port of the webAPI
/// </summary>
function TDotEnv4Delphi.Port: integer;
var
  _port: string;
begin
  Result := 0;

  _port := Env('Port');

  if _Port = EmptyStr then
   _port := Env('PORT');

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
  _port := Env('Port');

  if _Port = EmptyStr then
   _port := Env('PORT');

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
{$REGION 'Methods to work with Database connections'}
/// <summary>
///   Read variable and get the connection string
/// </summary>
function TDotEnv4Delphi.ConnectionString: string;
var
  ConnStr: string;
begin
  ConnStr := Env('ConnectionString');

  if ConnStr = EmptyStr then
   ConnStr := Env('CONNECTIONSTRING');

  if ConnStr = EmptyStr then
   ConnStr := Env('Connection_String');

  if ConnStr = EmptyStr then
   ConnStr := Env('CONNECTION_STRING');

  Result := ConnStr;
end;

/// <summary>
///   Read variable and get the Database URL
/// </summary>
function TDotEnv4Delphi.DatabaseURL: string;
var
  fDBURL: string;
begin
  fDBURL := Env('DATABASE_URL');

  if fDBURL = EmptyStr then
   fDBURL := Env('Database_URL');

  if fDBURL = EmptyStr then
   fDBURL := Env('DatabaseURL');

  if fDBURL = EmptyStr then
   fDBURL := Env('Database_URL');

  Result := fDBURL;
end;

/// <summary>
///   Read variable and get the DB Host
/// </summary>
function TDotEnv4Delphi.DBHost: string;
var
  db_host: string;
begin
  db_host := Env('DBHOST');

  if db_host = EmptyStr then
   db_host := Env('DB_HOST');

  if db_host = EmptyStr then
   db_host := Env('DB_Host');

  if db_host = EmptyStr then
   db_host := Env('DbHost');

  Result := db_host;
end;

/// <summary>
///   Read variable and get the DB Password
/// </summary>
function TDotEnv4Delphi.DBPassword: string;
var
  Pass: string;
begin
  Pass := Env('DBPassword');

  if Pass = EmptyStr then
   Pass := Env('DB_Password');

  if Pass = EmptyStr then
   Pass := Env('DB_PASSWORD');

  if Pass = EmptyStr then
   Pass := Env('DBPASSWORD');

  Result := Pass;
end;

/// <summary>
///   Read variable and get the Port to use to access the Database
/// </summary>
function TDotEnv4Delphi.DBPort: integer;
var
  _port: string;
begin
  Result := 0;

  _port := Env('DBPort');

  if _Port = EmptyStr then
   _port := Env('DBPORT');

  if _Port <> EmptyStr then
   Result := StrToInt(_Port);
end;

/// <summary>
///   Read variable and get the Port to use to access the Database otherwise returns the default value defined
/// </summary>
/// <param name="default">The default value</param>
function TDotEnv4Delphi.DBPortOrDefault(const default: integer = 0): integer;
var
  _port: string;
begin
  _port := Env('DBPort');

  if _Port = EmptyStr then
   _port := Env('DBPORT');

  if _Port <> EmptyStr then
   Result := StrToInt(_Port)
  else
   Result := default;
end;

/// <summary>
///   Read variable and get the Hostname to connect to the Database
/// </summary>
function TDotEnv4Delphi.Hostname: string;
var
  _host: string;
begin
  _host := Env('Hostname');

  if _host = EmptyStr then
   _host := Env('HOSTNAME');

  if _host = EmptyStr then
   _host := Env('Host_Name');

  if _host = EmptyStr then
   _host := Env('HOST_NAME');

  Result := _host;
end;

/// <summary>
///   Read variable and get the Password
/// </summary>
function TDotEnv4Delphi.Password: string;
var
  _pass: string;
begin
  _pass := Env('Password');

  if _pass = EmptyStr then
   _pass := Env('PASSWORD');

  Result := _pass;
end;
{$ENDREGION}

{ TDatabaseConnection }

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


{ Factories }

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

initialization


end.
