@echo off

cd ..\..
set APPS_ROOT=%CD%

cd "%ProgramW6432%\VcXsrv" >nul 2>&1
cd "%ProgramFiles(x86)%\VcXsrv" >nul 2>&1
cd "%ProgramFiles%\VcXsrv" >nul 2>&1
xlaunch.exe -run "%APPS_ROOT%\PortableApps\VcXsrvLauncher\config.xlaunch"

exit
