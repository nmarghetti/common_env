@echo off

call :xserver

echo Check if running as admin >&2
powershell -Command "if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { [Environment]::Exit(1) } else { [Environment]::Exit(0) }"
if errorlevel 1 (
  goto :user
) else (
  goto :admin
)

@REM RUNNING AS ROOT
:admin
  echo Running as admin >&2
  @REM Need to retrieve default WSL user
  set appPath=${appsRoot}\PortableApps\${ubuntuVersion}
  set userHome=${appsRoot}\home
  set wslUser=${wslUser}
  call :mount-user-home
  if not "%1%" == "exit" (
    wsl.exe --cd ~ -d ${distribution} -u root
  )
  goto :eof

@REM RUNNING AS USER
:user
  echo Running as user >&2
  set appPath=%cd%
  cd ../../home
  set userHome=%cd%
  set wslUser=%USERNAME%
  call :mount-user-home
  if not "%1%" == "exit" (
    wsl.exe --cd ~ -d ${distribution}
  )
  goto :eof

@REM Check if the WSL distribution is running
:check-wsl-running
  wsl.exe --list --running --quiet > %TEMP%\wsl_list.txt
  powershell -Command "if (Select-String -Quiet -Path '%TEMP%\wsl_list.txt' -Pattern '^${distribution}$' -Encoding Unicode) { [Environment]::Exit(0) } else { [Environment]::Exit(1) }"
  if %errorlevel% equ 0 (
    del %TEMP%\wsl_list.txt
    echo WSL ${distribution} is running
    exit /b 0
  )
  del %TEMP%\wsl_list.txt
  exit /b 1

@REM Try to start the WSL distribution
:start-wsl
  echo WSL ${distribution} is not running, starting it...
  wsl.exe --cd ~ -d ${distribution} -u root uname -a >nul 2>&1 || (
    echo Unable to start WSL, please retry later.
    pause
    exit 1
  )
  exit /b 0

@REM Ensure WSL is running or leave
:ensure-wsl-running
  cd %ProgramFiles%\WSL >nul 2>&1
  cd %ProgramW6432%\WSL >nul 2>&1
  wsl.exe --version >nul 2>&1 || (
    echo Unable to find WSL, exiting...
    pause
    exit 1
  )
  call :check-wsl-running
  if errorlevel 1 (
    call :start-wsl
    call :check-wsl-running
    if errorlevel 1 (
      call :start-wsl
      if errorlevel 1 (
        echo Failed to start WSL ${distribution} after retry, please try again later.
        pause
        exit 1
      )
    )
  )
  exit /b 0


@REM MOUNT USER HOME
:mount-user-home
  call :ensure-wsl-running
  set terminateWsl=0
  wsl.exe -u root -d ${distribution} bash -c "lsblk | grep -q ${wslUserHomeSize}G"
  if errorlevel 1 (
    echo %userHome%\wsl.vhdx needs to be mounted to ${distribution}
    powershell.exe %appPath%\App\setup.ps1 -InstallName ${distribution} -InstallUserHome %userHome%\wsl.vhdx
    set terminateWsl=1
  )

  wsl.exe -u root -d ${distribution} bash -c "lsblk | grep /home/%wslUser% | grep -q ${wslUserHomeSize}G"
  if errorlevel 1 (
    echo /home/%wslUser% needs to be mounted
    set WSL_USER=%wslUser%
    set WSL_USER_HOME_SIZE=${wslUserHomeSize}
    set WSLENV=WSL_USER:WSL_USER_HOME_SIZE:/p
    wsl.exe -u root -d ${distribution} <"%appPath%\App\setup.sh"
    set terminateWsl=1

    wsl.exe -u root -d ${distribution} bash -c "lsblk | grep /home/%wslUser% | grep -q ${wslUserHomeSize}G"
    if errorlevel 1 (
      echo Unable to mount user home /home/%wslUser% from %userHome%\wsl.vhdx
      pause
      exit 1
    )
  )
  @REM Restart it if needed
  if %terminateWsl% EQU 1 (
    call :terminate
    call :start-wsl
    call :ensure-wsl-running
  )
  goto :eof

@REM TERMINATE DISTRIBUTION
:terminate
  @REM Terminate WSL to reload the environment and avoid fstab warnings
  echo Restart ${distribution}
  wsl.exe --terminate ${distribution} >nul
  goto :eof

@REM ENSURE TO HAVE VcXsrv X SERVER RUNNING IF INSTALLED
:xserver
  if exist ${appsRoot}\PortableApps\VcXsrvLauncher\launch.cmd (
    tasklist /FI "IMAGENAME eq vcxsrv.exe" | findstr /B /R /C:"vcxsrv.exe" >nul 2>&1 || (
      start /MIN ${appsRoot}\PortableApps\VcXsrvLauncher\launch.cmd
    )
  )
  goto :eof
