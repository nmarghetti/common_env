@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\PuTTY"
START /B PUTTYGEN.EXE
