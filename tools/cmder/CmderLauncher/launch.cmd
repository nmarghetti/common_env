@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\cmder"
START /B Cmder.exe /start "%HOME%"
