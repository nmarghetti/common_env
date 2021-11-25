@echo off

REM https://www.tutorialspoint.com/batch_script/index.htm
REM http://www.trytoprogram.com/batch-file/

set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home
set APPDATA=%APPS_ROOT%\AppData\Roaming
set LOCALAPPDATA=%APPS_ROOT%\AppData\Local
set COMMON_ENV_FULL_DEBUG=0
set COMMON_ENV_BRANCH=master
if "%COMMON_ENV_INSTALL_DEVELOP%" == "1" (
  set COMMON_ENV_BRANCH=develop
)
if "%COMMON_ENV_INSTALL_APPS_ROOT%" == "" (
  set SETUP_PATH=%APPS_ROOT%
) else (
  set SETUP_PATH=%COMMON_ENV_INSTALL_APPS_ROOT%
)
if "%COMMON_ENV_INSTALL_SETUP_INI%" == "" (
  set SETUP_INI=setup.ini
) else (
  set SETUP_INI=%COMMON_ENV_INSTALL_SETUP_INI%
)
set APPS_LINK=https://download3.portableapps.com/portableapps/PortableApps.comPlatform/PortableApps.com_Platform_Setup_18.0.1.paf.exe?20190321
set APPS_EXE=PortableApps.exe
set APP_GIT_LINK=https://github.com/git-for-windows/git/releases/download/v2.32.0.windows.1/PortableGit-2.32.0-64-bit.7z.exe
set APP_GIT_EXE=PortableGit.exe


REM Check we have wget or curl in case exe are not there
set CHECK_FOR_DOWNLOAD=1
if exist PortableApps (
  if exist PortableApps\PortableGit (
    set CHECK_FOR_DOWNLOAD=0
  ) else (
    if exist %APP_GIT_EXE% (
      set CHECK_FOR_DOWNLOAD=0
    )
  )
) else (
  if exist %APPS_EXE% (
    if exist %APP_GIT_EXE% (
      set CHECK_FOR_DOWNLOAD=0
    )
  )
)
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
      echo "Unable to find wget or curl, please download https://eternallybored.org/misc/wget/1.20.3/64/wget.exe and save it along setup.cmd"
      pause
      exit 1
    )
  )
)

REM Try to download setup.ini if not present
if not exist "%SETUP_INI%" (
  set download_setup_ini=false
  if "%SETUP_INI%" == "setup.ini" set download_setup_ini=true
  if "%SETUP_INI%" == "setup_test.ini" set download_setup_ini=true
  if "%download_setup_ini%" == "true" (
    "%DOWNLOAD%" "%SETUP_INI%" "https://raw.githubusercontent.com/nmarghetti/common_env/%COMMON_ENV_BRANCH%/tools/%SETUP_INI%"
  )
)

REM Install PortableApps
if not exist PortableApps (
  if exist PortableApps.zip (
    tar -xf PortableApps.zip 2> nul
    if errorlevel 1 (
      7z.exe x PortableApps.zip 2> nul
    )
    if errorlevel 1 (
      "%ProgramFiles%\7-Zip\7z.exe" x PortableApps.zip 2> nul
    )
    if errorlevel 1 (
      powershell -command "Expand-Archive -Force '%~dp0PortableApps.zip' '%~dp0'" 2> nul
    )
  )
)

REM Install PortableApps
if not exist PortableApps (
	if exist %APPS_EXE% (
    echo Installing PortableApps...
    echo During the installation please follow those steps:
    echo     * Leave the selected language, you can change it later
    echo     * Select 'Select a custom location...' and leave the selected one
    echo     * At the end untick 'Run PortableApps.com Platform'
	  %APPS_EXE%
	) else (

    echo Downloading PortableApps...
    echo During the installation please follow those steps:
    echo     * Leave the selected language, you can change it later
    echo     * Select 'Select a custom location...' and leave the selected one
    echo     * At the end untick 'Run PortableApps.com Platform'
    "%DOWNLOAD%" %APPS_EXE% "%APPS_LINK%"
    if errorlevel 1 (
      echo "Error while trying to download PortableApps... Try to manually download and save as %APPS_EXE% from https://portableapps.com/download"
      DEL %APPS_EXE%
      pause
      exit 1
    ) else (
      %APPS_EXE%
      if errorlevel 1 (
        echo "Error while installing PortableApps... Try to manually download and save as %APPS_EXE% from https://portableapps.com/download"
        DEL %APPS_EXE%
        pause
        exit 1
      )
    )
	)
)

if not exist PortableApps (
  echo "PortableApps not installed, exiting"
  pause
  exit 1
)

REM Install Git for Windows
if not exist PortableApps\PortableGit (
  if exist %APP_GIT_EXE% (
    echo Installing Git for Windows...
    %APP_GIT_EXE% -o PortableApps\PortableGit -y
  ) else (
    echo Downloading Git for Windows...
    "%DOWNLOAD%" %APP_GIT_EXE% "%APP_GIT_LINK%"
    if errorlevel 1 (
      echo "Error while trying to download Git for Windows... Try to manually download the 64-bit Git for Windows PORTABLE and save as %APP_GIT_EXE% from %APP_GIT_LINK% or https://git-scm.com/download/win"
      DEL %APP_GIT_EXE%
      pause
      exit 1
    ) else (
      echo Installing Git for Windows...
      %APP_GIT_EXE% -o PortableApps\PortableGit -y
      if errorlevel 1 (
        echo "Error while installing Git for Windows... Try to manually download the 64-bit Git for Windows PORTABLE and save as %APP_GIT_EXE% from %APP_GIT_LINK% or https://git-scm.com/download/win"
        DEL %APP_GIT_EXE%
        pause
        exit 1
      )
    )
  )
)
if not exist PortableApps\PortableGit (
  echo "Error, Unable to install Git for Windows"
  pause
  exit 1
)

REM Create HOME
cd "%APPS_ROOT%"
if not exist "%HOME%" (
  mkdir "%HOME%"
)

REM Create APPDATA
cd "%APPS_ROOT%"
if not exist "%APPDATA%" (
  mkdir "%APPDATA%"
)

REM Create LOCALAPPDATA
cd "%APPS_ROOT%"
if not exist "%LOCALAPPDATA%" (
  mkdir "%LOCALAPPDATA%"
)

REM Copy setup.ini if present
cd "%APPS_ROOT%"
if exist "%SETUP_INI%" (
  copy "%SETUP_INI%" "%HOME%\.common_env.ini"
)

REM Clone common_env
if not exist "%APPS_ROOT%\Documents\dev" (
  mkdir "%APPS_ROOT%\Documents\dev"
)
if not exist "%APPS_ROOT%\Documents\dev\common_env" (
  "%APPS_ROOT%\PortableApps\PortableGit\bin\git.exe" clone -b %COMMON_ENV_BRANCH% https://github.com/nmarghetti/common_env.git "%APPS_ROOT%\Documents\dev\common_env"
  if errorlevel 1 (
    echo "An error occured durring installation, please retry..."
    pause
    exit 1
  )
)
REM Ensure to have the repo on the right branch and up to date
cd "%APPS_ROOT%\Documents\dev\common_env"
"%APPS_ROOT%\PortableApps\PortableGit\bin\git.exe" checkout %COMMON_ENV_BRANCH%
"%APPS_ROOT%\PortableApps\PortableGit\bin\git.exe" checkout origin/%COMMON_ENV_BRANCH% --track 2>nul
for /f %%i in ('"%APPS_ROOT%\PortableApps\PortableGit\bin\git.exe" symbolic-ref --short HEAD') do set branch=%%i
if "%branch%" NEQ "%COMMON_ENV_BRANCH%" (
  echo "Unable to checkout branch %branch% (current branch is %COMMON_ENV_BRANCH%). Exiting..."
  pause
  exit 1
)
"%APPS_ROOT%\PortableApps\PortableGit\bin\git.exe" pull --rebase

REM Setup
cd "%APPS_ROOT%"
echo ---------------- Start setup with bash ------------------
REM First light install with pacman package manager
findstr /B /R /C:"[\t ]*app[\t ]*=[\t ]*pacman" %SETUP_INI% >nul 2>&1 && (
  if not exist "%APPS_ROOT%\PortableApps\PortableGit\usr\bin\pacman.exe" (
    echo First ensure to configure gitbash
    start "Configure gitbash" /W "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%SETUP_PATH%\Documents\dev\common_env\scripts\setup.sh" gitbash
    echo Install pacman package manager
    start "Install pacman package manager" /W "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%SETUP_PATH%\Documents\dev\common_env\scripts\setup.sh" -k pacman
    if not exist "%APPS_ROOT%\PortableApps\PortableGit\usr\bin\pacman.exe" (
      echo Pacman package installer not installed. Exiting...
      pause
      exit 1
    )
    start "Install pacman packages" /W "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%SETUP_PATH%\Documents\dev\common_env\scripts\setup.sh" -k pacman
  )
)
if not "%COMMON_ENV_INSTALL_ONLY_EXTRA_APP%" == "" (
  "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%SETUP_PATH%\Documents\dev\common_env\scripts\setup.sh" -e %COMMON_ENV_INSTALL_ONLY_EXTRA_APP%
) else (
  if not "%COMMON_ENV_INSTALL_ONLY_APP%" == "" (
    "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%SETUP_PATH%\Documents\dev\common_env\scripts\setup.sh" -k %COMMON_ENV_INSTALL_ONLY_APP%
  ) else (
    "%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%SETUP_PATH%\Documents\dev\common_env\scripts\setup.sh"
  )
)

if "%errorlevel%" == "0" (
  echo Installation completed
  echo You can now execute Start.exe
  echo From there you can :
  echo     * launch 'Git bash'
  echo     * run setup_common_env -h
  echo     * check the usage to get more custom application
  echo You can also install many application from PortableApps:
  echo     * Apps -^> Get More Apps... -^> By Category
  echo Enjoy ;^)
) else (
  echo There seems to have a problem with the installation
)

pause
