@echo off

call ..\CommonFiles\common_path.cmd

cd %ProgramFiles%\WSL >nul 2>&1
cd %ProgramW6432%\WSL >nul 2>&1
wsl --list --running --quiet > %TEMP%\wsl_list.txt
powershell -Command "if (Select-String -Quiet -Path '%TEMP%\wsl_list.txt' -Pattern '^${distribution}$' -Encoding Unicode) { [Environment]::Exit(0) } else { [Environment]::Exit(1) }"
if %errorlevel% equ 0 (
  rm %TEMP%\wsl_list.txt
  echo ${distribution} is running
  goto start-vscode
)
rm %TEMP%\wsl_list.txt

:start-wsl
echo WSL ${distribution} is not running, starting it...
cd "%APPS_ROOT%\PortableApps\${ubuntuVersion}"
call launch.cmd exit

:start-vscode
cd "%APPS_ROOT%\PortableApps\VSCode"
START /B Code.exe --extensions-dir "..\VSCodeLauncher\data\extensions" --user-data-dir "..\VSCodeLauncher\data\user-data" --remote wsl+${distribution}
