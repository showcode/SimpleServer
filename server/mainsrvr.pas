//
// https://github.com/showcode
//

unit mainsrvr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, srvrimpl, StdCtrls, ExtCtrls, ComCtrls;

type
  PCompressionParams = ^TCompressionParams;
  TCompressionParams = record
    Compression: Integer;
    Grayscale: Boolean;
    Progressive: Boolean;
  end;

type
  TMainForm = class(TForm)
    PageControl: TPageControl;
    tsLog: TTabSheet;
    mLog: TMemo;
    pnlButtons: TPanel;
    pnlStatistic: TPanel;
    btnStatClear: TButton;
    lblMaxConnects: TLabel;
    lblCurrConnects: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    btnHide: TButton;
    pmTrayMenu: TPopupMenu;
    pmiShutdown: TMenuItem;
    pmiProperties: TMenuItem;
    pmiViewLog: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pmiShutdownClick(Sender: TObject);
    procedure pmiPropertiesClick(Sender: TObject);
    procedure pmiViewLogClick(Sender: TObject);
    procedure pmTrayMenuPopup(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnStatClearClick(Sender: TObject);
    procedure OnAppIdle(Sender: TObject; var Done: Boolean);
    procedure OnAppMessage(var Msg: tagMSG; var Handled: Boolean);
  protected
    FMaxSessions: Cardinal;
    FCurrSessions: Cardinal;
    FAllowClose: Boolean;
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WMEndSession(var Message: TWMEndSession); message WM_ENDSESSION;
    procedure OnCloseService(ASession: TMySession);
    procedure OnExecutService(ASession: TMySession; CtrlCode: Integer; const Data: string);
    procedure OnOpenService(ASession: TMySession);
    procedure SetCurrSessions(const Value: Cardinal);
    procedure SetMaxSessions(const Value: Cardinal);
    procedure ReadSettings;
    procedure Log(const Operation, Info: string);
    procedure SetCompressionParams(Params: string; var CompressParams: TCompressionParams);
    function MakeScreenShot(pCompressParams: PCompressionParams): string;
    procedure Shutdown;
  public
    property MaxSessions: Cardinal read FMaxSessions write SetMaxSessions;
    property CurrSessions: Cardinal read FCurrSessions write SetCurrSessions;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Jpeg, trayicon, netmessages, apputils, appconst;

var
  TrayIco: TTrayIcon = nil;
  Server: TMyServer = nil;
  hStopEvent: THandle = 0;
  ExePath: string = '';

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.ShowMainForm := False;
  FAllowClose := False;

  ExePath := ExtractFilePath(ParamStr(0));

  TrayIco := TTrayIcon.Create(Self);
  TrayIco.Icon := Application.Icon;
  TrayIco.Hint := SERVER_DISPLAYNAME;
  TrayIco.OnDblClick := TrayIconDblClick;
  TrayIco.PopupMenu := pmTrayMenu;
  //TrayIco.Visible := True;

  Server := TMyServer.Create;
  Server.Port := DEF_LISTEN_PORT;
  Server.OnOpenService := OnOpenService;
  Server.OnCloseService := OnCloseService;
  Server.OnExecuteService := OnExecutService;

  SetAboutMenu(Handle, SC_SYSMENU_ABOUT);
  SetAboutMenu(Application.Handle, SC_SYSMENU_ABOUT);
  Application.OnMessage := OnAppMessage;

  ReadSettings;
  Application.OnIdle := OnAppIdle;

  // start server
  try
    Server.Active := True;
    Application.ProcessMessages;
  finally
    if not Server.Active then
      Shutdown;
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := FAllowClose;
  Hide;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Server.Free;
  TrayIco.Free;
end;

procedure TMainForm.OnAppIdle(Sender: TObject; var Done: Boolean);
begin
  Done := False;
  if WaitForSingleObject(hStopEvent, 10) = WAIT_OBJECT_0 then
    Shutdown;
end;

procedure TMainForm.OnAppMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  case Msg.message of
    WM_SYSCOMMAND:
      if Msg.wParam = SC_SYSMENU_ABOUT then
        Handled := ShowAboutDlg;
  end;
end;

procedure TMainForm.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
  Message.Result := 1;
end;

procedure TMainForm.WMEndSession(var Message: TWMEndSession);
begin
  if Message.EndSession then begin
    Shutdown;
    Message.Result := 0;
  end;
end;

procedure TMainForm.ReadSettings;
var
  Params: TStringList;
begin
  Params := TStringList.Create;
  try
    {$IFNDEF VER130}
    Params.CaseSensitive := False;
    {$ENDIF !VER130}
    if FileExists(ExePath + CONFIG_FILE_NAME) then
      Params.LoadFromFile(ExePath + CONFIG_FILE_NAME);

    Server.Port := StrToIntDef(Params.Values[CONFIG_PORT], DEF_LISTEN_PORT);
    TrayIco.Visible := StrToBoolDef(Params.Values[CONFIG_SHOWTRAY], True);
  except
    Params.Free;
  end;
end;

procedure TMainForm.Shutdown;
begin
  FAllowClose := True;
  Close;
end;

procedure TMainForm.btnHideClick(Sender: TObject);
begin
  Hide;
end;

procedure TMainForm.btnStatClearClick(Sender: TObject);
begin
  MaxSessions := 0;
  lblMaxConnects.Caption := IntToStr(MaxSessions);
end;

procedure TMainForm.pmTrayMenuPopup(Sender: TObject);
begin
  pmiProperties.Enabled := FileExists(ExePath + MANAGER_EXENAME);
end;

procedure TMainForm.pmiPropertiesClick(Sender: TObject);
begin
  WinExec(MANAGER_EXENAME, SW_RESTORE);
end;

procedure TMainForm.pmiShutdownClick(Sender: TObject);
begin
  if not SetEvent(hStopEvent) then
    Shutdown;
end;

procedure TMainForm.pmiViewLogClick(Sender: TObject);
begin
  TrayIconDblClick(Sender);
end;

procedure TMainForm.TrayIconDblClick(Sender: TObject);
begin
  Show;
  ShowWindow(Application.Handle, SW_RESTORE);
end;

{************************** Logging & Statistic *****************************}

procedure TMainForm.SetCurrSessions(const Value: Cardinal);
begin
  if Value <> FCurrSessions then begin
    FCurrSessions := Value;
    if FCurrSessions > MaxSessions then
      MaxSessions := FCurrSessions;
    lblCurrConnects.Caption := IntToStr(FCurrSessions);
  end;
end;

procedure TMainForm.SetMaxSessions(const Value: Cardinal);
begin
  if Value <> FMaxSessions then begin
    FMaxSessions := Value;
    if FMaxSessions < CurrSessions then
      FMaxSessions := CurrSessions;
    lblMaxConnects.Caption := IntToStr(FMaxSessions);
  end;
end;

procedure TMainForm.Log(const Operation, Info: string);
var
  S: string;
begin
   S := DateTimeToStr(Now) + LF;
   if Operation <> '' then
    S := S + Operation + LF;
   if Info <> '' then
    S := S + Info + LF;
   mLog.Lines.Add(S);
end;

{************************** Server Handles *****************************}

procedure TMainForm.OnOpenService(ASession: TMySession);
begin
  Log('Client attached.', ASession.Params.CommaText);
  CurrSessions := CurrSessions + 1;
end;

procedure TMainForm.OnCloseService(ASession: TMySession);
begin
  Log('Client detached.', '');
  CurrSessions := CurrSessions - 1;
end;

procedure TMainForm.OnExecutService(ASession: TMySession; CtrlCode: Integer; const Data: string);
var
  JpegQuality: TCompressionParams;
  S: string;
begin
  try
    case CtrlCode of
      MC_REQ_DATA_LENGTH: begin
        Log('Request Length Calculation:', QuotedStr(Data));
        ASession.Send(MC_RES_DATA_LENGTH, IntToStr(Length(Data)));
        Log('Response:', IntToStr(Length(Data)));
      end;
      MC_REQ_SCREENSHOT: begin
        Log('Request Screenshot:', '');
        ASession.Send(MC_RES_SCREENSHOT, MakeScreenShot(nil));
        Log('Send Bitmap.', '');
      end;
      MC_REQ_JPEG_SCREENSHOT: begin
        Log('Request Compressed Screenshot:', '');
        SetCompressionParams(Data, JpegQuality);
        ASession.Send(MC_RES_JPEG_SCREENSHOT, MakeScreenShot(@JpegQuality));
        Log('Send Jpeg.', '');
      end;
      else begin
        S := Format('(%d) Unknown control code: %d', [0, CtrlCode]);
        ASession.Send(MC_RES_ERROR, S);
        Log('Error.', S);
      end;
    end;
  except
    on E: Exception do begin
      S := Format('(%d) %s', [-1, E.Message]);
      ASession.Send(MC_RES_ERROR, S);
      Log('Error.', S);
    end;
  end;
end;

procedure TMainForm.SetCompressionParams(Params: string; var CompressParams: TCompressionParams);
var 
  ParamList: TStringList;
begin
  ParamList := TStringList.Create;
  try
    ParamList.Text := Params;
    CompressParams.Compression :=
      StrToIntDef(ParamList.Values[CQ_COMPRESSION], 20);
    CompressParams.Grayscale :=
      StrToBoolDef(ParamList.Values[CQ_USE_GRAYSCALE], CompressParams.Grayscale);
    CompressParams.Progressive :=
      StrToBoolDef(ParamList.Values[CQ_USE_PROGRESSIVE], CompressParams.Progressive);
  finally
    ParamList.Free;
  end;
end;

function TMainForm.MakeScreenShot(pCompressParams: PCompressionParams): string;
var
  Bmp: TBitmap;
  Strm: TStringStream;
  Jpeg: TJPEGImage;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Width := Screen.Width;
    Bmp.Height := Screen.Height;
    BitBlt(
      Bmp.Canvas.Handle, 0, 0,
      Screen.Width, Screen.Height,
      GetDC(GetDesktopWindow),
      0, 0, SrcCopy
    );
    Strm := TStringStream.Create('');
    try
      if not Assigned(pCompressParams) then begin
        Bmp.SaveToStream(strm);
      end
      else begin
        Jpeg := TJPEGImage.Create;
        try
          Jpeg.Assign(bmp);
          Jpeg.CompressionQuality := pCompressParams^.Compression;
          Jpeg.Grayscale := pCompressParams^.Grayscale;
          Jpeg.ProgressiveEncoding := pCompressParams^.Progressive;
          Jpeg.Compress;
          Jpeg.SaveToStream(strm);
        finally
          Jpeg.Free;
        end;
      end;

      Result := Strm.DataString;
    finally
      Strm.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

initialization
  hStopEvent := CreateEvent(nil, True, False, SERVER_EVENT_NAME);
  if hStopEvent = 0 then
    Halt(1);

finalization
  CloseHandle(hStopEvent);

end.