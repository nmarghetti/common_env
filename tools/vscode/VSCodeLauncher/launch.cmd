@echo off
setlocal EnableDelayedExpansion

cd ..\..
set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home

REM PATH to node
if exist "%APPS_ROOT%\PortableApps\CommonFiles\node\node.exe" (
  set PATH=%APPS_ROOT%\PortableApps\CommonFiles\node;!PATH!
)

REM PATH to python venv 2.7
if exist "%HOME%\.venv\2.7.17\Scripts" (
  set PATH=%HOME%\.venv\2.7.17;%HOME%\.venv\2.7.17\Scripts;!PATH!
)
REM PATH to python 3.8
if exist "%APPS_ROOT%\PortableApps\CommonFiles\python\python.exe" (
  set PYTHONUSERBASE=%APPS_ROOT%\PortableApps\CommonFiles\python
  set PATH=!PYTHONUSERBASE!;!PYTHONUSERBASE!\Python38\Scripts;!PATH!
)
REM PATH to python venv 3.8
if exist "%HOME%\.venv\3.8.2\Scripts" (
  set PATH=%HOME%\.venv\3.8.2;%HOME%\.venv\3.8.2\Scripts;!PATH!
)

set PATH=%APPS_ROOT%\PortableApps\PortableGit\bin;%PATH%

cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\CommonFiles\VSCode_data\extensions" --user-data-dir "..\CommonFiles\VSCode_data\user-data"
