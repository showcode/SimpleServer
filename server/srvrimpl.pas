//
// https://github.com/showcode
//

unit srvrimpl;

interface

uses
  Classes, ScktComp, WinSock, Contnrs, common;

type
  TMySession = class;
  TMySessionList = class;
  TMyServer = class;

  TMySession = class
  private
    FOwner: TMyServer;
    FSocket: TCustomWinSocket;
    FRecvBuffer: string;
    FMessage: TNetMessage;
    FParams: TStrings;
    FFlag: Boolean;
  protected
    IsParamReceived: Boolean;
    procedure HandleData;
    procedure QueryConnectionParams;
  public
    constructor Create(AOwner: TMyServer; Socket: TCustomWinSocket);
    destructor Destroy; override;
    procedure Send(CtrlCode: Integer; const Data: string);

    property Message: TNetMessage read FMessage;
    property Params: TStrings read FParams;
  end;

  TMySessionList = class(TObjectList)
  protected
    property OwnsObjects;
  public
    constructor Create; reintroduce;
  end;

  TOpenServiceEvent = procedure(ASession: TMySession) of object;
  TExecuteServiceEvent = procedure(
    ASession: TMySession; CtrlCode: Integer; const Data: string) of object;
  TCloseServiceEvent = procedure(ASession: TMySession) of object;

  TMyServer = class
  private
    FServerSocket: TServerSocket;
    FSessions: TMySessionList;
    FOnExecuteService: TExecuteServiceEvent;
    FOnOpenService: TOpenServiceEvent;
    FOnCloseService: TCloseServiceEvent;
    procedure SetPort(const Value: Integer);
    function GetPort: Integer;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetSession(Index: Integer): TMySession;
    function GetSesisonCount: Integer;
  protected
    procedure DoOpenService(ASession: TMySession);
    procedure DoExecuteService(ASession: TMySession; Message: TNetMessage);
    procedure DoCloseService(ASession: TMySession);
    //procedure GetSocket(Sender: TObject; Socket: TSocket; var ClientSocket: TServerClientWinSocket);
    procedure ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    function FindSession(Socket: TCustomWinSocket): TMySession;
  public
    constructor Create;
    destructor Destroy; override;

    property Active: Boolean read GetActive write SetActive;
    property Port: Integer read GetPort write SetPort;
    property SessionCount: Integer read GetSesisonCount;
    property Sessions[Index: Integer]: TMySession read GetSession;
    property OnOpenService: TOpenServiceEvent read FOnOpenService write FOnOpenService;
    property OnExecuteService: TExecuteServiceEvent read FOnExecuteService write FOnExecuteService;
    property OnCloseService: TCloseServiceEvent read FOnCloseService write FOnCloseService;
  end;

implementation

{$DEFINE DEMAND_CONNECTION_PARAMS}

uses
  Windows, netmessages;

{ TMySession }

constructor TMySession.Create(AOwner: TMyServer; Socket: TCustomWinSocket);
begin
  FOwner := AOwner;
  FOwner.FSessions.Add(Self);
  FSocket := Socket;
  Socket.Data := Self;
  FMessage := TNetMessage.Create;
  FParams := TStringList.Create;
end;

destructor TMySession.Destroy;
var 
  Socket: TCustomWinSocket;
begin
  if Assigned(FSocket) then begin
    FSocket.Data := nil;
    Socket := FSocket;
    FSocket := nil;
    if not FFlag then
      Socket.Close;
  end;
  FOwner.FSessions.Extract(Self);

  FMessage.Free;
  FParams.Free;
  inherited;
end;

procedure TMySession.Send(CtrlCode: Integer; const Data: string);
var
  Msg: TNetMessage;
  S: string;
begin
  Msg := TNetMessage.Create;
  try
    Msg.CtrlCode := CtrlCode;
    Msg.Data := Data;
    Msg.PackTo(S);
    FSocket.SendBuf(Pointer(S)^, Length(S));
  finally
    Msg.Free;
  end;
end;

procedure TMySession.HandleData;
var 
  N: Integer;
begin
  if FSocket.ReceiveLength > 0 then begin
    N := Length(FRecvBuffer);
    SetLength(FRecvBuffer, N + FSocket.ReceiveLength);
    FSocket.ReceiveBuf(FRecvBuffer[N + 1], Length(FRecvBuffer) - N);
  end;

  while FMessage.Extract(FRecvBuffer) do begin
    case FMessage.CtrlCode of
      MC_RES_CONNECTION_PARAMS: begin
        FParams.CommaText := FMessage.Data;
        IsParamReceived := True;
        {$IFDEF DEMAND_CONNECTION_PARAMS}
        FOwner.DoOpenService(Self);
        {$ENDIF DEMAND_CONNECTION_PARAMS}
      end;
      else begin
        {$IFDEF DEMAND_CONNECTION_PARAMS}
        if not IsParamReceived then
          //Self.Free; Break
          QueryConnectionParams
        else
        {$ENDIF DEMAND_CONNECTION_PARAMS}
        FOwner.DoExecuteService(Self, FMessage);
      end;
    end;
  end;
end;

procedure TMySession.QueryConnectionParams;
begin
  Send(MC_REQ_CONNECTION_PARAMS, '');
end;

{ TMySessionList }

constructor TMySessionList.Create;
begin
  inherited Create(True);
end;

{ TMyServer }

constructor TMyServer.Create;
begin
  inherited;
  FSessions := TMySessionList.Create;
  FServerSocket := TServerSocket.Create(nil);
  FServerSocket.Port := 0;
  //FServerSocket.OnGetSocket := GetSocket;
  FServerSocket.OnClientConnect := ClientConnect;
  FServerSocket.OnClientDisconnect := ClientDisconnect;
  FServerSocket.OnClientRead := ClientRead;
end;

destructor TMyServer.Destroy;
begin
  Active := False;
  FServerSocket.Free;
  FSessions.Free;
  inherited;
end;

procedure TMyServer.DoOpenService(ASession: TMySession);
begin
  if Assigned(FOnOpenService) then
    FOnOpenService(ASession);
end;

procedure TMyServer.DoCloseService(ASession: TMySession);
begin
  if Assigned(FOnCloseService) then
    FOnCloseService(ASession);
end;

procedure TMyServer.DoExecuteService(ASession: TMySession; Message: TNetMessage);
begin
  if Assigned(FOnExecuteService) then
    FOnExecuteService(ASession, Message.CtrlCode, Message.Data);
end;

{************************** Socket Events *****************************}

function TMyServer.FindSession(Socket: TCustomWinSocket): TMySession;
begin
  Result := nil;
  if Assigned(Socket.Data) and (TMySession(Socket.Data).FSocket = Socket) then
    Result := Socket.Data;
end;

procedure TMyServer.ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var Session: TMySession;
begin
  Session := TMySession.Create(Self, Socket);
  Session.IsParamReceived := Session.IsParamReceived;
  {$IFNDEF DEMAND_CONNECTION_PARAMS}
  DoOpenService(Session);
  {$ENDIF !DEMAND_CONNECTION_PARAMS}
end;

procedure TMyServer.ClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
var 
  Session: TMySession;
begin
  Session := FindSession(Socket);
  if Assigned(Session) then begin
    try
      Session.FFlag := True;
      {$IFDEF DEMAND_CONNECTION_PARAMS}
        if Session.IsParamReceived then
      {$ENDIF DEMAND_CONNECTION_PARAMS}
      DoCloseService(Session);
    finally
      FindSession(Socket).Free;
    end;
  end;
end;

procedure TMyServer.ClientRead(Sender: TObject; Socket: TCustomWinSocket);
var 
  Session: TMySession;
begin
  Session := FindSession(Socket);
  Session.HandleData();
end;

{************************** Setters & Getters *****************************}

function TMyServer.GetSesisonCount: Integer;
begin
  Result := FSessions.Count;
end;

function TMyServer.GetSession(Index: Integer): TMySession;
begin
  Result := FSessions.Get(Index);
end;

//procedure TMyServer.GetSocket(Sender: TObject; Socket: TSocket;
//  var ClientSocket: TServerClientWinSocket);
//begin
//end;

function TMyServer.GetActive: Boolean;
begin
  Result := FServerSocket.Active;
end;

function TMyServer.GetPort: Integer;
begin
  Result := FServerSocket.Port;
end;

procedure TMyServer.SetActive(const Value: Boolean);
begin
  if not Value then
    FSessions.Clear;
  FServerSocket.Active := Value;
end;

procedure TMyServer.SetPort(const Value: Integer);
begin
  FServerSocket.Port := Value;
end;

end.