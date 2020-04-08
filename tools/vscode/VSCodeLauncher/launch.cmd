@echo off
cd ..\..
set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home

if exist "%HOME%\.venv\3.8.1\Scripts" (
  set PATH=%HOME%\.venv\3.8.1:%HOME%\.venv\3.8.1\Scripts;%PATH
)
set PATH=%APPS_ROOT%\PortableApps\PortableGit\bin;%PATH%

cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\CommonFiles\VSCode_data\extensions" --user-data-dir "..\CommonFiles\VSCode_data\user-data"
