@ECHO off

CALL .\cleanup.cmd
CALL .\setpaths.cmd
 
ECHO.
ECHO * Building %MODE% at: %DATE% %TIME% on %COMPUTERNAME% > con
ECHO.

CALL build_one.cmd .\server server %BINDIR% %MODE%  
CALL build_one.cmd .\service service %BINDIR% %MODE% 
CALL build_one.cmd .\manager manager %BINDIR% %MODE% 
CALL build_one.cmd .\cplapplet applet %BINDIR% %MODE% 
CALL build_one.cmd .\client client %BINDIR% %MODE% 

PAUSE