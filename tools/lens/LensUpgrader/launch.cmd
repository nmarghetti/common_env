@echo off

call ..\CommonFiles\common_path.cmd

"%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" "%APPS_ROOT%\Documents\dev\common_env\scripts\setup.sh" -u lens

pause
