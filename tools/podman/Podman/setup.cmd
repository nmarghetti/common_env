@echo off

call ..\CommonFiles\common_variable.cmd
"%APPS_ROOT%\PortableApps\PortableGit\bin\bash.exe" --init-file "%HOME%\.bashrc" %APPS_ROOT%\PortableApps\Podman\setup.sh

exit 0
