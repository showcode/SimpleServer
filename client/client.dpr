//
// https://github.com/showcode
//

program client;

uses
  Forms,
  appconst in '..\common\appconst.pas',
  srvraccess in 'srvraccess.pas',
  apputils in '..\common\apputils.pas',
  common in '..\common\common.pas',
  netmessages in '..\common\netmessages.pas',
  mainfrm in 'mainfrm.pas' {MainForm},
  showpicturefrm in 'showpicturefrm.pas' {PictureForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPictureForm, PictureForm);
  Application.Run;
end.