@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\MobaXterm"
START /B MobaXterm_Personal_20.2.exe
