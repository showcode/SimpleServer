//
// https://github.com/showcode
//

unit singlecopy;

interface

implementation

uses
  Windows, Forms, SysUtils;

const
  SINGLECPY_MUTEX_NAME_PREFIX = 'SINGLECPYMTX_';
  APPLICATION_CLASS = 'TApplication';

var
  hMutex: THandle = 0;

procedure ActivatePrevInstance;
var
  Wnd, h: HWND;
  S: string;
begin
  S := Application.Title;
  SetWindowText(Application.Handle, '');
  Wnd := FindWindow(APPLICATION_CLASS, PChar(S));
  SetWindowText(Application.Handle, PChar(S));
  if Wnd <> 0 then begin
    h := GetWindowLong(Wnd, GWL_HWNDPARENT);
    if h <> 0 then
      Wnd := h;

    if IsIconic(Wnd) then
      ShowWindow(Wnd, SW_RESTORE)
    else
      SetForegroundWindow(Wnd);
  end;
end;

procedure CheckPresence;
var
  SingleCopyMutexName: string;
begin
  SingleCopyMutexName :=
    SINGLECPY_MUTEX_NAME_PREFIX + ExtractFileName(ParamStr(0));
  hMutex := CreateMutex(nil, True, PChar(SingleCopyMutexName));
  if hMutex = 0 then
    Halt(0);
  if GetLastError = ERROR_ALREADY_EXISTS then begin
    ActivatePrevInstance();
    Halt(0);
  end;
end;

initialization
  CheckPresence;
finalization
  if hMutex <> 0 then
    CloseHandle(hMutex);
end.