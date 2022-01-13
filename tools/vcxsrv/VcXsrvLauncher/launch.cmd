@echo off

cd ..\..
set APPS_ROOT=%CD%

cd "%ProgramW6432%\VcXsrv"
cd "%ProgramFiles(x86)%\VcXsrv"
cd "%ProgramFiles%\VcXsrv"
xlaunch.exe -run "%APPS_ROOT%\PortableApps\VcXsrvLauncher\config.xlaunch"
