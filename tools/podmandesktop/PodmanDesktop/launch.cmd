@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\PodmanDesktop"
START /B podman_desktop.exe
