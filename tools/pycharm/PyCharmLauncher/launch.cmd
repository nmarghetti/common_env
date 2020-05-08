@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\PyCharm"
START /B bin\pycharm64.exe
