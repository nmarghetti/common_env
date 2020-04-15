@echo off
setlocal EnableDelayedExpansion

cd ..\..
set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home

REM PATH to node
if exist "%APPS_ROOT%\PortableApps\CommonFiles\node\node.exe" (
  set PATH=%APPS_ROOT%\PortableApps\CommonFiles\node;!PATH!
)

REM PATH to python 2.7, but VSCode does not work well with venv
::if exist "%HOME%\.venv\2\Scripts" (
::  set PATH=%HOME%\.venv\2;%HOME%\.venv\2\Scripts;!PATH!
::)
REM PATH to python 3.8
if exist "%APPS_ROOT%\PortableApps\CommonFiles\python\python.exe" (
  set PYTHONUSERBASE=%APPS_ROOT%\PortableApps\CommonFiles\python
  set PATH=!PYTHONUSERBASE!;!PYTHONUSERBASE!\Python38\Scripts;!PATH!
)
REM PATH to python venv 3, but VSCode does not work well with venv
::if exist "%HOME%\.venv\3\Scripts" (
::  set PATH=%HOME%\.venv\3;%HOME%\.venv\3\Scripts;!PATH!
::)

set PATH=%APPS_ROOT%\PortableApps\PortableGit\bin;%PATH%

cd "%APPS_ROOT%\PortableApps\cmder"
START /B Cmder.exe /start "%HOME%"
