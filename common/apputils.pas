//
// https://github.com/showcode
//

unit apputils;

interface

uses
  Windows, Messages;

  function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string;
  function StrToBoolDef(const S: string; Default: Boolean): Boolean;

  procedure SetAboutMenu(hWnd: HWND; uMsgID: Cardinal);
  function ShowAboutDlg: Boolean;

const
  SC_SYSMENU_ABOUT = WM_USER + 1;

implementation

uses
  Forms, SysUtils, appconst;

const
  NumBoolStrs: array [Boolean] of string = ('0', '1');
  TxtBoolStrs: array [Boolean] of string = ('False', 'True');

function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string;
begin
  if UseBoolStrs then
    Result := TxtBoolStrs[B]
  else
    Result := NumBoolStrs[B];
end;

function StrToBoolDef(const S: string; Default: Boolean): Boolean;
begin
  try
    if AnsiSameText(S, TxtBoolStrs[False]) then
      Result := False
    else
    if AnsiSameText(S, TxtBoolStrs[True]) then
      Result := True
    else
      Result := (StrToFloat(Trim(S)) <> 0.0);
  except
    //on E: EConvertError do
      Result := Default
  end;
end;

procedure SetAboutMenu(hWnd: HWND; uMsgID: Cardinal);
var
  hMenu: Windows.HMENU;
begin
  hMenu := GetSystemMenu(hWnd, False);
  AppendMenu(hMenu, MF_SEPARATOR, 0, '');
  AppendMenu(hMenu, MF_STRING, uMsgID, 'About...');
end;

function ShowAboutDlg: Boolean;
begin
  Result := True;
  Application.MessageBox(
    'Simple Server Suite' + LF +
    'version 1.0' + LF +
    'Copyright © by <author> (2007)' + LF,
    'About',
    MB_ICONINFORMATION or MB_OK
  );
end;

end.