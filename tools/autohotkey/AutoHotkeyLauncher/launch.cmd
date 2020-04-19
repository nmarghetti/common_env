@echo off
setlocal EnableDelayedExpansion

cd ..\..
set APPS_ROOT=%CD%

START /B PortableApps\AutoHotkey\AutoHotkeyU64.exe Documents\dev\common_env\tools\autohotkey\hotkey.ahk
