@echo off

call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%\PortableApps\${ubuntuVersion}"
call launch.cmd exit
if errorlevel 1 (
  echo Failed to start WSL ${distribution}, please try again later.
  pause
  exit 1
)

echo Starting VSCode in WSL ${distribution}...
cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\VSCodeLauncher\data\extensions" --user-data-dir "..\VSCodeLauncher\data\user-data" --remote wsl+${distribution}
