@echo off

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

REM Download setup.cmd from develop branch
"%DOWNLOAD%" setup.cmd "https://raw.githubusercontent.com/nmarghetti/common_env/develop/tools/setup.cmd"
if errorlevel 1 (
  echo "Error: unable to download setup.cmd from develop branch"
  pause
  exit 1
)

REM Delete common_env repository
if exist Documents\dev\common_env (
  del /q /s Documents\dev\common_env
)

set COMMON_ENV_INSTALL_DEVELOP=1
setup.cmd
