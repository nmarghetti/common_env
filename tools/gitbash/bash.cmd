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
    CALL :MinttyInfo
  START /B "%PORTABLEAPPS_GIT%\git-bash.exe" --cd="%PRJ_ROOT%"
  goto Done
) else if "%1" == "mintty" (
    : Either directly run mintty.exe
    CALL :MinttyInfo
    "%PORTABLEAPPS_GIT%\usr\bin\mintty.exe" --icon "%PORTABLEAPPS_GIT%\git-bash.exe,0" --exec "/usr/bin/bash" --login -i
    goto Done
) else if "%1" == "tmux" (
  if exist "%PORTABLEAPPS_GIT%\usr\bin\tmux.exe" (
    : Either tmux through mintty.exe
    CALL :MinttyInfo
    "%PORTABLEAPPS_GIT%\usr\bin\mintty.exe" --icon "%PORTABLEAPPS_GIT%\git-bash.exe,0" --exec "/usr/bin/bash" --login -i -c tmux
    goto Done
  )
  echo tmux is not installed
) else if "%1" == "zsh" (
  if exist "%PORTABLEAPPS_GIT%\usr\bin\zsh.exe" (
    : Either run zsh through bash.exe
    echo Starting zsh through cmd ^(no configurable mouse copy/paste^)
    "%PORTABLEAPPS_GIT%\bin\bash.exe" --init-file "%HOME%\.bashrc" -c 'exec zsh'
    goto Done
  )
  echo zsh is not installed
) else if "%1" == "zshtty" (
  if exist "%PORTABLEAPPS_GIT%\usr\bin\zsh.exe" (
    : Either zsh through mintty.exe
    CALL :MinttyInfo
    "%PORTABLEAPPS_GIT%\usr\bin\mintty.exe" --icon "%PORTABLEAPPS_GIT%\git-bash.exe,0" --exec "/usr/bin/zsh" --login -i
    goto Done
  )
  echo zsh is not installed
) else if "%1" == "tmuxzsh" (
  if exist "%PORTABLEAPPS_GIT%\usr\bin\zsh.exe" (
      if exist "%PORTABLEAPPS_GIT%\usr\bin\tmux.exe" (
      : Either zsh through mintty.exe
      CALL :MinttyInfo
      "%PORTABLEAPPS_GIT%\usr\bin\mintty.exe" --icon "%PORTABLEAPPS_GIT%\git-bash.exe,0" --exec "/usr/bin/zsh" --login -i -c tmux
      goto Done
    )
    echo tmux is not installed
  ) else (
    echo zsh is not installed
  )
)

: Either by default run bash.exe
echo Starting bash through cmd ^(no configurable mouse copy/paste^)
"%PORTABLEAPPS_GIT%\bin\bash.exe" --init-file "%HOME%\.bashrc"

:Done
EXIT /B %ERRORLEVEL%

:MinttyInfo
  echo Starting mintty, the terminal is not always well handled by some commands.
  echo At least you can configure the mouse copy/paste.
  echo When it will be started, check the following:
  echo     right click on title bar -^> Option... -^> Mouse
EXIT /B 0
