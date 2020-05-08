@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\VSCodeLauncher\data\extensions" --user-data-dir "..\VSCodeLauncher\data\user-data"
