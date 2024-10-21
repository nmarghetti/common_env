@echo off

call :xserver

powershell -Command "if (!(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { [Environment]::Exit(1) } else { [Environment]::Exit(0) }"
if errorlevel 1 (
  goto :user
) else (
  goto :admin
)

@REM RUNNING AS ROOT
:admin
set appPath=${appsRoot}\PortableApps\${ubuntuVersion}
set userHome=${appsRoot}\home
set wslUser=${wslUser}
call :mount-user-home
wsl.exe --cd ~ -d ${ubuntuVersion}-portable -u root
goto :eof

@REM RUNNING AS USER
:user
set appPath=%cd%
cd ../../home
set userHome=%cd%
set wslUser=%USERNAME%
call :mount-user-home
wsl.exe --cd ~ -d ${ubuntuVersion}-portable
goto :eof


@REM MOUNT USER HOME
:mount-user-home
cd %ProgramFiles%\WSL >nul 2>&1
cd %ProgramW6432%\WSL >nul 2>&1
wsl.exe -u root -d ${ubuntuVersion}-portable bash -c "lsblk | grep -q ${wslUserHomeSize}"
if errorlevel 1 (
  echo %userHome%\wsl.vhdx needs to be mounted to ${ubuntuVersion}-portable
  powershell.exe %appPath%\App\setup.ps1 -InstallName ${ubuntuVersion}-portable -InstallUserHome %userHome%\wsl.vhdx
  call :terminate
)

wsl.exe -u root -d ${ubuntuVersion}-portable bash -c "lsblk | grep -q /home/%wslUser%"
if errorlevel 1 (
  echo /home/%wslUser% needs to be mounted
  set WSL_USER=%wslUser%
  set WSL_USER_HOME_SIZE=${wslUserHomeSize}
  set WSLENV=WSL_USER:WSL_USER_HOME_SIZE:/p
  wsl.exe -u root -d ${ubuntuVersion}-portable <"%appPath%\App\setup.sh"
  call :terminate

  wsl.exe -u root -d ${ubuntuVersion}-portable bash -c "lsblk | grep -q /home/%wslUser%"
  if errorlevel 1 (
    echo Unable to mount user home /home/%wslUser% from %userHome%\wsl.vhdx
    pause
    exit 1
  )
)
goto :eof

@REM TERMINATE DISTRIBUTION
:terminate
@REM Terminate WSL to reload the environment and avoid fstab warnings
echo Restart ${ubuntuVersion}-portable
wsl.exe --terminate ${ubuntuVersion}-portable
goto :eof

@REM ENSURE TO HAVE VcXsrv X SERVER RUNNING IF INSTALLED
:xserver
if exist ${appsRoot}\PortableApps\VcXsrvLauncher\launch.cmd (
  tasklist /FI "IMAGENAME eq vcxsrv.exe" | findstr /B /R /C:"vcxsrv.exe" >nul 2>&1 || (
    start /MIN ${appsRoot}\PortableApps\VcXsrvLauncher\launch.cmd
  )
)
goto :eof
