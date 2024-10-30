@echo off

call ..\CommonFiles\common_path.cmd

if exist %WINDOWS_USERPROFILE%\AppData\Roaming\Insomnia (
  if not exist %USERPROFILE%\AppData\Roaming\Insomnia (
    mkdir %USERPROFILE%\AppData\Roaming\Insomnia
    copy %WINDOWS_USERPROFILE%\AppData\Roaming\Insomnia %USERPROFILE%\AppData\Roaming\Insomnia
  )
)

cd "%APPS_ROOT%\PortableApps\Insomnia"
START /B Insomnia.exe

