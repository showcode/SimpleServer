//
// https://github.com/showcode
//

unit mainfrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdCtrls, srvraccess, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    cbxServers: TComboBox;
    ActionList: TActionList;
    acServersAdd: TAction;
    acServersLoad: TAction;
    acServersSave: TAction;
    acServersDel: TAction;
    btnAdd: TButton;
    btnDel: TButton;
    btnLoad: TButton;
    btnSave: TButton;
    acConnect: TAction;
    mText: TMemo;
    btnConnect: TButton;
    acDisconnect: TAction;
    acSendText: TAction;
    acReqScreenshot: TAction;
    btnGetLength: TButton;
    btnGetScreenshot: TButton;
    lblTextLen: TLabel;
    pnlPreview: TPanel;
    imgScreenshot: TImage;
    gbxCompression: TGroupBox;
    cbxUseJpeg: TCheckBox;
    trbCompression: TTrackBar;
    cbxGrayScale: TCheckBox;
    cbxProgressive: TCheckBox;
    lblImageProperty: TLabel;
    StatusBar: TStatusBar;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    lblQuality: TLabel;
    btnShowViewer: TButton;
    acShowViewer: TAction;
    procedure acServersAddExecute(Sender: TObject);
    procedure acServersDelExecute(Sender: TObject);
    procedure acServersLoadExecute(Sender: TObject);
    procedure acServersSaveExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure acConnectExecute(Sender: TObject);
    procedure acDisconnectExecute(Sender: TObject);
    procedure acSendTextExecute(Sender: TObject);
    procedure acReqScreenshotExecute(Sender: TObject);
    procedure mTextChange(Sender: TObject);
    procedure cbxUseJpegClick(Sender: TObject);
    procedure acShowViewerExecute(Sender: TObject);
    procedure OnAppMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    FModified: Boolean;
    FConnected: Boolean;
    procedure OnServiceOpened(Sender: TObject);
    procedure OnServiceClosed(Sender: TObject);
    procedure OnServiceMessage(Sender: TObject; CtrlCode: Integer; const Data: string);
    procedure ShowScreenshot(Data: string; IsCompressed: Boolean);
    procedure SetModified(const Value: Boolean);
    procedure SetConnected(const Value: Boolean);
  public
    property Modified: Boolean read FModified write SetModified;
    property Connected: Boolean read FConnected write SetConnected;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Jpeg, apputils, appconst, netmessages, showpicturefrm;

var
  Provider: TServiceProvider = nil;
  ExePath: string = '';

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ExePath := ExtractFilePath(ParamStr(0));
  acServersLoad.Execute;
  Modified := False;

  Provider := TServiceProvider.Create;
  Provider.OnServiceOpened := OnServiceOpened;
  Provider.OnServiceClosed := OnServiceClosed;
  Provider.OnServiceMessage := OnServiceMessage;

  Connected := False;

  SetAboutMenu(Application.Handle, SC_SYSMENU_ABOUT);
  SetAboutMenu(Handle, SC_SYSMENU_ABOUT);
  Application.OnMessage := OnAppMessage;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Modified then
    case MessageDlg('Save changes in hosts list?', mtConfirmation, mbYesNoCancel, 0) of
      mrYes:
        acServersSave.Execute;
      mrCancel:
        CanClose := True;
      else
        CanClose := False;
    end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Provider.Free;
end;

procedure TMainForm.OnAppMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  case Msg.message of
    WM_SYSCOMMAND:
      if Msg.wParam = SC_SYSMENU_ABOUT then
        Handled := ShowAboutDlg;
  end;
end;

{************************ Hosts List ***************************}

procedure TMainForm.acServersAddExecute(Sender: TObject);
const
  Msg = 'Format: ''<Host name>:Port'' or ''<IP Address>:Port''';
var
  S: string;
  I: Integer;
begin
  S := cbxServers.Text;
  if S = '' then
    S := Format('127.0.0.1:%u', [DEF_LISTEN_PORT]);
  if InputQuery('New Server', Msg, S) then begin
    S := Trim(S);
    if S <> '' then begin
      I := cbxServers.Items.IndexOf(S);
      if I = -1 then begin
        I := cbxServers.Items.Add(S);
        Modified := True;
      end;
      cbxServers.ItemIndex := I;
      cbxServers.Refresh;
    end;
  end;
end;

procedure TMainForm.acServersDelExecute(Sender: TObject);
var
  S: string;
  I: Integer;
begin
  I := cbxServers.ItemIndex;
  if I >= 0 then begin
    S := 'Remove ''' + cbxServers.Items[I] + ''' from list?';
    if mrYes = MessageDlg(S, mtConfirmation, [mbYes, mbNo], 0) then begin
      cbxServers.Items.Delete(I);
      Modified := True;
      if I < cbxServers.Items.Count then
        cbxServers.ItemIndex := I
      else
        cbxServers.ItemIndex := I - 1;
      cbxServers.Refresh;
    end;
  end;
end;

procedure TMainForm.acServersLoadExecute(Sender: TObject);
begin
  if FileExists(ExePath + HOSTS_FILE_NAME) then
    cbxServers.Items.LoadFromFile(ExePath + HOSTS_FILE_NAME);
  cbxServers.ItemIndex := 0;
  Modified := False;
end;

procedure TMainForm.acServersSaveExecute(Sender: TObject);
begin
  cbxServers.Items.SaveToFile(ExePath + HOSTS_FILE_NAME);
  Modified := False;
end;

procedure TMainForm.SetModified(const Value: Boolean);
const
  ModifyStr: array[Boolean] of string = ('', 'Modified');
begin
  FModified := Value;
  acServersSave.Enabled := FModified;
  StatusBar.Panels[1].Text := ModifyStr[FModified];
end;

{*********************** Other Actions ***************************}

procedure DecomposeHost(const Host: string; var Addr: string; var Port: Cardinal);
var
  N: Integer;
begin
  N := Pos(':', Host);
  if N = 0 then begin
    Addr := Trim(Host);
    Port := 0;
  end
  else begin
    Addr := Trim(Copy(Host, 1, N - 1));
    Port := StrToIntDef(Trim(Copy(Host, N + 1, MaxInt)), 0);
  end;
end;

procedure TMainForm.acConnectExecute(Sender: TObject);
var
  N: Cardinal;
  S: string;
begin
  DecomposeHost(Trim(cbxServers.Text), S, N);

  if S <> '' then
    Provider.Server := S
  else
    raise Exception.Create('Wrong server address.');

  if N <> 0 then
    Provider.Port := N
  else
    Provider.Port := DEF_LISTEN_PORT;

  N := MAX_COMPUTERNAME_LENGTH;
  SetLength(S, N);
  if GetComputerName(PChar(S), N) then begin
    SetLength(S, N);
    Provider.Params.Values[CP_COMPUTER] := Trim(S);
  end;

  N := MAX_PROFILE_LEN;
  SetLength(S, N);
  if GetUserName(PChar(S), N) then begin
    SetLength(S, N);
    Provider.Params.Values[CP_USERNAME] := Trim(S);
  end;

  Provider.Active := True;
end;

procedure TMainForm.acDisconnectExecute(Sender: TObject);
begin
  Provider.Active := False;
end;

procedure TMainForm.acSendTextExecute(Sender: TObject);
begin
  Provider.Send(MC_REQ_DATA_LENGTH, mText.Text);
end;

procedure TMainForm.acReqScreenshotExecute(Sender: TObject);
var
  Params: TStringList;
begin
  if not cbxUseJpeg.Checked then begin
    Provider.Send(MC_REQ_SCREENSHOT);
    Exit;
  end;

  Params := TStringList.Create;
  try
    Params.Values[CQ_COMPRESSION] := IntToStr(trbCompression.Position);
    Params.Values[CQ_USE_GRAYSCALE] := BoolToStr(cbxGrayScale.Checked, True);
    Params.Values[CQ_USE_PROGRESSIVE] := BoolToStr(cbxProgressive.Checked, True);

    Provider.Send(MC_REQ_JPEG_SCREENSHOT, Params.Text);
  finally
    Params.Free;
  end;
end;

procedure TMainForm.acShowViewerExecute(Sender: TObject);
begin
  if Provider.Active then begin
    PictureForm.Picture.Assign(imgScreenshot.Picture);
    PictureForm.Show;
  end;
end;

procedure TMainForm.mTextChange(Sender: TObject);
begin
  lblTextLen.Caption := 'Text Length: ' + IntToStr(Length(mText.Text));
end;

procedure TMainForm.SetConnected(const Value: Boolean);
const
  ConnStatus: array [Boolean] of string = ('Disconnected', 'Connected');
begin
  FConnected := Value;
  acSendText.Enabled := FConnected;
  acReqScreenshot.Enabled := FConnected;
  acShowViewer.Enabled := FConnected and acShowViewer.Enabled;

  StatusBar.Panels[0].Text := ConnStatus[FConnected];
  cbxServers.Enabled := not FConnected;
  acServersAdd.Enabled := not FConnected;
  acServersDel.Enabled := not FConnected;
  acServersLoad.Enabled := not FConnected;
end;

{*********************** Client Handlers *************************}

procedure TMainForm.OnServiceOpened(Sender: TObject);
begin
  btnConnect.Action := acDisconnect;
  Connected := True;
end;

procedure TMainForm.OnServiceClosed(Sender: TObject);
begin
  btnConnect.Action := acConnect;
  PictureForm.Hide;
  Connected := False;
end;

procedure TMainForm.OnServiceMessage(Sender: TObject; CtrlCode: Integer; const Data: string);
begin
  case CtrlCode of
    MC_RES_DATA_LENGTH :
      ShowMessage('Server responded value: ' + Data);
    MC_RES_SCREENSHOT :
      ShowScreenshot(Data, False);
    MC_RES_JPEG_SCREENSHOT :
      ShowScreenshot(Data, True);
    MC_RES_ERROR :
      raise Exception.Create('Server error:'+ LF + Data);
  end;
end;

procedure TMainForm.ShowScreenshot(Data: string; IsCompressed: Boolean);
var
  strm: TStringStream;
  jpeg: TJPEGImage;
begin
  strm := TStringStream.Create(Data);
  try
    strm.Seek(0, soFromBeginning);
    if IsCompressed then begin
      jpeg := TJPEGImage.Create;
      try
        jpeg.LoadFromStream(strm);
        imgScreenshot.Picture.Assign(jpeg);
      finally
        jpeg.Free;
      end;

      lblImageProperty.Caption := Format('jpeg %dx%d %dK',
        [imgScreenshot.Picture.Width, imgScreenshot.Picture.Height, Length(Data) div 1024]);
    end
    else begin
      imgScreenshot.Picture.Bitmap.LoadFromStream(strm);
      lblImageProperty.Caption := Format('bmp %dx%d %dK',
        [imgScreenshot.Picture.Width, imgScreenshot.Picture.Height, Length(Data) div 1024]);
    end;
  finally
    strm.Free;
  end;

  if PictureForm.Visible then
    PictureForm.Picture.Assign(imgScreenshot.Picture);

  acShowViewer.Enabled := True;
end;

procedure TMainForm.cbxUseJpegClick(Sender: TObject);
begin
  trbCompression.Enabled := cbxUseJpeg.Checked;
  cbxGrayScale.Enabled := False; //cbxUseJpeg.Checked; // Not work!?
  cbxProgressive.Enabled := cbxUseJpeg.Checked;
end;

end.