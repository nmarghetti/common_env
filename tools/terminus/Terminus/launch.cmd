@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\Terminus"
START /B Terminus.exe
