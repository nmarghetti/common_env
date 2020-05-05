@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\XAMPP"
START /B xampp\xampp-control.exe
