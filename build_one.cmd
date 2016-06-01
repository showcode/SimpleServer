SET PROJDIR=%1
SET PROJNAME=%2
SET PROJBINDIR=%3
SET PROJBUILDMODE=%4

IF NOT EXIST "%PROJDIR%" GOTO end

PUSHD "%PROJDIR%"
DEL *.dcu *.exe *.dll 2> nul

"%DELPHIPATH%dcc32.exe" -q -b /U"%LIBPATH%" %PROJNAME%.dpr > con
IF ERRORLEVEL 1 GOTO build_failed

ECHO %PROJNAME% : [OK]
POPD
MOVE %PROJDIR%\%PROJNAME%.exe "%PROJBINDIR%" 2> nul
MOVE %PROJDIR%\%PROJNAME%.dll "%PROJBINDIR%" 2> nul
MOVE %PROJDIR%\%PROJNAME%.bpl "%PROJBINDIR%" 2> nul
MOVE %PROJDIR%\%PROJNAME%.cpl "%PROJBINDIR%" 2> nul
ECHO.
GOTO build_end

:build_failed
POPD
ECHO %PROJNAME% : [Failed]
ECHO.

:build_end

:end