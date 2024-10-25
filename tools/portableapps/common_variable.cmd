@echo off

cd ..\..
set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home

if not "%WINDOWS_USERPROFILE%" EQU "" (
  goto: override
)
@REM Save some system variables
set WINDOWS_HOMEDRIVE=%HOMEDRIVE%
set WINDOWS_HOMEPATH=%HOMEPATH%
set WINDOWS_USERPROFILE=%USERPROFILE%
set WINDOWS_APPDATA=%APPDATA%
set WINDOWS_LOCALAPPDATA=%LOCALAPPDATA%

:override
@REM Override system variables
set HOMEDRIVE=%~d0
set HOMEPATH=%HOME:~2%
set USERPROFILE=%HOME%
set APPDATA=%APPS_ROOT%\AppData\Roaming
set LOCALAPPDATA=%APPS_ROOT%\AppData\Local
