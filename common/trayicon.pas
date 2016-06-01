//
// https://github.com/showcode
//

unit trayicon;

interface

uses
  Classes, Messages, Controls, Menus, Graphics, ShellAPI;

const
  UM_NOTIFYTRAYICON =  WM_USER + 444;

type
  TTrayIcon = class(TComponent)
  private
    FVisible: Boolean;
    FTrayData: TNotifyIconData;
    FIcon: TIcon;
    FHint: string;
    FPopupMenu: TPopupMenu;
    FOnDblClick: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    procedure SetVisible(const Value: Boolean);
    procedure SetIcon(const Value: TIcon);
    procedure SetHint(const Value: string);
  protected
    procedure WMEndSession(var Message: TMessage);
    procedure NotifyTrayIcon(var Message: TMessage);
    procedure WindowProc(var Message: TMessage); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Refresh;
  published
    property Visible: Boolean read FVisible write SetVisible;
    property Icon: TIcon read FIcon write SetIcon;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property Hint: string read FHint write SetHint;

    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
  end;

implementation

uses
  Windows, SysUtils, Forms;

var
  WM_TASKBARCREATED: Cardinal = 0;

{ TTrayIcon }

constructor TTrayIcon.Create(AOwner: TComponent);
begin
  inherited;
  FIcon := TIcon.Create;

  FillChar(FTrayData, SizeOf(FTrayData), 0);
  FTrayData.cbSize := SizeOf(FTrayData);
  FTrayData.Wnd := {$IFNDEF VER130}Classes.{$ENDIF}AllocateHwnd(WindowProc);
  FTrayData.uID := FTrayData.Wnd;
  FTrayData.uFlags := NIF_ICON or NIF_MESSAGE;
  FTrayData.uCallbackMessage := UM_NOTIFYTRAYICON;
  FTrayData.hIcon := FIcon.Handle;
  FTrayData.szTip := '';
  Hint := Application.Title;

  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
end;

destructor TTrayIcon.Destroy;
begin
  Visible := False;

  FIcon.Free;
  {$IFNDEF VER130}Classes.{$ENDIF}DeallocateHWnd(FTrayData.Wnd);
  inherited;
end;

procedure TTrayIcon.Refresh;
begin
  if Visible then
    Shell_NotifyIcon(NIM_MODIFY, @FTrayData)
end;

procedure TTrayIcon.SetHint(const Value: string);
begin
  if Value <> FHint then begin
    FHint := Value;

    StrPLCopy(FTrayData.szTip, Hint, SizeOf(FTrayData.szTip) - 1);
    if Hint <> '' then
      FTrayData.uFlags := FTrayData.uFlags or NIF_TIP
    else
      FTrayData.uFlags := FTrayData.uFlags and not NIF_TIP;

    Refresh;
  end;
end;

procedure TTrayIcon.SetVisible(const Value: Boolean);
begin
  if Value <> FVisible then begin
    FVisible := Value;
    if Value then
      Shell_NotifyIcon(NIM_ADD, @FTrayData)
    else
      Shell_NotifyIcon(NIM_DELETE, @FTrayData)
  end;
end;

procedure TTrayIcon.SetIcon(const Value: TIcon);
begin
  FIcon.Assign(Value);
  FTrayData.hIcon := FIcon.Handle;
  Refresh;
end;

procedure TTrayIcon.NotifyTrayIcon(var Message: TMessage);
var
  Point: TPoint;

    function Shift: TShiftState;
    begin
      Result := [];
      if GetKeyState(VK_SHIFT) < 0 then
        Include(Result, ssShift);
      if GetKeyState(VK_CONTROL) < 0 then
        Include(Result, ssCtrl);
      if GetKeyState(VK_MENU) < 0 then
        Include(Result, ssAlt);
    end;

begin
  case Message.LParam of
    WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK,
    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN:
    begin
		  SetForegroundWindow(Application.Handle);
      Application.ProcessMessages;
    end;
  end;


  case Message.LParam of
    WM_LBUTTONDBLCLK, WM_MBUTTONDBLCLK, WM_RBUTTONDBLCLK:
      if Assigned(FOnDblClick) then begin
        FOnDblClick(Self);
      end;

    WM_LBUTTONDOWN :
      if Assigned(FOnMouseUp) then begin
        GetCursorPos(Point);
        FOnMouseUp(Self, mbLeft, Shift + [ssLeft], Point.X, Point.Y);
      end;
    WM_LBUTTONUP :
      if Assigned(FOnMouseUp) then begin
        GetCursorPos(Point);
        FOnMouseUp(Self, mbLeft, Shift + [ssLeft], Point.X, Point.Y);
      end;

    WM_RBUTTONDOWN :
      if Assigned(FOnMouseUp) then begin
        GetCursorPos(Point);
        FOnMouseUp(Self, mbLeft, Shift + [ssRight], Point.X, Point.Y);
      end;
    WM_RBUTTONUP : begin
      if Assigned(FOnMouseUp) then begin
        GetCursorPos(Point);
        FOnMouseUp(Self, mbLeft, Shift + [ssRight], Point.X, Point.Y);
      end;
      if Assigned(FPopupMenu) then begin
        GetCursorPos(Point);
        FPopupMenu.AutoPopup := False;
        FPopupMenu.PopupComponent := Owner;
        FPopupMenu.Popup(Point.X, Point.Y);
      end;
    end;
  end;//case
end;

procedure TTrayIcon.WMEndSession(var Message: TMessage);
begin
  if TWmEndSession(Message).EndSession then
    Visible := False;
end;

procedure TTrayIcon.WindowProc(var Message: TMessage);
begin
  if Message.Msg = WM_TASKBARCREATED then begin
    if Visible then
      Shell_NotifyIcon(NIM_ADD, @FTrayData)
  end
  else
  case Message.Msg of
    UM_NOTIFYTRAYICON :
      NotifyTrayIcon(Message);
    WM_QUERYENDSESSION :
      Message.Result := 1;
    WM_ENDSESSION :
      WMEndSession(Message);
    else
      inherited;
  end;
end;

end.