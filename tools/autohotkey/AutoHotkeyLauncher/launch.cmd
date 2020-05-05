@echo off
call ..\CommonFiles\common_path.cmd

cd "%APPS_ROOT%"
START /B PortableApps\AutoHotkey\AutoHotkeyU64.exe Documents\dev\common_env\tools\autohotkey\hotkey.ahk
