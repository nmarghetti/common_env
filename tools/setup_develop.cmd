@echo off

REM Change this to point to your local path
set COMMON_ENV_INSTALL_APPS_ROOT=.
REM Change this to point to your custom setup ini files (eg. setup_test.ini)
set COMMON_ENV_INSTALL_SETUP_INI=setup.ini
REM Set the only few app to run, (eg. git shell), or leave empty for all
set COMMON_ENV_INSTALL_ONLY_APP=

set CHECK_FOR_DOWNLOAD=1
if exist wget.exe (
  set DOWNLOAD="%CD%\wget.exe --progress=bar:force -O"
  set CHECK_FOR_DOWNLOAD=0
)
if %CHECK_FOR_DOWNLOAD%==1 (
  wget -h > nul 2>&1
  if not errorlevel 1 (
    set DOWNLOAD="wget --progress=bar:force -O"
  ) else (
    curl -h > nul 2>&1
    if not errorlevel 1 (
      set DOWNLOAD="curl --progress-bar -kLo"
    ) else (
      echo "Unable to find wget or curl, please download https://eternallybored.org/misc/wget/1.20.3/64/wget.exe and save it along setup_develop.cmd"
      pause
      exit 1
    )
  )
)

set COMMON_ENV_INSTALL_DEVELOP=1
if "%COMMON_ENV_INSTALL_APPS_ROOT%" EQU "." (
  REM Download setup.cmd from develop branch
  "%DOWNLOAD%" setup.cmd "https://raw.githubusercontent.com/nmarghetti/common_env/develop/tools/setup.cmd"
  if errorlevel 1 (
    echo "Error: unable to download setup.cmd from develop branch"
    pause
    exit 1
  )
  setup.cmd
) else (
  if not exist %COMMON_ENV_INSTALL_SETUP_INI% (
    copy "%COMMON_ENV_INSTALL_APPS_ROOT%\Documents\dev\common_env\tools\setup.ini" %COMMON_ENV_INSTALL_SETUP_INI%
  )
  "%COMMON_ENV_INSTALL_APPS_ROOT%\Documents\dev\common_env\tools\setup.cmd"
)
