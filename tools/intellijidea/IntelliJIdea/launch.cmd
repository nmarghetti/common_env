@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\IntelliJIdea"
START /B bin\idea64.exe
