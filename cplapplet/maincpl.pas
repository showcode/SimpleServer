//
// https://github.com/showcode
//

unit maincpl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, CtlPanel;

type
  TamServerCpl = class(TAppletModule)
    procedure AppletModuleActivate(Sender: TObject; Data: Integer);
    procedure AppletModuleNewInquire(Sender: TObject; var lData: Integer;
      var hIcon: HICON; var AppletName, AppletInfo: String);
    procedure AppletModuleStartWParms(Sender: TObject; Params: String);
    procedure AppletModuleStop(Sender: TObject; Data: Integer);
  private
  { private declarations }
  protected
  { protected declarations }
  public
  { public declarations }
  end;

var
  amServerCpl: TamServerCpl;

implementation

{$R *.DFM}

uses
  Dialogs, appconst;

procedure TamServerCpl.AppletModuleActivate(Sender: TObject; Data: Integer);
var
  S: string;
  I: Integer;
begin
  S := '';
  // find exe path
  for I := 0 to ParamCount do begin
    if Pos(LowerCase(APPLET_EXENAME), LowerCase(ParamStr(I))) = 0 then
      Continue;
    S := ExtractFilePath(ParamStr(I));
  end;

  if S = '' then begin
    S := 'Path not found.' + LF;
    for I := 0 to ParamCount do begin
      S := S + IntToStr(I) + ':' + ParamStr(I) + LF;
    end;
    ShowMessage(S);
  end
  else
  if WinExec(PChar(S + MANAGER_EXENAME), 0) < 32 then begin
    S := 'File not found.' + LF + S;
    ShowMessage(S);
  end;
end;

procedure TamServerCpl.AppletModuleNewInquire(Sender: TObject;
  var lData: Integer; var hIcon: HICON; var AppletName,
  AppletInfo: String);
begin
  AppletName := 'Simple Server Manager';
  AppletInfo := 'The Simple Server Control Manager';
end;

procedure TamServerCpl.AppletModuleStartWParms(Sender: TObject; Params: String);
begin
//
end;

procedure TamServerCpl.AppletModuleStop(Sender: TObject; Data: Integer);
begin
//
end;

end.