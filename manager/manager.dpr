//
// https://github.com/showcode
//

program manager;

uses
  Forms,
  mainmgr in 'mainmgr.pas' {MainForm},
  common in '..\common\common.pas',
  apputils in '..\common\apputils.pas',
  trayicon in '..\common\trayicon.pas',
  netmessages in '..\common\netmessages.pas',
  appconst in '..\common\appconst.pas',
  singlecopy in '..\common\singlecopy.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.