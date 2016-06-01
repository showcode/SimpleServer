//
// https://github.com/showcode
//

unit srvraccess;

interface

uses
  Classes, ScktComp, common;

type
  TServiceOpenedEvent = TNotifyEvent;
  TServiceClosedEvent = TNotifyEvent;
  TServiceMessageEvent =
    procedure(Sender: TObject; CtrlCode: Integer; const Data: string) of object;

  TServiceProvider = class
  private
    FSocket: TClientWinSocket;
    FParams: TStrings;
    FMessage: TNetMessage;
    FRecvBuffer: string;
    FPort: Integer;
    FServer: string;

    FOnServiceOpened: TServiceOpenedEvent;
    FOnServiceClosed: TServiceClosedEvent;
    FOnServiceMessage: TServiceMessageEvent;

    procedure SetActive(const Value: Boolean);
    procedure SetPort(const Value: Integer);
    procedure SetServer(const Value: string);
    function GetActive: Boolean;
    procedure HandleData;
  protected
    procedure SocketEvent(Sender: TObject; Socket: TCustomWinSocket;
      Event: TSocketEvent);
    procedure SocketError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure DoMessage(Message: TNetMessage);
    procedure DoOpened;
    procedure DoClosed;
    procedure SendParams;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Send(CtrlCode: Integer; const Data: string = '');

    property Active: Boolean read GetActive write SetActive;
    property Port: Integer read FPort write SetPort;
    property Server: string read FServer write SetServer;
    property Params: TStrings read FParams;

    property OnServiceOpened: TServiceOpenedEvent
      read FOnServiceOpened write FOnServiceOpened;
    property OnServiceClosed: TServiceClosedEvent
      read FOnServiceClosed write FOnServiceClosed;
    property OnServiceMessage: TServiceMessageEvent
      read FOnServiceMessage write FOnServiceMessage;
  end;

implementation

uses
  WinSock, netmessages;

{ TServiceProvider }

constructor TServiceProvider.Create;
begin
  inherited;
  FSocket := TClientWinSocket.Create(INVALID_SOCKET);
  FSocket.OnSocketEvent := SocketEvent;
  FSocket.OnErrorEvent := SocketError;

  FParams := TStringList.Create;
  FMessage := TNetMessage.Create;
end;

destructor TServiceProvider.Destroy;
begin
  Active := False;
  FSocket.Free;
  FParams.Destroy;
  FMessage.Destroy;
  inherited;
end;

procedure TServiceProvider.DoOpened;
begin
  if Assigned(FOnServiceOpened) then
    FOnServiceOpened(Self);
end;

procedure TServiceProvider.DoClosed;
begin
  if Assigned(FOnServiceClosed) then
    FOnServiceClosed(Self);
end;

procedure TServiceProvider.DoMessage(Message: TNetMessage);
begin
  if Assigned(FOnServiceMessage) then
    FOnServiceMessage(Self, Message.CtrlCode, Message.Data);
end;

{********************** Socket Events ***************************}

procedure TServiceProvider.SocketError(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin

end;

procedure TServiceProvider.SocketEvent(Sender: TObject; Socket: TCustomWinSocket;
  Event: TSocketEvent);
begin
  case Event of
    seLookup: ;
    seConnecting: ;
    seConnect: begin
      SendParams;
      DoOpened;
    end;
    seDisconnect:
      DoClosed;
    seRead:
      HandleData();
  end;
end;

procedure TServiceProvider.Send(CtrlCode: Integer; const Data: string = '');
var
  msg: TNetMessage;
  S: string;
begin
  msg := TNetMessage.Create;
  try
    msg.CtrlCode := CtrlCode;
    msg.Data := Data;
    msg.PackTo(S);
    FSocket.SendBuf(Pointer(S)^, Length(S));
  finally
    msg.Free;
  end;
end;

procedure TServiceProvider.SendParams;
begin
  Send(MC_RES_CONNECTION_PARAMS, FParams.CommaText);
end;

procedure TServiceProvider.HandleData;
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
      MC_REQ_CONNECTION_PARAMS:
        SendParams;
      else
        DoMessage(FMessage);
    end;
  end;
end;

{********************** Setters, Getters ***************************}

procedure TServiceProvider.SetActive(const Value: Boolean);
begin
  if Value <> Active then begin
    if Value then
      FSocket.Open(FServer, FServer, '', FPort, True)
    else
      FSocket.Disconnect(FSocket.SocketHandle)
  end;
end;

procedure TServiceProvider.SetPort(const Value: Integer);
begin
  if not Active then
    FPort := Value;
end;

procedure TServiceProvider.SetServer(const Value: string);
begin
  if not Active then
    FServer := Value;
end;

function TServiceProvider.GetActive: Boolean;
begin
  Result := FSocket.Connected;
end;

end.