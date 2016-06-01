//
// https://github.com/showcode
//

unit svcmain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs;

type
  TMyService = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
  protected
    procedure ReadSettings;
  public
    UseGuard: Boolean;
    function GetServiceController: TServiceController; override;
    function StartServer: Boolean;
    function ShutdownServer: Boolean;
    function TerminateServer: Boolean;
  end;

var
  MyService: TMyService;

implementation

{$R *.DFM}

uses
  WinSvc, appconst, apputils;

const
  //EVT_SUCC    = EVENTLOG_SUCCESS_TYPE;
  EVT_INFO    = EVENTLOG_INFORMATION_TYPE;
  EVT_WARNING = EVENTLOG_WARNING_TYPE;
  EVT_ERROR   = EVENTLOG_ERROR_TYPE;

var
  ExePath: string = '';
  hServerProcessHandle: THandle = 0;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MyService.Controller(CtrlCode);
end;

function TMyService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TMyService.ServiceCreate(Sender: TObject);
begin
  Name := SERVICE_NAME;
  DisplayName := SERVICE_DISPLAYNAME;
  UseGuard := True;
end;

procedure TMyService.ServiceExecute(Sender: TService);
var
  Err: Cardinal;
  hStopEvent: THandle;
  Restart: Boolean;
begin
  ExePath := ExtractFilePath(ParamStr(0));
  ReadSettings;

  // check and shutdown previos instance
  hStopEvent := OpenEvent(EVENT_ALL_ACCESS, False, SERVER_EVENT_NAME);
  if hStopEvent <> 0 then
    ShutdownServer;

  repeat
    Restart := False;
    CloseHandle(hStopEvent);

    if not StartServer then begin
      Err := GetLastError;
      LogMessage(Format('Server do not execute. ErrCode: %u ErrMsg: %s',
	[Err, SysErrorMessage(Err)]),  EVT_ERROR);
      Exit
    end;

    Sleep(1000);
    hStopEvent := OpenEvent(EVENT_ALL_ACCESS, False, SERVER_EVENT_NAME);

    LogMessage('Server is started.', EVT_INFO);

    while True do begin

      ServiceThread.ProcessRequests(False{ True});

      // check stop event
      if WaitForSingleObject(hStopEvent, 10) = WAIT_OBJECT_0 then
	ServiceThread.Terminate;

      // check terminate service and shutdown server
      if Terminated and not ShutdownServer then begin
	TerminateServer;
	Break
      end;

      // check server alive
      if WaitForSingleObject(hServerProcessHandle, 10) = WAIT_OBJECT_0 then begin
	if Terminated then begin
	  LogMessage('Server is stoped.', EVT_INFO);
	  Break
	end
	else
	if UseGuard then begin
	  LogMessage('Server abnormaly terminate. Restart process...', EVT_WARNING);
	  Restart := True;
	  Break
	end
	else begin
	  LogMessage('Server abnormaly terminate.', EVT_WARNING);
	  Break
	end;
      end;

    end;//while
  until not Restart;

  CloseHandle(hStopEvent);
  CloseHandle(hServerProcessHandle);
end;

function TMyService.StartServer: Boolean;
var
  CmdLine: string;
  SI: TStartupInfo;
  PI: TProcessInformation;
begin
  CmdLine := ExePath + '\' + SERVER_EXENAME;

  CloseHandle(hServerProcessHandle);

  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);

  Result := CreateProcess(
    PChar(CmdLine),
    nil,
    nil,
    nil,
    False,
    0,
    nil,
    PChar(ExePath),
    SI,
    PI
  );

  CloseHandle(PI.hThread);
  hServerProcessHandle := PI.hProcess;
end;

function TMyService.ShutdownServer: Boolean;
var
  hSrvrEvent: THandle;
begin
  hSrvrEvent := OpenEvent(EVENT_MODIFY_STATE, False, SERVER_EVENT_NAME);
  if hSrvrEvent <> 0 then begin
    SetEvent(hSrvrEvent);
    CloseHandle(hSrvrEvent);
  end;
  Result := (WaitForSingleObject(hServerProcessHandle, 2000) = WAIT_OBJECT_0);
end;

function TMyService.TerminateServer: Boolean;
var
  Err: Cardinal;
begin
  if not TerminateProcess(hServerProcessHandle, 0) then begin
    Err := GetLastError;
    Result := (WaitForSingleObject(hServerProcessHandle, 2000) = WAIT_OBJECT_0);
    if not Result then
      LogMessage(Format('Could not terminate service. ErrCode: %u ErrMsg: %s',
        [Err, SysErrorMessage(Err)]), EVT_ERROR);
  end
  else begin
    Result := (WaitForSingleObject(hServerProcessHandle, 2000) = WAIT_OBJECT_0);
    if not Result then
      LogMessage('Could not terminate service.', EVT_ERROR);
  end;

  if Result then
    LogMessage('Server abnormaly terminate.', EVT_ERROR);
end;

procedure TMyService.ReadSettings;
var
  FileName: string;
  Params: TStringList;
begin
  // read configuration file
  FileName := ExePath + CONFIG_FILE_NAME;
  if FileExists(FileName) then begin
    Params := TStringList.Create;
    try
      {$IFNDEF VER130}
      Params.CaseSensitive := False; //:(
      {$ENDIF !VER130}
      Params.LoadFromFile(FileName);

      UseGuard :=
        StrToBoolDef(Params.Values[CONFIG_USEGUARDIAN], UseGuard);
    except
      //
    end;
    Params.Free;
  end;
end;

end.
