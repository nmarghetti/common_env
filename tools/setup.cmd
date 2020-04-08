@echo off

set APPS_ROOT=%CD%
set HOME=%APPS_ROOT%\home
set COMMON_ENV_FULL_DEBUG=0
set APPS_EXE=PortableApps.exe
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

REM Install PortableApps
if not exist PortableApps (
	if exist %APPS_EXE% (
	  %APPS_EXE%
	) else (

    ::curl --progress-bar -kLo %APPS_EXE% "https://portableapps.com/downloading/?a=PortableApps.comPlatform&s=s&d=pa&n=The%20PortableApps.com%20Platform&f=PortableApps.com_Platform_Setup_16.1.1.paf.exe"
	  "%DOWNLOAD%" %APPS_EXE% "https://download3.portableapps.com/portableapps/PortableApps.comPlatform/PortableApps.com_Platform_Setup_16.1.1.paf.exe?20190321"
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
cd PortableApps
if not exist PortableGit (
  if not exist %APP_GIT_EXE% (
    if exist ..\%APP_GIT_EXE% (
      move ..\%APP_GIT_EXE% %APP_GIT_EXE%
    )
  )
  if exist %APP_GIT_EXE% (
    %APP_GIT_EXE%
    move %APP_GIT_EXE% ..\%APP_GIT_EXE%
  ) else (
    echo "%DOWNLOAD%"
    "%DOWNLOAD%" %APP_GIT_EXE% "https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/PortableGit-2.26.0-64-bit.7z.exe"
    if errorlevel 1 (
      echo "Error while trying to download Git for Windows... Try to manually download the 64-bit Git for Windows PORTABLE and save as %APP_GIT_EXE% from https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/PortableGit-2.26.0-64-bit.7z.exe or https://git-scm.com/download/win"
      DEL %APP_GIT_EXE%
      pause
      exit 1
    ) else (
      %APP_GIT_EXE%
      if errorlevel 1 (
        echo "Error while installing Git for Windows... Try to manually download the 64-bit Git for Windows PORTABLE and save as %APP_GIT_EXE% from https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/PortableGit-2.26.0-64-bit.7z.exe or https://git-scm.com/download/win"
        DEL %APP_GIT_EXE%
        pause
        exit 1
      )
    )
    move %APP_GIT_EXE% ..\%APP_GIT_EXE%
  )
)
if not exist PortableGit (
  echo "Error, Unable to install Git for Windows"
  pause
  exit 1
)

REM Create HOME
cd "%APPS_ROOT%"
if not exist "%HOME%" (
  mkdir "%HOME%"
)

REM Clone common_env
if not exist "%APPS_ROOT%\Documents\dev" (
  mkdir "%APPS_ROOT%\Documents\dev"
)
if not exist "%APPS_ROOT%\Documents\dev\common_env" (
  "%APPS_ROOT%\PortableApps\PortableGit\bin\git.exe" clone https://github.com/nmarghetti/common_env.git "%APPS_ROOT%\Documents\dev\common_env"
)

REM Setup
echo "---------------- Start setup with bash ------------------"
"%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%APPS_ROOT%\Documents\dev\common_env\scripts\setup.sh"

echo
echo "Installation completed"
echo "You can now execute Start.exe"
echo "From there you can run 'Git bash termninal' and check for more custom app to install with the command setup_common_env (add -h for to see the usage)"
echo "You can also install many application from PortableApps: Apps -> Get More Apps... -> By Category"
echo "Enjoy ;)"
pause