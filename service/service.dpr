//
// https://github.com/showcode
//

program service;

uses
  SvcMgr,
  svcmain in 'svcmain.pas' {MyService: TService},
  appconst in '..\common\appconst.pas',
  apputils in '..\common\apputils.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  {$IFDEF VER180}
	if not Application.DelayInitialize or Application.Installing then
  {$ENDIF VER180}
    Application.Initialize;
  Application.CreateForm(TMyService, MyService);
  Application.Run;
end.