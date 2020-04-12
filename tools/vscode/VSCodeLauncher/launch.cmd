@echo off
setlocal EnableDelayedExpansion

cd ..\..
set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home

if exist "%APPS_ROOT%\PortableApps\CommonFiles\node\node.exe" (
  set PATH=%APPS_ROOT%\PortableApps\CommonFiles\node;!PATH!
)

REM Do not use virtual env yet with VSCode, does not seem to work well as it installs python modules with pip install --user
REM PYTHONUSERBASE=<path> pip install --install-option="--home=path/" --user ... to be checked
if exist "%APPDATA%\Python\Python38\Scripts" (
  set PATH=%APPDATA%\Python\Python38\Scripts;!PATH!
)
::if exist "%HOME%\.venv\2\Scripts" (
::  set PATH=%HOME%\.venv\2;%HOME%\.venv\2\Scripts;!PATH!
::)
::if exist "%HOME%\.venv\3\Scripts" (
::  set PATH=%HOME%\.venv\3;%HOME%\.venv\3\Scripts;!PATH!
::)
if exist "%APPS_ROOT%\PortableApps\CommonFiles\python\python.exe" (
  set PATH=%APPDATA%\PortableApps\CommonFiles\python;!PATH!
)

set PATH=%APPS_ROOT%\PortableApps\PortableGit\bin;%PATH%

cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\CommonFiles\VSCode_data\extensions" --user-data-dir "..\CommonFiles\VSCode_data\user-data"
