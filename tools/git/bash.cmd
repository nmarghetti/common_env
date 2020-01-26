@echo off
REM This would launch git-bash in a terminal, simulating a linux environment with some custom configuration

: Go up few folder to set PortableApps root
cd ..
set PORTABLEAPPS_ROOT=%CD%
set PORTABLEAPPS_GIT=%PORTABLEAPPS_ROOT%\PortableApps\PortableGit

: Set HOME to source sh profile when launching git-bash on the project
set HOME=%PORTABLEAPPS_ROOT%\home

: Set project where to go
set PRJ_ROOT=%PORTABLEAPPS_ROOT%\Documents\dev
cd "%PRJ_ROOT%"

if "%1" == "git" (
  : Either run git-bash.exe
  echo "Starting git-bash, the terminal is not always well handled by some commands."
  echo "At least you can configure the mouse copy/paste."
  echo "When it will be started, check the following:"
  echo "    right click on title bar -> Option... -> Mouse"
  START /B "%PORTABLEAPPS_GIT%\git-bash.exe" --cd="%PRJ_ROOT%"
) else  if "%1" == "mintty" (
    : Either directly run mintty.exe
    echo "Starting git-bash, the terminal is not always well handled by some commands."
    echo "At least you can configure the mouse copy/paste."
    echo "When it will be started, check the following:"
    echo "    right click on title bar -> Option... -> Mouse"
    "%PORTABLEAPPS_GIT%\usr\bin\mintty.exe" --icon "%PORTABLEAPPS_GIT%\git-bash.exe,0" --exec "/usr/bin/bash" --login -i
) else (
  : Either run bash.exe
  echo "Starting bash, no configurable mouse copy/paste"
  "%PORTABLEAPPS_GIT%\bin\bash.exe" --init-file "%HOME%\.bashrc"
)

