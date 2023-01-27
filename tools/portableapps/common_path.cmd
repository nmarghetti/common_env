@echo off
REM EnableDelayedExpansion would be needed inside subprocess in () to call variables with !!, eg. set PATH=some_path;!PATH!
REM setlocal EnableDelayedExpansion

cd ..\..
set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home
set APPDATA=%APPS_ROOT%\AppData\Roaming
set LOCALAPPDATA=%APPS_ROOT%\AppData\Local

REM PATH to /usr/bin
set PATH=%APPS_ROOT%\PortableApps\PortableGit\usr\bin;%PATH%

REM PATH to /mingw64/bin if gcc installed
if exist "%APPS_ROOT%\PortableApps\PortableGit\mingw64\bin\g++.exe" set PATH=%APPS_ROOT%\PortableApps\PortableGit\mingw64\bin;%PATH%

REM PATH to node
if exist "%APPS_ROOT%\PortableApps\CommonFiles\node\node.exe" set PATH=%APPS_ROOT%\PortableApps\CommonFiles\node;%PATH%

REM PATH to python venv 2.7
if exist "%HOME%\.venv\2.7.17\Scripts" set PATH=%HOME%\.venv\2.7.17;%HOME%\.venv\2.7.17\Scripts;%PATH%

REM PATH to java
if not exist "%APPS_ROOT%\PortableApps\CommonFiles\java\bin\java.exe" goto :no_java
  set PATH=%APPS_ROOT%\PortableApps\CommonFiles\java\bin;%PATH%
  set JAVA_HOME=%APPS_ROOT%\PortableApps\CommonFiles\java
:no_java

REM PATH to python 3.8
:: using () make the variable not being updated in the parent batch, so lets us a goto
::if exist "%APPS_ROOT%\PortableApps\CommonFiles\python\python.exe" (
::  set PYTHONUSERBASE=%APPS_ROOT%\PortableApps\CommonFiles\python
::  set PATH=!PYTHONUSERBASE!;!PYTHONUSERBASE!\Python38\Scripts;!PATH!
::)
if not exist "%APPS_ROOT%\PortableApps\CommonFiles\python\python.exe" goto :no_python_3_8
  set PYTHONUSERBASE=%APPS_ROOT%\PortableApps\CommonFiles\python
  set PATH=%PYTHONUSERBASE%;%PYTHONUSERBASE%\Scripts;%PYTHONUSERBASE%\Python38\Scripts;%PATH%
:no_python_3_8

REM PATH to python venv 3.8
if exist "%HOME%\.venv\3.8.2\Scripts" set PATH=%HOME%\.venv\3.8.2;%HOME%\.venv\3.8.2\Scripts;%PATH%

REM PATH to python venv 3 (/usr/bin/python)
if exist "%HOME%\.venv\3\bin" set PATH=%HOME%\.venv\3\bin;%PATH%

REM PATH to git
set PATH=%APPS_ROOT%\PortableApps\PortableGit\bin;%PATH%

REM PATH to gcloud, kubectl, gke-gcloud-auth-plugin, etc.
if exist "%APPS_ROOT%\PortableApps\CommonFiles\gcloud\bin\gcloud" set PATH=%APPS_ROOT%\PortableApps\CommonFiles\gcloud\bin;%PATH%
