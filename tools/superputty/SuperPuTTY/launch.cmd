@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\SuperPutty"
START /B SuperPutty.exe
