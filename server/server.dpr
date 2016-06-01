//
// https://github.com/showcode
//

program server;

uses
  Forms,
  mainsrvr in 'mainsrvr.pas' {MainForm},
  srvrimpl in 'srvrimpl.pas',
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