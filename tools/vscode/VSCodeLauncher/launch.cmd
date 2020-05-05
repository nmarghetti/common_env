@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\CommonFiles\VSCode_data\extensions" --user-data-dir "..\CommonFiles\VSCode_data\user-data"
