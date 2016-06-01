//
// https://github.com/showcode
//

unit mainmgr;

interface

uses
  Windows, Messages, Classes, Graphics, Controls, Forms, Menus, StdCtrls,
  ExtCtrls, ComCtrls, Dialogs;

type
  TMainForm = class(TForm)
    PageControl: TPageControl;
    tsProperties: TTabSheet;
    pnlSettings: TPanel;
    lblListenPort: TLabel;
    edtPort: TEdit;
    pnlButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    btnStartStop: TButton;
    lblStatus: TLabel;
    rgRunMode: TRadioGroup;
    rgStartMode: TRadioGroup;
    cbxUseGuardian: TCheckBox;
    Image1: TImage;
    lblInfo: TLabel;
    btnApply: TButton;
    cbxShowTray: TCheckBox;
    tmrCheckStatus: TTimer;
    btnSetDefault: TButton;
    cbxCtrlApplet: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnStartStopClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure tmrCheckStatusTimer(Sender: TObject);
    procedure PropertyModified(Sender: TObject);
    procedure btnSetDefaultClick(Sender: TObject);
  private
    FModify: Boolean;
    procedure ReadSettings;
    procedure StoreSettings;
    function GetIsRunning: Boolean;
    function CtrlService(RequreRun: Boolean): Boolean;
    function CtrlAppServer(RequreRun: Boolean): Boolean;
    procedure SetModify(const Value: Boolean);
    procedure OnAppMessage(var Msg: tagMSG; var Handled: Boolean);
  public
    UsedService: Boolean;
    property Modify: Boolean read FModify write SetModify;
    property IsRunning: Boolean read GetIsRunning;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  SysUtils, WinSvc, Registry, apputils, appconst;

const
  ActionCaption: array [Boolean] of TCaption = ('Start', 'Stop');

var
  ExePath: string = '';

procedure RaiseLastError;
begin
  {$IFDEF VER130}
  RaiseLastWin32Error
  {$ELSE !VER130}
  RaiseLastOSError
  {$ENDIF !VER130}
end;

function IsWindowsNT: Boolean;
begin
  Result := (Win32Platform = VER_PLATFORM_WIN32_NT);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ExePath := ExtractFilePath(ParamStr(0));
  ReadSettings;
  Modify := False;

  if not IsWindowsNT then begin
    rgRunMode.Enabled := False;
    rgRunMode.ItemIndex := 1;
  end;

  SetAboutMenu(Handle, SC_SYSMENU_ABOUT);
  SetAboutMenu(Application.Handle, SC_SYSMENU_ABOUT);
  Application.OnMessage := OnAppMessage;
end;

procedure TMainForm.OnAppMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  case Msg.message of
    WM_SYSCOMMAND:
      if Msg.wParam = SC_SYSMENU_ABOUT then
        Handled := ShowAboutDlg;
  end;
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.btnApplyClick(Sender: TObject);
const
  WarnMsg = 'Server must be stopped before reconfiguration. Shutdown of server?';
var
  N: Integer;
begin
  if not Modify then
    Exit;

  try
    N := StrToInt(edtPort.Text);
    if (N <= 0) or (N > MAXWORD) then
      Abort;
  except
    raise Exception.Create('Invalid port value.');
  end;

  if IsRunning then begin
    if mrYes <> MessageDlg(WarnMsg, mtConfirmation, mbYesNoCancel, 0) then
      Exit;

    CtrlService(False);
    CtrlAppServer(False);

    Exit;
  end;

  StoreSettings;
  Modify := False;
end;

procedure TMainForm.btnOkClick(Sender: TObject);
begin
  btnApply.Click;
  Close;
end;

procedure TMainForm.btnStartStopClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    if IsRunning then begin
      CtrlService(False);
      CtrlAppServer(False);
    end
    else
    if UsedService then
      CtrlService(True)
    else
      CtrlAppServer(True);

    btnStartStop.Caption := ActionCaption[IsRunning];
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.tmrCheckStatusTimer(Sender: TObject);
begin
  if IsRunning then begin
    btnStartStop.Caption := ActionCaption[True];
    lblStatus.Caption := 'Server is running.';
  end
  else begin
    btnStartStop.Caption := ActionCaption[IsRunning];
    lblStatus.Caption := 'Server is stopped.'
  end;
end;

procedure TMainForm.PropertyModified(Sender: TObject);
begin
  Modify := True;
  //if selected service mode then guard is enabled
  cbxUseGuardian.Enabled := (rgRunMode.ItemIndex = 0);
  if not cbxUseGuardian.Enabled then
    cbxUseGuardian.Checked := False;
end;

procedure TMainForm.SetModify(const Value: Boolean);
begin
  FModify := Value;
  btnApply.Enabled := FModify;
  btnStartStop.Enabled := not FModify;
end;

procedure TMainForm.btnSetDefaultClick(Sender: TObject);
begin
  edtPort.Text := IntToStr(DEF_LISTEN_PORT);
end;

{**************************** Server Control *******************************}

function TMainForm.GetIsRunning: Boolean;
var
  hSvcMgr, hService: Integer;
  Status: TServiceStatus;
  hSrvrEvent: THandle;
begin
  hSrvrEvent := OpenEvent(EVENT_MODIFY_STATE, False, SERVER_EVENT_NAME);
  Result := (hSrvrEvent <> 0);
  CloseHandle(hSrvrEvent);

  if Result then
    Exit;

  if not IsWindowsNT then
    Exit;

  hSvcMgr := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if hSvcMgr = 0 then
    RaiseLastError;
  try
    hService := OpenService(hSvcMgr, SERVICE_NAME, SERVICE_QUERY_STATUS);

    if (hService <> 0) or (GetLastError <> ERROR_SERVICE_DOES_NOT_EXIST) then
      try
        ZeroMemory(@Status, Sizeof(Status));
        if not QueryServiceStatus(hService, Status) then
          RaiseLastError;
        Result := SERVICE_RUNNING = Status.dwCurrentState;
      finally
        CloseServiceHandle(hService);
      end;
  finally
    CloseServiceHandle(hSvcMgr);
  end;
end;

function TMainForm.CtrlAppServer(RequreRun: Boolean): Boolean;
var
  hSrvrEvent: THandle;
begin
  if RequreRun then begin
    Result := (WinExec(PChar(ExePath + SERVER_EXENAME), 0) > 31);
  end
  else begin
    hSrvrEvent := OpenEvent(EVENT_MODIFY_STATE, False, SERVER_EVENT_NAME);
    if hSrvrEvent <> 0 then begin
      SetEvent(hSrvrEvent);
      CloseHandle(hSrvrEvent);
    end;
    Result := True;
  end;
  Sleep(1000);
end;

function TMainForm.CtrlService(RequreRun: Boolean): Boolean;
var
  hSvcMgr, hService: Integer;
  Status: TServiceStatus;
  N: Cardinal;
  NullStr: PChar;
begin
  Result := False;
  if not IsWindowsNT then
    Exit;

  hSvcMgr := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
   if hSvcMgr = 0 then
    RaiseLastError;

  try
    hService := OpenService(hSvcMgr,
      SERVICE_NAME, SERVICE_QUERY_STATUS or SERVICE_START or SERVICE_STOP);

    try
      if RequreRun then begin
        NullStr := nil;
        if not StartService(hService, 0, NullStr) then
          RaiseLastError;

        ZeroMemory(@Status, Sizeof(Status));
        if not QueryServiceStatus(hService, Status) then
          RaiseLastError;

        while SERVICE_RUNNING <> Status.dwCurrentState do begin
          N := Status.dwCheckPoint;
          Sleep(Status.dwWaitHint);

          if not QueryServiceStatus(hService, Status) then
            RaiseLastError;

          if (Status.dwCheckPoint < N) then begin
            // dwCheckPoint is not change !!! 
            Break;
          end;
        end;
      end
      else
      if (hService <> 0) or (GetLastError <> ERROR_SERVICE_DOES_NOT_EXIST) then begin
        ZeroMemory(@Status, Sizeof(Status));
        if not QueryServiceStatus(hService, Status) then
          RaiseLastError;

        if SERVICE_STOPPED <> Status.dwCurrentState then begin

          if not ControlService(hService, SERVICE_CONTROL_STOP, Status) then
            RaiseLastError;

          while SERVICE_STOPPED <> Status.dwCurrentState do begin
            N := Status.dwCheckPoint;
            Sleep(Status.dwWaitHint);

            if not QueryServiceStatus(hService, Status) then
              RaiseLastError;

            if (Status.dwCheckPoint < N) then begin
              // dwCheckPoint is not change !!!
              Break;
            end;
          end;
        end;
      end;

      Result := True;
    finally
      CloseServiceHandle(hService);
    end;

  finally
    CloseServiceHandle(hSvcMgr);
  end;
end;

{**************************** Settings *******************************}

procedure TMainForm.ReadSettings;
var
  Params: TStringList;
  N: Cardinal;
  AutoStart: Boolean;
  hSvcMgr, hService: Integer;
  R: TRegistry;
  pConfig: PQueryServiceConfig;
  FileName: string;
begin
  AutoStart := False;

  // read configuration file
  FileName := ExePath + CONFIG_FILE_NAME;
  Params := TStringList.Create;
  try
    {$IFNDEF VER130}
    Params.CaseSensitive := False; //:(
    {$ENDIF !VER130}
    if FileExists(FileName) then
      Params.LoadFromFile(FileName);

    edtPort.Text :=
      IntToStr(StrToIntDef(Params.Values[CONFIG_PORT], DEF_LISTEN_PORT));
    cbxShowTray.Checked :=
      StrToBoolDef(Params.Values[CONFIG_SHOWTRAY], cbxShowTray.Checked);
    cbxUseGuardian.Checked :=
      StrToBoolDef(Params.Values[CONFIG_USEGUARDIAN], cbxUseGuardian.Checked);
  finally
    Params.Free;
  end;

  // read configuration for service mode

  if IsWindowsNT then begin
    hSvcMgr := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
    if hSvcMgr = 0 then
      RaiseLastError;

    try
      hService := OpenService(hSvcMgr,
        SERVICE_NAME, SERVICE_QUERY_CONFIG or SERVICE_QUERY_STATUS);
      UsedService := (hService <> 0);

      if UsedService then
        try
          QueryServiceConfig(hService, nil, 0, N);

          GetMem(pConfig, N);
          try
            ZeroMemory(pConfig, N);
            if not QueryServiceConfig(hService, pConfig, N, N) then
              RaiseLastError;

            AutoStart :=
              (pConfig^.dwStartType <> SERVICE_DEMAND_START)
              and (pConfig^.dwStartType <> SERVICE_DISABLED)

          finally
            FreeMem(pConfig);
          end;
        finally
          CloseServiceHandle(hService);
        end;
    finally
      CloseServiceHandle(hSvcMgr);
    end;
  end;

  // read configuration for application mode

  R := TRegistry.Create(KEY_ALL_ACCESS);
  try
    R.RootKey := HKEY_LOCAL_MACHINE;
    if not R.OpenKey(REG_AUTORUN_KEY, False) then
      RaiseLastError;

    if not UsedService then begin
      AutoStart := R.ValueExists(REG_AUTORUN_NAME);
    end
    else begin
      R.DeleteValue(REG_AUTORUN_NAME);
    end;

    R.CloseKey;
  finally
    R.Free;
  end;

  // read configuration for cpl applet

  SetLength(FileName, Length(ExePath + APPLET_EXENAME) + 1);
  GetPrivateProfileString(
    'MMCPL',
    REG_APPLET_NAME,
    'Param Not Found',
    PChar(FileName),
    Length(FileName),
    'control.ini'
  );

  cbxCtrlApplet.Checked := (TrimRight(FileName) = ExePath + APPLET_EXENAME);

  if UsedService then
    rgRunMode.ItemIndex := 0
  else
    rgRunMode.ItemIndex := 1;

  if AutoStart then
    rgStartMode.ItemIndex := 0
  else
    rgStartMode.ItemIndex := 1;

   btnStartStop.Caption := ActionCaption[IsRunning];
end;

procedure TMainForm.StoreSettings;
var
  Params: TStringList;
  N: Integer;
  AutoStart: Boolean;
  hSvcMgr, hService: Integer;
  StartType: Cardinal;
  FileName: string;
  R: TRegistry;
begin
  // update configuration file
  Params := TStringList.Create;
  try
    {$IFNDEF VER130}
    Params.CaseSensitive := False;
    {$ENDIF !VER130}
    FileName := ExePath + CONFIG_FILE_NAME;
    if FileExists(FileName) then
      Params.LoadFromFile(FileName);

    Params.Values[CONFIG_PORT] := edtPort.Text;
    Params.Values[CONFIG_SHOWTRAY] := BoolToStr(cbxShowTray.Checked, True);
    Params.Values[CONFIG_USEGUARDIAN] := BoolToStr(cbxUseGuardian.Checked, True);
    Params.SaveToFile(FileName);
  finally
    Params.Free;
  end;

  UsedService := (rgRunMode.ItemIndex = 0);
  AutoStart := (rgStartMode.ItemIndex = 0);
  if AutoStart then
    StartType := SERVICE_AUTO_START
  else
    StartType := SERVICE_DEMAND_START;

  // configure service mode

  if IsWindowsNT then begin
    hSvcMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
    if hSvcMgr = 0 then
      RaiseLastError;

    try
      hService := OpenService(hSvcMgr, SERVICE_NAME, SERVICE_ALL_ACCESS);

      FileName := ExePath + SERVICE_EXENAME;

      if not UsedService then begin
        if hService <> 0 then begin    // service exist; deleting
          BOOL(N) := DeleteService(hService);
          CloseServiceHandle(hService);

          if (N = 0) and (GetLastError <> ERROR_SERVICE_MARKED_FOR_DELETE) then
            RaiseLastError;
        end;
      end
      else
      if hService = 0 then begin       // service not exist; creating
        hService := CreateService(
          hSvcMgr,
          SERVICE_NAME,
          SERVICE_DISPLAYNAME,
          SERVICE_ALL_ACCESS,
          SERVICE_WIN32_OWN_PROCESS + SERVICE_INTERACTIVE_PROCESS,
          StartType,
          SERVICE_ERROR_NORMAL,
          PChar(FileName),
          nil,
          nil,
          nil,
          nil,
          nil
        );

        if hService = 0 then
          RaiseLastError;

        CloseServiceHandle(hService);
      end
      else begin                       // service exist; change properies
        BOOL(N) := ChangeServiceConfig(
          hService,
          SERVICE_WIN32_OWN_PROCESS + SERVICE_INTERACTIVE_PROCESS,
          StartType,
          SERVICE_ERROR_NORMAL,
          PChar(FileName),
          nil,
          nil,
          nil,
          nil,
          nil,
          SERVICE_DISPLAYNAME
        );

        CloseServiceHandle(hService);

        if N = 0 then
          RaiseLastError;
      end;

    finally
      CloseServiceHandle(hSvcMgr);
    end;
  end;

  // configure application mode

  R := TRegistry.Create(KEY_ALL_ACCESS);
  try
    R.RootKey := HKEY_LOCAL_MACHINE;
    if not R.OpenKey(REG_AUTORUN_KEY, False) then
      RaiseLastError;

    FileName := ExePath + SERVER_EXENAME;

    if not UsedService and AutoStart then begin
      R.WriteString(REG_AUTORUN_NAME, FileName);
    end
    else begin
      R.DeleteValue(REG_AUTORUN_NAME);
    end;

    R.CloseKey;
  finally
    R.Free;
  end;

  // configure cpl applet

  if cbxCtrlApplet.Checked then
    FileName := ExePath + APPLET_EXENAME
  else
    FileName := '';
  WritePrivateProfileString('MMCPL', REG_APPLET_NAME, PChar(FileName), 'control.ini');
end;

end.