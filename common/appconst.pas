//
// https://github.com/showcode
//

unit appconst;

interface

const
  // server
  SERVER_EXENAME = 'server.exe';
  SERVER_EVENT_NAME = '{40BFA941-1131-450D-AF3F-A06A0C9D9A1E}-SimpleServer';
  SERVER_DISPLAYNAME = 'Simple Server';

  DEF_LISTEN_PORT = 22;

  // service
  SERVICE_EXENAME = 'service.exe';
  SERVICE_NAME = 'SimpleSvc';
  SERVICE_DISPLAYNAME = 'Simple Server Service';

  REG_AUTORUN_KEY = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run\';
  REG_AUTORUN_NAME = 'Simple Server';

  // manager
  MANAGER_EXENAME     = 'manager.exe';

  CONFIG_FILE_NAME    = 'server.cnf';
  CONFIG_PORT         = 'Port';
  CONFIG_SHOWTRAY     = 'ShowTrayIcon';
  CONFIG_USEGUARDIAN  = 'UseGuardian';

  // applet
  APPLET_EXENAME      = 'applet.cpl';
  REG_CPLS_KEY        = 'Software\Microsoft\Windows\CurrentVersion\Control Panel\Cpls';
  REG_APPLET_NAME     = 'Simple Server Applet';

  // client
  HOSTS_FILE_NAME = 'hosts.txt';



  // compression quality params
  CQ_COMPRESSION      = 'Compression';
  CQ_USE_GRAYSCALE    = 'Grayscale';
  CQ_USE_PROGRESSIVE  = 'Progressive';

  // connection params
  CP_COMPUTER = 'ComputerName';
  CP_USERNAME = 'UserName';

  // line feed
  LF = #$D#$A;

implementation

end.
