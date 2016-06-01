//
// https://github.com/showcode
//

unit showpicturefrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TPictureForm = class(TForm)
    imgPicture: TImage;
    pnlButtons: TPanel;
    btnRestore: TButton;
    btnShot: TButton;
    procedure imgPictureDblClick(Sender: TObject);
    procedure btnRestoreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnShotClick(Sender: TObject);
  private
    procedure SetPicture(const Value: TPicture);
    function GetPicture: TPicture;
    procedure ShowFullScreen(FullScreen: Boolean);
  public
    property Picture: TPicture read GetPicture write SetPicture;
  end;

var
  PictureForm: TPictureForm;

implementation

{$R *.dfm}

uses
  mainfrm;

{ TPictureForm }

procedure TPictureForm.btnShotClick(Sender: TObject);
begin
  MainForm.acReqScreenshot.Execute;
end;

procedure TPictureForm.FormCreate(Sender: TObject);
begin
  pnlButtons.Hide;
  pnlButtons.DragKind := dkDock;
  pnlButtons.Constraints.MaxHeight := pnlButtons.Height;
  pnlButtons.Constraints.MinHeight := pnlButtons.Height;
  pnlButtons.Constraints.MaxWidth := pnlButtons.Width;
  pnlButtons.Constraints.MinWidth := pnlButtons.Width;
  {$IFNDEF VER130}
  imgPicture.Proportional := True;
  {$ENDIF !VER130}
end;

var
  PreviousState: TWindowState;

procedure TPictureForm.ShowFullScreen(FullScreen: Boolean);
var
  ARect: TRect;
begin
  if FullScreen then begin
    PreviousState := WindowState;
    BorderStyle := bsNone;
    WindowState := wsMaximized;
    SetForegroundWindow(Application.Handle);
    //btnRestore.Show;
    ARect.TopLeft := pnlButtons.ClientToScreen(pnlButtons.BoundsRect.TopLeft);
    ARect.BottomRight := pnlButtons.ClientToScreen(pnlButtons.BoundsRect.BottomRight);
    pnlButtons.ManualFloat(pnlButtons.BoundsRect);
  end
  else begin
    pnlButtons.ManualDock(Self);
    pnlButtons.Hide;
    WindowState := PreviousState;
    BorderStyle := bsSizeable;
  end;
end;

var
  IsFullScreen: Boolean = False;

procedure TPictureForm.imgPictureDblClick(Sender: TObject);
begin
  IsFullScreen := not IsFullScreen;
  ShowFullScreen(IsFullScreen);
end;

procedure TPictureForm.btnRestoreClick(Sender: TObject);
begin
  imgPictureDblClick(Sender);
end;

function TPictureForm.GetPicture: TPicture;
begin
  Result := imgPicture.Picture
end;

procedure TPictureForm.SetPicture(const Value: TPicture);
begin
  imgPicture.Picture := Value;
end;

end.
